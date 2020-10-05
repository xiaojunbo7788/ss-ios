//
//  WXYZ_RechargeViewController.m
//  WXReader
//
//  Created by Andrew on 2018/7/4.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_RechargeViewController.h"
#import "WXYZ_RecordsViewController.h"

#import "WXYZ_RechargeTableViewCell.h"
#import "WXYZ_MemberPayTypeTableViewCell.h"
#import "WXYZ_MemberAboutTableViewCell.h"
#import "WXYZ_RechargeHeaderView.h"
#import "WXYZ_UserInfoManager.h"
#import "WXYZ_RechargeModel.h"
#import "WXYZ_PayTableViewCell.h"
#import "WXYZ_WebViewViewController.h"
#import "WXYZ_BannerActionManager.h"
#import "WXYZ_MonthlyModel.h"
#if !WX_Third_Pay
    #import "IAPManager.h"
#endif

@interface WXYZ_RechargeViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate
#if !WX_Third_Pay
, IApRequestResultsDelegate
#endif
>
{
    NSInteger goodsSelectIndex; // 商品选择位置
#if WX_Third_Pay
    NSInteger payStyleIndex;    // 支付方式选择位置
#endif
    
    UILabel *priceLabel;
    UIButton *confirmButton;
}

@property (nonatomic, strong) WXYZ_RechargeModel *rechargeModel;

@property (nonatomic, strong) WXYZ_RechargeHeaderView *headerView;

@end

@implementation WXYZ_RechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
    [self netRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarLightContentStyle];
    [kNotification postNotificationName:Notification_Hidden_Tabbar object:@"1"];
}

- (void)initialize
{
    if (self.pushFromReader) {
        id target = self.navigationController.interactivePopGestureRecognizer.delegate;
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:target action:NSSelectorFromString(@"handleNavigationTransition:")];
        panGesture.delegate = self; // 设置手势代理，拦截手势触发
        [self.view addGestureRecognizer:panGesture];
        
        // 一定要禁止系统自带的滑动手势
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netRequest) name:Notification_Recharge_Success object:nil];
    
    [self setNavigationBarTitle:[NSString stringWithFormat:@"%@充值", WXYZ_SystemInfoManager.masterUnit]];
    self.navigationBar.backgroundColor = kColorRGB(46, 46, 48);
    self.navigationBar.navTitleLabel.textColor = kWhiteColor;
    [self.navigationBar setLightLeftButton];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(SCREEN_WIDTH - 64.0f - kHalfMargin, PUB_NAVBAR_HEIGHT - 2 - 40.0f, 64.0f, 40.0f);
    [rightButton setTitle:@"充值记录" forState:UIControlStateNormal];
    [rightButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:kFont12];
    [rightButton addTarget:self action:@selector(rechargeRecordClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:rightButton];
    
    goodsSelectIndex = 0;
#if WX_Third_Pay
    payStyleIndex = 0;
#else
    [IAPManager sharedManager].delegate = self;
#endif
    self.view.backgroundColor = kGrayViewColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netRequest) name:Notification_Login_Success object:nil];
}

- (void)createSubviews
{
    self.mainTableViewGroup.delegate = self;
    self.mainTableViewGroup.dataSource = self;
    [self.mainTableViewGroup registerClass:[WXYZ_PayTableViewCell class] forCellReuseIdentifier:@"WXYZ_PayTableViewCell"];
    [self.view addSubview:self.mainTableViewGroup];
    
    [self.mainTableViewGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT - PUB_TABBAR_HEIGHT);
    }];
    
    
    self.headerView = [[WXYZ_RechargeHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, PUB_NAVBAR_HEIGHT + 60 + 2 * kMargin)];
    [self.mainTableViewGroup setTableHeaderView:self.headerView];
    WS(weakSelf)
    self.headerView.bannerrImageClickBlock = ^(WXYZ_BannerModel *bannerModel) {
        if ([WXYZ_BannerActionManager getBannerActionWithBannerModel:bannerModel productionType:weakSelf.productionType]) {
            [weakSelf.navigationController pushViewController:[WXYZ_BannerActionManager getBannerActionWithBannerModel:bannerModel productionType:weakSelf.productionType] animated:YES];
        }
    };
    
    UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - PUB_TABBAR_HEIGHT, SCREEN_WIDTH, PUB_TABBAR_HEIGHT)];
    toolBar.backgroundColor = kWhiteColor;
    toolBar.layer.shadowColor = [UIColor blackColor].CGColor;
    toolBar.layer.shadowOffset = CGSizeMake(0, 0);
    toolBar.layer.shadowOpacity = 0.1f;
    toolBar.layer.shadowRadius = 1.0f;
    [self.view addSubview:toolBar];
    
    confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.adjustsImageWhenHighlighted = NO;
    [confirmButton setBackgroundImage:[UIImage imageNamed:@"member_pay_btn"] forState:UIControlStateNormal];
    [confirmButton setTitle:@"立即充值" forState:UIControlStateNormal];
    [confirmButton setTitleColor:kColorRGBA(122, 70, 0, 1) forState:UIControlStateNormal];
    [confirmButton.titleLabel setFont:[UIFont boldSystemFontOfSize:kFontSize14]];
    [confirmButton addTarget:self action:@selector(confirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:confirmButton];
    
    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(toolBar.mas_right);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT - PUB_TABBAR_OFFSET);
    }];
    
    priceLabel = [[UILabel alloc] init];
    priceLabel.font = kMainFont;
    priceLabel.textColor = kBlackColor;
    [toolBar addSubview:priceLabel];
    
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(confirmButton.mas_left);
        make.height.mas_equalTo(confirmButton.mas_height);
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.rechargeModel.list.count;
    }
    
    if (section == 1) {
        if (self.rechargeModel.thirdOn) {
            return [[self.rechargeModel.list objectOrNilAtIndex:goodsSelectIndex] pal_channel]?[[self.rechargeModel.list objectOrNilAtIndex:goodsSelectIndex] pal_channel].count:0;
        } else {
            return 0;
        }
    }
    
    if (section == 2 && (self.rechargeModel.about.count <= 0 || !self.rechargeModel.about)) {
        return 0;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            WXYZ_RechargeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_RechargeTableViewCell"];
            if (!cell) {
                cell = [[WXYZ_RechargeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_RechargeTableViewCell"];
            }
            cell.goodsModel = [self.rechargeModel.list objectAtIndex:indexPath.row];
            cell.cellSelected = (goodsSelectIndex == indexPath.row);
            cell.selectionStyle = UITableViewCellAccessoryNone;
            return cell;
        }
            break;
        case 1:
        {
            WXYZ_MemberPayTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_MemberPayTypeTableViewCell"];
            if (!cell) {
                cell = [[WXYZ_MemberPayTypeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_MemberPayTypeTableViewCell"];
            }
#if WX_Third_Pay
            cell.payModel = [[[self.rechargeModel.list objectOrNilAtIndex:goodsSelectIndex] pal_channel] objectOrNilAtIndex:indexPath.row];
            cell.paySelected = (indexPath.row == payStyleIndex);
#endif
            cell.selectionStyle = UITableViewCellAccessoryNone;
            return cell;
        }
            break;
        case 2:
        {
            WXYZ_MemberAboutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_MemberAboutTableViewCell"];
            
            if (!cell) {
                cell = [[WXYZ_MemberAboutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_MemberAboutTableViewCell"];
            }
            cell.about = self.rechargeModel.about;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
        default:
            break;
    }
    
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        goodsSelectIndex = indexPath.row;
        [self.mainTableViewGroup reloadData];
    }
    #if WX_Third_Pay
        if (indexPath.section == 1 && [[self.rechargeModel.list objectOrNilAtIndex:goodsSelectIndex] pal_channel].count > 0 && payStyleIndex != indexPath.row) {
            WXYZ_MemberPayTypeTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.paySelected = YES;
            payStyleIndex = indexPath.row;
            [self.mainTableViewGroup reloadData];
        }
    #endif
}

//section头间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1 && !self.rechargeModel.thirdOn) {
        return CGFLOAT_MIN;
    }
    
    if (section == 2 && (self.rechargeModel.about.count <= 0 || !self.rechargeModel.about)) {
        return CGFLOAT_MIN;
    }
    
    return 50;
}

//section头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!self.rechargeModel) {
        return [[UIView alloc] init];
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kHalfMargin, 0, SCREEN_WIDTH - kHalfMargin, 50)];
    if (section == 0) {
        headerTitleLabel.text = @"充值套餐";
    } else if (section == 1) {
        headerTitleLabel.text = @"支付方式";
    } else if (section == 2) {
        headerTitleLabel.text = @"充值说明";
    }
    
    headerTitleLabel.font = kBoldFont15;
    headerTitleLabel.textColor = kBlackColor;
    [view addSubview:headerTitleLabel];
    
    NSMutableAttributedString *priceString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"总计：%@", [self.rechargeModel.list objectAtIndex:goodsSelectIndex].fat_price?:@""]];
    [priceString addAttribute:NSFontAttributeName value:kBoldFont22 range:NSMakeRange(3, priceString.length - 3)];
    [priceString addAttribute:NSForegroundColorAttributeName value:kColorRGB(228, 185, 122) range:NSMakeRange(3, priceString.length - 3)];
    
    priceLabel.attributedText = priceString;
    
    return view;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1 && !self.rechargeModel.thirdOn) {
        return CGFLOAT_MIN;
    }
    
    if (section == 2 && (self.rechargeModel.about.count <= 0 || !self.rechargeModel.about)) {
        return CGFLOAT_MIN;
    }
    
    return kHalfMargin;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (!self.rechargeModel) {
        return [[UIView alloc] init];
    }
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = kGrayViewColor;
    return view;
}

#pragma mark IApRequestResultsDelegate

#if !WX_Third_Pay
- (void)requestSuccess
{
    self.mainTableViewGroup.userInteractionEnabled = YES;
}

- (void)filedWithErrorCode:(NSInteger)errorCode andError:(NSString *)error
{
    self.mainTableViewGroup.userInteractionEnabled = YES;
}

#endif

- (void)rechargeRecordClick
{
    WXYZ_RecordsViewController *vc = [[WXYZ_RecordsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)confirmButtonClick
{
    if (!WXYZ_UserInfoManager.isLogin) {
        [WXYZ_LoginViewController presentLoginView];
        return;
    }
    
    if (self.rechargeModel.list.count > 0) {
#if WX_Third_Pay
        WXYZ_GoodsModel *t_goodsModel = [self.rechargeModel.list objectOrNilAtIndex:goodsSelectIndex];
        WXYZ_PayModel *t_payModel = [t_goodsModel.pal_channel objectOrNilAtIndex:payStyleIndex];
        NSDictionary *dic = @{@"channel_id":@(t_payModel.channel_id),@"goods_id":@(t_goodsModel.goods_id),@"type":t_payModel.channel_code};
        [self gotoPay:dic];
//        params.putExtraParams("channel_id", palChannelBean.getChannel_id()+"");
//                           params.putExtraParams("goods_id", mGoosId);
//                           params.putExtraParams("type", palChannelBean.getChannel_code());
//        NSString *payURL = t_payModel.gateway;
//
//        if (payURL.length == 0) {
//            payURL = APIURL;
//        }
        
        
        
        
//        if ([t_payModel.gateway containsString:@"?"]) {
//            payURL = [payURL stringByAppendingString:[NSString stringWithFormat:@"&token=%@", [[WXYZ_UserInfoManager sharedManager] getUserInfoWithKey:USER_TOKEN]]];
//        } else {
//            payURL = [payURL stringByAppendingString:[NSString stringWithFormat:@"?token=%@", [[WXYZ_UserInfoManager sharedManager] getUserInfoWithKey:USER_TOKEN]]];
//        }
//        payURL = [payURL stringByAppendingString:[NSString stringWithFormat:@"&goods_id=%@", [WXYZ_UtilsHelper formatStringWithInteger:t_goodsModel.goods_id]]];
//        
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:payURL]];
#else
        WXYZ_GoodsModel *goodsModel = [self.rechargeModel.list objectOrNilAtIndex:goodsSelectIndex];
        self.mainTableViewGroup.userInteractionEnabled = NO;
        [IAPManager sharedManager].production_id = self.production_id;
        [IAPManager sharedManager].productionType = self.productionType;
        [[IAPManager sharedManager] requestProductWithId:[NSString stringWithFormat:@"%@", goodsModel.apple_id]];
#endif
    }
}

- (void)gotoPay:(NSDictionary *)p {
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:@"/pay/codepay" parameters:p model:nil success:^(BOOL isSuccess, NSDictionary *_Nullable dic, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            WXYZ_WebViewViewController *vc = [[WXYZ_WebViewViewController alloc] init];
            vc.form = dic[@"data"];
            vc.navTitle = @"支付";
            vc.isPresentState = NO;
            [[WXYZ_ViewHelper getCurrentNavigationController] pushViewController:vc animated:YES];
        }
    } failure:nil];
}

- (void)netRequest
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Pay_Center parameters:nil model:WXYZ_RechargeModel.class success:^(BOOL isSuccess, WXYZ_RechargeModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            weakSelf.rechargeModel = t_model;
            weakSelf.headerView.rechargeModel = t_model;
        }
        [weakSelf.mainTableViewGroup reloadData];
    } failure:nil];
    
    
    [WXYZ_NetworkRequestManger POST:Member_Monthly parameters:@{@"site_id":@"2"} model:WXYZ_MonthlyModel.class success:^(BOOL isSuccess, WXYZ_MonthlyModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
                   
              weakSelf.headerView.banner = t_model.banner;

              [weakSelf.mainTableViewGroup setTableHeaderView:weakSelf.headerView];

              [weakSelf.mainTableViewGroup endRefreshing];

              [weakSelf.mainTableViewGroup reloadData];

          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {


          }];
}

@end

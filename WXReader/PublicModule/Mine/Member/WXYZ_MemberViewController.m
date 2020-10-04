//
//  WXYZ_MemberViewController.m
//  WXReader
//
//  Created by Andrew on 2018/6/15.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_MemberViewController.h"
#import "WXYZ_WebViewViewController.h"

#import "WXYZ_MemeberModel.h"
#import "WXYZ_RechargeModel.h"

#import "WXYZ_MemberPayTableViewCell.h"
#import "WXYZ_MemberPayTypeTableViewCell.h"
#import "WXYZ_MemberPrivilegeTableViewCell.h"
#import "WXYZ_MemberAboutTableViewCell.h"
#import "WXYZ_BannerActionManager.h"
#import "WXYZ_MemberHeaderView.h"

#if !WX_Third_Pay
    #import "IAPManager.h"
#endif

@interface WXYZ_MemberViewController () <UITableViewDelegate, UITableViewDataSource
#if !WX_Third_Pay
, IApRequestResultsDelegate
#endif
>
{
    UILabel *priceLabel;
    UIButton *confirmButton;
    
    NSInteger goodsSelectIndex;
//#if WX_Third_Pay
    NSInteger payStyleIndex;
//#endif
}

@property (nonatomic, strong) WXYZ_MemberHeaderView *headerView;

@property (nonatomic, strong) WXYZ_MemeberModel *memberModel;

@end

@implementation WXYZ_MemberViewController

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
}

- (void)initialize
{
    [self setNavigationBarTitle:@"开通会员"];
    self.navigationBar.backgroundColor = kColorRGB(46, 46, 48);
    self.navigationBar.navTitleLabel.textColor = kWhiteColor;
    [self.navigationBar setLightLeftButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netRequest) name:Notification_Login_Success object:nil];
    
    self.view.backgroundColor = kGrayViewColor;
    goodsSelectIndex = 0;
#if !WX_Third_Pay
    [IAPManager sharedManager].delegate = self;
#endif
}

- (void)createSubviews
{
    self.mainTableViewGroup.delegate = self;
    self.mainTableViewGroup.dataSource = self;
    [self.view addSubview:self.mainTableViewGroup];
    
    [self.mainTableViewGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT - PUB_TABBAR_HEIGHT);
    }];
    
    self.headerView = [[WXYZ_MemberHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, PUB_NAVBAR_HEIGHT + kGeometricHeight(SCREEN_WIDTH - kMargin, 1053, 215) + 30)];
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
    [confirmButton setTitle:@"立即开通" forState:UIControlStateNormal];
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        if (self.memberModel.thirdOn) {
            return [[self.memberModel.list objectOrNilAtIndex:goodsSelectIndex] pal_channel]?[[self.memberModel.list objectOrNilAtIndex:goodsSelectIndex] pal_channel].count:0;
        } else {
            return 0;
        }
    }
    
    if (section == 3 && (self.memberModel.about.count <= 0 || !self.memberModel.about)) {
        return 0;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            WS(weakSelf)
            WXYZ_MemberPayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_MemberPayTableViewCell"];
            if (!cell) {
                cell = [[WXYZ_MemberPayTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_MemberPayTableViewCell"];
            }
            cell.goodsList = self.memberModel.list;
            cell.selectItemBlock = ^(NSInteger itemIndex) {
                SS(strongSelf)
                strongSelf->goodsSelectIndex = itemIndex;
                strongSelf->payStyleIndex = 0;
                [weakSelf.mainTableViewGroup reloadData];
            };
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
            cell.payModel = [[[self.memberModel.list objectOrNilAtIndex:goodsSelectIndex] pal_channel] objectOrNilAtIndex:indexPath.row];
            cell.paySelected = (indexPath.row == payStyleIndex);
#endif
            cell.selectionStyle = UITableViewCellAccessoryNone;
            return cell;
        }
            break;
        case 2:
        {
            
            WXYZ_MemberPrivilegeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_MemberPrivilegeTableViewCell"];
            if (!cell) {
                cell = [[WXYZ_MemberPrivilegeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_MemberPrivilegeTableViewCell"];
            }
            cell.privilege = self.memberModel.privilege;
            cell.selectionStyle = UITableViewCellAccessoryNone;
            return cell;
        }
            break;
        case 3:
        {
            WXYZ_MemberAboutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_MemberAboutTableViewCell"];
            
            if (!cell) {
                cell = [[WXYZ_MemberAboutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_MemberAboutTableViewCell"];
            }
            cell.about = self.memberModel.about;
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
#if WX_Third_Pay
    if (indexPath.section == 1 && [[self.memberModel.list objectOrNilAtIndex:goodsSelectIndex] pal_channel].count > 0 && payStyleIndex != indexPath.row) {
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
    if (section == 1 && !self.memberModel.thirdOn) {
        return CGFLOAT_MIN;
    }
    
    if (section == 3 && (self.memberModel.about.count <= 0 || !self.memberModel.about)) {
        return CGFLOAT_MIN;
    }
    
    return 50;
}

//section头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!self.memberModel) {
        return [[UIView alloc] init];
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kHalfMargin, 0, SCREEN_WIDTH - kHalfMargin, 50)];
    if (section == 0) {
        headerTitleLabel.text = @"会员套餐";
    } else if (section == 1) {
        headerTitleLabel.text = @"支付方式";
    } else if (section == 2) {
        headerTitleLabel.text = @"会员特权";
    } else {
        headerTitleLabel.text = @"会员说明";
    }
    
    headerTitleLabel.font = kBoldFont15;
    headerTitleLabel.textColor = kBlackColor;
    [view addSubview:headerTitleLabel];
    
    NSMutableAttributedString *priceString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"总计：%@", [self.memberModel.list objectAtIndex:goodsSelectIndex].fat_price?:@""]];
    [priceString addAttribute:NSFontAttributeName value:kBoldFont22 range:NSMakeRange(3, priceString.length - 3)];
    [priceString addAttribute:NSForegroundColorAttributeName value:kColorRGB(228, 185, 122) range:NSMakeRange(3, priceString.length - 3)];
    
    priceLabel.attributedText = priceString;
    
    return view;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1 && !self.memberModel.thirdOn) {
        return CGFLOAT_MIN;
    }
    
    if (section == 3 && (self.memberModel.about.count <= 0 || !self.memberModel.about)) {
        return CGFLOAT_MIN;
    }
    
    return kHalfMargin;
}

// section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (!self.memberModel) {
        return [[UIView alloc] init];
    }
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = kGrayViewColor;
    return view;
}

#pragma mark IApRequestResultsDelegate
- (void)requestSuccess
{
    self.mainTableViewGroup.userInteractionEnabled = YES;
    if (self.paySuccessBlock) {
        self.paySuccessBlock();
    }
    [self netRequest];
}

- (void)filedWithErrorCode:(NSInteger)errorCode andError:(NSString *)error
{
    self.mainTableViewGroup.userInteractionEnabled = YES;
}

- (void)confirmButtonClick
{
    if (!WXYZ_UserInfoManager.isLogin) {
        [WXYZ_LoginViewController presentLoginView];
        return;
    }
    
    if (self.memberModel.list.count > 0) {
#if WX_Third_Pay
        WXYZ_GoodsModel *t_goodsModel = [self.memberModel.list objectOrNilAtIndex:goodsSelectIndex];
        WXYZ_PayModel *t_payModel = [t_goodsModel.pal_channel objectOrNilAtIndex:payStyleIndex];
        NSDictionary *dic = @{@"channel_id":@(t_payModel.channel_id),@"goods_id":@(t_goodsModel.goods_id),@"type":t_payModel.channel_code};
        [self gotoPay:dic];
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
        WXYZ_GoodsModel *goodsModel = [self.memberModel.list objectOrNilAtIndex:goodsSelectIndex];
        self.mainTableViewGroup.userInteractionEnabled = NO;
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

- (void)netRequest {
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Member_Center parameters:nil model:WXYZ_MemeberModel.class success:^(BOOL isSuccess, WXYZ_MemeberModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            weakSelf.headerView.userModel = t_model.user;
            weakSelf.memberModel = t_model;
        }
        [weakSelf.mainTableViewGroup reloadData];
    } failure:nil];
    
    
    
    NSString *site_type = @"";
       switch (self.productionType) {
           case WXYZ_ProductionTypeBook:
               site_type = @"1";
               break;
           case WXYZ_ProductionTypeComic:
               site_type = @"2";
               break;
           case WXYZ_ProductionTypeAudio:
               site_type = @"3";
               break;
               
           default:
               break;
       }

       
       [WXYZ_NetworkRequestManger POST:Member_Monthly parameters:@{@"site_id":@"2"} model:WXYZ_MonthlyModel.class success:^(BOOL isSuccess, WXYZ_MonthlyModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
                
           weakSelf.headerView.banner = t_model.banner;

           [weakSelf.mainTableViewGroup setTableHeaderView:weakSelf.headerView];

           [weakSelf.mainTableViewGroup endRefreshing];

           [weakSelf.mainTableViewGroup reloadData];

       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {


       }];
}

@end

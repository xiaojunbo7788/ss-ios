//
//  WXYZ_CancelAccountViewController.m
//  WXReader
//
//  Created by Andrew on 2019/12/21.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_CancelAccountViewController.h"
#import "WXYZ_WebViewViewController.h"
#import "AppDelegate.h"

#import "WXYZ_CancelAccountTableViewCell.h"

@interface WXYZ_CancelAccountViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UIButton *agreementButton;

@property (nonatomic, strong) UIButton *applyButton;

@end

@implementation WXYZ_CancelAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
}

- (void)initialize
{
    [self setNavigationBarTitle:@"注销账号"];
}

- (void)createSubviews
{
    self.dataSourceArray = [NSMutableArray arrayWithArray:@[
    @[@"账号安全", @"最好使用常用设备提交申请，注销申请审核后，注销操作立即生效。"],
    @[@"账号状态", @"申请注销的账号应为正常使用中的状态，应处于未封禁或未被审查的状态。"],
    @[@"账号财产已结清", @"申请注销的账号无有效状态的会员，没有余额等；且没有任何未结清、未完成的交易。"]
    ]];
    
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    [self.mainTableView setTableHeaderView:self.headerView];
    [self.view addSubview:self.mainTableView];
    
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT);
    }];
    
    self.applyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.applyButton.alpha = 0.6;
    self.applyButton.backgroundColor = kRedColor;
    [self.applyButton setTitle:@"申请注销" forState:UIControlStateNormal];
    [self.applyButton addTarget:self action:@selector(applyClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.applyButton];
    
    [self.applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).with.offset(- PUB_TABBAR_OFFSET);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT - PUB_TABBAR_OFFSET);
    }];
    
    [self.mainTableView reloadData];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"WXYZ_CancelAccountTableViewCell";
    WXYZ_CancelAccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_CancelAccountTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.titleString = [self.dataSourceArray objectAtIndex:indexPath.row][0];
    cell.detailString = [self.dataSourceArray objectAtIndex:indexPath.row][1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//section头间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kLabelHeight + kMargin;
}
//section头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kLabelHeight + kMargin)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kHalfMargin, kMargin, SCREEN_WIDTH, kLabelHeight)];
    titleLabel.text = @"申请注销前，您的账号需要注意以下条款：";
    titleLabel.textColor = kBlackColor;
    titleLabel.font = kBoldFont15;
    [view addSubview:titleLabel];
    
    return view;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kLabelHeight + kHalfMargin;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kLabelHeight + kHalfMargin)];
    view.backgroundColor = [UIColor clearColor];
    
    if (!self.agreementButton) {
        self.agreementButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.agreementButton.frame = CGRectMake(kHalfMargin, kHalfMargin, 30, 30);
        self.agreementButton.selected = NO;
        self.agreementButton.adjustsImageWhenHighlighted = NO;
        [self.agreementButton setImageEdgeInsets:UIEdgeInsetsMake(7, 0, 7, 14)];
        [self.agreementButton setImage:[UIImage imageNamed:@"audio_download_unselect"] forState:UIControlStateNormal];
        [self.agreementButton setImage:[UIImage imageNamed:@"audio_download_select"] forState:UIControlStateSelected];
        [self.agreementButton addTarget:self action:@selector(agreementClick) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:self.agreementButton];
        
        WS(weakSelf)
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"我已阅读并接受《用户注销协议》"];
        text.lineSpacing = 5;
        text.font = kMainFont;
        [text setTextHighlightRange:NSMakeRange(7, 8) color:kMainColor backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            WXYZ_WebViewViewController *vc = [[WXYZ_WebViewViewController alloc] init];
            vc.navTitle = @"用户注销协议";
            AppDelegate *delegate = (AppDelegate *)kRCodeSync([UIApplication sharedApplication].delegate);
            vc.URLString = delegate.checkSettingModel.protocol_list.logoff ?: [NSString stringWithFormat:@"%@%@", APIURL, Log_Off];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }];
        [text setTextHighlightRange:NSMakeRange(0, 7) color:kBlackColor backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            [weakSelf agreementClick];
        }];

        YYLabel *tipsLabel = [[YYLabel alloc] init];
        tipsLabel.frame = CGRectMake(kMargin + 10, kHalfMargin, SCREEN_WIDTH - (kMargin + 30 + kMargin), 30);
        tipsLabel.numberOfLines = 0;
        tipsLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 2 * kMargin;
        tipsLabel.attributedText = text;
        tipsLabel.textAlignment = NSTextAlignmentLeft;
        tipsLabel.userInteractionEnabled = YES;
        [view addSubview:tipsLabel];
    }
    
    return view;
}

- (UIView *)headerView
{
    if (!_headerView) {
        
        NSString *str = @"重要提醒：个人账号可以申请注销。为了避免被盗号或非本人操作所带来的损失，注销前需要确认账号所属，以及可能涉及的虚拟财产结算。";
        
        _headerView = [[UIView alloc] init];
        _headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, [WXYZ_ViewHelper getDynamicHeightWithLabelFont:kMainFont labelWidth:(SCREEN_WIDTH - (kMargin + kHalfMargin)) labelText:str] + 80 + 2 * kMargin);
        _headerView.backgroundColor = [UIColor whiteColor];
        
        UIView *headerBackView = [[UIView alloc] init];
        headerBackView.backgroundColor = kGrayViewColor;
        headerBackView.layer.cornerRadius = 12;
        [_headerView addSubview:headerBackView];
        
        [headerBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kHalfMargin);
            make.top.mas_equalTo(kHalfMargin);
            make.width.mas_equalTo(SCREEN_WIDTH - kMargin);
            make.height.mas_equalTo(_headerView.mas_height).with.offset(- kHalfMargin);
        }];
        
        UIImageView *headerImageView = [[UIImageView alloc] init];
        headerImageView.image = [UIImage imageNamed:@"cancel_account"];
        [_headerView addSubview:headerImageView];
        
        [headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(kMargin);
            make.centerX.mas_equalTo(_headerView.mas_centerX);
            make.width.height.mas_equalTo(80);
        }];
        
        UILabel *headerLabel = [[UILabel alloc] init];
        headerLabel.numberOfLines = 0;
        headerLabel.font = kMainFont;
        headerLabel.textColor = kColorRGB(96, 106, 100);
        [_headerView addSubview:headerLabel];
        
        [headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kMargin + kHalfMargin);
            make.top.mas_equalTo(headerImageView.mas_bottom).with.offset(kHalfMargin);
            make.width.mas_equalTo(SCREEN_WIDTH - 2 * (kMargin + kHalfMargin));
            make.height.mas_equalTo([WXYZ_ViewHelper getDynamicHeightWithLabelFont:kMainFont labelWidth:(SCREEN_WIDTH - (kMargin + kHalfMargin)) labelText:str]);
        }];
        
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:str]];
        [attributeString addAttribute:NSFontAttributeName value:kBoldMainFont range:NSMakeRange(0, 5)];
        headerLabel.attributedText = attributeString;
    }
    return _headerView;
}

- (void)agreementClick
{
    self.agreementButton.selected = !self.agreementButton.selected;
    
    if (self.agreementButton.selected) {
        self.applyButton.alpha = 1;
    } else {
        self.applyButton.alpha = 0.6;
    }
}

- (void)applyClick
{
    if (self.agreementButton.selected) {
        WS(weakSelf)
        [WXYZ_NetworkRequestManger POST:Cancel_Account parameters:nil model:nil success:^(BOOL isSuccess, id  _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
            if (isSuccess) {
                [WXYZ_UserInfoManager logout];
                
                weakSelf.agreementButton.selected = NO;
                weakSelf.applyButton.alpha = 0.6;
                
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"注销成功"];
            }
        } failure:nil];
    }
}

@end

//
//  WXYZ_SettingViewController.m
//  WXReader
//
//  Created by Andrew on 2018/7/11.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_SettingViewController.h"
#import "WXYZ_PushSettingViewController.h"

#import "WXYZ_SettingSwitchTableViewCell.h"
#import "WXYZ_SettingNormalTableViewCell.h"
#import "WXYZ_SettingLogoutTableViewCell.h"

@interface WXYZ_SettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *sourcesArray;

@end

@implementation WXYZ_SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarDefaultStyle];
}

- (void)initialize
{
    [self setNavigationBarTitle:@"设置"];
    self.view.backgroundColor = kGrayViewColor;
}

- (void)createSubviews
{
    if (WXYZ_UserInfoManager.isLogin) {
        self.sourcesArray = @[
#if WX_Recharge_Mode
            @[@"自动购买下一章"],
#endif
            @[@"通知管理"],
            @[@"清除缓存", @"好评支持"],
            @[@"退出登录"]
        ];
    } else {
        self.sourcesArray = @[@[@"清除缓存", @"好评支持"]];
    }
    
    self.mainTableViewGroup.delegate = self;
    self.mainTableViewGroup.dataSource = self;
    [self.view addSubview:self.mainTableViewGroup];
    
    [self.mainTableViewGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT);
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sourcesArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.sourcesArray objectOrNilAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (WXYZ_UserInfoManager.isLogin) {
#if WX_Recharge_Mode
        if (indexPath.section == 0) {
            return [self createSettingSwitchCellWithTableView:tableView atIndexPath:indexPath];
        } else if (indexPath.section == 3) {
            return [self createSettingLogoutCellWithTableView:tableView atIndexPath:indexPath];
        }
#else
        if (indexPath.section == 2) {
            return [self createSettingLogoutCellWithTableView:tableView atIndexPath:indexPath];
        }
#endif
    }
    return [self createSettingNormalCellWithTableView:tableView atIndexPath:indexPath];
}

- (UITableViewCell *)createSettingSwitchCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_SettingSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_SettingSwitchTableViewCell0"];
    
    if (!cell) {
        cell = [[WXYZ_SettingSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_SettingSwitchTableViewCell0"];
    }
    cell.leftTitleText = [[self.sourcesArray objectOrNilAtIndex:indexPath.section] objectOrNilAtIndex:indexPath.row];
    cell.hiddenEndLine = YES;
    
    if ([WXYZ_UserInfoManager shareInstance].auto_sub) {
        [cell.switchButton setDefaultOnState:YES];
    } else {
        [cell.switchButton setDefaultOnState:NO];
    }
    
    WS(weakSelf)
    cell.switchButton.didChangeHandler = ^(BOOL isOn) {
        [weakSelf autoSubNetRequest];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)createSettingLogoutCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_SettingLogoutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_SettingLogoutTableViewCell"];
    
    if (!cell) {
        cell = [[WXYZ_SettingLogoutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_SettingLogoutTableViewCell"];
    }
    cell.leftTitleText = [[self.sourcesArray objectOrNilAtIndex:indexPath.section] objectOrNilAtIndex:indexPath.row];
    cell.hiddenEndLine = [[self.sourcesArray objectOrNilAtIndex:indexPath.section] count] - 1 == indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)createSettingNormalCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_SettingNormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_SettingNormalTableViewCell"];
    
    if (!cell) {
        cell = [[WXYZ_SettingNormalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_SettingNormalTableViewCell"];
    }
    cell.leftTitleText = [[self.sourcesArray objectOrNilAtIndex:indexPath.section] objectOrNilAtIndex:indexPath.row];
    cell.hiddenEndLine = NO;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHalfMargin;
}
//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_SettingBasicTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.leftTitleText isEqualToString:@"通知管理"]) {
        [self.navigationController pushViewController:[[WXYZ_PushSettingViewController alloc] init] animated:YES];
    }
    
    if ([cell.leftTitleText isEqualToString:@"清除缓存"]) {
        WXYZ_AlertView *alert = [[WXYZ_AlertView alloc] init];
        alert.alertViewDetailContent = @"是否清除缓存信息";
        alert.confirmButtonClickBlock = ^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"清除缓存成功"];
            });
        };
        [alert showAlertView];
    }
    
    if ([cell.leftTitleText isEqualToString:@"好评支持"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WX_EvaluationAddress] options:@{} completionHandler:nil];
    }
    
    if ([cell.leftTitleText isEqualToString:@"退出登录"]) {
        [self tableView:tableView settingLogoutdidSelectRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView settingLogoutdidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [WXYZ_UserInfoManager logout];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Login_Success object:nil];
    [self.mainTableViewGroup reloadData];
    [self popViewController];
}

- (void)autoSubNetRequest {
    [WXYZ_NetworkRequestManger POST:Auto_Sub_Chapter parameters:nil model:nil success:^(BOOL isSuccess, NSDictionary *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            BOOL autoSub = [t_model[@"data"][@"auto_sub"] boolValue];
            [WXYZ_UserInfoManager updateWithDict:@{KEY_PATH(WXYZ_UserInfoManager.shareInstance, auto_sub):@(autoSub)}];
        }
    } failure:nil];
}

@end

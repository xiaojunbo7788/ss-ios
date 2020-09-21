//
//  WXYZ_PushSettingViewController.m
//  WXReader
//
//  Created by Andrew on 2019/12/5.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>

#import "WXYZ_PushSettingViewController.h"

#import "WXYZ_SettingSwitchTableViewCell.h"
#import "WXYZ_PushSettingTableViewCell.h"

#import "WXYZ_PushSettingModel.h"

@interface WXYZ_PushSettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) BOOL allowedPush;

@end

@implementation WXYZ_PushSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
    [self currentNotificationStatus];
    [self netRequest];
}

- (void)initialize
{
    [self setNavigationBarTitle:@"通知管理"];
    self.view.backgroundColor = kGrayViewColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentNotificationStatus) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)createSubviews
{
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
    if (self.allowedPush) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return self.dataSourceArray.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        WXYZ_PushSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_PushSettingTableViewCell"];
        if (!cell) {
            cell = [[WXYZ_PushSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_PushSettingTableViewCell"];
        }
        cell.leftTitleText = @"设置新消息通知";
        cell.allowedPush = self.allowedPush;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    WS(weakSelf)
    WXYZ_PushSettingModel *settingModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    WXYZ_SettingSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_SettingSwitchTableViewCell0"];
    if (!cell) {
        cell = [[WXYZ_SettingSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_SettingSwitchTableViewCell0"];
    }
    cell.leftTitleText = settingModel.label?:@"";
    cell.hiddenEndLine = NO;
    
    if (settingModel.status == 1) {
        [cell.switchButton setDefaultOnState:YES];
    } else {
        [cell.switchButton setDefaultOnState:NO];
    }
    cell.switchButton.didChangeHandler = ^(BOOL isOn) {
        [weakSelf switchPushStateRequest:settingModel.push_key];
    };
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
    if (section == 0) {
        return 30;
    }
    return CGFLOAT_MIN;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    view.backgroundColor = [UIColor clearColor];
    if (section == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kMargin, 0, SCREEN_WIDTH - 2 * kMargin, 30)];
        label.backgroundColor = [UIColor clearColor];
        label.text = [NSString stringWithFormat:@"请在 iPhone 的“设置”-“%@”设置开启/关闭", App_Name];
        label.textColor = kGrayTextColor;
        label.font = kFont10;
        [view addSubview:label];
    }
    return view;
}

- (void)currentNotificationStatus
{
    WS(weakSelf)
    if (@available(iOS 10 , *)) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            if (settings.authorizationStatus == UNAuthorizationStatusDenied) {
                weakSelf.allowedPush = NO;
            } else {
                weakSelf.allowedPush = YES;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.mainTableViewGroup reloadData];                
            });
        }];
    }
}

- (void)netRequest
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:User_Push_State parameters:nil model:nil success:^(BOOL isSuccess, NSDictionary *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            for (NSDictionary *t_dic in [[t_model objectForKey:@"data"] objectForKey:@"list"]) {
                [weakSelf.dataSourceArray addObject:[WXYZ_PushSettingModel modelWithDictionary:t_dic]];
            }
            [weakSelf.mainTableViewGroup reloadData];
        }
    } failure:nil];
}

- (void)switchPushStateRequest:(NSString *)push_key
{
    [WXYZ_NetworkRequestManger POST:User_Update_Push_State parameters:@{@"push_key":push_key?:@""} model:nil success:nil failure:nil];
}

@end

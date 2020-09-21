//
//  WXYZ_MineViewController.m
//  WXReader
//
//  Created by Andrew on 2018/5/15.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_MineViewController.h"
#import "WXYZ_CollectionController.h"
#import "WXYZ_UserDataViewController.h"
#import "WXYZ_AppraiseViewController.h"
#import "WXYZ_FeedbackCenterViewController.h"
#import "WXYZ_SettingViewController.h"
#import "WXYZ_RecordsViewController.h"
#if WX_Task_Mode && WX_Super_Member_Mode && WX_Recharge_Mode
#import "WXYZ_TaskViewController.h"
#endif
#import "WXYZ_DownloadCacheViewController.h"
#import "WXYZ_RechargeViewController.h"
#import "WXYZ_AboutViewController.h"
#import "WXYZ_MemberViewController.h"
#import "WXYZ_HistoryViewController.h"

#import "WXYZ_MineTableViewCell.h"

#import "WXYZ_MineHeaderView.h"

#import "WXYZ_UserCenterModel.h"

#import "WXYZ_ProductionCollectionManager.h"
#if WX_W_Share_Mode || WX_Q_Share_Mode
    #import "WXYZ_ShareManager.h"
#endif

#import "WXYZ_SticketLogViewController.h"
#import "WXYZ_GiftLogViewController.h"
#import "WXYZ_WebViewViewController.h"
#import "WXYZ_InviteViewController.h"

@interface WXYZ_MineViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) WXYZ_MineHeaderView *headerView;

@property (nonatomic, strong) WXYZ_UserCenterModel *userModel;

@end

@implementation WXYZ_MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setStatusBarDefaultStyle];
    [self netRequest];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Show_Tabbar object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setStatusBarDefaultStyle];
}

- (void)initialize
{
    [self hiddenNavigationBar:YES];
    
    self.view.backgroundColor = kGrayViewColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avatarChanged:) name:Notification_Avatar_Changed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nicknameChnaged:) name:Notification_NickName_Changed object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netRequest) name:Notification_Login_Success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToUserInfo) name:Notification_Push_UserInfo object:nil];
}

- (void)createSubviews
{
    self.mainTableViewGroup.delegate = self;
    self.mainTableViewGroup.dataSource = self;
    [self.view addSubview:self.mainTableViewGroup];
    
    [self.mainTableViewGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_height).with.offset(- PUB_TABBAR_HEIGHT);
    }];
    
    UIView *topCoverView = [[UIView alloc] init];
    topCoverView.backgroundColor = kWhiteColor;
    [self.view addSubview:topCoverView];
    
    [topCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(is_iPhoneX?30:20);
    }];
    
    WS(weakSelf)
    self.headerView = [[WXYZ_MineHeaderView alloc] init];
    self.headerView.avatarSelectedBlock = ^{
        if (WXYZ_UserInfoManager.isLogin) {
            [weakSelf.navigationController pushViewController:[[WXYZ_UserDataViewController alloc] init] animated:YES];
        } else {
            [WXYZ_LoginViewController presentLoginView];
        }
    };
    
    // 金币
#if WX_Records_Mode
    self.headerView.goldSelectedBlock = ^{
        WXYZ_RecordsViewController *vc = [[WXYZ_RecordsViewController alloc] init];
        vc.pageIndex = 0;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
#endif
    
#if WX_Task_Mode && WX_Super_Member_Mode && WX_Recharge_Mode
    // 书券余额
    self.headerView.taskSelectedBlock = ^{
//        [weakSelf.navigationController pushViewController:[[WXYZ_TaskViewController alloc] init] animated:YES];
        WXYZ_RecordsViewController *vc = [[WXYZ_RecordsViewController alloc] init];
        vc.pageIndex = 1;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
#endif
    
#if WX_Records_Mode
    // 月票余额
    self.headerView.voucherSelectedBlock = ^{
        [weakSelf.navigationController pushViewController:[[WXYZ_SticketLogViewController alloc] init] animated:YES];
    };
#endif
    
    [self.mainTableViewGroup setTableHeaderView:self.headerView];
    
    [self.mainTableViewGroup addHeaderRefreshWithRefreshingBlock:^{
        [weakSelf netRequest];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.userModel.panelNewList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userModel.panelNewList[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_MineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_MineTableViewCell"];
    
    if (!cell) {
        cell = [[WXYZ_MineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_MineTableViewCell"];
    }
    cell.cellModel = self.userModel.panelNewList[indexPath.section][indexPath.row];
    
    cell.hiddenEndLine = (indexPath.row == self.userModel.panelNewList[indexPath.section].count - 1);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_MineTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    // 充值
    if ([cell.cellModel.action isEqualToString:@"recharge"] && cell.cellModel.enable) {
        [self.navigationController pushViewController:[[WXYZ_RechargeViewController alloc] init] animated:YES];
    }

    // 包月
    if ([cell.cellModel.action isEqualToString:@"vip"] && cell.cellModel.enable) {
        [self.navigationController pushViewController:[[WXYZ_MemberViewController alloc] init] animated:YES];
    }

#if WX_Task_Mode && WX_Super_Member_Mode && WX_Recharge_Mode
    // 任务
    if ([cell.cellModel.action isEqualToString:@"task"] && cell.cellModel.enable) {
        [self.navigationController pushViewController:[[WXYZ_TaskViewController alloc] init] animated:YES];
    }
#endif

    if ([cell.cellModel.action isEqualToString:@"invite"] && cell.cellModel.enable) {
        [self shareToFriend];
    }

    if ([cell.cellModel.action isEqualToString:@"history"] && cell.cellModel.enable) {
        [self.navigationController pushViewController:[[WXYZ_HistoryViewController alloc] init] animated:YES];
    }

    if ([cell.cellModel.action isEqualToString:@"download"] && cell.cellModel.enable) {
        [self.navigationController pushViewController:[[WXYZ_DownloadCacheViewController alloc] init] animated:YES];
    }

#if WX_Comments_Mode
    // 我的书评
    if ([cell.cellModel.action isEqualToString:@"comment"] && cell.cellModel.enable) {
        [self.navigationController pushViewController:[[WXYZ_AppraiseViewController alloc] init] animated:YES];
    }
#endif

    // 联系客服
    if ([cell.cellModel.action isEqualToString:@"service"] && cell.cellModel.enable) {
        [self.navigationController pushViewController:[[WXYZ_AboutViewController alloc] init] animated:YES];
    }

    // 意见反馈
    if ([cell.cellModel.action isEqualToString:@"feedback"] && cell.cellModel.enable) {
        [self.navigationController pushViewController:[[WXYZ_FeedbackCenterViewController alloc] init] animated:YES];
    }

    // 设置
    if ([cell.cellModel.action isEqualToString:@"setting"] && cell.cellModel.enable) {
        [self.navigationController pushViewController:[[WXYZ_SettingViewController alloc] init] animated:YES];
    }
    
    // 打赏记录
    if ([cell.cellModel.action isEqualToString:@"reward"] && cell.cellModel.enable) {
        [self.navigationController pushViewController:[[WXYZ_GiftLogViewController alloc] init] animated:YES];
    }
    
    // 成为作家
    if ([cell.cellModel.action isEqualToString:@"url"] && cell.cellModel.enable) {
        WXYZ_WebViewViewController *vc = [[WXYZ_WebViewViewController alloc] init];
        vc.URLString = cell.cellModel.content;
        vc.navTitle = @"成为作家";
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    // 喜欢的作者
    if ([cell.cellModel.action isEqualToString:@"author"] && cell.cellModel.enable) {
        
        WXYZ_CollectionController *vc = [[WXYZ_CollectionController alloc] init];
        vc.type  =1;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    // 喜欢的原著
    if ([cell.cellModel.action isEqualToString:@"orginal"] && cell.cellModel.enable) {
        
        WXYZ_CollectionController *vc = [[WXYZ_CollectionController alloc] init];
        vc.type = 2;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    // 喜欢的汉化组
    if ([cell.cellModel.action isEqualToString:@"hanhua"] && cell.cellModel.enable) {
        WXYZ_CollectionController *vc = [[WXYZ_CollectionController alloc] init];
        vc.type = 3;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
//    // 领取红包码
//    if (YES) {
//        [self.navigationController pushViewController:[WXYZ_InviteViewController new] animated:YES];
//        return;
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([[self.userModel.panelNewList objectOrNilAtIndex:section] count] == 0) {
        return CGFLOAT_MIN;
    }
    return kHalfMargin;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kHalfMargin)];
    view.backgroundColor = kGrayViewColor;
    return view;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == self.userModel.panelNewList.count - 1) {
        return kMargin;
    }
    return CGFLOAT_MIN;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kMargin)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)avatarChanged:(NSNotification *)noti
{
    if ([noti.object isKindOfClass:[UIImage class]]) {
        self.headerView.avatarImage = noti.object;
    }
}

- (void)nicknameChnaged:(NSNotification *)noti
{
    self.headerView.nickName = noti.object;
}

- (void)pushToUserInfo
{
    [self.navigationController pushViewController:[[WXYZ_UserDataViewController alloc] init] animated:YES];
}

- (void)shareToFriend
{
#if WX_W_Share_Mode || WX_Q_Share_Mode
    [[WXYZ_ShareManager sharedManager] shareApplicationInController:self shareState:WXYZ_ShareStateAll];    
#endif
}

- (void)netRequest
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POSTQuick:User_Center parameters:nil model:WXYZ_UserCenterModel.class success:^(BOOL isSuccess, id _Nullable t_model, BOOL isCache, WXYZ_NetworkRequestModel *requestModel) {
        [weakSelf.mainTableViewGroup endRefreshing];
        if (isSuccess) {
            weakSelf.userModel = t_model;
            weakSelf.headerView.userModel = t_model;
            [weakSelf.mainTableViewGroup reloadData];
            if (!isCache) {
                [WXYZ_UserInfoManager updateWithDict:requestModel.data];
            }
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg ?: @""];
            if (requestModel.code == 302) {
                [WXYZ_UserInfoManager logout];
                [weakSelf netRequest];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf.mainTableViewGroup endRefreshing];
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
    }];
}

@end

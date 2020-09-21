//
//  WXYZ_TaskViewController.m
//  WXReader
//
//  Created by Andrew on 2018/11/15.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "WXYZ_TaskViewController.h"
#import "WXYZ_TaskTableViewCell.h"
#import "WXYZ_TaskHeaderView.h"
#import "WXYZ_TaskModel.h"
#import "WXYZ_ShareManager.h"
// 充值
#import "WXYZ_RechargeViewController.h"

// 包月
#import "WXYZ_MemberViewController.h"

#import "WXYZ_UserDataViewController.h"
#import "WXYZ_GuideViewController.h"

@interface WXYZ_TaskViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) WXYZ_TaskModel *taskModel;

@property (nonatomic, weak) WXYZ_TaskHeaderView *headerView;

@end

@implementation WXYZ_TaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
}

- (void)initialize
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareSuccess) name:Notification_Share_Success object:nil];
    [self setNavigationBarTitle:@"福利中心"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarDefaultStyle];
    [self netRequest];
}

- (void)createSubviews
{
    UIButton *_rightBtn = nil;
    WS(weakSelf)
    [self setNavigationBarRightButton:({
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn = rightBtn;
        rightBtn.adjustsImageWhenHighlighted = NO;
        [rightBtn setImage:[YYImage imageNamed:@"book_help"] forState:UIControlStateNormal];
        [rightBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            NSString *t_rules = [weakSelf.taskModel.sign_info.sign_rules componentsJoinedByString:@"\n"];
            if (t_rules.length > 0 && t_rules) {
                WXYZ_GuideViewController *vc = [[WXYZ_GuideViewController alloc] init];
                vc.guideString = t_rules;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
        }]];
        rightBtn;
    })];
    [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navigationBar.navTitleLabel);
        make.right.equalTo(self.view).offset(- kMoreHalfMargin);
        make.height.width.mas_equalTo(19);
    }];
    
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.contentInset = UIEdgeInsetsMake(0, 0, PUB_TABBAR_OFFSET, 0);
    [self.view addSubview:self.mainTableView];
    
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT);
    }];

    
#if WX_Sign_Mode
    WXYZ_TaskHeaderView *headerView = [[WXYZ_TaskHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 160)];
    self.headerView = headerView;
    headerView.signClickBlock = ^{
        [weakSelf netRequest];
    };
    [self.mainTableView setTableHeaderView:headerView];
#endif
    
    [self.mainTableView addHeaderRefreshWithRefreshingBlock:^{
        [weakSelf netRequest];
    }];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.taskModel.task_menu.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.taskModel.task_menu objectAtIndex:section].task_list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_TaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_TaskTableViewCell"];
    
    if (!cell) {
        cell = [[WXYZ_TaskTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_TaskTableViewCell"];
    }
    
    WS(weakSelf)
    cell.taskModel = [[self.taskModel.task_menu objectAtIndex:indexPath.section].task_list objectAtIndex:indexPath.row];
    cell.taskClickBlock = ^(NSString * _Nonnull taskAction) {
        if ([taskAction isEqualToString:@"share_app"]) {
            [[WXYZ_ShareManager sharedManager] shareApplicationInController:weakSelf shareState:WXYZ_ShareStateAll];
        } else if ([taskAction isEqualToString:@"read_book"]) {
            [self.navigationController popViewControllerAnimated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Change_Tabbar_Index object:@"1"];
            });
        } else if ([taskAction isEqualToString:@"comment_book"]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Change_Tabbar_Index object:@"1"];
            });
        } else if ([taskAction isEqualToString:@"finish_info"]) {
//            [self.navigationController popToRootViewControllerAnimated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[WXYZ_ViewHelper getCurrentNavigationController] pushViewController:[[WXYZ_UserDataViewController alloc] init] animated:YES];
//                [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Push_UserInfo object:nil];
            });
        } else if ([taskAction isEqualToString:@"add_book"]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Change_Tabbar_Index object:@"1"];
            });
        } else if ([taskAction isEqualToString:@"recharge"]) {
            [weakSelf.navigationController pushViewController:[[WXYZ_RechargeViewController alloc] init] animated:YES];
        } else if ([taskAction isEqualToString:@"vip"]) {
            [weakSelf.navigationController pushViewController:[[WXYZ_MemberViewController alloc] init] animated:YES];
        }
    };
    
    cell.hiddenEndLine = (indexPath.row == [self.taskModel.task_menu objectAtIndex:indexPath.section].task_list.count - 1);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40 + kMargin;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == self.taskModel.task_menu.count - 1) {
        return PUB_TABBAR_OFFSET == 0 ? 10 : PUB_TABBAR_OFFSET;
    }
    return CGFLOAT_MIN;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, PUB_TABBAR_OFFSET == 0 ? 10 : PUB_TABBAR_OFFSET)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    view.backgroundColor = kGrayViewColor;
    
    UIView *titleLableBack = [[UIView alloc] init];
    titleLableBack.backgroundColor = [UIColor whiteColor];
    [view addSubview:titleLableBack];
    
    [titleLableBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(view.mas_bottom);
        make.width.mas_equalTo(view.mas_width);
        make.height.mas_equalTo(40);
    }];
    
    // 主标题
    UILabel *mainTitleLabel = [[UILabel alloc] init];
    mainTitleLabel.textAlignment = NSTextAlignmentLeft;
    mainTitleLabel.textColor = kBlackColor;
    mainTitleLabel.backgroundColor = kWhiteColor;
    mainTitleLabel.text = [self.taskModel.task_menu objectAtIndex:section].task_title;
    mainTitleLabel.font = kBoldFont15;
    [view addSubview:mainTitleLabel];
    
    [mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin + 4 + 5);
        make.top.mas_equalTo(view.mas_top).with.offset(10);
        make.width.mas_equalTo(view.mas_width).with.multipliedBy(0.5);
        make.height.mas_equalTo(40);
    }];
    
    UIView *mainTitleHoldView = [[UIView alloc] init];
    mainTitleHoldView.backgroundColor = kMainColor;
    mainTitleHoldView.layer.cornerRadius = 3.0;
    [view addSubview:mainTitleHoldView];
    
    [mainTitleHoldView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.centerY.mas_equalTo(mainTitleLabel.mas_centerY);
        make.width.mas_equalTo(4);
        make.height.mas_equalTo(kLabelHeight * 2 - 2 * kMargin - 6);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = kGrayLineColor;
    [view addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.bottom.mas_equalTo(view.mas_bottom).with.offset( - kCellLineHeight);
        make.width.mas_equalTo(SCREEN_WIDTH - kMargin);
        make.height.mas_equalTo(kCellLineHeight);
    }];
    
    return view;
}

- (void)guideClick
{
    NSString *t_rules = [self.taskModel.sign_info.sign_rules componentsJoinedByString:@"\n"];
    if (t_rules.length > 0 && t_rules) {
        WXYZ_GuideViewController *vc = [[WXYZ_GuideViewController alloc] init];
        vc.guideString = t_rules;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)netRequest
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Task_Center parameters:nil model:WXYZ_TaskModel.class success:^(BOOL isSuccess, WXYZ_TaskModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            weakSelf.taskModel = t_model;
            weakSelf.headerView.signInfoModel = self.taskModel.sign_info;
        }
        [weakSelf.mainTableView endRefreshing];
        [weakSelf.mainTableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf.mainTableView endRefreshing];
        [weakSelf.mainTableView reloadData];
    }];
}

// 完成阅读任务
+ (void)taskReadRequestWithProduction_id:(NSInteger)production_id
{
    // 完成阅读任务
    if (WXYZ_UserInfoManager.isLogin) {
        if (![WXYZ_SystemInfoManager.taskReadProductionId isEqualToString:[WXYZ_UtilsHelper formatStringWithInteger:production_id]]) {
            [WXYZ_NetworkRequestManger POST:Task_Read parameters:nil model:nil success:^(BOOL isSuccess, NSDictionary *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
                WXYZ_SystemInfoManager.taskReadProductionId = [WXYZ_UtilsHelper formatStringWithInteger:production_id];
            } failure:nil];
        }
    }
}

- (void)shareSuccess {
    [self netRequest];
}

@end

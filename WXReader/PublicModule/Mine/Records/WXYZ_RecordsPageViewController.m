//
//  WXYZ_RecordsPageViewController.m
//  WXReader
//
//  Created by Andrew on 2019/4/2.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_RecordsPageViewController.h"
#import "WXYZ_RecordsTableViewCell.h"
#import "WXYZ_RecordsModel.h"

@interface WXYZ_RecordsPageViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation WXYZ_RecordsPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
    [self netRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarDefaultStyle];
}

- (void)initialize
{
    [self hiddenNavigationBar:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netRequest) name:Notification_Login_Success object:nil];
}

- (void)createSubviews
{
    [self createEmptyView];
    
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.contentInset = UIEdgeInsetsMake(0, 0, PUB_TABBAR_OFFSET, 0);
    [self.view addSubview:self.mainTableView];
    
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT + 44);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT - 44);
    }];
    
    WS(weakSelf)
    [self.mainTableView addHeaderRefreshWithRefreshingBlock:^{
        weakSelf.currentPageNumber = 1;
        [weakSelf netRequest];
    }];
    
    [self.mainTableView addFooterRefreshWithRefreshingBlock:^{
        weakSelf.currentPageNumber ++;
        [weakSelf netRequest];
    }];
    
    if (!WXYZ_UserInfoManager.isLogin) {
        [self setEmptyOnView:self.mainTableView title:@"登录后查看流水记录" buttonTitle:@"立即登录" tapBlock:^{
            [WXYZ_LoginViewController presentLoginView];
        }];
    } else {
        [self setEmptyOnView:self.mainTableView title:@"暂无流水记录" buttonTitle:@"" tapBlock:^{
            
        }];
    }
}

- (void)createEmptyView {
    WS(weakSelf)
    if (!WXYZ_UserInfoManager.isLogin) {
        [self setEmptyOnView:self.mainTableView title:@"登录后查看打赏记录" buttonTitle:@"立即登录" tapBlock:^{
            [WXYZ_LoginViewController presentLoginView:^(WXYZ_UserInfoManager * _Nonnull userDataModel) {
                weakSelf.emptyView = nil;
                [weakSelf createEmptyView];
            }];
        }];
    } else {
        [self setEmptyOnView:self.mainTableView title:@"暂无打赏记录" buttonTitle:@"" tapBlock:^{
            
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_RecordsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_RecordsTableViewCell"];
    
    if (!cell) {
        cell = [[WXYZ_RecordsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_RecordsTableViewCell"];
    }
    cell.listModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    cell.hiddenEndLine = (indexPath.row == self.dataSourceArray.count - 1);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, PUB_TABBAR_OFFSET == 0 ? 10 : PUB_TABBAR_OFFSET)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)netRequest
{
    if ([WXYZ_NetworkReachabilityManager networkingStatus] == NO) {
        [self.mainTableView ly_showEmptyView];
        return;
    }
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Consumption_Records parameters:@{@"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber], @"unit":self.unit} model:WXYZ_RecordsModel.class success:^(BOOL isSuccess, WXYZ_RecordsModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            if (weakSelf.currentPageNumber == 1) {
                [weakSelf.dataSourceArray removeAllObjects];
                weakSelf.dataSourceArray = [NSMutableArray arrayWithArray:t_model.list];
            } else {
                [weakSelf.dataSourceArray addObjectsFromArray:t_model.list];
            }
            if (t_model.total_page <= t_model.current_page) {
                [weakSelf.mainTableView hideRefreshFooter];
            }
        }
        [weakSelf.mainTableView endRefreshing];
        [weakSelf.mainTableView reloadData];
        [weakSelf.mainTableView ly_endLoading];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf.mainTableView endRefreshing];
        [weakSelf.mainTableView ly_endLoading];
    }];
}


@end

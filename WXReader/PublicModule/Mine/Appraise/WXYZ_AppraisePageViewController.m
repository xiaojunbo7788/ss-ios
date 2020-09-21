//
//  WXYZ_AppraisePageViewController.m
//  WXReader
//
//  Created by Andrew on 2018/7/4.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_AppraisePageViewController.h"
#import "WXYZ_AppraiseDetailViewController.h"
#import "WXYZ_AppraiseTableViewCell.h"

@interface WXYZ_AppraisePageViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation WXYZ_AppraisePageViewController

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
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.contentInset = UIEdgeInsetsMake(0, 0, PUB_TABBAR_OFFSET, 0);
    [self.view addSubview:self.mainTableView];
    
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(self.view.mas_top);
        make.height.mas_equalTo(SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT - self.pageViewHeight);
        make.width.mas_equalTo(self.view.mas_width);
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
        [self setEmptyOnView:self.mainTableView title:@"登录后可查看评论内容" buttonTitle:@"立即登录" tapBlock:^{
            [WXYZ_LoginViewController presentLoginView];
        }];
    } else {
        [self setEmptyOnView:self.mainTableView title:@"暂无评论内容" buttonTitle:@"" tapBlock:^{
            
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"WXYZ_AppraiseTableViewCell";
    WXYZ_AppraiseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_AppraiseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.commentsDetailModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    cell.hiddenEndLine = indexPath.row == self.dataSourceArray.count - 1;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN)];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_CommentsDetailModel *t_model = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    
    WXYZ_AppraiseDetailViewController *vc = [[WXYZ_AppraiseDetailViewController alloc] init];
    vc.productionType = self.productionType;
    vc.comment_id = t_model.comment_id;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)netRequest
{
    if ([WXYZ_NetworkReachabilityManager networkingStatus] == NO) {
        [self.mainTableView endRefreshing];
        [self.mainTableView ly_showEmptyView];
        return;
    }
    
    NSString *url = @"";
    switch (self.productionType) {
        case WXYZ_ProductionTypeBook:
            url = Book_Comments_List;
            break;
        case WXYZ_ProductionTypeComic:
            url = Comic_Comments_List;
            break;
        case WXYZ_ProductionTypeAudio:
            url = Audio_Comments_List;
            break;
            
        default:
            break;
    }
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:url parameters:@{@"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber]} model:WXYZ_CommentsModel.class success:^(BOOL isSuccess, WXYZ_CommentsModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            if (weakSelf.currentPageNumber == 1) {
                [weakSelf.mainTableView showRefreshFooter];
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

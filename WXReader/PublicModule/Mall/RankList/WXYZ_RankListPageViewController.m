//
//  WXYZ_BookRankListBoyViewController.m
//  WXReader
//
//  Created by Andrew on 2018/6/14.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_RankListPageViewController.h"
#import "WXYZ_RankListDetailViewController.h"
#import "WXYZ_RankListTableViewCell.h"
#import "WXYZ_RankListModel.h"

@interface WXYZ_RankListPageViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation WXYZ_RankListPageViewController

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
        make.bottom.mas_equalTo(self.view.mas_bottom).with.offset(- PUB_NAVBAR_HEIGHT - self.pageViewHeight);
        make.width.mas_equalTo(self.view.mas_width);
    }];
    
    [self setEmptyOnView:self.mainTableView title:@"暂无数据" buttonTitle:@"" tapBlock:^{
        
    }];
    
    WS(weakSelf)
    [self.mainTableViewGroup addHeaderRefreshWithRefreshingBlock:^{
        [weakSelf netRequest];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_RankListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXBookRankListTableViewCell"];
    
    if (!cell) {
        cell = [[WXYZ_RankListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXBookRankListTableViewCell"];
    }
    if (self.dataSourceArray.count) {
        cell.rankListModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    }
    cell.productionType = self.productionType;
    cell.hiddenEndLine = (indexPath.row == self.dataSourceArray.count - 1);
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
//    return PUB_TABBAR_OFFSET == 0 ? kHalfMargin : PUB_TABBAR_OFFSET;
    return CGFLOAT_MIN;
}

//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, PUB_TABBAR_OFFSET)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataSourceArray && self.dataSourceArray.count > 0) {
        WXYZ_RankListModel *t_model = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
        WXYZ_RankListDetailViewController *vc = [[WXYZ_RankListDetailViewController alloc] init];
        vc.channel = self.channel;
        vc.productionType = self.productionType;
        vc.rank_type = t_model.rank_type;
        vc.navTitle = t_model.list_name?:@"";
        [self.navigationController pushViewController:vc animated:YES];        
    }
}

- (void)netRequest
{
    NSString *url = @"";
    switch (self.productionType) {
        case WXYZ_ProductionTypeBook:
            url = Book_Rank_List;
            break;
        case WXYZ_ProductionTypeComic:
            url = Comic_Rank_List;
            break;
        case WXYZ_ProductionTypeAudio:
            url = Audio_Rank_List;
            break;
            
        default:
            break;
    }
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:url parameters:@{@"channel_id":self.channel} model:nil success:^(BOOL isSuccess, NSDictionary *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            NSArray *t_arr = t_model[@"data"];
            for (NSDictionary *t_dic in t_arr) {
                WXYZ_RankListModel *t_model = [WXYZ_RankListModel modelWithDictionary:t_dic];
                [weakSelf.dataSourceArray addObject:t_model];
            }
        }
        
        [weakSelf.mainTableView endRefreshing];
        [weakSelf.mainTableView reloadData];
        [weakSelf.mainTableView ly_endLoading];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf.mainTableView endRefreshing];
        [weakSelf.mainTableView reloadData];
        [weakSelf.mainTableView ly_endLoading];
    }];
}

@end

//
//  WXYZ_AudioSoundRecommendedViewController.m
//  WXReader
//
//  Created by Andrew on 2020/3/12.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AudioSoundRecommendedViewController.h"

#import "WXYZ_AudioSoundRecommendedTableViewCell.h"

#import "WXYZ_AudioSoundRecommendedModel.h"

@interface WXYZ_AudioSoundRecommendedViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation WXYZ_AudioSoundRecommendedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
    [self netRequest];
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
        make.edges.mas_equalTo(self.view);
    }];
    
    [self setEmptyOnView:self.mainTableView title:@"暂无数据" buttonTitle:@"" tapBlock:nil];
    
    WS(weakSelf)
    [self.mainTableView addHeaderRefreshWithRefreshingBlock:^{
        weakSelf.currentPageNumber = 1;
        [weakSelf netRequest];
    }];
    
    [self.mainTableView addFooterRefreshWithRefreshingBlock:^{
        weakSelf.currentPageNumber ++;
        [weakSelf netRequest];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"WXYZ_AudioSoundRecommendedTableViewCell";
    WXYZ_AudioSoundRecommendedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_AudioSoundRecommendedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.productionType = self.productionType;
    [cell setListModel:[self.dataSourceArray objectOrNilAtIndex:indexPath.row]];
    cell.hiddenEndLine = (indexPath.row == self.dataSourceArray.count - 1);
    WS(weakSelf)
    cell.clickBlock = ^(NSInteger production_id) {
        WXYZ_AudioMallDetailViewController *vc = [[WXYZ_AudioMallDetailViewController alloc] init];
        vc.audio_id = production_id;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
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
    WXYZ_ProductionModel *t_model = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    WXYZ_AudioMallDetailViewController *vc = [[WXYZ_AudioMallDetailViewController alloc] init];
    vc.audio_id = t_model.production_id;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.mainTableView]) {
        if (!self.canScroll) {
            scrollView.contentOffset = CGPointZero;
        }
        
        if (scrollView.contentOffset.y > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Audio_Can_Leave_Top object:@NO];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y <= 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Audio_Can_Leave_Top object:@YES];
    }
}

- (void)netRequest
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Audio_Info_Recommend parameters:@{@"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber]} model:WXYZ_AudioSoundRecommendedModel.class success:^(BOOL isSuccess, WXYZ_AudioSoundRecommendedModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
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
        [weakSelf.mainTableView reloadData];
        [weakSelf.mainTableView ly_endLoading];
    }];
}

@end

//
//  WXYZ_MallRecommendMoreViewController.m
//  WXReader
//
//  Created by Andrew on 2018/5/28.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_MallRecommendMoreViewController.h"
#import "WXYZ_MallRecommendModel.h"
#import "WXYZ_ProductionListTableViewCell.h"

@interface WXYZ_MallRecommendMoreViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation WXYZ_MallRecommendMoreViewController

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
    [self setStatusBarDefaultStyle];
}

- (void)createSubviews
{
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.contentInset = UIEdgeInsetsMake(0, 0, PUB_TABBAR_OFFSET, 0);
    [self.view addSubview:self.mainTableView];
    
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT);
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
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"WXYZ_ProductionListTableViewCell";
    WXYZ_ProductionListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_ProductionListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.productionType = self.productionType;
    cell.listModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.hiddenEndLine = (indexPath.row == self.dataSourceArray.count - 1);
    return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionModel *productionModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    
    switch (self.productionType) {
        case WXYZ_ProductionTypeBook:
        {
            WXYZ_BookMallDetailViewController *vc = [[WXYZ_BookMallDetailViewController alloc] init];
            vc.book_id = productionModel.production_id;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
#if WX_Enable_Comic
        case WXYZ_ProductionTypeComic:
                    
        {
            WXYZ_ComicMallDetailViewController *vc = [[WXYZ_ComicMallDetailViewController alloc] init];
            vc.comic_id = productionModel.production_id;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
#endif

#if WX_Enable_Audio
        case WXYZ_ProductionTypeAudio:
        {
            WXYZ_AudioMallDetailViewController *vc = [[WXYZ_AudioMallDetailViewController alloc] init];
            vc.audio_id = productionModel.production_id;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
#endif
            
        default:
            break;
    }
}

- (void)netRequest
{
    NSString *url = @"";
    switch (self.productionType) {
        case WXYZ_ProductionTypeBook:
            url = Book_Recommend_More;
            break;
        case WXYZ_ProductionTypeComic:
            url = Comic_Recommend_More;
            break;
        case WXYZ_ProductionTypeAudio:
            url = Audio_Recommend_More;
            break;
            
        default:
            break;
    }
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:url parameters:@{@"recommend_id":self.recommend_id, @"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber]} model:WXYZ_MallRecommendModel.class success:^(BOOL isSuccess, WXYZ_MallRecommendModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            [weakSelf setNavigationBarTitle:t_model.recommendTitle?:@"查看更多"];
            if (weakSelf.currentPageNumber == 1) {
                [weakSelf.dataSourceArray removeAllObjects];
                weakSelf.dataSourceArray = [NSMutableArray arrayWithArray:t_model.recommendList.list];
            } else {
                [weakSelf.dataSourceArray addObjectsFromArray:t_model.recommendList.list];
            }
            if (t_model.recommendList.total_page <= t_model.recommendList.current_page) {
                [weakSelf.mainTableView hideRefreshFooter];
            }
        }
        [weakSelf.mainTableView endRefreshing];
        [weakSelf.mainTableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf.mainTableView endRefreshing];
    }];
}

@end

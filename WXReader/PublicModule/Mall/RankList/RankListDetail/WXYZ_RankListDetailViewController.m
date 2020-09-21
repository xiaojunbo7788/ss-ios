//
//  WXYZ_RankListDetailViewController.m
//  WXReader
//
//  Created by Andrew on 2018/6/14.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_RankListDetailViewController.h"

#import "WXYZ_ProductionListTableViewCell.h"
#import "WXYZ_PublicADStyleTableViewCell.h"

@interface WXYZ_RankListDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) BOOL needRefresh;

@end

@implementation WXYZ_RankListDetailViewController

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
    self.needRefresh = YES;
    [self setNavigationBarTitle:self.navTitle];
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
    
    [self setEmptyOnView:self.mainTableView title:@"暂无数据" tapBlock:nil];
    
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
    WXYZ_ProductionModel *t_model = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    if (t_model.ad_type == 0) {
        WXYZ_ProductionListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_ProductionListTableViewCell"];
        if (!cell) {
            cell = [[WXYZ_ProductionListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_ProductionListTableViewCell"];
        }
        cell.isRankList = YES;
        cell.productionType = self.productionType;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.listModel = t_model;
        cell.hiddenEndLine = (indexPath.row == self.dataSourceArray.count - 1);
        return cell;
    } else {
        WXYZ_PublicADStyleTableViewCell *cell = [self.adCellDictionary objectForKey:[WXYZ_UtilsHelper formatStringWithInteger:indexPath.row]];
        if (!cell) {
            static NSString *cellName = @"WXYZ_PublicADStyleTableViewCell";
            cell = [[WXYZ_PublicADStyleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            [cell setAdModel:t_model refresh:self.needRefresh];
            cell.mainTableView = tableView;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self.adCellDictionary setObject:cell forKey:[WXYZ_UtilsHelper formatStringWithInteger:indexPath.row]];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionModel *t_model = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    switch (self.productionType) {
#if WX_Enable_Book
        case WXYZ_ProductionTypeBook:
        {
            WXYZ_BookMallDetailViewController *vc = [[WXYZ_BookMallDetailViewController alloc] init];
            vc.book_id = t_model.production_id;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
#endif
            
#if WX_Enable_Comic
        case WXYZ_ProductionTypeComic:
        {
            WXYZ_ComicMallDetailViewController *vc = [[WXYZ_ComicMallDetailViewController alloc] init];
            vc.comic_id = t_model.production_id;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
#endif
            
#if WX_Enable_Audio
        case WXYZ_ProductionTypeAudio:
        {
            WXYZ_AudioMallDetailViewController *vc = [[WXYZ_AudioMallDetailViewController alloc] init];
            vc.audio_id = t_model.production_id;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
#endif
            
        default:
            break;
    }
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
    NSString *url = @"";
    switch (self.productionType) {
        case WXYZ_ProductionTypeBook:
            url = Book_Rank_Detail_List;
            break;
        case WXYZ_ProductionTypeComic:
            url = Comic_Rank_Detail_List;
            break;
        case WXYZ_ProductionTypeAudio:
            url = Audio_Rank_Detail_List;
            break;
            
        default:
            break;
    }
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:url parameters:@{@"channel_id":self.channel, @"rank_type":self.rank_type, @"page_num":[WXYZ_UtilsHelper formatStringWithInteger:weakSelf.currentPageNumber]} model:WXYZ_ProductionListModel.class success:^(BOOL isSuccess, WXYZ_ProductionListModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            if (weakSelf.currentPageNumber == 1) {
                weakSelf.dataSourceArray = [NSMutableArray arrayWithArray:t_model.list];
            } else {
                [weakSelf.dataSourceArray addObjectsFromArray:t_model.list];
            }
            
            weakSelf.needRefresh = YES;
            [weakSelf.mainTableView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.needRefresh = NO;
            });
            if (t_model.total_page <= t_model.current_page) {
                [weakSelf.mainTableView hideRefreshFooter];
            }
        }
        
        [weakSelf.mainTableView endRefreshing];
        [weakSelf.mainTableView ly_endLoading];
        if (weakSelf.dataSourceArray.count == 0) {
            [weakSelf.mainTableView ly_showEmptyView];
        } else {
            [weakSelf.mainTableView ly_hideEmptyView];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf.mainTableView endRefreshing];
        [weakSelf.mainTableView ly_endLoading];
    }];
}

@end

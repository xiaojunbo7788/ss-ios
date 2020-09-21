//
//  WXYZ_ComicDiscoverViewController.m
//  WXReader
//
//  Created by Andrew on 2019/6/12.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicDiscoverViewController.h"

#import "WXYZ_ComicDiscoverTableViewCell.h"
#import "WXYZ_ComicDiscoverADTableViewCell.h"

#import "WXYZ_DiscoverHeaderView.h"

#import "WXYZ_ComicDiscoverModel.h"

#import "WXYZ_BannerActionManager.h"

@interface WXYZ_ComicDiscoverViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) WXYZ_ComicDiscoverModel *comicDiscoverModel;

@property (nonatomic, strong) WXYZ_DiscoverHeaderView *headerView;

@property (nonatomic, assign) BOOL needRefresh;

@end

@implementation WXYZ_ComicDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
    [self netRequest];
}

- (void)initialize
{
    self.needRefresh = YES;
    [self hiddenNavigationBar:YES];
}

- (void)createSubviews
{
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    [self.view addSubview:self.mainTableView];
    
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_height).with.offset(- PUB_TABBAR_HEIGHT - PUB_NAVBAR_HEIGHT);
    }];
    
    WS(weakSelf)
    self.headerView = [[WXYZ_DiscoverHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN)];
    self.headerView.bannerrImageClickBlock = ^(WXYZ_BannerModel * _Nonnull bannerModel) {
        if ([WXYZ_BannerActionManager getBannerActionWithBannerModel:bannerModel productionType:WXYZ_ProductionTypeComic]) {
            [weakSelf.navigationController pushViewController:[WXYZ_BannerActionManager getBannerActionWithBannerModel:bannerModel productionType:WXYZ_ProductionTypeComic] animated:YES];
        }
    };
    [self.mainTableView setTableHeaderView:self.headerView];
    
    [self.mainTableView addHeaderRefreshWithRefreshingBlock:^{
        [weakSelf netRequest];
    }];
    
    [self.mainTableView addFooterRefreshWithRefreshingBlock:^{
        weakSelf.currentPageNumber++;
        [weakSelf netRequest];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.comicDiscoverModel.item_list.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionModel *t_model = [self.comicDiscoverModel.item_list.list objectOrNilAtIndex:indexPath.row];
    
    if (t_model.ad_type == 0) {
        WXYZ_ComicDiscoverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_ComicDiscoverTableViewCell"];
        
        if (!cell) {
            cell = [[WXYZ_ComicDiscoverTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_ComicDiscoverTableViewCell"];
        }
        cell.listModel = [self.comicDiscoverModel.item_list.list objectOrNilAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        static NSString *cellName = @"WXYZ_ComicDiscoverADTableViewCell";
        WXYZ_ComicDiscoverADTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (!cell) {
            cell = [[WXYZ_ComicDiscoverADTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        [cell setAdModel:t_model refresh:self.needRefresh];
        cell.mainTableView = tableView;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
//    return 10;
    return CGFLOAT_MIN;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionModel *t_model = [self.comicDiscoverModel.item_list.list objectOrNilAtIndex:indexPath.row];
    
    WXYZ_ComicMallDetailViewController *vc = [[WXYZ_ComicMallDetailViewController alloc] init];
    vc.comic_id = t_model.production_id;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)netRequest
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POSTQuick:Comic_Discover parameters:@{@"channel_id":@(WXYZ_SystemInfoManager.sexChannel), @"page_num" : @(self.currentPageNumber)} model:WXYZ_ComicDiscoverModel.class success:^(BOOL isSuccess, WXYZ_ComicDiscoverModel * _Nullable t_model, BOOL isCache, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            weakSelf.headerView.banner = t_model.banner;
            weakSelf.comicDiscoverModel = t_model;
            
            if (weakSelf.comicDiscoverModel.banner.count > 0) {
                weakSelf.headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH / 4);
            } else {
                weakSelf.headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN);
            }
            if (t_model.item_list.current_page >= t_model.item_list.total_page) {
                [weakSelf.mainTableView hideRefreshFooter];
            }
            [weakSelf.mainTableView setTableHeaderView:weakSelf.headerView];
        }
        [weakSelf.mainTableView endRefreshing];
        weakSelf.needRefresh = YES;
        [weakSelf.mainTableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.needRefresh = NO;
        });
    } failure:nil];
    
}

@end

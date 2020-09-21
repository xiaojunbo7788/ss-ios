//
//  WXZY_CollectionBookViewController.m
//  WXReader
//
//  Created by geng on 2020/9/13.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXZY_CollectionBookViewController.h"
#import "WXYZ_HistoryTableViewCell.h"
#import "WXYZ_BookReaderViewController.h"
#import "WXYZ_ComicReaderViewController.h"
#import "WXYZ_ProductionReadRecordManager.h"
#import "WXYZ_ProductionCollectionManager.h"
@interface WXZY_CollectionBookViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign) BOOL needRefresh;

@end

@implementation WXZY_CollectionBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
}

- (void)initialize {
    self.needRefresh = YES;
    switch (self.listModel.type) {
        case 1:
            [self setNavigationBarTitle:self.listModel.author];
            break;
        case 2:
            [self setNavigationBarTitle:self.listModel.original];
            break;
        case 3:
            [self setNavigationBarTitle:self.listModel.sinici];
            break;
            
        default:
            break;
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self netRequest];
}

- (void)createSubviews {
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.contentInset = UIEdgeInsetsMake(0, 0, PUB_TABBAR_OFFSET, 0);
    [self.view addSubview:self.mainTableView];
    
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.height.mas_equalTo(SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT - self.pageViewHeight);
        make.width.mas_equalTo(self.view.mas_width);
    }];
    
    [self createEmptyView];
    
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

- (void)createEmptyView {
    WS(weakSelf)
    if (!WXYZ_UserInfoManager.isLogin) {
        [self setEmptyOnView:self.mainTableView title:@"登录后可同步历史记录" buttonTitle:@"立即登录" tapBlock:^{
            [WXYZ_LoginViewController presentLoginView:^(WXYZ_UserInfoManager * _Nonnull userDataModel) {
                weakSelf.emptyView = nil;
                [weakSelf createEmptyView];
            }];
        }];
    } else {
        [self setEmptyOnView:self.mainTableView title:@"暂无记录" buttonTitle:@"" tapBlock:^{
            
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionModel *productionModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    WXYZ_HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_HistoryTableViewCell"];
            
    if (!cell) {
        cell = [[WXYZ_HistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_HistoryTableViewCell"];
    }
    cell.productionType = self.productionType;
    cell.productionModel = productionModel;
    cell.hiddenEndLine = self.dataSourceArray.count - 1 == indexPath.row;
    cell.continueReadBlock = ^(NSInteger book_id) {
    WXYZ_ComicReaderViewController *vc = [[WXYZ_ComicReaderViewController alloc] init];
    [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] moveCollectionToTopWithProductionModel:productionModel];
    vc.comicProductionModel = productionModel;
    vc.chapter_id = [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] getReadingRecordChapter_idWithProduction_id:productionModel.production_id];
        [self.navigationController pushViewController:vc animated:YES];
    };
            
    cell.hiddenEndLine = (self.dataSourceArray.count - 1 == indexPath.row);
    if (indexPath.row + 1 < self.dataSourceArray.count) {
        WXYZ_ProductionModel *t_model = [self.dataSourceArray objectOrNilAtIndex:indexPath.row + 1];
        cell.hiddenEndLine = t_model.advert_id != 0;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionModel *t_model = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    WXYZ_ComicMallDetailViewController *vc = [[WXYZ_ComicMallDetailViewController alloc] init];
    vc.comic_id = t_model.production_id;
    [self.navigationController pushViewController:vc animated:YES];
}

//section头间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
//section头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
//    return PUB_TABBAR_OFFSET == 0 ? 10 : PUB_TABBAR_OFFSET;
    return CGFLOAT_MIN;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, PUB_TABBAR_OFFSET == 0 ? 10 : PUB_TABBAR_OFFSET)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}


- (void)netRequest {
    if ([WXYZ_NetworkReachabilityManager networkingStatus] == NO) {
        [self.mainTableView ly_showEmptyView];
        return;
    }
    
    NSDictionary *dic = @{@"channel_id":self.listModel.from_channel,@"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber]};
    NSString *url = @"";
    switch (self.listModel.type) {
        case 1:
            url = MyLikeAuthorList;
            dic = @{@"channel":self.listModel.from_channel,@"channel_id":self.listModel.from_channel,@"author":self.listModel.author,@"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber]};
            break;
        case 2:
            url = MyLikeOriginalList;
            dic = @{@"channel":self.listModel.from_channel,@"channel_id":self.listModel.from_channel,@"original":self.listModel.original,@"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber]};
            break;
        case 3:
            url = MyLikeSiniciList;
            dic = @{@"channel":self.listModel.from_channel,@"channel_id":self.listModel.from_channel,@"sinici":self.listModel.sinici,@"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber]};
            break;
            
        default:
            break;
    }
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:url parameters:dic model:nil success:^(BOOL isSuccess, id _Nullable d_model, WXYZ_NetworkRequestModel *requestModel) {
        WXYZ_ProductionListModel *t_model = [WXYZ_ProductionListModel modelWithDictionary:d_model[@"data"]];
        if (isSuccess) {
            if (weakSelf.currentPageNumber == 1) {
                [weakSelf.mainTableView showRefreshFooter];
                weakSelf.dataSourceArray = [NSMutableArray arrayWithArray:t_model.list];
            } else {
                [weakSelf.dataSourceArray addObjectsFromArray:t_model.list];
            }
            if (t_model.total_page <= t_model.current_page) {
                [weakSelf.mainTableView hideRefreshFooter];
            }
        }
        [weakSelf.mainTableView endRefreshing];
        weakSelf.needRefresh = YES;
        [weakSelf.mainTableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.needRefresh = NO;
        });
        [weakSelf.mainTableView ly_endLoading];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf.mainTableView endRefreshing];
        [weakSelf.mainTableView ly_endLoading];
    }];
}


@end

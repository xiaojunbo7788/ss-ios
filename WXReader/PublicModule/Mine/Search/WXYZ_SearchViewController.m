//
//  WXYZ_SearchViewController.m
//  WXReader
//
//  Created by Andrew on 2018/7/3.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_SearchViewController.h"
#import "WXYZ_BookMallStyleDoubleTableViewCell.h"
#import "WXYZ_ProductionListTableViewCell.h"
#import "WXYZ_SearchHeaderView.h"
#import "WXYZ_TagBookViewController.h"
#import "WXYZ_SearchBar.h"

#import "WXYZ_MallCenterLabelModel.h"
#import "WXYZ_SearchModel.h"
#import "WXYZ_TagListViewController.h"

@interface WXYZ_SearchViewController () <UITableViewDelegate, UITableViewDataSource, DPSearchBarDelegate,WXYZ_SearchHeaderViewDelegate>
{
    NSString *searchString;
    BOOL inSearchState;
}

@property (nonatomic, strong) WXYZ_SearchHeaderView *headerView;

@property (nonatomic, strong) WXYZ_MallCenterLabelModel *labelModel;

@property (nonatomic, strong) WXYZ_SearchBar *searchBar;

@end

@implementation WXYZ_SearchViewController

- (void)viewDidLoad
{
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Show_Tabbar object:nil];
}

- (void)initialize
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self hiddenNavigationBar:YES];
}

- (void)createSubviews
{
    self.searchBar = [[WXYZ_SearchBar alloc] initWithFrame:CGRectMake(5, PUB_NAVBAR_OFFSET + 25, SCREEN_WIDTH, 40)];
    self.searchBar.placeholderText = self.placeholder ?: @"搜索您感兴趣的书籍";
    self.searchBar.backgroundColor = [UIColor clearColor];
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
    
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.contentInset = UIEdgeInsetsMake(0, 0, PUB_TABBAR_OFFSET, 0);
    [self.view addSubview:self.mainTableView];
    
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT + kHalfMargin);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT - kHalfMargin);
    }];
    
    [self setEmptyOnView:self.mainTableView title:@"未搜索到相关内容" buttonTitle:nil tapBlock:^{
        
    }];
    
    WS(weakSelf)
    self.headerView = [[WXYZ_SearchHeaderView alloc] init];
    self.headerView.delegate  =self;
    self.headerView.hotWorkClickBlock = ^(NSString *hotWord) {
        weakSelf.searchBar.searchText = hotWord;
        [weakSelf searchButtonClickedWithSearchText:hotWord];
    };
    [self.mainTableView setTableHeaderView:self.headerView];
    
    [self.mainTableView addHeaderRefreshWithRefreshingBlock:^{
        weakSelf.currentPageNumber = 1;
        [weakSelf searchNetRequest];
    }];
    
    [self.mainTableView addFooterRefreshWithRefreshingBlock:^{
        weakSelf.currentPageNumber ++;
        [weakSelf searchNetRequest];
    }];
    
    [self.mainTableView hideRefreshHeader];
    [self.mainTableView hideRefreshFooter];
    [self.mainTableView titleLabel].hidden = YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return inSearchState?self.dataSourceArray.count:self.labelModel?1:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WS(weakSelf)
    if (inSearchState) {
        static NSString *cellName = @"WXYZ_ProductionListTableViewCell";
        WXYZ_ProductionListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (!cell) {
            cell = [[WXYZ_ProductionListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        cell.productionType = self.productionType;
        cell.listModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        static NSString *cellName = @"WXYZ_BookMallStyleDoubleTableViewCell";
        WXYZ_BookMallStyleDoubleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (!cell) {
            cell = [[WXYZ_BookMallStyleDoubleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        cell.cellDidSelectItemBlock = ^(NSInteger production_id) {
            
            switch (weakSelf.productionType) {
#if WX_Enable_Book
                case WXYZ_ProductionTypeBook:
                {
                    WXYZ_BookMallDetailViewController *vc = [[WXYZ_BookMallDetailViewController alloc] init];
                    vc.book_id = production_id;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }
                    break;
#endif
                    
#if WX_Enable_Comic
                case WXYZ_ProductionTypeComic:
                {
                    WXYZ_ComicMallDetailViewController *vc = [[WXYZ_ComicMallDetailViewController alloc] init];
                    vc.comic_id = production_id;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }
                    break;
#endif
                    
#if WX_Enable_Audio
                case WXYZ_ProductionTypeAudio:
                {
                    WXYZ_AudioMallDetailViewController *vc = [[WXYZ_AudioMallDetailViewController alloc] init];
                    vc.audio_id = production_id;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }
                    break;
#endif
                    
                default:
                    break;
            }
        };
        cell.labelModel = self.labelModel;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
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
    if (inSearchState) {
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
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar searchBarResignFirstResponder];
}

- (void)cancelButtonClicked
{
    if (searchString.length > 0) {
        self.searchBar.searchText = @"";
        [self.searchBar resignFirstResponder];
        [self searchBarCleanText];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)searchButtonClickedWithSearchText:(NSString *)searchText
{
    self.currentPageNumber = 1;
    inSearchState = YES;
    searchString = searchText;
    [self searchNetRequest];
}

- (void)searchBarCleanText
{
    self.currentPageNumber = 1;
    inSearchState = NO;
    searchString = @"";
    self.headerView.hidden = NO;
    [self.headerView setNormalFrame];
    [self.mainTableView reloadData];
    [self.mainTableView ly_startLoading];
    [self.mainTableView hideRefreshFooter];
    [self.mainTableView hideRefreshHeader];
    [self.mainTableView titleLabel].hidden = YES;
}

- (void)searchNetRequest
{
    NSString *url = @"";
    switch (self.productionType) {
        case WXYZ_ProductionTypeBook:
            url = Book_Search_List;
            break;
        case WXYZ_ProductionTypeComic:
            url = Comic_Search_List;
            break;
        case WXYZ_ProductionTypeAudio:
            url = Audio_Search_List;
            break;
            
        default:
            break;
    }
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:url parameters:@{@"keyword":searchString, @"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber]} model:WXYZ_ProductionListModel.class success:^(BOOL isSuccess, WXYZ_ProductionListModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            if (weakSelf.currentPageNumber == 1) {
                weakSelf.headerView.hidden = YES;
                weakSelf.headerView.frame = CGRectMake(0, 0, 0.1, 0.1);
                [weakSelf.mainTableView showRefreshHeader];
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

- (void)netRequest
{
    NSString *url = @"";
    switch (self.productionType) {
        case WXYZ_ProductionTypeBook:
            url = Book_Search;
            break;
        case WXYZ_ProductionTypeComic:
            url = Comic_Search;
            break;
        case WXYZ_ProductionTypeAudio:
            url = Audio_Search;
            break;
            
        default:
            break;
    }
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:url parameters:nil model:WXYZ_SearchModel.class success:^(BOOL isSuccess, WXYZ_SearchModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            for (WXYZ_ProductionModel *tt_model in t_model.list) {
                tt_model.productionType = weakSelf.productionType;
            }
            weakSelf.headerView.hotWordArray = t_model.hot_word;
            
//            if (t_model.hot_word.count > 0) {
//                weakSelf.searchBar.placeholderText = [t_model.hot_word objectOrNilAtIndex:(arc4random() % (t_model.hot_word.count - 1))];
//            } else {
//                weakSelf.searchBar.placeholderText = @"搜索您感兴趣的书籍";
//            }
            
            weakSelf.labelModel = [[WXYZ_MallCenterLabelModel alloc] init];
            weakSelf.labelModel.list = t_model.list;
            weakSelf.labelModel.label = @"热搜榜";
            weakSelf.labelModel.style = 2;
        }
        [weakSelf.mainTableView reloadData];
    } failure:nil];
    
    
       [WXYZ_NetworkRequestManger POSTQuick:MyTagList parameters:@{@"page_size":@"9"} model:nil success:^(BOOL isSuccess, id _Nullable t_model, BOOL isCache, WXYZ_NetworkRequestModel *requestModel) {
           if (isSuccess) {
               NSArray *list = t_model[@"data"][@"list"];
               [self.headerView showTagArray:list];
           } else {
               [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg ?: @""];
               if (requestModel.code == 302) {
                   [WXYZ_UserInfoManager logout];
                   [weakSelf netRequest];
               }
           }
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
       }];
}

- (void)selectTagBy:(NSDictionary *)data {
    WXYZ_TagBookViewController *vc = [[WXYZ_TagBookViewController alloc] init];
    vc.classType = 1;
    vc.tagTitle = data[@"title"];
    vc._id = data[@"id"];
//    vc.hidesBottomBarWhenPushed = true;
    [self.navigationController pushViewController:vc animated:true];
}

- (void)selectMoreTag {
    WXYZ_TagListViewController *vc = [[WXYZ_TagListViewController alloc] init];
//    vc.hidesBottomBarWhenPushed = true;
    [self.navigationController pushViewController:vc animated:true];
}

@end

//
//  WXYZ_ClassifyViewController.m
//  WXReader
//
//  Created by Andrew on 2019/6/17.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ClassifyViewController.h"

#import "WXYZ_ProductionListTableViewCell.h"
#import "WXYZ_PublicADStyleTableViewCell.h"
#import "WXYZ_TagListViewController.h"
#import "WXYZ_ClassifyHeaderView.h"

#import "WXYZ_ClassifyModel.h"

@interface WXYZ_ClassifyViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) WXYZ_ClassifyHeaderView *headerView;

@property (nonatomic, strong) NSMutableDictionary *parameterDic;

@property (nonatomic, strong) NSString *oldField;

@property (nonatomic, strong) NSString *oldValue;

@property (nonatomic, assign) BOOL needRefresh;

@end

@implementation WXYZ_ClassifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
    [self netRequestWithDictionary:@{@"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber], @"page_size":@"10"}];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setStatusBarDefaultStyle];
}

- (void)initialize
{
    self.needRefresh = YES;
    NSString *navTitle = @"会员书库";
    if (!self.isMemberStore) {
        navTitle = @"分类";
        UIButton *rightButton;
        [self setNavigationBarRightButton:({
               UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
               rightButton = button;
               [button setTitle:@"标签列表" forState:UIControlStateNormal];
               [button setTitleColor:kColorRGB(255, 154, 102) forState:UIControlStateNormal];
               button.titleLabel.font = kFont14;
               button.backgroundColor = [UIColor clearColor];
               [button addTarget:self action:@selector(gotoTagList) forControlEvents:UIControlEventTouchUpInside];
               button;
           })];
           [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
               make.right.equalTo(self.view).offset(-kMargin);
               make.centerY.equalTo(self.navigationBar.navTitleLabel);
           }];
    }
    
    [self setNavigationBarTitle:navTitle];
    
    self.parameterDic = [NSMutableDictionary dictionary];
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
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT);
    }];
    
    [self.mainTableView setTableHeaderView:self.headerView];
    
    WS(weakSelf)
    [self.mainTableView addHeaderRefreshWithRefreshingBlock:^{
        weakSelf.currentPageNumber = 1;
        [weakSelf netRequestWithDictionary:@{@"page_num":[WXYZ_UtilsHelper formatStringWithInteger:weakSelf.currentPageNumber]}];
    }];
    
    [self.mainTableView addFooterRefreshWithRefreshingBlock:^{
        weakSelf.currentPageNumber ++;
        [weakSelf netRequestWithDictionary:@{@"page_num":[WXYZ_UtilsHelper formatStringWithInteger:weakSelf.currentPageNumber]}];
    }];
    
    [self setEmptyOnView:self.mainTableView title:@"暂无数据" centerY:200 tapBlock:^{}];
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
    return kHalfMargin;
}
//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kHalfMargin)];
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

- (WXYZ_ClassifyHeaderView *)headerView
{
    if (!_headerView) {
        WS(weakSelf)
        _headerView = [[WXYZ_ClassifyHeaderView alloc] init];
        _headerView.searchBoxSelectBlock = ^(NSString * _Nonnull field, NSString * _Nonnull value) {
            if ([weakSelf.oldField isEqualToString:field] && [weakSelf.oldValue isEqualToString:value]) return ;
            weakSelf.oldField = field;
            weakSelf.oldValue = value;
            weakSelf.currentPageNumber = 1;
            [weakSelf netRequestWithDictionary:@{field:value}];
        };
    }
    return _headerView;
}

- (void)netRequestWithDictionary:(NSDictionary *)parameter
{
    NSString *url = Book_Category_List;
    
    switch (self.productionType) {
        case WXYZ_ProductionTypeBook:
        {
            if (self.isMemberStore) {
                url = Book_Member_Store;
            } else {
                url = Book_Category_List;
            }
        }
            break;
        case WXYZ_ProductionTypeComic:
        {
            if (self.isMemberStore) {
                url = Comic_Member_Store;
            } else {
                url = Comic_Category_List;
            }
        }
            break;
        case WXYZ_ProductionTypeAudio:
        {
            if (self.isMemberStore) {
                url = Audio_Member_Store;
            } else {
                url = Audio_Category_Index;
            }
        }
            break;
            
        default:
            break;
    }
    
    [self.parameterDic addEntriesFromDictionary:parameter];
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:url parameters:self.parameterDic model:WXYZ_ClassifyModel.class success:^(BOOL isSuccess, WXYZ_ClassifyModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            if (weakSelf.currentPageNumber == 1) {
                [weakSelf.mainTableView showRefreshFooter];
                weakSelf.dataSourceArray = [NSMutableArray arrayWithArray:t_model.classList.list];
                weakSelf.headerView.search_box = t_model.search_box;
            } else {
                [weakSelf.dataSourceArray addObjectsFromArray:t_model.classList.list];
            }
            if (t_model.classList.total_page <= t_model.classList.current_page) {
                [weakSelf.mainTableView hideRefreshFooter];
            }
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg ?: @"请求错误"];
        }
        
        [weakSelf.mainTableView endRefreshing];
        weakSelf.needRefresh = YES;
        [weakSelf.mainTableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.needRefresh = NO;
        });
        [weakSelf.mainTableView ly_endLoading];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:@"请求错误"];
        [weakSelf.mainTableView endRefreshing];
        [weakSelf.mainTableView ly_endLoading];
    }];
}

- (void)gotoTagList {
    WXYZ_TagListViewController *vc = [[WXYZ_TagListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:true];
}

@end

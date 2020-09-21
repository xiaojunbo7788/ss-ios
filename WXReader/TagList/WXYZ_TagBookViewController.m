//
//  WXYZ_ClassifyViewController.m
//  WXReader
//
//  Created by Andrew on 2019/6/17.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_TagBookViewController.h"
#import "WXYZ_TagHeadView.h"
#import "WXYZ_ProductionListTableViewCell.h"
#import "WXYZ_PublicADStyleTableViewCell.h"
#import "WXYZ_TagListViewController.h"
#import "WXYZ_ClassifyHeaderView.h"
#import "WXYZ_SystemInfoManager.h"
#import "WXYZ_ClassifyModel.h"

@interface WXYZ_TagBookViewController () <UITableViewDelegate, UITableViewDataSource,WXYZ_TagHeadViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *parameterDic;

@property (nonatomic, strong) NSString *oldField;

@property (nonatomic, strong) NSString *oldValue;

@property (nonatomic, assign) BOOL needRefresh;
@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, copy) NSString *requestUrl;
@property (nonatomic, copy) NSDictionary *requestDic;
@property (nonatomic, strong) WXYZ_TagHeadView *headerView;
@end

@implementation WXYZ_TagBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.channelId = [NSString stringWithFormat:@"%li",WXYZ_SystemInfoManager.sexChannel];
    [self initialize];
    [self createSubviews];
    [self request:@""];

}

- (void)request:(NSString *)sort {
    //0 作者、1、标签、2、分类、3、汉化组、4、原著
      switch (self.classType) {
          case 0:
               [self setNavigationBarTitle:@"作者"];
               self.requestUrl = MyLikeAuthorList;
              self.requestDic = @{@"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber], @"page_size":@"10",@"author":self.tagTitle,@"channel_id":self.channelId,@"sort":sort};
              break;
          case 1:
                [self setNavigationBarTitle:@"标签"];
              self.requestUrl = TagBookList;
              self.requestDic = @{@"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber], @"page_size":@"10",@"tab":self.tagTitle,@"channel_id":self.channelId,@"sort":sort};
              break;
          case 2:
                [self setNavigationBarTitle:@"分类"];
              self.requestUrl = ClassTagList;
               self.requestDic = @{@"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber], @"page_size":@"10",@"tags":self.tagTitle,@"channel_id":self.channelId,@"sort":sort};
              
              break;
          case 3:
               [self setNavigationBarTitle:@"汉化组"];
               self.requestUrl = MyLikeSiniciList;
               self.requestDic = @{@"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber], @"page_size":@"10",@"sinici":self.tagTitle,@"channel_id":self.channelId,@"sort":sort};
              break;
          case 4:
               [self setNavigationBarTitle:@"原著"];
               self.requestUrl = MyLikeOriginalList;
               self.requestDic = @{@"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber], @"page_size":@"10",@"original":self.tagTitle,@"channel_id":self.channelId,@"sort":sort};
              break;
              
          default:
              break;
      }
      
      [self netRequestWithDictionary:self.requestDic];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Hidden_Tabbar object:nil];
    [self setStatusBarDefaultStyle];
}

- (void)initialize
{
    self.needRefresh = YES;
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
    
    self.headerView = [[WXYZ_TagHeadView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 91)];
    self.headerView.delegate = self;
    if (self.tagTitle != nil) {
        self.headerView.titleView.text = [NSString stringWithFormat:@"  %@  ",self.tagTitle];
    } else {
        self.headerView.titleView.text = [NSString stringWithFormat:@"  %@  ",@"未知"];
    }
    self.mainTableView.tableHeaderView = self.headerView;
    
    WS(weakSelf)
    [self.mainTableView addHeaderRefreshWithRefreshingBlock:^{
        weakSelf.currentPageNumber = 1;
        [weakSelf netRequestWithDictionary:weakSelf.requestDic];
    }];
    
    [self.mainTableView addFooterRefreshWithRefreshingBlock:^{
        weakSelf.currentPageNumber ++;
        [weakSelf netRequestWithDictionary:weakSelf.requestDic];
    }];
    
    [self setEmptyOnView:self.mainTableView title:@"暂无数据" centerY:200 tapBlock:^{}];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
//    switch (self.productionType) {
//#if WX_Enable_Book
//        case WXYZ_ProductionTypeBook:
//        {
//            WXYZ_BookMallDetailViewController *vc = [[WXYZ_BookMallDetailViewController alloc] init];
//            vc.book_id = t_model.production_id;
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//            break;
//#endif
//
//#if WX_Enable_Comic
//        case WXYZ_ProductionTypeComic:
//        {
//            WXYZ_ComicMallDetailViewController *vc = [[WXYZ_ComicMallDetailViewController alloc] init];
//            vc.comic_id = t_model.production_id;
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//            break;
//#endif
//        default:
//            break;
//    }
    WXYZ_ComicMallDetailViewController *vc = [[WXYZ_ComicMallDetailViewController alloc] init];
    vc.comic_id = t_model.production_id;
    [self.navigationController pushViewController:vc animated:YES];
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


- (void)netRequestWithDictionary:(NSDictionary *)parameter
{

    [self.parameterDic addEntriesFromDictionary:parameter];
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:self.requestUrl parameters:self.parameterDic model:nil success:^(BOOL isSuccess,  id _Nullable d_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
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

#pragma mark - WXYZ_TagHeadViewDelegate
- (void)selectSort:(NSString *)sort {
    self.currentPageNumber = 1;
    [self request:sort];
}

@end

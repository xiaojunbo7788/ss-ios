//
//  WXYZ_HistoryPageViewController.m
//  WXReader
//
//  Created by Andrew on 2019/6/18.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_HistoryPageViewController.h"
#if WX_Enable_Book
    #import "WXYZ_BookReaderViewController.h"
#endif

#if WX_Enable_Comic
    #import "WXYZ_ComicReaderViewController2.h"
#endif

#if WX_Enable_Audio
    #import "WXYZ_AudioSoundPlayPageViewController.h"
    #import "WXYZ_Player.h"
#endif

#import "WXYZ_HistoryTableViewCell.h"
#import "WXYZ_PublicADStyleTableViewCell.h"

#import "WXYZ_ProductionReadRecordManager.h"
#import "WXYZ_ProductionCollectionManager.h"

@interface WXYZ_HistoryPageViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) BOOL needRefresh;

@end

@implementation WXYZ_HistoryPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarDefaultStyle];
    [self netRequest];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 每次进入历史记录时删除目前未删除干净的记录
    NSString *url = @"";
    switch (self.productionType) {
        case WXYZ_ProductionTypeBook:
            url = Book_Readlog_Delete;
            break;
        case WXYZ_ProductionTypeComic:
            url = Comic_Readlog_Delete;
            break;
        case WXYZ_ProductionTypeAudio:
            url = Audio_Readlog_Delete;
            break;
        default:
            break;
    }
    WS(weakSelf)
    for (NSString *log_id in [self log_idArr]) {
        [WXYZ_NetworkRequestManger POST:url parameters:@{@"log_id":log_id} model:nil success:^(BOOL isSuccess, id _Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
            if (!isSuccess) {
                // 删除失败，保存删除的log_id下次删除
                [weakSelf addLog_id:log_id];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [weakSelf addLog_id:log_id];
        }];
    }
}

- (void)initialize
{
    self.needRefresh = YES;
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
        [self setEmptyOnView:self.mainTableView title:@"暂无历史记录" buttonTitle:@"" tapBlock:^{
            
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
    
    if (productionModel.ad_type == 0) {
        WS(weakSelf)
        WXYZ_HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_HistoryTableViewCell"];
        
        if (!cell) {
            cell = [[WXYZ_HistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_HistoryTableViewCell"];
        }
        cell.productionType = self.productionType;
        cell.productionModel = productionModel;
        cell.hiddenEndLine = self.dataSourceArray.count - 1 == indexPath.row;
        cell.continueReadBlock = ^(NSInteger book_id) {
            switch (self.productionType) {
#if WX_Enable_Book
                case WXYZ_ProductionTypeBook:
                {
                    WXYZ_BookReaderViewController *vc = [[WXYZ_BookReaderViewController alloc] init];
                    [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] moveCollectionToTopWithProductionModel:productionModel];
                    vc.book_id = book_id;
                    [weakSelf.navigationController pushViewController:vc animated:NO];
                }
                    break;
#endif
                    
#if WX_Enable_Comic
                case WXYZ_ProductionTypeComic:
                {
                    WXYZ_ComicReaderViewController2 *vc = [[WXYZ_ComicReaderViewController2 alloc] init];
                    [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] moveCollectionToTopWithProductionModel:productionModel];
                    vc.comicProductionModel = productionModel;
                    vc.chapter_id = [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] getReadingRecordChapter_idWithProduction_id:productionModel.production_id];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
#endif
                    
#if WX_Enable_Audio
                case WXYZ_ProductionTypeAudio:
                {
                    if ([WXYZ_Player sharedPlayer].state != WXYZ_PlayPagePlayerStatePlaying) {
                        [[WXYZ_Player sharedPlayer] play];
                    }
                    
                    WXYZ_AudioSoundPlayPageViewController *vc = [[WXYZ_AudioSoundPlayPageViewController alloc] init];
                    [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] moveCollectionToTopWithProductionModel:productionModel];
                    [vc loadDataWithAudio_id:productionModel.production_id chapter_id:0];
                    WXYZ_NavigationController *nav = [[WXYZ_NavigationController alloc] initWithRootViewController:vc];
                    [[WXYZ_ViewHelper getWindowRootController] presentViewController:nav animated:YES completion:nil];
                }
                    break;
#endif
                    
                default:
                    break;
            }
        };
        
        cell.hiddenEndLine = (self.dataSourceArray.count - 1 == indexPath.row);
        if (indexPath.row + 1 < self.dataSourceArray.count) {
             WXYZ_ProductionModel *t_model = [self.dataSourceArray objectOrNilAtIndex:indexPath.row + 1];
            cell.hiddenEndLine = t_model.advert_id != 0;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    } else {
        WXYZ_PublicADStyleTableViewCell *cell = [self.adCellDictionary objectForKey:[WXYZ_UtilsHelper formatStringWithInteger:indexPath.row]];
        if (!cell) {
            static NSString *cellName = @"WXYZ_PublicADStyleTableViewCell";
            cell = [[WXYZ_PublicADStyleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            [cell setAdModel:productionModel refresh:self.needRefresh];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionModel *productionModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    
    if (productionModel.ad_type > 0) {
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self deleteReadlogWithIndexPath:indexPath];
}

- (void)netRequest
{
    if ([WXYZ_NetworkReachabilityManager networkingStatus] == NO) {
        [self.mainTableView ly_showEmptyView];
        return;
    }
    
    NSString *url = @"";
    switch (self.productionType) {
        case WXYZ_ProductionTypeBook:
            url = Book_Read_Log_List;
            break;
        case WXYZ_ProductionTypeComic:
            url = Comic_Read_Log_List;
            break;
        case WXYZ_ProductionTypeAudio:
            url = Audio_Read_Log_List;
            break;
            
        default:
            break;
    }
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:url parameters:@{@"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber]} model:WXYZ_ProductionListModel.class success:^(BOOL isSuccess, WXYZ_ProductionListModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
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

- (void)deleteReadlogWithIndexPath:(NSIndexPath *)indexPath {
    // 获取被删除的cell
    NSString *log_id;
    NSMutableArray<NSIndexPath *> *pathArr = [NSMutableArray array];
    if (indexPath) {
        [pathArr addObject:indexPath];
        WXYZ_ProductionModel *productionModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
        log_id = [WXYZ_UtilsHelper formatStringWithInteger:productionModel.log_id];
        [self.dataSourceArray removeObjectAtIndex:indexPath.row];
    } else {
        for (NSInteger i = 0; i < self.dataSourceArray.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [pathArr addObject:indexPath];
        }
        [self.dataSourceArray removeAllObjects];
        log_id = @"all";
    }
    
    // 删除并更新页面
    if (@available(iOS 11.0, *)) {
        [self.mainTableView performBatchUpdates:^{
            [self.mainTableView deleteRowsAtIndexPaths:pathArr withRowAnimation:UITableViewRowAnimationLeft];
        } completion:^(BOOL finished) {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:finished ? @"清除成功" : @"删除失败"];
            [self.mainTableView ly_endLoading];
        }];
    } else {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"清除成功"];
            [self.mainTableView ly_endLoading];
        }];
        [self.mainTableView beginUpdates];
        [self.mainTableView deleteRowsAtIndexPaths:pathArr withRowAnimation:UITableViewRowAnimationLeft];
        [self.mainTableView endUpdates];
        [CATransaction commit];
    }
    
    
    
    NSString *url = @"";
    switch (self.productionType) {
        case WXYZ_ProductionTypeBook:
            url = Book_Readlog_Delete;
            break;
        case WXYZ_ProductionTypeComic:
            url = Comic_Readlog_Delete;
            break;
        case WXYZ_ProductionTypeAudio:
            url = Audio_Readlog_Delete;
            break;
            
        default:
            break;
    }
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:url parameters:@{@"log_id":log_id} model:nil success:^(BOOL isSuccess, id _Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (!isSuccess) {
            // 删除失败，保存删除的log_id下次删除
            [weakSelf addLog_id:log_id];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf addLog_id:log_id];
    }];
}

- (void)stepClear {
    if (self.dataSourceArray.count == 0) return;
    
    WXYZ_AlertView *alert = [[WXYZ_AlertView alloc] init];
    alert.alertViewDetailContent = @"是否清除历史记录";
    alert.confirmButtonClickBlock = ^{
        [self deleteReadlogWithIndexPath:nil];
    };
    [alert showAlertView];
}

- (void)addLog_id:(NSString *)log_id {
    NSString *filePath =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *fullPath = [filePath stringByAppendingPathComponent:@"listory.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fullPath contents:nil attributes:nil];
    }
    
    NSArray<NSString *> *arr = [NSArray arrayWithContentsOfFile:fullPath];
    if (!arr) arr = [NSArray array];
    NSMutableSet<NSString *> *logSet = [NSMutableSet setWithArray:arr];
    
    if ([log_id isEqualToString:@"all"]) {
        for (WXYZ_ProductionModel *t_model in self.dataSourceArray) {
            [logSet addObject:[NSString stringWithFormat:@"%zd", t_model.log_id]];
        }
    } else {
        [logSet addObject:log_id];
    }
    
    arr = logSet.allObjects;
    
    [arr writeToFile:fullPath atomically:YES];
}

- (NSArray<NSString *> *)log_idArr {
    NSString *filePath =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *fullPath = [filePath stringByAppendingPathComponent:@"listory.plist"];
    
    return [NSArray arrayWithContentsOfFile:fullPath];
}

@end

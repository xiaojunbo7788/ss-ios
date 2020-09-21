//
//  WXYZ_BookDirectoryViewController.m
//  WXReader
//
//  Created by Andrew on 2018/6/11.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BookDirectoryViewController.h"
#import "WXYZ_BookReaderViewController.h"

#import "WXYZ_BookDirectoryTableViewCell.h"

#import "WXYZ_ReaderSettingHelper.h"
#import "WXYZ_ReaderBookManager.h"
#import "WXYZ_ProductionReadRecordManager.h"
#import "WXYZ_CatalogModel.h"

@interface WXYZ_BookDirectoryViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
{
    BOOL isScroll;//进入目录滚动到指定位置,只进行一次
    BOOL first;// 第一次进入目录
}

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, assign) BOOL firstRequest;

/// 目录是不是逆序
@property (nonatomic, assign) BOOL isReverseOrder;

/// 已购买章节
@property (nonatomic, strong) NSMutableArray<NSString *> *purchasedChapters;

@property (nonatomic, strong) NSMutableArray<WXYZ_CatalogListModel *> *dataSourceArray;

@end

@implementation WXYZ_BookDirectoryViewController

@synthesize dataSourceArray = _dataSourceArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
    if (self.dataSourceArray.count == 0) {
        [self requestCatalogWithDown:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSInteger index = 0;
    if (self.dataSourceArray.count > 0) {
        NSInteger chapter_id = [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] getReadingRecordChapter_idWithProduction_id:[self.book_id integerValue]];
        for (WXYZ_CatalogListModel *t_model in self.dataSourceArray) {
            if ([t_model.chapter_id integerValue] == chapter_id) {
                break;
            }
            index++;
        }
        if (index == self.dataSourceArray.count) {// 如果没有阅读记录
            index = 0;
        }
    }
    [self.mainTableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.dataSourceArray.count > 0) {
            [self.mainTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        }
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    first = NO;
}

- (void)initialize {
    self.dataSourceArray = [NSMutableArray array];
    self.purchasedChapters = [NSMutableArray array];
    first = YES;
    
    [self hiddenNavigationBar:YES];
    
    if (self.bookModel) {
        self.book_id = [WXYZ_UtilsHelper formatStringWithInteger:self.bookModel.production_id];
    }
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paySuccess:) name:Notification_Production_Pay_Success object:nil];
    
    // 获取本地目录列表
    if (![WXYZ_NetworkReachabilityManager networkingStatus]) {
        NSString *path =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        path = [path stringByAppendingPathComponent:[WXYZ_UtilsHelper stringToMD5:@"book_catalog"]];
        NSString *catalogName = [NSString stringWithFormat:@"%@_%@", self.book_id, @"catalog"];
        NSString *fullPath = [path stringByAppendingFormat:@"/%@.plist", [WXYZ_UtilsHelper stringToMD5:catalogName]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:fullPath];
            WXYZ_CatalogModel *catalog = [WXYZ_CatalogModel modelWithDictionary:dict];
            self.dataSourceArray = [catalog.list mutableCopy];
        } else {
            self.dataSourceArray = [self.bookModel.list mutableCopy];
        }
    } else {
        if (self.bookModel.list.count != 0) {
            self.dataSourceArray = [self.bookModel.list mutableCopy];
        }
    }
    
    [self setEmptyOnView:self.mainTableView title:@"暂无目录列表" buttonTitle:@"" tapBlock:^{
        
    }];
}

- (void)paySuccess:(NSNotification *)noti {
    NSArray<NSString *> *t_arr = noti.object;
    [self.purchasedChapters addObjectsFromArray:t_arr];
}

- (void)createSubviews {
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.showsVerticalScrollIndicator = YES;
    self.mainTableView.showsHorizontalScrollIndicator = NO;
    [self.mainTableView registerClass:WXYZ_BookDirectoryTableViewCell.class forCellReuseIdentifier:@"WXBookDirectoryTableViewCell"];
    [self.view addSubview:self.mainTableView];
    self.mainTableView.contentInset = UIEdgeInsetsMake(0, 0, PUB_TABBAR_OFFSET, 0);
    
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    WS(weakSelf)
    [self.mainTableView addHeaderRefreshWithRefreshingBlock:^{
        [weakSelf requestCatalogWithDown:NO];
    }];

    [self.mainTableView addFooterRefreshWithRefreshingBlock:^{
        [weakSelf requestCatalogWithDown:YES];
    }];
    
    WXYZ_CatalogListModel *list = self.dataSourceArray.firstObject;
    if ([list.previou_chapter isEqualToString:@"0"]) {
        [self.mainTableView hideRefreshHeader];
    }

    list = self.dataSourceArray.lastObject;
    if ([list.next_chapter isEqualToString:@"0"]) {
        [self.mainTableView hideRefreshFooter];
    }

    if (self.dataSourceArray.count > 0) {
        [self.mainTableView ly_hideEmptyView];
    } else {
        [self.mainTableView ly_showEmptyView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXYZ_BookDirectoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXBookDirectoryTableViewCell" forIndexPath:indexPath];
    
    WXYZ_CatalogListModel *t_model = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    cell.hiddenEndLine = (indexPath.row == self.dataSourceArray.count - 1);
    if ([self.purchasedChapters containsObject:t_model.chapter_id]) {
        t_model.preview = NO;
        [self.purchasedChapters removeObject:t_model.chapter_id];
    }
    cell.chapterModel = t_model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WS(weakSelf)
    self.selectedIndexPath = indexPath;
    NSInteger chapterIndex = indexPath.row;
//    if (self.isReverseOrder) {
//        chapterIndex = self.dataSourceArray.count - 1 - chapterIndex;
//    }
    WXYZ_CatalogListModel *t_model = self.dataSourceArray[chapterIndex];
    [[WXYZ_ReaderSettingHelper sharedManager] setLocationMemoryOfChapterIndex:t_model.display_order pagerIndex:0 book_id:[self.book_id integerValue]];
    [WXYZ_ReaderBookManager sharedManager].currentChapterIndex = t_model.display_order;
    [WXYZ_ReaderBookManager sharedManager].currentPagerIndex = 0;
        
    if (self.isReader) {
        UIViewController *vc = nil;
        for (UIViewController *obj in self.navigationController.viewControllers) {
            if ([obj isKindOfClass:WXYZ_BookReaderViewController.class]) {
                vc = obj;
                break;
            }
        }
        if (vc) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Retry_Chapter object:nil];
            [self.navigationController popToViewController:vc animated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        if (self.isBookDetailPush) {
            WXYZ_BookReaderViewController *vc = [[WXYZ_BookReaderViewController alloc] init];
            vc.book_id = [self.book_id integerValue];
            vc.bookModel = self.bookModel;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Retry_Chapter object:nil];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    });
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHalfMargin;
}
//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)orderChapter:(UIButton *)sender {
    if (!self.isReverseOrder) {
        [sender setImage:[UIImage imageNamed:@"book_directory_reverse"] forState:UIControlStateNormal];
        self.isReverseOrder = YES;
    } else {
        [sender setImage:[UIImage imageNamed:@"book_directory_order"] forState:UIControlStateNormal];
        self.isReverseOrder = NO;
    }
    
    if (![WXYZ_NetworkReachabilityManager networkingStatus]) {
        self.dataSourceArray = [[[self.dataSourceArray reverseObjectEnumerator] allObjects] mutableCopy];
        [self.mainTableView reloadData];
        return;
    }
    
    NSDictionary *params = @{
        @"book_id" : self.book_id,
        @"order_by" : self.isReverseOrder ? @(2) : @(1)
    };
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Book_New_Catalog parameters:params model:WXYZ_CatalogModel.class success:^(BOOL isSuccess, WXYZ_CatalogModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            [weakSelf.dataSourceArray removeAllObjects];
            [weakSelf.dataSourceArray addObjectsFromArray:t_model.list];
            
            [weakSelf.mainTableView reloadData];

            if (@available(iOS 11.0, *)) {
                [weakSelf.mainTableView performBatchUpdates:nil completion:^(BOOL finished) {
                    [weakSelf.mainTableView scrollToTopAnimated:NO];
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.mainTableView scrollToTopAnimated:NO];
                });
            }
            
            [weakSelf.mainTableView ly_endLoading];
            [weakSelf.mainTableView hideRefreshHeader];
            [weakSelf.mainTableView showRefreshFooter];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf.mainTableView ly_endLoading];
    }];
}

// isDown：YES 往下翻页，NO 往上翻页
- (void)requestCatalogWithDown:(BOOL)isDown {
    if (![WXYZ_NetworkReachabilityManager networkingStatus]) {
        [self.mainTableView endRefreshing];
        return;
    }
    
    // 判断目录是不是倒序展示
    if (self.isReverseOrder) {
        isDown = !isDown;
    }
    // 章节id
    NSString *chapter_id;
    // 翻页方式
    NSString *scrollType = isDown ? @"1" : @"2";
    
    if (first) {// 判断是不是首次进入目录页面
        if (self.dataSourceArray.count > 0) {
            NSArray<WXYZ_CatalogListModel *> *list = self.dataSourceArray;
            chapter_id = list.lastObject.next_chapter;
            if ([chapter_id isEqualToString:@"0"]) {
                [self.mainTableView endRefreshing];
                [self.mainTableView hideRefreshFooter];
                return;
            }
        } else {
            chapter_id = [NSString stringWithFormat:@"%zd", [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] getReadingRecordChapter_idWithProduction_id:[self.book_id integerValue]]];
        }
        [self requestCatalogWithScrollType:scrollType chapter_id:chapter_id];
        return;
    }
    
    // 获取正确的章节id
    NSArray<WXYZ_CatalogListModel *> *list = self.dataSourceArray;
    if (isDown && self.isReverseOrder) {// 往下翻页，倒序
        chapter_id = list.firstObject.next_chapter;
    }
    if (isDown && !self.isReverseOrder) {// 往下翻页，正序
        chapter_id = list.lastObject.next_chapter;
    }
    
    if (!isDown && self.isReverseOrder) {// 往上翻页，倒序
        chapter_id = list.lastObject.previou_chapter;
    }
    
    if (!isDown && !self.isReverseOrder) {// 往上翻页，正序
        chapter_id = list.firstObject.previou_chapter;
    }
    
    if ([chapter_id isEqualToString:@"0"]) {
        [self.mainTableView endRefreshing];
        if (isDown) {
            [self.mainTableView hideRefreshFooter];
        } else {
            [self.mainTableView hideRefreshHeader];
        }
        return;
    }
    
    [self requestCatalogWithScrollType:scrollType chapter_id:chapter_id];
}

// scrollType 1：向下加载；2：向上加载
- (void)requestCatalogWithScrollType:(NSString *)scrollType chapter_id:(NSString *)chapter_id {
    if (!self.book_id || !chapter_id) {
        if (self.dataSourceArray.count > 0) {
            [self.mainTableView ly_hideEmptyView];
        } else {
            [self.mainTableView ly_showEmptyView];
        }
        [self.mainTableView endRefreshing];
        return;
    }
    NSDictionary *params = @{
        @"book_id" : self.book_id,
        @"chapter_id" : chapter_id,
        @"scroll_type" : scrollType,
    };
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Book_New_Catalog parameters:params model:WXYZ_CatalogModel.class success:^(BOOL isSuccess, WXYZ_CatalogModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        [weakSelf.mainTableView endRefreshing];
        if (isSuccess) {
            BOOL isDown = [scrollType isEqualToString:@"1"];
            if (isDown && t_model.list.count == 1 && weakSelf.dataSourceArray.count == 0) {
                [weakSelf requestCatalogWithScrollType:@"2" chapter_id:chapter_id];
                return;
            }
            [weakSelf updateTableViewWithList:t_model.list isDown:isDown firstRequest:weakSelf.firstRequest];
            weakSelf.firstRequest = YES;
            // 隐藏上拉/下拉刷新控件
            if (isDown && self.isReverseOrder) {// 往下翻页，倒序
                if ([t_model.list.lastObject.next_chapter isEqualToString:@"0"]) {
                    [weakSelf.mainTableView hideRefreshHeader];
                }
            }
            
            if (isDown && !self.isReverseOrder) {// 往下翻页，正序
                if ([t_model.list.lastObject.next_chapter isEqualToString:@"0"]) {
                    [weakSelf.mainTableView hideRefreshFooter];
                }
            }
            
            if (!isDown && self.isReverseOrder) {// 往上翻页，倒序
                if ([t_model.list.firstObject.previou_chapter isEqualToString:@"0"]) {
                    [weakSelf.mainTableView hideRefreshFooter];
                }
            }
            
            if (!isDown && !self.isReverseOrder) {// 往上翻页，正序
                if ([t_model.list.firstObject.previou_chapter isEqualToString:@"0"]) {
                    [weakSelf.mainTableView hideRefreshHeader];
                }
            }
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        }
        if (weakSelf.dataSourceArray.count > 0) {
            [weakSelf.mainTableView ly_hideEmptyView];
        } else {
            [weakSelf.mainTableView ly_showEmptyView];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
        [weakSelf.mainTableView endRefreshing];
        if (weakSelf.dataSourceArray.count > 0) {
            [weakSelf.mainTableView ly_hideEmptyView];
        } else {
            [weakSelf.mainTableView ly_showEmptyView];
        }
    }];
}

// 更新tableView
- (void)updateTableViewWithList:(NSArray<WXYZ_CatalogListModel *> *)list isDown:(BOOL)isDown firstRequest:(BOOL)firstRequest {
    NSMutableArray<NSIndexPath *> *pathArr = [NSMutableArray array];
    // 刷新前的数据个数
    NSUInteger oldCount = self.dataSourceArray.count;
    
    // 填充数据
    if (isDown && self.isReverseOrder) {// 往下翻页，倒序
        list = list.reverseObjectEnumerator.allObjects;
        [self.dataSourceArray insertObjects:list atIndex:0];
        for (NSUInteger i = 0; i < list.count; i++) {
            [pathArr addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    
    if (isDown && !self.isReverseOrder) {// 往下翻页，正序
        [self.dataSourceArray addObjectsFromArray:list];
        for (NSUInteger i = oldCount; i < self.dataSourceArray.count; i++) {
            [pathArr addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    
    if (!isDown && self.isReverseOrder) {// 往上翻页，倒序
        list = list.reverseObjectEnumerator.allObjects;
        [self.dataSourceArray addObjectsFromArray:list];
        for (NSUInteger i = oldCount; i < self.dataSourceArray.count; i++) {
            [pathArr addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    
    if (!isDown && !self.isReverseOrder) {// 往上翻页，正序
        [self.dataSourceArray insertObjects:list atIndex:0];
        for (NSUInteger i = 0; i < list.count; i++) {
            [pathArr addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    
    self.bookModel.list = self.dataSourceArray;
    
    // 判断是不是第一次刷新
    if (self.mainTableView.visibleCells.count == 0) {
        [self.mainTableView reloadData];
        NSInteger chapter_id = [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] getReadingRecordChapter_idWithProduction_id:[self.book_id integerValue]];
        
        NSInteger __block index = -1;
        [self.dataSourceArray enumerateObjectsUsingBlock:^(WXYZ_CatalogListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.chapter_id integerValue] == chapter_id) {
                index = idx;
                *stop = YES;
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (index != -1) {
                [self.mainTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
            }
        });
        if (isDown == NO) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mainTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSourceArray.count - 2 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionBottom];
            });
        }
        return;
    }
    
    
    [UIView performWithoutAnimation:^{
        [self.mainTableView insertRowsAtIndexPaths:pathArr withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    if (isDown && self.isReverseOrder) {// 往下翻页，倒序
        [self.mainTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:list.count inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
    
    if (isDown && !self.isReverseOrder) {// 往下翻页，正序
        [self.mainTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:oldCount inSection:0] animated:NO scrollPosition:UITableViewScrollPositionBottom];
    }
    
    if (!isDown && self.isReverseOrder) {// 往上翻页，倒序
        [self.mainTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:oldCount inSection:0] animated:NO scrollPosition:UITableViewScrollPositionBottom];
    }
    
    if (!isDown && !self.isReverseOrder) {// 往上翻页，正序
        [self.mainTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:list.count inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

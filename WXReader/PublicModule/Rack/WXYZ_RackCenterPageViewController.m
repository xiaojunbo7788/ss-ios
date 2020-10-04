//
//  WXYZ_RackCenterPageViewController.m
//  WXReader
//
//  Created by Andrew on 2020/7/1.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_RackCenterPageViewController.h"
#if WX_Enable_Book
#import "WXYZ_BookReaderViewController.h"
#endif

#if WX_Enable_Comic
#import "WXYZ_ComicReaderViewController2.h"
#endif

#if WX_Enable_Audio
#import "WXYZ_AudioSoundPlayPageViewController.h"
#endif
#import "WXYZ_AnnouncementInfoViewController.h"
#import "WXYZ_TaskViewController.h"

#import "WXYZ_RackCenterCollectionViewCell.h"
#import "WXYZ_RackCenterAddMoreCollectionViewCell.h"
#import "WXYZ_RackCenterHeaderView.h"

#import "WXYZ_ProductionCollectionManager.h"
#import "WXYZ_ProductionReadRecordManager.h"
#import "NSObject+Observer.h"

@interface WXYZ_RackCenterPageViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    BOOL editingProduction;
}

@property (nonatomic, strong) WXYZ_RackCenterHeaderView *headerView;

@property (nonatomic, strong) UIView *toolBarView;

@property (nonatomic, strong) UIButton *toolBarDeleteButton;

@property (nonatomic, strong) UIButton *toolBarCheckAllButton;

@property (nonatomic, strong) WXYZ_RackCenterModel *rackCenterModel;

@property (nonatomic, strong) NSMutableArray *deleteSourceArray;

// 角标记录
@property (nonatomic, strong) NSMutableDictionary *productionCornerBadges;


@end

@implementation WXYZ_RackCenterPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setStatusBarDefaultStyle];
    
    [self localSourceRequest];
    
    [self netRequest];
}

- (void)initialize
{
    [self hiddenNavigationBar:YES];
    self.view.backgroundColor = kWhiteColor;
    self.deleteSourceArray = [NSMutableArray array];
    
    // 签到加入书架
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localSourceRequest) name:Notification_Reload_Rack_Production object:nil];
}

- (void)createSubviews
{
    self.mainCollectionViewFlowLayout.minimumLineSpacing = kMargin;
    self.mainCollectionViewFlowLayout.minimumInteritemSpacing = 0;
    self.mainCollectionViewFlowLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, Rack_Header_Height);
    self.mainCollectionViewFlowLayout.footerReferenceSize = CGSizeMake(SCREEN_WIDTH, kHalfMargin);
    self.mainCollectionViewFlowLayout.itemSize = CGSizeMake(BOOK_WIDTH, BOOK_HEIGHT + BOOK_CELL_TITLE_HEIGHT / 2);
    self.mainCollectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(0, kHalfMargin, 0, kHalfMargin);
    
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.dataSource = self;
    [self.mainCollectionView registerClass:[WXYZ_RackCenterCollectionViewCell class] forCellWithReuseIdentifier:@"WXYZ_RackCenterCollectionViewCell"];
    [self.mainCollectionView registerClass:[WXYZ_RackCenterAddMoreCollectionViewCell class] forCellWithReuseIdentifier:@"WXYZ_RackCenterAddMoreCollectionViewCell"];
    [self.mainCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self.mainCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    [self.view addSubview:self.mainCollectionView];
    
    [self.mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_height).with.offset(- PUB_NAVBAR_HEIGHT - PUB_TABBAR_HEIGHT);
    }];
    
    UILongPressGestureRecognizer *editLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startEdited:)];
    editLongPressGesture.minimumPressDuration = 1.0f;
    editLongPressGesture.numberOfTouchesRequired = 1;
    [self.mainCollectionView addGestureRecognizer:editLongPressGesture];
    
    WS(weakSelf)
    [self.mainCollectionView addHeaderRefreshWithRefreshingBlock:^{
        [weakSelf localSourceRequest];
        [weakSelf netRequest];
    }];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (editingProduction) {
        return self.dataSourceArray.count;
    }
    return self.dataSourceArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataSourceArray.count == indexPath.row && !editingProduction) {
        static NSString *CellIdentifier = @"WXYZ_RackCenterAddMoreCollectionViewCell";
        WXYZ_RackCenterAddMoreCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    } else {
        static NSString *CellIdentifier = @"WXYZ_RackCenterCollectionViewCell";
        WXYZ_RackCenterCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        WXYZ_ProductionModel *t_bookModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
        cell.productionModel = t_bookModel;
        cell.badgeNum = [WXYZ_UtilsHelper formatStringWithInteger:[[self.productionCornerBadges objectForKey:[WXYZ_UtilsHelper formatStringWithInteger:t_bookModel.production_id]] total_chapters]];
        cell.bookSeleced = NO;
        cell.startEditing = editingProduction;
        for (WXYZ_ProductionModel *t_model in self.deleteSourceArray) {
            if (t_model.production_id == t_bookModel.production_id) {
                cell.bookSeleced = YES;
            }
        }
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *collectionHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        collectionHeaderView.backgroundColor = [UIColor clearColor];
        if (self.rackCenterModel && self.rackCenterModel.recommendList.count > 0 && !editingProduction) {
            self.headerView.rackModel = self.rackCenterModel;
            [self showHeaderViewWithAnimated:NO];
        } else if (self.rackCenterModel) {
            [self hiddenHeaderViewWithAnimated:NO];
        }
        [collectionHeaderView addSubview:self.headerView];
        return collectionHeaderView;
    } else {
        UICollectionReusableView *collectionFooterView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        return collectionFooterView;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataSourceArray.count == indexPath.row && !editingProduction) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Change_Tabbar_Index object:@"1"];
        switch (self.productionType) {
#if WX_Enable_Book
            case WXYZ_ProductionTypeBook:
                [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Rack_JumpToMallCenter object:@"book"];
                break;
#endif
                
#if WX_Enable_Comic
            case WXYZ_ProductionTypeComic:
                [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Rack_JumpToMallCenter object:@"comic"];
                break;
#endif
                
#if WX_Enable_Audio
            case WXYZ_ProductionTypeAudio:
                [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Rack_JumpToMallCenter object:@"audio"];
                break;
#endif
            default:
                break;
        }
        
    } else {
        WXYZ_RackCenterCollectionViewCell *cell = (WXYZ_RackCenterCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        WXYZ_ProductionModel *productionModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
        
        if (!editingProduction) {
            
            [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:self.productionType] moveCollectionToTopWithProductionModel:productionModel];
            
            switch (self.productionType) {
#if WX_Enable_Book
                case WXYZ_ProductionTypeBook:
                {
                    if (self.pushToReaderViewControllerBlock) {
                        self.pushToReaderViewControllerBlock(cell.bookImageView, productionModel);
                    }
                }
                    break;
#endif
                    
#if WX_Enable_Comic
                case WXYZ_ProductionTypeComic:
                {
                    WXYZ_ComicReaderViewController2 *vc = [[WXYZ_ComicReaderViewController2 alloc] init];
                    vc.comicProductionModel = productionModel;
                    vc.chapter_id = [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] getReadingRecordChapter_idWithProduction_id:productionModel.production_id];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
#endif
                    
#if WX_Enable_Audio
                case WXYZ_ProductionTypeAudio:
                {
                    WXYZ_AudioSoundPlayPageViewController *vc = [[WXYZ_AudioSoundPlayPageViewController alloc] init];
                    [vc loadDataWithAudio_id:productionModel.production_id chapter_id:0];
                    WXYZ_NavigationController *nav = [[WXYZ_NavigationController alloc] initWithRootViewController:vc];
                    [[WXYZ_ViewHelper getWindowRootController] presentViewController:nav animated:YES completion:nil];
                }
                    break;
#endif
                default:
                    break;
            }
            
            // 读书任务请求
            [WXYZ_TaskViewController taskReadRequestWithProduction_id:productionModel.production_id];

            // 如果有更新则更新本地数据源
            if ([cell.badgeNum integerValue] > 0) {
                WXYZ_ProductionModel *t_model = [self.productionCornerBadges objectForKey:[WXYZ_UtilsHelper formatStringWithInteger:productionModel.production_id]];
                if (t_model) {
                    [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:self.productionType] modificationCollectionWithProductionModel:t_model];
                }
            }
            return;
        }
        
        if (cell.bookSeleced) {
            cell.bookSeleced = NO;
            [self.deleteSourceArray removeObject:productionModel];
        } else {
            cell.bookSeleced = YES;
            [self.deleteSourceArray addObject:productionModel];
        }
        
        [self reloadToolBarState];
    }
}

#pragma mark - 点击事件

- (void)showHeaderViewWithAnimated:(BOOL)animated
{
    if (self.rackCenterModel.recommendList.count == 0) return ;
    
    [self.mainCollectionView showRefreshHeader];
    
    [UIView animateWithDuration:animated?kAnimatedDuration:0.0f animations:^{
        if (self.rackCenterModel.announcement.count > 0) {
            self.headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, Rack_Header_Height);
            self.mainCollectionViewFlowLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, Rack_Header_Height);
        } else {
            self.headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, Rack_Header_Height_NoRecommend);
            self.mainCollectionViewFlowLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, Rack_Header_Height_NoRecommend);
        }
        [self.mainCollectionView setCollectionViewLayout:self.mainCollectionViewFlowLayout animated:animated];
    }];
}

- (void)hiddenHeaderViewWithAnimated:(BOOL)animated
{
    [self.mainCollectionView hideRefreshHeader];
    
    [UIView animateWithDuration:animated?kAnimatedDuration:0.0f animations:^{
        self.headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
        self.mainCollectionViewFlowLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 10);
        [self.mainCollectionView setCollectionViewLayout:self.mainCollectionViewFlowLayout animated:animated];
    }];
}

// 工具栏点击
- (void)toolBarActionClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 11: // 取消操作
            [self endEdited];
            break;
        case 22: // 删除操作
        {
            if (self.deleteSourceArray.count == 0) {
                return;
            }
            
            NSMutableArray *t_deleteArray = [NSMutableArray array];
            for (WXYZ_ProductionModel *t_model in self.deleteSourceArray) {
                [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:self.productionType] removeCollectionWithProductionModel:t_model];
                [t_deleteArray addObject:[WXYZ_UtilsHelper formatStringWithInteger:t_model.production_id]];
            }

            NSString *url = @"";
            NSString *production_key = @"";
            switch (self.productionType) {
                case WXYZ_ProductionTypeBook:
                    url = Book_Delete_Collect;
                    production_key = @"book_id";
                    break;
                case WXYZ_ProductionTypeComic:
                    url = Comic_Collect_Delete;
                    production_key = @"comic_id";
                    break;
                case WXYZ_ProductionTypeAudio:
                    url = Audio_Collection_Delete;
                    production_key = @"audio_id";
                    break;
                    
                default:
                    break;
            }
            [WXYZ_NetworkRequestManger POST:url parameters:@{production_key:[t_deleteArray componentsJoinedByString:@","]} model:nil success:nil failure:nil];
            
            [self endEdited];
            
            [self localSourceRequest];
        }
        case 33: // 全选/取消操作
        {
            [self.deleteSourceArray removeAllObjects];
            
            if (!sender.selected) {
                self.deleteSourceArray = [self.dataSourceArray mutableCopy];
                [sender setTitle:@"取消全选" forState:UIControlStateNormal];
            } else {
                [sender setTitle:@"全选" forState:UIControlStateNormal];
                [self.deleteSourceArray removeAllObjects];
            }
            
            sender.selected = !sender.selected;
            
            [self.mainCollectionView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[WXYZ_RackCenterCollectionViewCell class]]) {
                    WXYZ_RackCenterCollectionViewCell *cell = (WXYZ_RackCenterCollectionViewCell *)obj;
                    cell.bookSeleced = sender.selected;
                }
            }];
            
            [self reloadToolBarState];
        }
            break;
        default:
            break;
    }
}

// 开启编辑状态
- (void)startEdited:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    if (editingProduction) {
        return;
    }
    editingProduction = YES;
    
    [self.deleteSourceArray removeAllObjects];
    
    CGPoint pointTouch = [gestureRecognizer locationInView:self.mainCollectionView];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [self.mainCollectionView indexPathForItemAtPoint:pointTouch];
        if ([[self.mainCollectionView cellForItemAtIndexPath:indexPath] isKindOfClass:[WXYZ_RackCenterCollectionViewCell class]]) {
            
            // 获取当前被点击的书籍,默认选中
            WXYZ_RackCenterCollectionViewCell *t_cell = (WXYZ_RackCenterCollectionViewCell *)[self.mainCollectionView cellForItemAtIndexPath:indexPath];
            [self.deleteSourceArray addObject:t_cell.productionModel];
            
            // 隐藏推荐栏
            [self hiddenHeaderViewWithAnimated:YES];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kAnimatedDuration + 0.1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.mainCollectionView reloadData];
            });
            
            [UIView animateWithDuration:kAnimatedDuration animations:^{
                self.toolBarView.frame = CGRectMake(0, SCREEN_HEIGHT - PUB_TABBAR_HEIGHT, SCREEN_WIDTH, PUB_TABBAR_HEIGHT);
            }];
            
            [self reloadToolBarState];
        } else {
            editingProduction = NO;
        }
    }
}

- (void)endEdited
{
    editingProduction = NO;
    
    [self showHeaderViewWithAnimated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimatedDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mainCollectionView reloadData];
    });
    
    [UIView animateWithDuration:kAnimatedDuration animations:^{
        self.toolBarView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, PUB_TABBAR_HEIGHT);
    }];
    
    [self reloadToolBarState];
}

- (void)reloadToolBarState
{
    if (self.deleteSourceArray.count == 0) {
        
        self.toolBarDeleteButton.backgroundColor = kGrayLineColor;
        self.toolBarDeleteButton.enabled = NO;
        [self.toolBarDeleteButton setTitle:@"删除(0)" forState:UIControlStateNormal];
        [self.toolBarDeleteButton setTitleColor:kGrayTextColor forState:UIControlStateNormal];
        
        self.toolBarCheckAllButton.selected = NO;
        [self.toolBarCheckAllButton setTitle:@"全选" forState:UIControlStateNormal];
        
    } else {
        self.toolBarDeleteButton.backgroundColor = kRedColor;
        self.toolBarDeleteButton.enabled = YES;
        [self.toolBarDeleteButton setTitle:[NSString stringWithFormat:@"删除(%@)", [WXYZ_UtilsHelper formatStringWithInteger:self.deleteSourceArray.count]] forState:UIControlStateNormal];
        [self.toolBarDeleteButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
        
        
        if (self.deleteSourceArray.count == self.dataSourceArray.count) {
            self.toolBarCheckAllButton.selected = YES;
            [self.toolBarCheckAllButton setTitle:@"取消全选" forState:UIControlStateNormal];
        } else {
            self.toolBarCheckAllButton.selected = NO;
            [self.toolBarCheckAllButton setTitle:@"全选" forState:UIControlStateNormal];
        }
    }
}

#pragma mark - lazy

- (WXYZ_RackCenterHeaderView *)headerView
{
    if (!_headerView) {
        WS(weakSelf)
        _headerView = [[WXYZ_RackCenterHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, Rack_Header_Height)];
        _headerView.backgroundColor = [UIColor whiteColor];
        _headerView.productionType = self.productionType;
        _headerView.adBannerClickBlock = ^(NSString * _Nonnull title, NSString * _Nonnull content) {
            WXYZ_AnnouncementInfoViewController *vc = [[WXYZ_AnnouncementInfoViewController alloc] init];
            vc.titleText = title?:@"";
            vc.contentText = content?:@"";
            [weakSelf.navigationController pushViewController:vc animated:YES];
        };
        
        _headerView.recommendBannerClickBlock = ^(NSInteger production_id) {
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
        
        _headerView.collectionClickBlock = ^{
          [weakSelf.navigationController pushViewController:[[WXYZ_TaskViewController alloc] init] animated:YES];
        };
    }
    return _headerView;
}

- (UIView *)toolBarView
{
    if (!_toolBarView) {
        _toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, PUB_TABBAR_HEIGHT)];
        _toolBarView.backgroundColor = kWhiteColor;
        WS(weakSelf)
        [_toolBarView addObserver:KEY_PATH(_toolBarView, frame) complete:^(UIView * _Nonnull toolBarView, id  _Nullable oldVal, id  _Nullable newVal) {
            CGRect frame = [newVal CGRectValue];
            if (CGRectGetMinY(frame) >= SCREEN_HEIGHT) {
                toolBarView.hidden = YES;
                weakSelf.tabBarController.tabBar.hidden = NO;
            } else {
                toolBarView.hidden = NO;
                weakSelf.tabBarController.tabBar.hidden = YES;
            }
        }];
        [self.view addSubview:_toolBarView];
        
        UIButton *toolBarCheckAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        toolBarCheckAllButton.tag = 33;
        toolBarCheckAllButton.selected = NO;
        toolBarCheckAllButton.frame = CGRectMake(0, 0, SCREEN_WIDTH / 3, PUB_TABBAR_HEIGHT - PUB_TABBAR_OFFSET);
        toolBarCheckAllButton.adjustsImageWhenHighlighted = NO;
        [toolBarCheckAllButton setTitle:@"全选" forState:UIControlStateNormal];
        [toolBarCheckAllButton setTitleColor:kBlackColor forState:UIControlStateNormal];
        [toolBarCheckAllButton.titleLabel setFont:kMainFont];
        [toolBarCheckAllButton addTarget:self action:@selector(toolBarActionClick:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBarView addSubview:toolBarCheckAllButton];
        
        self.toolBarCheckAllButton = toolBarCheckAllButton;
        
        UIButton *toolBarDeleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        toolBarDeleteButton.frame = CGRectMake(SCREEN_WIDTH / 3, 0, SCREEN_WIDTH / 3, PUB_TABBAR_HEIGHT - PUB_TABBAR_OFFSET);
        toolBarDeleteButton.backgroundColor = kGrayLineColor;
        toolBarDeleteButton.tag = 22;
        [toolBarDeleteButton setTitleColor:kGrayTextColor forState:UIControlStateNormal];
        [toolBarDeleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [toolBarDeleteButton.titleLabel setFont:kMainFont];
        [toolBarDeleteButton addTarget:self action:@selector(toolBarActionClick:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBarView addSubview:toolBarDeleteButton];
        
        self.toolBarDeleteButton = toolBarDeleteButton;
        
        UIButton *cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancleButton.frame = CGRectMake(SCREEN_WIDTH / 3 * 2, 0, SCREEN_WIDTH / 3, PUB_TABBAR_HEIGHT - PUB_TABBAR_OFFSET);
        cancleButton.tag = 11;
        [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancleButton setTitleColor:kBlackColor forState:UIControlStateNormal];
        [cancleButton.titleLabel setFont:kMainFont];
        [cancleButton addTarget:self action:@selector(toolBarActionClick:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBarView addSubview:cancleButton];
    }
    return _toolBarView;
}

// 加载本地书籍缓存
- (void)localSourceRequest
{
    NSArray *cacheArray = [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:self.productionType] getAllCollection];
    if (![cacheArray isEqualToArray:self.dataSourceArray]) {
        self.dataSourceArray = [cacheArray mutableCopy];
        [self.mainCollectionView reloadData];
    }
    
    [self.mainCollectionView scrollToTop];
    
    [self.mainCollectionView endRefreshing];
}

- (void)netRequest
{
    // 书籍更新角标
    self.productionCornerBadges = [NSMutableDictionary dictionary];
    
    NSString *url = @"";
    switch (self.productionType) {
        case WXYZ_ProductionTypeBook:
            url = Book_Rack;
            break;
        case WXYZ_ProductionTypeComic:
            url = Comic_Rack;
            break;
        case WXYZ_ProductionTypeAudio:
            url = Audio_Rack;
            break;
            
        default:
            break;
    }
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:url parameters:nil model:WXYZ_RackCenterModel.class success:^(BOOL isSuccess, WXYZ_RackCenterModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            weakSelf.rackCenterModel = t_model;
            for (WXYZ_ProductionModel *t_model in weakSelf.rackCenterModel.productionList) {
                [weakSelf.productionCornerBadges setObject:t_model forKey:[WXYZ_UtilsHelper formatStringWithInteger:t_model.production_id]];
            }
        }
        [weakSelf.mainCollectionView endRefreshing];
        [weakSelf.mainCollectionView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf.mainCollectionView endRefreshing];
        [weakSelf.mainCollectionView reloadData];
    }];
}

@end

//
//  WXYZ_ComicReaderViewController2.m
//  WXReader
//
//  Created by Andrew on 2019/6/3.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicReaderViewController2.h"
#import "WXYZ_CommentsViewController.h"
#import "WXYZ_ComicReaderDirectoryViewController.h"
#import "WXYZ_ComicReaderDownloadViewController.h"

#import "WXYZ_ComicReaderTableViewCell.h"
#import "WXYZ_ComicReaderBottomTableViewCell.h"
#import "WXYZ_PublicADStyleTableViewCell.h"

#import "WXYZ_ComicMenuView.h"
#import "WXYZ_ChapterBottomPayBar.h"

#import "WXYZ_ADManager.h"
#import "WXYZ_ComicDownloadManager.h"
#import "WXYZ_ProductionReadRecordManager.h"
#import "WXYZ_NightModeView.h"

#import "WXYZ_ComicBarrageModel.h"
#import "OCBarrage.h"

#import "WXYZ_ProductionCollectionManager.h"
#import "WXYZ_ComicReaderAdapterCollectionViewCell.h"

#define MinScale 1.0f
#define MaxScale 2.0f

@interface WXYZ_ComicReaderViewController2 () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate,WXYZ_ComicMenuSettingBarDelegate,WXYZ_ComicReaderTableViewCellDelegate>
{
    BOOL isEnableTurnPage;
    BOOL isEnableBarrage;
}

@property (nonatomic, strong) UIScrollView *mainBottomScrollView;

@property (nonatomic, strong) WXYZ_ProductionChapterModel *comicChapterModel;

@property (nonatomic, strong) WXYZ_ADModel *adModel;

@property (nonatomic, strong) UIView *welcomePageView;

@property (nonatomic, strong) WXYZ_ChapterBottomPayBar *payBar;

@property (nonatomic, strong) OCBarrageManager *barrageManager;

@property (nonatomic, strong) NSMutableArray<WXYZ_ComicBarrageList *> *barrageList;

/// 弹幕所有的数据
@property (nonatomic, copy) NSArray<WXYZ_ComicBarrageList *> *totalBarrageArray;

/// YES：弹幕数据已完
@property (nonatomic, assign) BOOL barrageComplete;

@property (nonatomic, assign) BOOL needRefresh;

/// 上次请求的章节ID
@property (nonatomic, assign) NSInteger oldChapterID;

@property (nonatomic, assign) int selMode;

@property (nonatomic, weak) UICollectionView *collectioinVIew;

@end

@implementation WXYZ_ComicReaderViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selMode = 1;
    [self initialize];
    [self createSubviews];
    [self netRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarDefaultStyle];
    
    if (self.comicProductionModel.is_recommend) {
        self.comicProductionModel.is_recommend = NO;
        [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] modificationCollectionWithProductionModel:self.comicProductionModel];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    if (self.mainTableViewGroup.contentOffset.y > 0) {
        [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] setComicReadingRecord:self.comicChapterModel.production_id chapter_id:self.chapter_id offsetY:self.mainTableViewGroup.contentOffset.y];
    }
}

- (void)initialize
{
    self.oldChapterID = -1;
    self.needRefresh = YES;
    self.barrageList = [NSMutableArray array];
    self.totalBarrageArray = [NSArray array];
    [self setNavigationBarTitle:[[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] getReadingRecordChapterTitleWithProduction_id:self.comicProductionModel.production_id]?:@""];
    // 设置菜单栏展示项

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:Enable_Click_Page] isEqualToString:@"0"]) {
        isEnableTurnPage = NO;
    } else {
        isEnableTurnPage = YES;
    }
    
    NSString *enableBarrage = [[NSUserDefaults standardUserDefaults] objectForKey:Enable_Barrage];
    if ([enableBarrage isEqualToString:@"0"] || !enableBarrage) {
        isEnableBarrage = NO;
    } else {
        isEnableBarrage = YES;
    }
    
    [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] moveCollectionToTopWithProductionModel:self.comicProductionModel];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeChapter:) name:Notification_Switch_Chapter object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popViewController) name:Notification_Pop_Comic_Reader object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToComments) name:Notification_Push_To_Comments object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToDirectory) name:Notification_Push_To_Directory object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableTapClick:) name:Enable_Click_Page object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(barrageSwitchClick:) name:Notification_Switch_Barrage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewScorllToTop) name:Notification_Reader_Scroll_To_Top object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToDownloadView) name:Notification_Push_To_Comic_Download object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBarrage:) name:Notification_Change_Barrage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeChange:) name:Enable_Click_Night object:nil];
}

- (void)createSubviews
{   
    self.mainBottomScrollView = [[UIScrollView alloc] init];
    self.mainBottomScrollView.minimumZoomScale = MinScale;
    self.mainBottomScrollView.maximumZoomScale = MaxScale;
    self.mainBottomScrollView.bounces = NO;
    self.mainBottomScrollView.delegate = self;
    self.mainBottomScrollView.showsVerticalScrollIndicator = NO;
    self.mainBottomScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.mainBottomScrollView];
    
    [self.mainBottomScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT);
    }];
    
    if (@available(iOS 11.0, *)) {
        self.mainBottomScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    
    self.mainTableViewGroup.delegate = self;
    self.mainTableViewGroup.dataSource = self;
    [self.mainBottomScrollView addSubview:self.mainTableViewGroup];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_HEIGHT, PUB_NAVBAR_HEIGHT)];
    headerView.backgroundColor = kWhiteColor;
    [self.mainTableViewGroup setTableHeaderView:headerView];
    
    [self.mainTableViewGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(self.mainBottomScrollView.mas_width);
        make.height.mas_equalTo(self.mainBottomScrollView.mas_height);
    }];
    
    WS(weakSelf)
    CGFloat y = (SCREEN_HEIGHT - 290) / 2.0 - 50;
    [self setEmptyOnView:self.mainTableViewGroup imageName:@"" title:@"内容获取失败" detailTitle:nil buttonTitle:@"重试" centerY:y tapBlock:^{
        [weakSelf netRequest];
    }];
    
    [self.mainTableViewGroup addToastFooterRefreshWithRefreshingBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Switch_Chapter object:[WXYZ_UtilsHelper formatStringWithInteger:weakSelf.comicChapterModel.next_chapter]];
    }];
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTapRecognizer.numberOfTouchesRequired = 1;
    [self.mainTableViewGroup addGestureRecognizer:singleTapRecognizer];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [self.mainTableViewGroup addGestureRecognizer:doubleTapRecognizer];
    
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    
    [self.view addSubview:self.welcomePageView];
    
    [self.view addSubview:[WXYZ_ComicMenuView sharedManager]];
    [WXYZ_ComicMenuView sharedManager].delegate = self;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:Enable_Click_Night] isEqualToString:@"1"]) {
        [self.view addSubview:[WXYZ_NightModeView sharedManager]];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView == self.mainBottomScrollView) {
        if (self.selMode == 1) {
             return self.mainTableViewGroup;
        } else {
            if (self.collectioinVIew != nil) {
                 return self.collectioinVIew;
            }
           return self.mainTableViewGroup;
        }
    }
    return nil;
   
}

- (void)tableViewScorllToTop
{
    [self.mainTableViewGroup scrollToTop];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.comicChapterModel.is_preview) {
        [[WXYZ_ComicMenuView sharedManager] changeMode:self.selMode];
        [[WXYZ_ComicMenuView sharedManager] showMenuView];
        [self.barrageManager pause];
        
        if (scrollView == self.mainTableViewGroup) {
            CGRect cellRect = [self.mainTableViewGroup rectForRowAtIndexPath:[NSIndexPath indexPathForRow:9 inSection:0]];
                         if (cellRect.size.width > 0 && cellRect.size.height > 0) {
                               if (cellRect.size.width > 0 && cellRect.size.height > 0) {
                                   if (self.mainTableViewGroup.contentOffset.y >= cellRect.origin.y-cellRect.size.height/2) {
                                       [self showPayAlert:self.comicChapterModel];
                                       self.mainTableViewGroup.scrollEnabled = false;
                                   }
                               }
                             
                         }
                   
                   if (self.comicChapterModel.image_list.count <= 10) {
                       CGRect cellRect2 = [self.mainTableViewGroup rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.comicChapterModel.image_list.count-1 inSection:0]];
                       if (cellRect2.size.width > 0 && cellRect2.size.height > 0) {
                           if (self.mainTableViewGroup.contentOffset.y >= cellRect2.origin.y-cellRect2.size.height/2) {
                               [self showPayAlert:self.comicChapterModel];
                               self.mainTableViewGroup.scrollEnabled = false;
                           }
                       }
                   }
        }
        return;
    }
    if (scrollView == self.mainTableViewGroup) {
        if (scrollView.contentOffset.y <= PUB_NAVBAR_HEIGHT) {
            [[WXYZ_ComicMenuView sharedManager] showMenuView];
            [self.barrageManager pause];
        } else if (scrollView.contentOffset.y > scrollView.contentSize.height - SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT) {
            [[WXYZ_ComicMenuView sharedManager] showMenuView];
            [self.barrageManager pause];
        } else {
            [[WXYZ_ComicMenuView sharedManager] hiddenMenuView];
            if (isEnableBarrage) {
                [self.barrageManager resume];
            }
        }
    }
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if (self.comicChapterModel.image_list.count > 0) {
        if (self.selMode == 1) {
            if ([WXYZ_ADManager canLoadAd:WXYZ_ADViewTypeComic adPosition:WXYZ_ADViewPositionEnd]) {
                      return 3;
                  }
                  return 2;
        } else {
            return 1;
        }
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (self.selMode == 1) {
             return self.comicChapterModel.image_list.count;
        } else {
            return 1;
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.comicChapterModel.image_list.count > 0) {
        if (indexPath.section == 0) {
            if (self.selMode == 1) {
                WXYZ_ComicReaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_ComicReaderTableViewCell"];
                if (!cell) {
                    cell = [[WXYZ_ComicReaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_ComicReaderTableViewCell"];
                    cell.delegate = self;
                }
                cell.selModel = self.selMode;
                cell.localRow = (int)indexPath.row;
                cell.comic_id = self.comicChapterModel.production_id;
                cell.chapter_id = self.comicChapterModel.chapter_id;
                cell.chapter_update_time = [self.comicChapterModel.update_time integerValue];
                cell.imageModel = [self.comicChapterModel.image_list objectOrNilAtIndex:indexPath.row];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            } else {
                WXYZ_ComicReaderAdapterCollectionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_ComicReaderAdapterCollectionViewCell"];
                if (!cell) {
                    cell = [[WXYZ_ComicReaderAdapterCollectionViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_ComicReaderAdapterCollectionViewCell"];
                }
                self.collectioinVIew = cell.collectionView;
                cell.comic_id = self.comicChapterModel.production_id;
                cell.chapter_id = self.comicChapterModel.chapter_id;
                cell.chapter_update_time = [self.comicChapterModel.update_time integerValue];
                [cell reloadDataByArray:self.comicChapterModel.image_list];
                return cell;
            }
            
        }
        
        if ([WXYZ_ADManager canLoadAd:WXYZ_ADViewTypeComic adPosition:WXYZ_ADViewPositionEnd] && self.selMode == 1) {
            if (indexPath.section == 1) {
                static NSString *cellName = @"WXYZ_PublicADStyleTableViewCell";
                WXYZ_PublicADStyleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
                if (!cell) {
                    cell = [[WXYZ_PublicADStyleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
                }
                [cell setAdModel:self.adModel refresh:self.needRefresh];
                cell.mainTableView = tableView;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
        }
        WXYZ_ComicReaderBottomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_ComicReaderBottomTableViewCell"];
        
        if (!cell) {
            cell = [[WXYZ_ComicReaderBottomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_ComicReaderBottomTableViewCell"];
        }
        cell.comicChapterModel = self.comicChapterModel;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return [[UITableViewCell alloc] init];
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([WXYZ_ADManager canLoadAd:WXYZ_ADViewTypeComic adPosition:WXYZ_ADViewPositionEnd] && section == 1) {
        return kHalfMargin;
    }
    return CGFLOAT_MIN;
}

//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN)];
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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
           if (self.selMode == 1) {
                return UITableViewAutomaticDimension;
           } else {
               return tableView.height;
           }
       }
       return UITableViewAutomaticDimension;
}

#pragma mark - 点击事件

- (void)singleTap:(UITapGestureRecognizer *)tapGes
{
    CGPoint touchPoint = [tapGes locationInView:self.view];
    CGFloat contentOffSetY = self.mainTableViewGroup.contentOffset.y;
    CGFloat contentSizeH = self.mainTableViewGroup.contentSize.height;
    CGFloat scrollOffSet = SCREEN_HEIGHT * self.mainBottomScrollView.zoomScale * 3 / 4;
    
    if ([WXYZ_ComicMenuView sharedManager].isShowing) {
        if (touchPoint.y < PUB_NAVBAR_HEIGHT || touchPoint.y > SCREEN_HEIGHT - 80) {
            return;
        }
    }
    
    if (touchPoint.y <= SCREEN_HEIGHT / 3 && isEnableTurnPage) { // 向上滚动
        [self.mainTableViewGroup setContentOffset:CGPointMake(0, (contentOffSetY - SCREEN_HEIGHT / 4 * 3) <= 0?0:(contentOffSetY - SCREEN_HEIGHT / 4 * 3 + SCREEN_HEIGHT * (self.mainBottomScrollView.zoomScale - MinScale))) animated:YES];
    } else if (touchPoint.y >= SCREEN_HEIGHT / 3 * 2 && isEnableTurnPage) { // 向下滚动
        
        if (contentOffSetY + SCREEN_HEIGHT + scrollOffSet >= contentSizeH) {
            contentOffSetY = contentSizeH - SCREEN_HEIGHT + (SCREEN_HEIGHT / 4) * (self.mainBottomScrollView.zoomScale - MinScale);
        } else {
            contentOffSetY = contentOffSetY + scrollOffSet;
        }
        [self.mainTableViewGroup setContentOffset:CGPointMake(0, contentOffSetY) animated:YES];
    } else { // 菜单栏
        if (contentOffSetY > PUB_NAVBAR_HEIGHT && !(contentOffSetY > contentSizeH - SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT)) {
            [[WXYZ_ComicMenuView sharedManager] autoShowOrHiddenMenuView];
            if ([WXYZ_ComicMenuView sharedManager].isShowing) {
                [self.barrageManager pause];
            } else {
                if (isEnableBarrage) {
                    [self.barrageManager resume];
                }
            }
        }
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)tapGes
{
    if (self.comicChapterModel.image_list.count == 0) return;
    CGFloat currScale = self.mainBottomScrollView.zoomScale;
    CGFloat goalScale;

    if ([WXYZ_ComicMenuView sharedManager].isShowing) {
        if ([tapGes locationInView:self.view].y < PUB_NAVBAR_HEIGHT || [tapGes locationInView:self.view].y > SCREEN_HEIGHT - 80) {
            return;
        }
    }
    
    if (currScale == MinScale) {
        goalScale = MaxScale;
    } else {
        goalScale = MinScale;
    }
    
    if (currScale == goalScale) {
        return;
    }
    
    CGPoint touchPoint = [tapGes locationInView:[self viewForZoomingInScrollView:self.mainBottomScrollView]];
    CGFloat xsize = self.mainBottomScrollView.frame.size.width / goalScale;
    CGFloat ysize = self.mainBottomScrollView.frame.size.height / goalScale;
    CGFloat x = touchPoint.x - xsize / 2;
    CGFloat y = touchPoint.y - ysize / 2;
    
    [self.mainBottomScrollView zoomToRect:CGRectMake(x, y, xsize, ysize) animated:YES];
}

- (void)enableTapClick:(NSNotification *)noti
{
    if ([noti.object isEqualToString:@"1"]) {        
        isEnableTurnPage = YES;
    }
    
    if ([noti.object isEqualToString:@"0"]) {
        isEnableTurnPage = NO;
    }
}

- (void)barrageSwitchClick:(NSNotification *)noti
{
    if ([noti.object isEqualToString:@"1"]) {
        isEnableBarrage = YES;
//        [self.barrageManager resume];
        [self addNormalBarrage];
        self.barrageManager.renderView.hidden = NO;
    }
    
    if ([noti.object isEqualToString:@"0"]) {
        isEnableBarrage = NO;
//        [self.barrageManager pause];
        self.barrageManager.renderView.hidden = YES;
    }
}

- (void)nightModeChange:(NSNotification *)noti
{
    if ([noti.object isEqualToString:@"1"]) {
        [self.view addSubview:[WXYZ_NightModeView sharedManager]];
    } else {
        [[WXYZ_NightModeView sharedManager] removeFromSuperview];
    }
}

- (void)pushToComments
{
    WXYZ_CommentsViewController *vc = [[WXYZ_CommentsViewController alloc] init];
    vc.production_id = self.comicProductionModel.production_id;
    vc.chapter_id = self.chapter_id;
    vc.productionType = WXYZ_ProductionTypeComic;
    vc.commentsSuccessBlock = ^(WXYZ_CommentsDetailModel *commentModel) {
        
        WXYZ_ProductionChapterModel *chapterModel = [WXYZ_ComicMenuView sharedManager].comicChapterModel;
        
        chapterModel.total_comment = commentModel.comment_num;
        
        [WXYZ_ComicMenuView sharedManager].comicChapterModel = chapterModel;
    };
    WXYZ_NavigationController *nav = [[WXYZ_NavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)pushToDirectory
{
    WXYZ_ComicReaderDirectoryViewController *vc = [[WXYZ_ComicReaderDirectoryViewController alloc] init];
    vc.comic_id = self.comicProductionModel.production_id;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushToDownloadView
{
    WXYZ_ComicReaderDownloadViewController *vc = [[WXYZ_ComicReaderDownloadViewController alloc] init];
    vc.comicModel = self.comicProductionModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)changeChapter:(NSNotification *)noti
{
    self.chapter_id = [noti.object integerValue];
    [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] addReadingRecordWithProduction_id:self.comicChapterModel.production_id chapter_id:self.chapter_id chapterTitle:self.comicChapterModel.chapter_title];
    [self.mainTableViewGroup setContentOffset:CGPointZero];
    [self netRequest];
}

- (void)reloadDataSource
{
    [self hiddenNavigationBar:YES];
    [self hiddenNavigationBarLeftButton];

    self.mainBottomScrollView.userInteractionEnabled = YES;
    [[WXYZ_ComicMenuView sharedManager] changeMode:self.selMode];
    [[WXYZ_ComicMenuView sharedManager] showMenuView];

    self.needRefresh = YES;
    [self.mainTableViewGroup reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.needRefresh = NO;
    });
    NSDictionary<NSString *, NSString *> *dict = [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] getComicReadingRecord:self.comicChapterModel.production_id];
    if ([dict objectForKey:[NSString stringWithFormat:@"%zd", self.chapter_id]]) {
        CGFloat offsetY = [[dict objectForKey:[NSString stringWithFormat:@"%zd", self.chapter_id]] floatValue];
        if (offsetY > self.mainTableViewGroup.contentSize.height) {
            offsetY = self.mainTableViewGroup.contentSize.height;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainTableViewGroup setContentOffset:CGPointMake(0, offsetY)];
        });
    }

    if (!self.comicChapterModel) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Enable_Click_Page object:@"0"];
    }

    [self.mainTableViewGroup ly_endLoading];

    if (self.welcomePageView.alpha > 0) {
        [UIView animateWithDuration:kAnimatedDuration animations:^{
            self.welcomePageView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.welcomePageView removeAllSubviews];
            [self.welcomePageView removeFromSuperview];
        }];
    }
}

- (UIView *)welcomePageView
{
    if (!_welcomePageView) {
        _welcomePageView = [[UIView alloc] init];
        _welcomePageView.backgroundColor = kWhiteColor;
        _welcomePageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _welcomePageView.userInteractionEnabled = NO;
        
        NSMutableArray *imagesArray = [NSMutableArray array];
        for (int i = 1; i < 27; i++) {
            [imagesArray addObject:[YYImage imageNamed:[NSString stringWithFormat:@"comic_loading%d.png", i]]];
        }
        
        YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
        imageView.animationDuration = 2;
        imageView.animationImages = imagesArray;
        imageView.animationRepeatCount = 999;
        [_welcomePageView addSubview:imageView];
        
        [imageView startAnimating];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_welcomePageView.mas_centerX).with.offset(- kMargin);
            make.centerY.mas_equalTo(_welcomePageView.mas_centerY);
            make.width.height.mas_equalTo(_welcomePageView.mas_width).with.multipliedBy(0.5);
        }];
        
        UIView *progress = [[UIView alloc] init];
        progress.backgroundColor = kGrayViewColor;
        progress.layer.cornerRadius = 1.5;
        [_welcomePageView addSubview:progress];
        
        [progress mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_welcomePageView.mas_centerX);
            make.top.mas_equalTo(imageView.mas_bottom);
            make.width.mas_equalTo(imageView.mas_width);
            make.height.mas_equalTo(3);
        }];
        
        UIBezierPath *bezPath = [UIBezierPath bezierPath];
        [bezPath moveToPoint:CGPointMake(0, 1)];
        [bezPath addLineToPoint:CGPointMake(SCREEN_WIDTH / 2, 1)];
         
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.lineWidth = 3;
        layer.path = bezPath.CGPath;
        layer.strokeColor = kMainColor.CGColor;
        layer.fillColor = kGrayViewColor.CGColor;
        layer.lineCap = @"round";
        [progress.layer addSublayer:layer];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration = 30;
        animation.fromValue = @0;
        animation.toValue = @1;
        animation.repeatCount = 999;
        [layer addAnimation:animation forKey:nil];
        
    }
    return _welcomePageView;
}

- (void)netRequest
{
    if ([WXYZ_NetworkReachabilityManager networkingStatus] == NO) {
        [self.emptyView setTitleStr:@"当前为离线状态，只可查看缓存内容哦"];
        
        // 获取本地缓存信息
        self.comicChapterModel = [[WXYZ_ComicDownloadManager sharedManager] getDownloadChapterModelWithProduction_id:self.comicProductionModel.production_id chapter_id:[[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] getReadingRecordChapter_idWithProduction_id:self.comicProductionModel.production_id]];
        
        // 不存在就只展示缓存内容
        if (!self.comicChapterModel) {
            WXYZ_ProductionModel *productionModel = [[WXYZ_DownloadHelper sharedManager] getDownloadProductionModelWithProduction_id:self.comicProductionModel.production_id productionType:WXYZ_ProductionTypeComic];
            
            // 没有阅读记录
            if (self.chapter_id == 0) {
                self.comicChapterModel = [productionModel.chapter_list firstObject];
                self.chapter_id = self.comicChapterModel.chapter_id;
            } else {
                for (WXYZ_ProductionChapterModel *chapterModel in productionModel.chapter_list) {
                    if (self.chapter_id == chapterModel.chapter_id) {
                        self.comicChapterModel = chapterModel;
                    }
                }
            }
        }
        
        // 设置记录信息
        [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] addReadingRecordWithProduction_id:self.comicChapterModel.production_id chapter_id:self.chapter_id chapterTitle:self.comicChapterModel.chapter_title];
        
        [[WXYZ_ComicMenuView sharedManager] stopLoadingData];
        [WXYZ_ComicMenuView sharedManager].comicChapterModel = self.comicChapterModel;
        [WXYZ_ComicMenuView sharedManager].productionModel = self.comicProductionModel;
        
        if (self.comicChapterModel.next_chapter > 0) {
            [self.mainTableViewGroup showRefreshFooter];
        } else {
            [self.mainTableViewGroup hideRefreshFooter];
        }
        
        [self reloadDataSource];
        [self.mainTableViewGroup endRefreshing];
        [self.mainTableViewGroup ly_endLoading];
        return;
    }
    
    WS(weakSelf)
    [self.emptyView setTitleStr:@"内容获取失败"];
    [self.emptyView setBtnTitleStr:@"重试"];
    
    [[WXYZ_ComicMenuView sharedManager] startLoadingData];
    self.mainBottomScrollView.userInteractionEnabled = NO;
    
    if (self.chapter_id == self.oldChapterID) return;
    
    [WXYZ_NetworkRequestManger POST:Comic_Chapter parameters:@{@"comic_id":[WXYZ_UtilsHelper formatStringWithInteger:self.comicProductionModel.production_id], @"chapter_id":[WXYZ_UtilsHelper formatStringWithInteger:self.chapter_id]} model:WXYZ_ProductionChapterModel.class success:^(BOOL isSuccess, WXYZ_ProductionChapterModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        [[WXYZ_ComicMenuView sharedManager] stopLoadingData];
        weakSelf.oldChapterID = -1;
        if (isSuccess) {
            weakSelf.comicChapterModel = t_model;

            weakSelf.chapter_id = t_model.chapter_id;
            [weakSelf requestBarrage];

            [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] addReadingRecordWithProduction_id:t_model.production_id chapter_id:t_model.chapter_id chapterTitle:t_model.chapter_title];
            [WXYZ_ComicMenuView sharedManager].comicChapterModel = t_model;
            [WXYZ_ComicMenuView sharedManager].productionModel = weakSelf.comicProductionModel;

            //TODO:这里是否每章节都判断
//            && t_model.last_chapter > 0
            if (t_model.is_preview ) {
//                [weakSelf showPayAlert:t_model];
            } else {
                [weakSelf.payBar hiddenBottomPayBar];
                weakSelf.payBar.isShow = false;
                [weakSelf.payBar removeFromSuperview];
                weakSelf.payBar = nil;
            }

            if (t_model.next_chapter > 0) {
                [weakSelf.mainTableViewGroup showRefreshFooter];
            } else {
                [weakSelf.mainTableViewGroup hideRefreshFooter];
            }

        }
        [weakSelf reloadDataSource];
        [weakSelf.mainTableViewGroup endRefreshing];
        [weakSelf.mainTableViewGroup ly_endLoading];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        weakSelf.oldChapterID = -1;
        [[WXYZ_ComicMenuView sharedManager] stopLoadingData];
        [weakSelf.mainTableViewGroup endRefreshing];
        [weakSelf.mainTableViewGroup ly_endLoading];
    }];

    [WXYZ_NetworkRequestManger POST:Advert_Info parameters:@{@"type" : @"2", @"position" : @"8"} model:WXYZ_ADModel.class success:^(BOOL isSuccess, WXYZ_ADModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        weakSelf.adModel = t_model;
    } failure:nil];

    [WXYZ_NetworkRequestManger POST:Comic_Add_Read_Log parameters:@{@"comic_id":[WXYZ_UtilsHelper formatStringWithInteger:self.comicProductionModel.production_id], @"chapter_id":[WXYZ_UtilsHelper formatStringWithInteger:self.chapter_id]} model:nil success:nil failure:nil];
}

- (void)showPayAlert:(WXYZ_ProductionChapterModel * _Nullable)t_model {
    if (!self.payBar && self) {
        if (self.payBar.isShow) {
            return;
        }
        WXYZ_ProductionChapterModel *tt_model = [[WXYZ_ProductionChapterModel alloc] init];
        tt_model.production_id = t_model.production_id;
        tt_model.chapter_id = t_model.chapter_id;
        tt_model.recharge_content = t_model.recharge_content;
        WXYZ_ChapterBottomPayBar *payBar = [[WXYZ_ChapterBottomPayBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) chapterModel:tt_model barType:WXYZ_BottomPayBarTypeBuyChapter productionType:WXYZ_ProductionTypeComic];
        self.payBar = payBar;
        self.payBar.isShow = true;
        WS(weakSelf);
        payBar.paySuccessChaptersBlock = ^(NSArray<NSString *> * _Nonnull success_chapter_ids) {
            [weakSelf netRequest];
        };
        payBar.canTouchHiddenView = NO;
        [self.view addSubview:payBar];
        [payBar showBottomPayBar];
    }
}

// 请求弹幕数据
- (void)requestBarrage {
    // 移除当前所有弹幕
    [self.barrageList removeAllObjects];
    self.totalBarrageArray = @[];
    self.currentPageNumber = 1;
    self.barrageComplete = NO;
    [self.barrageManager.renderView removeAllSubviews];
    [self.barrageManager.renderView.animatingCells removeAllObjects];
    [self.barrageManager.renderView.idleCells removeAllObjects];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addNormalBarrage) object:nil];
    [self request_Barrage];
}

- (void)request_Barrage {
    WS(weakSelf)
    if (self.barrageComplete) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addNormalBarrage) object:nil];
        [self.barrageList removeAllObjects];
        self.barrageList = [NSMutableArray arrayWithArray:self.totalBarrageArray];
        if (self.barrageList.count > 0) {
            if (_barrageManager.renderView.animatingCells.count == 0 && weakSelf.barrageComplete) {
                self.barrageManager.renderView.animationStopBlock = ^{
                    if (weakSelf.barrageManager.renderView.animatingCells.count <= 1) {
                        [weakSelf addNormalBarrage];
                    }
                };
                [weakSelf addNormalBarrage];
            } else {
                self.barrageManager.renderView.animationStopBlock = ^{
                    if (weakSelf.barrageManager.renderView.animatingCells.count <= 1 && weakSelf.barrageComplete) {
                        [weakSelf addNormalBarrage];
                    }
                };
            }
        }
        return;
    }

    NSDictionary *params = @{
        @"comic_id"   : @(self.comicProductionModel.production_id),
        @"chapter_id" : @(self.chapter_id),
        @"page_num"   : @(self.currentPageNumber),
    };
    [WXYZ_NetworkRequestManger POST:Comic_Barrage parameters:params model:WXYZ_ComicBarrageModel.class success:^(BOOL isSuccess, WXYZ_ComicBarrageModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            weakSelf.barrageComplete = t_model.current_page >= t_model.total_page;
            [weakSelf.barrageList addObjectsFromArray:t_model.list];
            weakSelf.totalBarrageArray = [weakSelf.totalBarrageArray arrayByAddingObjectsFromArray:t_model.list];
            
            [weakSelf addNormalBarrage];
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg ?: @"弹幕获取失败"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:@"请求失败"];
    }];
}

- (void)addNormalBarrage {
    if (isEnableBarrage == NO) {
        return;
    }
    if ([WXYZ_ComicMenuView sharedManager].isShowing) {
        [self.barrageManager pause];
    }
    WXYZ_ComicBarrageList *t_model = [self barrageModel];
    if (!t_model) {
        self.currentPageNumber++;
        [self request_Barrage];
        return;
    }
    
    OCBarrageTextDescriptor *textDescriptor = [[OCBarrageTextDescriptor alloc] init];
    textDescriptor.text = t_model.content ?: @"";
    textDescriptor.textColor = [UIColor colorWithHexString:t_model.color ?: @""];
    textDescriptor.positionPriority = OCBarragePositionVeryHigh;
    textDescriptor.textFont = [UIFont systemFontOfSize:17.0];
    textDescriptor.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
    textDescriptor.strokeWidth = -1;
    textDescriptor.fixedSpeed = 15;
    textDescriptor.barrageCellClass = [OCBarrageTextCell class];
    if (![WXYZ_ComicMenuView sharedManager].isShowing) {
        [self.barrageManager renderBarrageDescriptor:textDescriptor];
    }
    
    [self performSelector:@selector(addNormalBarrage) afterDelay:0.5];
}

// 获取弹幕内容
- (WXYZ_ComicBarrageList *)barrageModel {
    WXYZ_ComicBarrageList *t_model = [self.barrageList objectOrNilAtIndex:0];
    if (t_model && ![WXYZ_ComicMenuView sharedManager].isShowing) {
        [self.barrageList removeObject:t_model];
    }
    return t_model;
}

// 更新弹幕
- (void)changeBarrage:(NSNotification *)noti {
    NSString *text = noti.object ?: @"";
    
    WXYZ_ComicBarrageList *t_model = [[WXYZ_ComicBarrageList alloc] init];
    t_model.content = text;
    t_model.color = @"#fdf03e";
    
    [self.barrageList insertObject:t_model atIndex:0];
    self.totalBarrageArray = [self.totalBarrageArray arrayByAddingObjectsFromArray:@[t_model]];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addNormalBarrage) object:nil];
    [self addNormalBarrage];
}

- (OCBarrageManager *)barrageManager {
    if (!_barrageManager) {
        _barrageManager = [[OCBarrageManager alloc] init];
        _barrageManager.renderView.backgroundColor = [UIColor clearColor];
        _barrageManager.renderView.userInteractionEnabled = NO;
        [_barrageManager start];
        [self.view insertSubview:_barrageManager.renderView belowSubview:[WXYZ_ComicMenuView sharedManager]];
        [_barrageManager.renderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(self.view);
            make.top.equalTo(self.view).offset(kStatusBarHeight);
            make.height.equalTo(self.view).multipliedBy(1.0 / 3.0);
        }];
    }
    return _barrageManager;
}

- (void)refreshCurrentCell:(int)row {
    @weakify(self);
    //NSLog(@"imageData%@",imageData);
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView performWithoutAnimation:^{
            @strongify(self);
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.mainTableViewGroup reloadRowsAtIndexPaths:[NSArray arrayWithObjects:newIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        }];
    });
}


#pragma mark - WXYZ_ComicMenuSettingBarDelegate
- (void)changeMode:(int)mode {
    if (mode == self.selMode) {
        return;
    }
    self.selMode = mode;
    if (self.selMode == 2) {
        self.mainTableViewGroup.scrollEnabled = false;
    } else {
         self.mainTableViewGroup.scrollEnabled = true;
    }
    [self.mainTableViewGroup reloadData];
}

- (void)dealloc {
    [WXYZ_ComicMenuView sharedManager].delegate = nil;
}

@end

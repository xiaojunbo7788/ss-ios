//
//  WXYZ_BookReaderViewController.m
//  WXReader
//
//  Created by Andrew on 2018/5/29.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BookReaderViewController.h"
#import "WXYZ_BookReaderTextViewController.h"
#import "WXYZ_BookReaderBackViewController.h"
#import "WXYZ_DownloadCacheViewController.h"
#import "WXYZ_CoverPageViewController.h"
#import "WXYZ_ScorllPageViewController.h"
#import "WXYZ_CommentsViewController.h"
#import "WXYZ_DirectoryViewController.h"
#import "WXYZ_BookBackSideViewController.h"
#import "WXYZ_RechargeViewController.h"

// 书籍管理类
#import "WXYZ_ProductionCollectionManager.h"
#import "WXYZ_ReaderBookManager.h"
#import "WXYZ_ADManager.h"

#import "WXYZ_ReaderAnimationLayer.h"
#import "WXYZ_ReaderSettingHelper.h"
#import "WXYZ_BookReaderMenuBar.h"
#import "DZMAnimatedTransitioning.h"
#import "WXYZ_TouchAssistantView.h"
#import "WXYZ_GuideView.h"

#import "UINavigationController+DZM.h"
#import "NSObject+Observer.h"
#import "UIImage+Color.h"

@interface WXYZ_BookReaderViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIGestureRecognizerDelegate, WXCoverPageControlDataSource, WXCoverPageControlDelegate, WXScrollPageControlDataSource, WXScrollPageControlDelegate>

@property (nonatomic, strong) WXYZ_ReaderSettingHelper *functionalManager;

@property (nonatomic, strong) WXYZ_ReaderBookManager *readerManager;

@property (nonatomic, strong) WXYZ_BookReaderMenuBar *readerMenuBar;

@property (nonatomic, weak) UIPageViewController *pageViewController;

@property (nonatomic, weak) WXYZ_CoverPageViewController *szPageViewController;

@property (nonatomic, weak) WXYZ_ScorllPageViewController *dpPageViewController;

@property (nonatomic, strong) UIViewController *currentTextViewController;

@property (nonatomic, assign) WXReaderTransitionStyle pageViewControllerStyle;

@property (nonatomic, strong) WXYZ_ReaderAnimationLayer *readerAnimationLayer;

@property (nonatomic, assign) BOOL isAT;

@property (nonatomic, assign) BOOL sliding;

// 章节信息加载失败
@property (nonatomic, assign) BOOL emptyData;

@property (nonatomic, assign) BOOL isJumpToMenuView;

// 修复PageViewController轻滑页面错误的问题
@property (nonatomic, assign) BOOL needMoveBack;

// 向后翻页
@property (nonatomic, assign) BOOL turnAfter;
@property (nonatomic, assign) BOOL turnBefore;

@property (nonatomic, assign) BOOL blankStatus;

@property (nonatomic, assign) NSInteger coverPagerIndex;// 覆盖翻页模式页数

// 底部广告
@property (nonatomic, strong) WXYZ_ADManager *adView;

@property (nonatomic, assign) NSInteger specificIndex;

@property (nonatomic, assign) NSInteger chapterSort;

/// 加载动画
@property (nonatomic, weak) UIView *loadingView;

@end

@implementation WXYZ_BookReaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
}

- (instancetype)init {
    if (self = [super init]) {
        self.specifiedChapter = -1;
        self.specifiedPage = -1;
        self.specificIndex = -1;
        self.chapterSort = -1;
    }
    return self;
}

- (instancetype)initWithSpecificIndex:(NSInteger)specificIndex chapterSort:(NSInteger)chapterSort {
    if (self = [super init]) {
        self.specificIndex = specificIndex;
        self.chapterSort = chapterSort;
    }
    return self;
}

- (instancetype)initWithChapterIndex:(NSInteger)specifiedChapter {
    if (self = [super init]) {
        self.specifiedChapter = specifiedChapter;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[WXYZ_ReaderSettingHelper sharedManager] hiddenStatusBar];
    // 屏幕常亮开启
    [[WXYZ_ReaderSettingHelper sharedManager] openScreenKeep];
    
    [self hiddenHomeIndicator];
    
    [[WXYZ_TouchAssistantView sharedManager] hiddenAssistiveTouchView];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Show_PayView object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Hidden_Tabbar object:@"1"];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] modificationCollectionWithProductionModel:self.readerManager.bookModel];
    if (!self.isJumpToMenuView) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Show_Tabbar object:@"animation"];
    }
    
    [self viewWillResignActive];
    
    [[WXYZ_TouchAssistantView sharedManager] showAssistiveTouchView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[WXYZ_ReaderSettingHelper sharedManager] showStatusBar];
    // 屏幕常亮关闭
    [[WXYZ_ReaderSettingHelper sharedManager] closeScreenKeep];
    
    [self showHomeIndicator];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isJumpToMenuView = NO;
    [self navigationCanSlidingBack:NO];
}

- (void)viewWillResignActive
{
    // 停止自动阅读
    [_readerMenuBar stopAutoRead];
    
    // 隐藏工具栏
    [_readerMenuBar hiddend];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    
    return YES;
}

- (void)initialize
{   
    [self hiddenNavigationBar:YES];
    
    _readerMenuBar = [WXYZ_BookReaderMenuBar sharedManager];
    
    _functionalManager = [WXYZ_ReaderSettingHelper sharedManager];
    
    _readerManager = [WXYZ_ReaderBookManager sharedManager];
    _readerManager.ticket_num = nil;
    _readerManager.reward_num = nil;
    _readerManager.markIndex = self.specificIndex;
    if (self.bookModel) {
        _readerManager.bookModel = self.bookModel;
        [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] moveCollectionToTopWithProductionModel:self.bookModel];
    } else {
        _readerManager.book_id = self.book_id;
    }
    
    // 设置bookid
    _readerManager.book_id = self.book_id;
    // 记录观看位置
    _readerManager.currentChapterIndex = [_functionalManager getMemoryChapterIndexWithBook_id:_book_id];
    _readerManager.currentPagerIndex = [_functionalManager getMemoryPagerIndexWithBook_id:_book_id];
    if (self.specificIndex != -1) {
        _readerManager.currentPagerIndex = self.chapterSort;
    }
    
    // 设置背景色
    self.view.backgroundColor = [_functionalManager getReaderBackgroundColor];
    
    // 设置滚动样式
    self.pageViewControllerStyle = [_functionalManager getTransitionStyle];
    
    // 菜单栏相关操作回调
    WS(weakSelf)
    // 字号改变
    _functionalManager.readerFontChanged = ^{
        [weakSelf showAttributeAtChapterIndex:weakSelf.readerManager.currentChapterIndex pagerIndex:weakSelf.readerManager.currentPagerIndex];
    };
    
    // 字体间距改变
    _functionalManager.readerLinesSpacingChanged = ^{
        [weakSelf showAttributeAtChapterIndex:weakSelf.readerManager.currentChapterIndex pagerIndex:weakSelf.readerManager.currentPagerIndex];
    };
    
    // 翻页样式改变
    _functionalManager.readerTransitionStyleChanged = ^(WXReaderTransitionStyle transitionStyle) {
        weakSelf.pageViewControllerStyle = transitionStyle;
        [weakSelf addPageViewController];
    };
    
    // 自动翻页
    self.readerAnimationLayer.readerAutoReadBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf turnThePage];
        });
    };
    
    // 自动阅读启动或者停止
    _functionalManager.readerAutoReaderStateChanged = ^(WXReaderAutoReadState state) {
        if (state == WXReaderAutoReadStateStart) {
            [weakSelf.readerAnimationLayer startReadingAnimation];
        } else if (state == WXReaderAutoReadStatePause) {
            [weakSelf.readerAnimationLayer pauseAnimation];
        } else if (state == WXReaderAutoReadStateResume) {
            [weakSelf.readerAnimationLayer resumeAnimation];
        } else {
            [weakSelf.readerAnimationLayer stopAnimation];
        }
    };
    
    _functionalManager.readerBackgroundViewChanged = ^() {
        [weakSelf.szPageViewController reloadData];
    };
    
    // 改变自动阅读间隔时间
    _functionalManager.readerAutoReadSpeedChanged = ^(NSInteger readSpeed) {
        [weakSelf.readerAnimationLayer resetDuration:readSpeed];
    };
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popViewController:) name:NSNotification_Reader_Back object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeEmptyState:) name:NSNotification_EmptyView_Changed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadChapterData:) name:NSNotification_Retry_Chapter object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCheckSetting) name:Notification_Check_Setting_Update object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushView:) name:NSNotification_Reader_Push object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToDownloadController) name:Notification_Push_To_Download object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadView) name:Notification_Reader_Ad_Hidden object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextChapter:) name:Notification_Reader_Ad_TurnThePage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookMark:) name:NSNOtification_Book_Mark object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

// 广告关闭后自动刷新页面
- (void)nextChapter:(NSNotification *)noti {
    if ([noti.object isEqualToString:@"1"]) {
        [self turnThePage];
    }
}

- (void)reloadView {
    [self showAttributeAtChapterIndex:self.readerManager.currentChapterIndex pagerIndex:self.readerManager.currentPagerIndex];
}

- (void)bookMark:(NSNotification *)noti {
    NSDictionary *dict = noti.object;
    
    NSInteger chapterSort = [dict.allKeys.firstObject integerValue];
    NSInteger specificIndex = [dict.allValues.firstObject integerValue];
    
    self.specifiedPage = -1;
    self.specifiedChapter = -1;
    
    self.readerManager.markIndex = specificIndex;
    self.specificIndex = specificIndex;
    [self showAttributeAtChapterIndex:chapterSort pagerIndex:0];
}

- (void)createSubviews
{
    [self addPageViewController];
    int startNum = [[[NSUserDefaults standardUserDefaults] objectForKey:WX_GUIDE_SHOW] intValue];
    if (startNum == 0) {
        WXYZ_GuideView *guideView = [[WXYZ_GuideView alloc] initWithGuideType:WXYZ_GuideTypeBookReader];
        [self.view addSubview:guideView];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:WX_GUIDE_SHOW];
    }
    
    if ([WXYZ_ADManager canLoadAd:WXYZ_ADViewTypeBook adPosition:WXYZ_ADViewPositionBottom]) {
        [self.view addSubview:self.adView];
    }
    
}

- (void)addTapGestureAtController:(UIViewController *)controller
{
    if (self.pageViewControllerStyle == WXReaderTransitionStylePageCurl) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGesture:)];
        [controller.view addGestureRecognizer:tap];
        
        for (UIGestureRecognizer *t_ges in _pageViewController.gestureRecognizers) {
            if ([t_ges isKindOfClass:[UIPanGestureRecognizer class]]) {
                [t_ges addTarget:self action:@selector(pageViewPan:)];
            }
        }
    }
    
    UITapGestureRecognizer *readerViewSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGesture:)];
    readerViewSingleTap.delegate = self;
    readerViewSingleTap.numberOfTapsRequired = 1;
    readerViewSingleTap.numberOfTouchesRequired = 1;
    [controller.view addGestureRecognizer:readerViewSingleTap];
    
}

- (void)pageViewPan:(UIPanGestureRecognizer *)pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.sliding = YES;
            break;
        case UIGestureRecognizerStateChanged:
            
            break;
        case UIGestureRecognizerStateEnded:
            if (self.needMoveBack) {
                self.turnAfter = NO;
                self.turnBefore = NO;
                if ([_readerManager haveNextChapter]) {
                    [_readerManager getNextPagerAttributedText:nil];
                }
            }
            break;
        case UIGestureRecognizerStateCancelled:
            self.sliding = NO;
            break;
        case UIGestureRecognizerStateFailed:
            self.sliding = NO;
            break;
            
        default:
            break;
    }
}

- (void)singleTapGesture:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self.view];
    if (point.x > SCREEN_WIDTH / 3 && point.x < SCREEN_WIDTH / 3 * 2) {
        [_readerMenuBar show];
    } else  if (point.x <= SCREEN_WIDTH / 3 && !self.sliding) {
        [_readerMenuBar hiddend];
        if (self.pageViewControllerStyle == WXReaderTransitionStylePageCurl && !self.sliding) {
            WXYZ_BookReaderTextViewController *readerBookViewController = [[WXYZ_BookReaderTextViewController alloc] init];
            
            if (![_readerManager isTheFormerPager]) {
                if (![_readerManager havePreCache]) {
                    [self showAlertView];
                }
                WS(weakSelf)
                [_readerManager getPrePagerAttributedText:^(NSAttributedString * _Nullable content) {
                    [weakSelf hideAlertView];
                    if (content.length > 0) {
                        readerBookViewController.contentString = content;
                        WXYZ_BookReaderBackViewController *backViewController = [[WXYZ_BookReaderBackViewController alloc] init];
                        [backViewController updateWithViewController:(id)readerBookViewController];
                        [_pageViewController setViewControllers:@[readerBookViewController?:[[WXYZ_BasicViewController alloc] init], backViewController?:[[WXYZ_BasicViewController alloc] init]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
                    }
                }];
            }
        }
    } else if (point.x >= SCREEN_WIDTH / 3 * 2 && !self.sliding) {
        [_readerMenuBar hiddend];
        
        if (self.pageViewControllerStyle == WXReaderTransitionStylePageCurl) {
            WXYZ_BookReaderTextViewController *readerBookViewController = [[WXYZ_BookReaderTextViewController alloc] init];
            
            if ([_readerManager haveNextChapter] || [_readerManager haveNextPager]) {
                if (![_readerManager haveNextCache]) {
                    [self showAlertView];
                }
                WS(weakSelf)
                [_readerManager getNextPagerAttributedText:^(NSAttributedString *content) {
                    [weakSelf hideAlertView];
                    if (content.length > 0) {
                        readerBookViewController.contentString = content;
                        WXYZ_BookReaderBackViewController *backViewController = [[WXYZ_BookReaderBackViewController alloc] init];
                        [backViewController updateWithViewController:(id)readerBookViewController];
                        [_pageViewController setViewControllers:@[readerBookViewController?:[[WXYZ_BasicViewController alloc] init], backViewController?:[[WXYZ_BasicViewController alloc] init]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
                    }
                }];
            } else if ([_readerManager isTheLastPager]) {
                
            }
        }
    }
    self.sliding = NO;
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint touchPoint = [touch locationInView:self.view];
    if (self.pageViewControllerStyle == WXReaderTransitionStylePageCurl && (touchPoint.x >= 80 && touchPoint.x <= SCREEN_WIDTH - 80)) {
        return YES;
    }
    if (touchPoint.x < SCREEN_WIDTH / 3 || touchPoint.x > SCREEN_WIDTH / 3 * 2) {
        return NO;
    }
    return YES;
}

- (void)popViewController:(NSNotification *)noti
{
    BOOL containModel = NO;
    for (WXYZ_ProductionModel *t_model in [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] getAllCollection]) {
        if (t_model.production_id == self.book_id) {
            containModel = YES;
        }
    }
    
    if (!containModel && !noti.object) {
        WS(weakSelf)
        WXYZ_AlertView *alert = [[WXYZ_AlertView alloc] init];
        alert.alertViewDetailContent = @"是否收藏";
        alert.alertViewCancelTitle = @"再看看";
        alert.alertViewConfirmTitle = @"收藏";
        alert.confirmButtonClickBlock = ^{
            
            [WXYZ_UtilsHelper synchronizationRackProductionWithProduction_id:self.bookModel.production_id productionType:WXYZ_ProductionTypeBook complete:nil];
            [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] addCollectionWithProductionModel:weakSelf.readerManager.bookModel atIndex:0];
            [[WXYZ_BookReaderMenuBar sharedManager] hiddend];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        alert.cancelButtonClickBlock = ^{
            [[WXYZ_BookReaderMenuBar sharedManager] hiddend];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        [alert showAlertView];
        return;
    }
    
    [[WXYZ_BookReaderMenuBar sharedManager] stopAutoRead];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushView:(NSNotification *)noti
{
    self.isJumpToMenuView = YES;
    // 跳转到目录
    if ([noti.object isEqualToString:@"WXBookDirectoryViewController"]) {
        [[WXYZ_BookReaderMenuBar sharedManager] hiddend];
        WXYZ_DirectoryViewController *vc = [[WXYZ_DirectoryViewController alloc] init];
        vc.isReader = YES;
        vc.bookModel = _readerManager.bookModel;
        vc.currentIndex = _readerManager.currentChapterIndex;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    // 跳转到评论
    if ([noti.object isEqualToString:@"WXYZ_CommentsViewController"]) {
        [[WXYZ_BookReaderMenuBar sharedManager] hiddend];
        WXYZ_CommentsViewController *vc = [[WXYZ_CommentsViewController alloc] init];
        vc.pushFromReader = YES;
        vc.production_id = self.book_id;
        vc.chapter_id = self.readerManager.chapter_id;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if ([noti.object isEqualToString:@"WXYZ_RechargeViewController"]) {
        WXYZ_RechargeViewController *vc = [[WXYZ_RechargeViewController alloc] init];
        vc.production_id = self.book_id;
        vc.productionType = WXYZ_ProductionTypeBook;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if ([noti.object isEqualToString:@"WXYZ_BookBackSideViewController"]) {
        WXYZ_BookBackSideViewController *vc = [[WXYZ_BookBackSideViewController alloc] init];
        vc.bookModel = _readerManager.bookModel;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if ([noti.object isEqualToString:@"WXYZ_BookMallDetailViewController"]) {
        WXYZ_BookMallDetailViewController *vc = [[WXYZ_BookMallDetailViewController alloc] init];
        vc.isReader = YES;
        vc.book_id = self.readerManager.book_id;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pushToDownloadController
{
#if WX_Download_Mode
    self.isJumpToMenuView = YES;
    WXYZ_DownloadCacheViewController *vc = [[WXYZ_DownloadCacheViewController alloc] init];
    vc.onlyBookMode = YES;
    vc.pushFromReader = YES;
    [self.navigationController pushViewController:vc animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Hidden_Tabbar object:nil];
#endif
}

- (void)changeEmptyState:(NSNotification *)noti
{
    NSInteger number = [noti.object integerValue];
    if (self.emptyData == number) {
        return;
    }
    if (number == 1) {
        self.emptyData = YES;
    } else {
        self.emptyData = NO;
    }
}

- (void)reloadChapterData:(NSNotification *)noti
{
    if (noti.object) {
        [self showAttributeAtChapterIndex:_readerManager.currentChapterIndex pagerIndex:0];
    } else {
        [self showAttributeAtChapterIndex:_readerManager.currentChapterIndex pagerIndex:_readerManager.currentPagerIndex];
    }
}

- (void)updateCheckSetting
{
    WS(weakSelf)
    // 重加载目录
    [[WXYZ_ReaderBookManager sharedManager] requestBookModelWithBookId:self.book_id completionHandler:^{
        [weakSelf reloadChapterData:nil];
    }];
    
    if (![WXYZ_ADManager canLoadAd:WXYZ_ADViewTypeBook adPosition:WXYZ_ADViewPositionBottom]) {
        self.pageViewController.view.frame = self.view.frame;
        self.adView.hidden = YES;
    } else {
        self.pageViewController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, [[WXYZ_ReaderSettingHelper sharedManager] getReaderViewBottom] + kMargin + kHalfMargin);
        self.adView.hidden = NO;
    }
}

// 翻页
- (void)turnThePage
{
    if (self.pageViewControllerStyle == WXReaderTransitionStyleCover) {
        if ([self.szPageViewController canSwitchToIndex:_readerManager.currentPagerIndex + 1]) {
            [self.szPageViewController switchToIndex:_readerManager.currentPagerIndex + 1 animated:YES];
        }
        
    } else if (self.pageViewControllerStyle == WXReaderTransitionStyleNone) {
        if ([self.szPageViewController canSwitchToIndex:_readerManager.currentPagerIndex + 1]) {
            [self.szPageViewController switchToIndex:_readerManager.currentPagerIndex + 1 animated:NO];
        }
    } else if (self.pageViewControllerStyle == WXReaderTransitionStylePageCurl) {
        
        WXYZ_BookReaderTextViewController *readerBook = [[WXYZ_BookReaderTextViewController alloc] init];
        
        if ([_readerManager haveNextChapter] || [_readerManager haveNextPager]) {
            if (![_readerManager haveNextCache]) {
                [self showAlertView];
            }
            WS(weakSelf)
            [_readerManager getNextPagerAttributedText:^(NSAttributedString *content) {
                [weakSelf hideAlertView];
                readerBook.contentString = content;
            }];
        } else {
            if ([_readerManager isTheLastPager]) {
                [[WXYZ_BookReaderMenuBar sharedManager] stopAutoRead];
                return;
            }
        }
        
        WXYZ_BookReaderBackViewController *backViewController = [[WXYZ_BookReaderBackViewController alloc] init];
        [backViewController updateWithViewController:readerBook];
        
        [self.pageViewController setViewControllers:@[readerBook?:[[WXYZ_BasicViewController alloc] init], backViewController?:[[WXYZ_BasicViewController alloc] init]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
            
        }];
        
    } else if (self.pageViewControllerStyle == WXReaderTransitionStyleScroll) {
        
        if ([self.dpPageViewController canSwitchToIndex:_readerManager.currentPagerIndex + 1]) {
            [self.dpPageViewController switchToIndex:_readerManager.currentPagerIndex + 1 animated:YES];
        }
    }
}

// 自动阅读动画
- (WXYZ_ReaderAnimationLayer *)readerAnimationLayer
{
    if (!_readerAnimationLayer) {
        _readerAnimationLayer = [[WXYZ_ReaderAnimationLayer alloc] initWithView:self.view];
    }
    return _readerAnimationLayer;
}

- (WXYZ_ADManager *)adView
{
    if (!_adView) {
        CGFloat y = [[WXYZ_ReaderSettingHelper sharedManager] getReaderViewBottom] + kMargin + kHalfMargin;
        CGRect frame = CGRectMake(0, y, SCREEN_WIDTH, SCREEN_HEIGHT - y);
        _adView = [[WXYZ_ADManager alloc] initWithFrame:frame adType:WXYZ_ADViewTypeBook adPosition:WXYZ_ADViewPositionBottom];
    }
    return _adView;
}

- (void)addPageViewController
{
    if (self.pageViewController) {
        
        for (UIGestureRecognizer *t_gesture in self.pageViewController.gestureRecognizers) {
            [self.pageViewController.view removeGestureRecognizer:t_gesture];
        }
        [self.pageViewController.view removeAllSubviews];
        [self.pageViewController.view removeFromSuperview];
        [self.pageViewController removeFromParentViewController];
        self.pageViewController = nil;
    }
    
    if (self.szPageViewController) {
        for (UIGestureRecognizer *t_gesture in self.szPageViewController.view.gestureRecognizers) {
            [self.szPageViewController.view removeGestureRecognizer:t_gesture];
        }
        
        [self.szPageViewController.view removeAllSubviews];
        [self.szPageViewController.view removeFromSuperview];
        [self.szPageViewController removeFromParentViewController];
        self.szPageViewController = nil;
    }
    
    if (self.dpPageViewController) {
        for (UIGestureRecognizer *t_gesture in self.dpPageViewController.view.gestureRecognizers) {
            [self.dpPageViewController.view removeGestureRecognizer:t_gesture];
        }
        
        [self.dpPageViewController.view removeAllSubviews];
        [self.dpPageViewController.view removeFromSuperview];
        [self.dpPageViewController removeFromParentViewController];
        self.dpPageViewController = nil;
    }
    
    switch (self.pageViewControllerStyle) {
        case WXReaderTransitionStyleNone:
        {
            WXYZ_CoverPageViewController *pageVC = [[WXYZ_CoverPageViewController alloc] init];
            pageVC.dataSource = self;
            pageVC.delegate = self;
            pageVC.circleSwitchEnabled = YES;
            pageVC.contentModeController = NO;
            pageVC.switchAnimated = NO;
            pageVC.view.backgroundColor = [_functionalManager getReaderBackgroundColor];
            
            [self addChildViewController:pageVC];
            [self.view addSubview:pageVC.view];
            
            self.szPageViewController = pageVC;
            
            [self addTapGestureAtController:self.szPageViewController];
            
            [self showAttributeAtChapterIndex:_readerManager.currentChapterIndex pagerIndex:_readerManager.currentPagerIndex];
        }
            break;
        case WXReaderTransitionStyleCover:
        {
            WXYZ_CoverPageViewController *pageVC = [[WXYZ_CoverPageViewController alloc] init];
            pageVC.dataSource = self;
            pageVC.delegate = self;
            pageVC.circleSwitchEnabled = YES;
            pageVC.contentModeController = NO;
            pageVC.switchAnimated = YES;
            pageVC.view.backgroundColor = [_functionalManager getReaderBackgroundColor];
            
            [self addChildViewController:pageVC];
            [self.view addSubview:pageVC.view];
            
            self.szPageViewController = pageVC;
            
            [self addTapGestureAtController:self.szPageViewController];
            
            [self showAttributeAtChapterIndex:_readerManager.currentChapterIndex pagerIndex:_readerManager.currentPagerIndex];
        }
            break;
        case WXReaderTransitionStyleScroll:
        {
            WXYZ_ScorllPageViewController *pageVC = [[WXYZ_ScorllPageViewController alloc] init];
            pageVC.dataSource = self;
            pageVC.delegate = self;
            pageVC.circleSwitchEnabled = YES;
            pageVC.switchAnimated = YES;
            pageVC.view.backgroundColor = [_functionalManager getReaderBackgroundColor];
            
            [self addChildViewController:pageVC];
            [self.view addSubview:pageVC.view];
            
            self.dpPageViewController = pageVC;
            
            [self addTapGestureAtController:self.dpPageViewController];
            
            [self showAttributeAtChapterIndex:_readerManager.currentChapterIndex pagerIndex:_readerManager.currentPagerIndex];
        }
            break;
        case WXReaderTransitionStylePageCurl:
        {
            UIPageViewController *pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionSpineLocationKey : @(UIPageViewControllerSpineLocationMin)}];
            pageViewController.delegate = self;
            pageViewController.dataSource = self;
            pageViewController.doubleSided = YES;
            if ([WXYZ_ADManager canLoadAd:WXYZ_ADViewTypeBook adPosition:WXYZ_ADViewPositionBottom]) {
                pageViewController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, [[WXYZ_ReaderSettingHelper sharedManager] getReaderViewBottom] + kMargin + kHalfMargin);
            } else {
                pageViewController.view.frame = self.view.frame;
            }
            
            [self addChildViewController:pageViewController];
            [self.view addSubview:pageViewController.view];
            _pageViewController = pageViewController;
            
            [self addTapGestureAtController:_pageViewController];
            
            [self showAttributeAtChapterIndex:_readerManager.currentChapterIndex pagerIndex:_readerManager.currentPagerIndex];
            
        }
            break;
            
        default:
            break;
    }
    
    if ([WXYZ_NetworkReachabilityManager networkingStatus]) {
        [self.view bringSubviewToFront:self.adView];
    }

}

// 显示章节内容
- (void)showAttributeAtChapterIndex:(NSInteger)chapterIndex pagerIndex:(NSInteger)pagerIndex
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.blankStatus == NO) {
            WS(weakSelf)
            UIView *loadinView = [WXYZ_TopAlertManager showLoading:self.view];
            [loadinView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
                if (weakSelf.readerMenuBar.hidden) {
                    [weakSelf.readerMenuBar show];
                } else {
                    [weakSelf.readerMenuBar hiddend];
                }
            }]];
        }
    });
    

    WS(weakSelf)
    if (self.pageViewControllerStyle == WXReaderTransitionStyleCover ||
        self.pageViewControllerStyle == WXReaderTransitionStyleNone) {
        
        [_readerManager getPagerAttributedTextWithChapterIndex:chapterIndex pagerIndex:pagerIndex completionHandler:^(NSAttributedString *content) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.blankStatus = YES;
                WXYZ_BookReaderTextViewController *readerController = [[WXYZ_BookReaderTextViewController alloc] init];
                readerController.contentString = content;
                weakSelf.currentTextViewController = readerController;
                [weakSelf.szPageViewController reloadData];
                [WXYZ_TopAlertManager hideLoading];
                weakSelf.specificIndex = -1;
                weakSelf.specifiedPage = -1;
                weakSelf.readerManager.markIndex = -1;
            });
        }];
        
    } else if (self.pageViewControllerStyle == WXReaderTransitionStylePageCurl) {
        
        [_readerManager getPagerAttributedTextWithChapterIndex:chapterIndex pagerIndex:pagerIndex completionHandler:^(NSAttributedString *content) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.blankStatus = YES;
                WXYZ_BookReaderTextViewController *readerController = [[WXYZ_BookReaderTextViewController alloc] init];
                readerController.contentString = content;
                [weakSelf.pageViewController setViewControllers:@[readerController?:[[WXYZ_BasicViewController alloc] init]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
                [WXYZ_TopAlertManager hideLoading];
                weakSelf.specificIndex = -1;
                weakSelf.specifiedPage = -1;
                weakSelf.readerManager.markIndex = -1;
            });
        }];
    } else if (self.pageViewControllerStyle == WXReaderTransitionStyleScroll) {
        [_readerManager getPagerAttributedTextWithChapterIndex:chapterIndex pagerIndex:pagerIndex completionHandler:^(NSAttributedString *content) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.blankStatus = YES;
                WXYZ_BookReaderTextViewController *readerController = [[WXYZ_BookReaderTextViewController alloc] init];
                readerController.contentString = content;
                weakSelf.currentTextViewController = readerController;
                [weakSelf.dpPageViewController reloadData];
                [WXYZ_TopAlertManager hideLoading];
                weakSelf.specificIndex = -1;
                weakSelf.specifiedPage = -1;
                weakSelf.readerManager.markIndex = -1;
            });
        }];
    }
}

#pragma mark - UIPageViewController Delegate

// 向前翻阅
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[WXYZ_BookReaderTextViewController class]] &&
        self.pageViewControllerStyle == WXReaderTransitionStylePageCurl) {
        
        WXYZ_BookReaderBackViewController *backViewController = [[WXYZ_BookReaderBackViewController alloc] init];
        [backViewController updateWithViewController:(id)viewController];
        return backViewController;
    }
    
    if (self.turnBefore) {
        if ([_readerManager haveNextPager]) {
            [_readerManager getNextPagerAttributedText:nil];
        }
    }
    self.turnBefore = YES;
    self.needMoveBack = YES;
    WXYZ_BookReaderTextViewController *readerBook = [[WXYZ_BookReaderTextViewController alloc] init];
    
    if (![_readerManager isTheFormerPager]) {
        if (![_readerManager havePreCache]) {
            [self showAlertView];
        }
        WS(weakSelf)
        [_readerManager getPrePagerAttributedText:^(NSAttributedString * _Nullable content) {
            [weakSelf hideAlertView];
            readerBook.contentString = content;
        }];
        return readerBook;
    } else {
        self.turnBefore = NO;
        return nil;
    }
}

// 向后翻阅
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    if (_emptyData) {
        return nil;
    }
   if ([viewController isKindOfClass:[WXYZ_BookReaderTextViewController class]] &&
        self.pageViewControllerStyle == WXReaderTransitionStylePageCurl) {
        
        WXYZ_BookReaderBackViewController *backViewController = [[WXYZ_BookReaderBackViewController alloc] init];
        [backViewController updateWithViewController:(id)viewController];
        return backViewController;
    }
    
    self.turnAfter = YES;
    if (self.turnBefore) {
        if ([_readerManager haveNextPager]) {
            [_readerManager getNextPagerAttributedText:nil];
            self.turnBefore = NO;
        }
    }
    
    WXYZ_BookReaderTextViewController *readerBook = [[WXYZ_BookReaderTextViewController alloc] init];
    
    if ([_readerManager haveNextChapter] || ![_readerManager isTheLastPager]) {
        if (![_readerManager haveNextCache]) {
            [self showAlertView];
        }
        WS(weakSelf)
        [_readerManager getNextPagerAttributedText:^(NSAttributedString *content) {
            [weakSelf hideAlertView];
            readerBook.contentString = content;
        }];
        return readerBook;
    } else {
        self.turnAfter = NO;
        return nil;
    }
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    self.needMoveBack = NO;
    [self.readerAnimationLayer resetAnimation];
    self.pageViewController.view.userInteractionEnabled = NO;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (finished || completed) {
        // 返回数据前关闭交互，确保只允许翻一页
        self.pageViewController.view.userInteractionEnabled = YES;
        self.needMoveBack = NO;
        if (!completed) {
            if (self.turnAfter) {
                if (![_readerManager isTheFormerPager]) {
                    [_readerManager getPrePagerAttributedText:^(NSAttributedString * _Nullable content) {
                        
                    }];
                }
            }
            
            if (self.turnBefore) {
                if ([_readerManager haveNextPager]) {
                    [_readerManager getNextPagerAttributedText:nil];
                }
            }
        }
        self.turnAfter = NO;
        self.turnBefore = NO;
        self.sliding = NO;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.pageViewController.view.userInteractionEnabled = YES;
    
    if (!self.turnAfter && !self.turnBefore) {
        if (![_readerManager haveNextPager]) {
            [self turnThePage];
        }        
    }
}

#pragma mark -  SZPageControllerDelegate Delegate
- (NSInteger)numberOfPagesInPageController:(WXYZ_CoverPageViewController *)pageController
{
    return _readerManager.currentChapterPagerCount + 1;
}

- (UIView *)pageController:(WXYZ_CoverPageViewController *)pageController viewForIndex:(NSInteger)index direction:(PageRollingDirection)rollingDirection
{
    self.coverPagerIndex = index;
    [self.readerAnimationLayer resetAnimation];
    WXYZ_BookReaderTextViewController *readerBook = [[WXYZ_BookReaderTextViewController alloc] init];
    
    switch (rollingDirection) {
        case PageRollingDirectionNone:
        {
            [_readerManager getPagerAttributedTextWithChapterIndex:_readerManager.currentChapterIndex pagerIndex:_readerManager.currentPagerIndex completionHandler:^(NSAttributedString *content) {
                readerBook.contentString = content;
            }];
            return readerBook.view;
        }
            break;
        case PageRollingDirectionLeft:
            if (![_readerManager isTheFormerPager]) {
                if (![_readerManager havePreCache]) {
                    [self showAlertView];
                }
                WS(weakSelf)
                [_readerManager getPrePagerAttributedText:^(NSAttributedString * _Nullable content) {
                    [weakSelf hideAlertView];
                    readerBook.contentString = content;
                }];
                self.currentTextViewController = readerBook;
            } else {
                return nil;
            }
            return readerBook.view;
            break;
        case PageRollingDirectionRight:
            if ([_readerManager haveNextChapter]) {
                if (![_readerManager haveNextCache]) {
                    [self showAlertView];
                }
                WS(weakSelf)
                [_readerManager getNextPagerAttributedText:^(NSAttributedString *content) {
                    [weakSelf hideAlertView];
                    readerBook.contentString = content;
                }];
                self.currentTextViewController = readerBook;
            } else {
                if ([_readerManager isTheLastPager]) {
                    return nil;
                } else {
                    if (![_readerManager haveNextCache]) {
                        [self showAlertView];
                    }
                    WS(weakSelf)
                    [_readerManager getNextPagerAttributedText:^(NSAttributedString *content) {
                        [weakSelf hideAlertView];
                        readerBook.contentString = content;
                    }];
                    self.currentTextViewController = readerBook;
                }
            }
            return readerBook.view;
            break;
            
        default:
            return nil;
            break;
    }
}

- (void)pageController:(nonnull WXYZ_CoverPageViewController *)pageController currentView:(nullable UIView *)currentView currentIndex:(NSInteger)currentIndex direction:(PageRollingDirection)rollingDirection
{
    if (self.coverPagerIndex == currentIndex) {
        return;
    }
    
    // 取消操作后重置数据页数
    
    if (rollingDirection == PageRollingDirectionLeft) { // 向后翻页取消
        [_readerManager getPrePagerAttributedText:nil];
    } else if (rollingDirection == PageRollingDirectionRight) { // 向前翻页取消
        [_readerManager getNextPagerAttributedText:nil];
    }
}

- (void)pageControllerSwitchToLastDisabled:(WXYZ_CoverPageViewController *)pageController {
    [self.szPageViewController reloadData];
}

- (void)pageControllerSwitchToNextDisabled:(WXYZ_CoverPageViewController *)pageController {
    [self.szPageViewController reloadData];
}

#pragma mark - DPPageViewControllerDelegate
- (NSInteger)dp_numberOfPagesInPageController:(WXYZ_CoverPageViewController *)pageController
{
    return _readerManager.currentChapterPagerCount + 1;
}

- (UIView *)dp_pageController:(WXYZ_CoverPageViewController *)pageController viewForIndex:(NSInteger)index direction:(DPPageRollingDirection)rollingDirection
{
    [self.readerAnimationLayer resetAnimation];
    WXYZ_BookReaderTextViewController *readerBook = [[WXYZ_BookReaderTextViewController alloc] init];
    
    switch (rollingDirection) {
        case DPPageRollingDirectionNone:
        {
            [_readerManager getPagerAttributedTextWithChapterIndex:_readerManager.currentChapterIndex pagerIndex:_readerManager.currentPagerIndex completionHandler:^(NSAttributedString *content) {
                readerBook.contentString = content;
            }];
            return readerBook.view;
        }
            break;
        case DPPageRollingDirectionLeft:
            
            if (![_readerManager isTheFormerPager]) {
                if (![_readerManager havePreCache]) {
                    [self showAlertView];
                }
                WS(weakSelf)
                [_readerManager getPrePagerAttributedText:^(NSAttributedString * _Nullable content) {
                    readerBook.contentString = content;
                    [weakSelf hideAlertView];
                }];
                self.currentTextViewController = readerBook;
                return readerBook.view;
            } else {
                return nil;
            }

            break;
        case DPPageRollingDirectionRight:
            if ([_readerManager haveNextChapter]) {
                if (![_readerManager haveNextCache]) {
                    [self showAlertView];
                }
                WS(weakSelf)
                [_readerManager getNextPagerAttributedText:^(NSAttributedString *content) {
                    [weakSelf hideAlertView];
                    readerBook.contentString = content;
                }];
                self.currentTextViewController = readerBook;
            } else {
                if ([_readerManager isTheLastPager]) {
                    return nil;
                } else {
                    if (![_readerManager haveNextCache]) {
                        [self showAlertView];
                    }
                    WS(weakSelf)
                    [_readerManager getNextPagerAttributedText:^(NSAttributedString *content) {
                        [weakSelf hideAlertView];
                        readerBook.contentString = content;
                    }];
                    self.currentTextViewController = readerBook;
                }
            }
            return readerBook.view;
            break;
            
        default:
            return nil;
            break;
    }
}

- (void)dp_pageControllerSwitchToLastDisabled:(WXYZ_CoverPageViewController *)pageController {
    [self.szPageViewController reloadData];
}

- (void)dp_pageControllerSwitchToNextDisabled:(WXYZ_CoverPageViewController *)pageController {
    [self.szPageViewController reloadData];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {

    if (!self.isJumpToMenuView) {
        if (self.isAT) {
            return [[DZMAnimatedTransitioning alloc] initWithOperation:operation];
        }
    }
    
    return nil;
}

static BOOL isShow;
- (void)showAlertView {
    isShow = YES;
    WS(weakSelf)
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_loadingView.superview) return;
        UIView *loadinView = [self showLoading];
        _loadingView = loadinView;
        [loadinView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            if (weakSelf.readerMenuBar.hidden) {
                [weakSelf.readerMenuBar show];
            } else {
                [weakSelf.readerMenuBar hiddend];
            }
        }]];
    });
}

- (void)hideAlertView {
    isShow = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    });
}

- (UIView *)showLoading {
    UIView *mainView = [[UIView alloc] init];
    mainView.backgroundColor = kColorRGBA(0, 0, 0, 0);
    [self.view addSubview:mainView];
    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(mainView.superview);
    }];
    
    NSMutableArray<YYImage *> *arr = [NSMutableArray array];
    for (int i = 0; i < 47; i++) {
        YYImage *image = [YYImage imageNamed:[NSString stringWithFormat:@"%@%d", @"loading", i]];
        image = [image imageWithColor:[[[WXYZ_ReaderSettingHelper sharedManager] getReaderTextColor] colorWithAlphaComponent:0.75]];
        [arr addObject:image];
    }
    
    YYAnimatedImageView *loadingView = [[YYAnimatedImageView alloc] init];
    loadingView.backgroundColor = [UIColor clearColor];
    loadingView.animationImages = arr;
    loadingView.animationDuration = 2.0;
    [loadingView startAnimating];
    [mainView addSubview:loadingView];
    [loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(mainView);
        make.width.mas_equalTo(90);
        make.height.equalTo(loadingView.mas_width).multipliedBy(150.0 / 240.0);
    }];
    __weak typeof(loadingView) weakView = loadingView;
    [NSTimer scheduledTimerWithTimeInterval:loadingView.animationDuration block:^(NSTimer * _Nonnull timer) {
           if (!weakView.superview) {
               [timer invalidate];
               timer = nil;
           }
           NSArray *t_arr = [[loadingView.animationImages reverseObjectEnumerator] allObjects];
           weakView.animationImages = t_arr;
       } repeats:YES];
    return mainView;
}

@end

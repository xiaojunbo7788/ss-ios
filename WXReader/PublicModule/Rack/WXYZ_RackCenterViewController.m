//
//  WXYZ_RackCenterViewController.m
//  WXReader
//
//  Created by Andrew on 2019/5/22.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_RackCenterViewController.h"
#import "WXYZ_TaskViewController.h"
#import "WXYZ_RackCenterPageViewController.h"

#if WX_Enable_Book
    #import "WXYZ_BookReaderViewController.h"
#endif

#import "SGPagingView.h"

#import "NSObject+DZM.h"
#import "UINavigationController+DZM.h"

@interface WXYZ_RackCenterViewController () <SGPageTitleViewDelegate, SGPageContentCollectionViewDelegate>
{
    NSMutableArray *childArr;
}

@property (nonatomic, strong) SGPageTitleView *pageTitleView;

@property (nonatomic, strong) SGPageContentCollectionView *pageContentCollectionView;

@end

@implementation WXYZ_RackCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setStatusBarDefaultStyle];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Show_Tabbar object:nil];
}

- (void)initialize
{
    [self hiddenNavigationBarLeftButton];
    [self hiddenSeparator];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synchronizationRack) name:Notification_Login_Success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synchronizationRack) name:Notification_Reload_Rack_Production object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synchronizationRack) name:UIApplicationWillEnterForegroundNotification object:nil];
    
}

- (void)synchronizationRack
{
    [WXYZ_UtilsHelper synchronizationRack];
}

- (void)createSubviews
{
#if WX_Enable_Book
    WS(weakSelf)
    WXYZ_RackCenterPageViewController *bookVC = [[WXYZ_RackCenterPageViewController alloc] init];
    bookVC.productionType = WXYZ_ProductionTypeBook;
    bookVC.pushToReaderViewControllerBlock = ^(UIView * _Nonnull transitionView, WXYZ_ProductionModel * _Nonnull productionModel) {
        weakSelf.ATTarget = transitionView;
        WXYZ_BookReaderViewController *vc = [[WXYZ_BookReaderViewController alloc] init];
        vc.book_id = productionModel.production_id;
        [weakSelf.navigationController pushATViewController:vc animated:YES];
    };
    bookVC.view.backgroundColor = kWhiteColor;
    [self addChildViewController:bookVC];
#endif
    
#if WX_Enable_Comic
    WXYZ_RackCenterPageViewController *comicVC = [[WXYZ_RackCenterPageViewController alloc] init];
    comicVC.productionType = WXYZ_ProductionTypeComic;
    comicVC.view.backgroundColor = kWhiteColor;
    [self addChildViewController:comicVC];
#endif
    
#if WX_Enable_Audio
    WXYZ_RackCenterPageViewController *audioVC = [[WXYZ_RackCenterPageViewController alloc] init];
    audioVC.productionType = WXYZ_ProductionTypeAudio;
    audioVC.view.backgroundColor = kWhiteColor;
    [self addChildViewController:audioVC];
#endif
    
    NSMutableArray *titleArr = [NSMutableArray array];
    childArr = [NSMutableArray array];
    
    for (NSNumber *siteNumber in [WXYZ_UtilsHelper getSiteState]) {
#if WX_Enable_Book
        if ([siteNumber integerValue] == 1) {
            [titleArr addObject:@"小说"];
            [childArr addObject:bookVC];
        }
#endif
        
#if WX_Enable_Comic
        if ([siteNumber integerValue] == 2) {
            [titleArr addObject:@"漫画"];
            [childArr addObject:comicVC];
        }
#endif
        
#if WX_Enable_Audio
        if ([siteNumber integerValue] == 3) {
            [titleArr addObject:@"听书"];
            [childArr addObject:audioVC];
        }
#endif
    }
    
    if ([WXYZ_UtilsHelper getSiteState].count == 1) {
        [titleArr removeAllObjects];
        [titleArr addObject:@"书架"];
    }
    
    self.pageContentCollectionView = [[SGPageContentCollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) parentVC:self childVCs:childArr];
    _pageContentCollectionView.delegatePageContentCollectionView = self;
    [self.view addSubview:self.pageContentCollectionView];
    
    self.pageConfigure.indicatorStyle = SGIndicatorStyleDynamic;
    self.pageConfigure.indicatorDynamicWidth = 14;
    self.pageConfigure.indicatorHeight = 3;
    self.pageConfigure.indicatorFixedWidth = 10;
    self.pageConfigure.indicatorToBottomDistance = 3;
    self.pageConfigure.titleSelectedColor = kBlackColor;
    self.pageConfigure.titleFont = kBoldFont16;
    self.pageConfigure.titleTextZoom = YES;
    self.pageConfigure.titleGradientEffect = YES;
    self.pageConfigure.titleTextZoomRatio = 0.5;
    self.pageConfigure.showIndicator = YES;
        
    self.pageTitleView = [SGPageTitleView pageTitleViewWithFrame:CGRectMake(kHalfMargin, (is_iPhoneX?kQuarterMargin:kHalfMargin) + kHalfMargin + PUB_NAVBAR_OFFSET, titleArr.count * 60, pageView_H) delegate:self titleNames:titleArr configure:self.pageConfigure];
    self.pageTitleView.backgroundColor = [UIColor clearColor];
    [self.navigationBar addSubview:_pageTitleView];
}

- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex {
    [self.pageContentCollectionView setPageContentCollectionViewCurrentIndex:selectedIndex];
}

- (void)pageContentCollectionView:(SGPageContentCollectionView *)pageContentCollectionView progress:(CGFloat)progress originalIndex:(NSInteger)originalIndex targetIndex:(NSInteger)targetIndex {
    [self.pageTitleView setPageTitleViewWithProgress:progress originalIndex:originalIndex targetIndex:targetIndex];
}

- (void)pageContentCollectionView:(SGPageContentCollectionView *)pageContentCollectionView index:(NSInteger)index
{
    for (UIViewController *vc in childArr) {
        [vc performSelector:@selector(endEdited)];
    }
}

@end

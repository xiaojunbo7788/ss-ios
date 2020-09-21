//
//  WXYZ_DiscoverViewController.m
//  WXReader
//
//  Created by Andrew on 2019/6/13.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_DiscoverViewController.h"

#if WX_Enable_Comic
    #import "WXYZ_ComicDiscoverViewController.h"
#endif

#if WX_Enable_Book
    #import "WXYZ_BookDiscoverViewController.h"
#endif

#if WX_Enable_Audio
    #import "WXYZ_AudioDiscoverViewController.h"
#endif

#import "WXYZ_LimitTimeFreeViewController.h"

#import "SGPagingView.h"

@interface WXYZ_DiscoverViewController () <SGPageTitleViewDelegate, SGPageContentCollectionViewDelegate>

@property (nonatomic, strong) SGPageTitleView *pageTitleView;
@property (nonatomic, strong) SGPageContentCollectionView *pageContentCollectionView;

@end

@implementation WXYZ_DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setStatusBarDefaultStyle];
}

- (void)initialize
{
    [self hiddenNavigationBarLeftButton];
    [self hiddenSeparator];
}

- (void)createSubviews
{
#if WX_Enable_Comic
    WXYZ_ComicDiscoverViewController *comicVC = [[WXYZ_ComicDiscoverViewController alloc] init];
    comicVC.productionType = WXYZ_ProductionTypeComic;
    [self addChildViewController:comicVC];
#endif
    
#if WX_Enable_Book
    WXYZ_BookDiscoverViewController *bookVC = [[WXYZ_BookDiscoverViewController alloc] init];
    bookVC.productionType = WXYZ_ProductionTypeBook;
    [self addChildViewController:bookVC];
#endif
    
#if WX_Enable_Audio
    WXYZ_AudioDiscoverViewController *audioVC = [[WXYZ_AudioDiscoverViewController alloc] init];
    audioVC.productionType = WXYZ_ProductionTypeAudio;
    [self addChildViewController:audioVC];
#endif
    
    NSMutableArray *titleArr = [NSMutableArray array];
    NSMutableArray *childArr = [NSMutableArray array];
    
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
        [titleArr addObject:@"发现"];
    }

    self.pageContentCollectionView = [[SGPageContentCollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) parentVC:self childVCs:childArr];
    _pageContentCollectionView.delegatePageContentCollectionView = self;
    [self.view addSubview:self.pageContentCollectionView];
    
    self.pageConfigure.indicatorStyle = SGIndicatorStyleDynamic;
    self.pageConfigure.indicatorHeight = 3;
    self.pageConfigure.indicatorFixedWidth = 10;
    self.pageConfigure.indicatorToBottomDistance = 3;
    self.pageConfigure.titleSelectedColor = kBlackColor;
    self.pageConfigure.titleFont = kBoldFont16;
    self.pageConfigure.titleTextZoom = YES;
    self.pageConfigure.titleGradientEffect = YES;
    self.pageConfigure.titleTextZoomRatio = 0.5;
    self.pageConfigure.indicatorDynamicWidth = 14;
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

@end

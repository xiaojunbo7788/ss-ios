//
//  WXYZ_LimitTimeFreeViewController.m
//  WXReader
//
//  Created by Andrew on 2019/6/25.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_LimitTimeFreeViewController.h"
#import "WXYZ_LimitTimeFreePageViewController.h"
#import "SGPagingView.h"

@interface WXYZ_LimitTimeFreeViewController () <
#if WX_Enable_PageControl
SGPageTitleViewDelegate,
#endif
SGPageContentCollectionViewDelegate>

#if WX_Enable_PageControl
@property (nonatomic, strong) SGPageTitleView *pageTitleView;
#endif
@property (nonatomic, strong) SGPageContentCollectionView *pageContentCollectionView;

@end

@implementation WXYZ_LimitTimeFreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
}

- (void)initialize
{
    [self setNavigationBarTitle:@"限时免费"];
    [self hiddenSeparator];
}

- (void)createSubviews
{
    WXYZ_LimitTimeFreePageViewController *boyVC = [[WXYZ_LimitTimeFreePageViewController alloc] init];
    boyVC.channel = @"1";
    boyVC.productionType = self.productionType;
    
#if WX_Enable_PageControl
    WXYZ_LimitTimeFreePageViewController *girlVC = [[WXYZ_LimitTimeFreePageViewController alloc] init];
    girlVC.channel = @"2";
    girlVC.productionType = self.productionType;
#endif
    
    NSArray *childArr = @[boyVC
#if WX_Enable_PageControl
                          , girlVC
#endif
                          ];
    
    
    self.pageContentCollectionView = [[SGPageContentCollectionView alloc] initWithFrame:
#if WX_Enable_PageControl
                                      CGRectMake(0, PUB_NAVBAR_HEIGHT + 44, SCREEN_WIDTH, SCREEN_HEIGHT)
#else
                                      CGRectMake(0, PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)
#endif
                                                                               parentVC:self childVCs:childArr];
    _pageContentCollectionView.delegatePageContentCollectionView = self;
    [self.view addSubview:self.pageContentCollectionView];
    
#if WX_Enable_PageControl
    NSArray *titleArr = @[@"男生", @"女生"];
    self.pageTitleView = [SGPageTitleView pageTitleViewWithFrame:CGRectMake(0, PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, 44) delegate:self titleNames:titleArr configure:self.pageConfigure];
    self.pageTitleView.backgroundColor = kWhiteColor;
    [self.view addSubview:_pageTitleView];
    
    if (WXYZ_SystemInfoManager.sexChannel == 2) {
        [self.pageTitleView setSelectedIndex:1];
    }
#endif
}

#if WX_Enable_PageControl
- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex {
    [self.pageContentCollectionView setPageContentCollectionViewCurrentIndex:selectedIndex];
}

- (void)pageContentCollectionView:(SGPageContentCollectionView *)pageContentCollectionView progress:(CGFloat)progress originalIndex:(NSInteger)originalIndex targetIndex:(NSInteger)targetIndex {
    [self.pageTitleView setPageTitleViewWithProgress:progress originalIndex:originalIndex targetIndex:targetIndex];
}
#endif

@end

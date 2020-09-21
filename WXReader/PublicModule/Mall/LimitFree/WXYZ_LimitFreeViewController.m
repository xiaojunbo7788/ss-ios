//
//  WXYZ_LimitFreeViewController.m
//  WXReader
//
//  Created by Andrew on 2018/6/19.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_LimitFreeViewController.h"
#import "WXYZ_LimitFreePageViewController.h"
#import "SGPagingView.h"

@interface WXYZ_LimitFreeViewController () <
#if WX_Enable_PageControl
SGPageTitleViewDelegate,
#endif
SGPageContentCollectionViewDelegate>

#if WX_Enable_PageControl
@property (nonatomic, strong) SGPageTitleView *pageTitleView;
#endif
@property (nonatomic, strong) SGPageContentCollectionView *pageContentCollectionView;

@end

@implementation WXYZ_LimitFreeViewController

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
    [self setNavigationBarTitle:self.navTitle?:@"免费"];
    [self hiddenSeparator];
}

- (void)createSubviews
{
    WXYZ_LimitFreePageViewController *boyVC = [[WXYZ_LimitFreePageViewController alloc] init];
    boyVC.productionType = self.productionType;
    boyVC.channel = @"1";
    
#if WX_Enable_PageControl
    WXYZ_LimitFreePageViewController *girlVC = [[WXYZ_LimitFreePageViewController alloc] init];
    girlVC.productionType = self.productionType;
    girlVC.channel = @"2";
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


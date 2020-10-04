//
//  WXYZ_FansViewController.m
//  WXReader
//
//  Created by LL on 2020/8/11.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_FansViewController.h"

#import "WXYZ_WebViewViewController.h"
#import "AppDelegate.h"

@interface WXYZ_FansViewController ()  <SGPageTitleViewDelegate, SGPageContentCollectionViewDelegate>

@property (nonatomic, strong) SGPageTitleView *pageTitleView;
@property (nonatomic, strong) SGPageContentCollectionView *pageContentCollectionView;
@property (nonatomic, strong) WXYZ_WebViewViewController *bookVC;

@end

@implementation WXYZ_FansViewController

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Show_Tabbar object:nil];
}

- (void)initialize
{
    [self hiddenNavigationBarLeftButton];
    [self hiddenSeparator];
}

- (void)createSubviews
{
    AppDelegate *app = (AppDelegate *)kRCodeSync([UIApplication sharedApplication].delegate);
    
    if (app.checkSettingModel.web_view_urlist != nil && app.checkSettingModel.web_view_urlist.count > 0) {
        [self succesState:app.checkSettingModel.web_view_urlist];
    } else {
        [self errorState];
    }
}

- (void)succesState:(NSArray *)data {
    
    
    
    NSMutableArray *titleArr = [[NSMutableArray alloc] init];
    NSMutableArray *childArr = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in data) {
        [titleArr addObject:dic[@"play_title"]];
        WXYZ_WebViewViewController *bookVC = [[WXYZ_WebViewViewController alloc] init];
        bookVC.isNoHiddenTab = true;
        bookVC.URLString = dic[@"play_url"];
        bookVC.OnTheFrontPage = YES;
        [bookVC hiddenNavigationBar:YES];
        [childArr addObject:bookVC];
    }


    self.pageContentCollectionView = [[SGPageContentCollectionView alloc] initWithFrame:CGRectMake(0, PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - PUB_TABBAR_HEIGHT - PUB_NAVBAR_HEIGHT) parentVC:self childVCs:childArr];
    _pageContentCollectionView.delegatePageContentCollectionView = self;
    [self.view addSubview:self.pageContentCollectionView];
    self.pageConfigure.indicatorStyle = SGIndicatorStyleDynamic;
    self.pageConfigure.indicatorDynamicWidth = 24;
    self.pageConfigure.indicatorHeight = 3;
    self.pageConfigure.indicatorFixedWidth = 10;
    self.pageConfigure.indicatorToBottomDistance = 3;
    self.pageConfigure.titleSelectedColor = kBlackColor;
    self.pageConfigure.titleFont = kBoldFont16;
    self.pageConfigure.titleTextZoom = YES;
    self.pageConfigure.titleGradientEffect = YES;
    self.pageConfigure.titleTextZoomRatio = 0.5;
    self.pageConfigure.showIndicator = YES;
       
    self.pageTitleView = [SGPageTitleView pageTitleViewWithFrame:CGRectMake(kHalfMargin, (is_iPhoneX?kQuarterMargin:kHalfMargin) + kHalfMargin + PUB_NAVBAR_OFFSET, childArr.count * 60, pageView_H) delegate:self titleNames:titleArr configure:self.pageConfigure];
    self.pageTitleView.backgroundColor = [UIColor clearColor];
    [self.navigationBar addSubview:_pageTitleView];
}

- (void)errorState {
     AppDelegate *app = (AppDelegate *)kRCodeSync([UIApplication sharedApplication].delegate);
    self.bookVC = [[WXYZ_WebViewViewController alloc] init];
    self.bookVC.URLString = app.checkSettingModel.web_view_url;
    self.bookVC.OnTheFrontPage = YES;
    [self.bookVC hiddenNavigationBar:YES];

    NSArray *titleArr = @[@"娱乐"];
    NSArray *childArr = @[self.bookVC];
    CGFloat pageView_Width = 80;

    self.pageContentCollectionView = [[SGPageContentCollectionView alloc] initWithFrame:CGRectMake(0, PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - PUB_TABBAR_HEIGHT - PUB_NAVBAR_HEIGHT) parentVC:self childVCs:childArr];
    _pageContentCollectionView.delegatePageContentCollectionView = self;
    [self.view addSubview:self.pageContentCollectionView];
    self.pageConfigure.indicatorStyle = SGIndicatorStyleDynamic;
    self.pageConfigure.indicatorDynamicWidth = 24;
    self.pageConfigure.indicatorHeight = 3;
    self.pageConfigure.indicatorFixedWidth = 10;
    self.pageConfigure.indicatorToBottomDistance = 3;
    self.pageConfigure.titleSelectedColor = kBlackColor;
    self.pageConfigure.titleFont = kBoldFont16;
    self.pageConfigure.titleTextZoom = YES;
    self.pageConfigure.titleGradientEffect = YES;
    self.pageConfigure.titleTextZoomRatio = 0.5;
    self.pageConfigure.showIndicator = YES;
       
    self.pageTitleView = [SGPageTitleView pageTitleViewWithFrame:CGRectMake(kHalfMargin, (is_iPhoneX?kQuarterMargin:kHalfMargin) + kHalfMargin + PUB_NAVBAR_OFFSET, pageView_Width, pageView_H) delegate:self titleNames:titleArr configure:self.pageConfigure];
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

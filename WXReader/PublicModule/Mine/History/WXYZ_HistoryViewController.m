//
//  WXYZ_HistoryViewController.m
//  WXReader
//
//  Created by Andrew on 2019/6/18.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_HistoryViewController.h"
#import "WXYZ_HistoryPageViewController.h"

#import "SGPagingView.h"

@interface WXYZ_HistoryViewController () <SGPageTitleViewDelegate, SGPageContentCollectionViewDelegate>

@property (nonatomic, strong) SGPageTitleView *pageTitleView;
@property (nonatomic, strong) SGPageContentCollectionView *pageContentCollectionView;

@property (nonatomic, weak) WXYZ_HistoryPageViewController *bookVC;

@property (nonatomic, weak) WXYZ_HistoryPageViewController *comicVC;

@property (nonatomic, weak) WXYZ_HistoryPageViewController *audioVC;

@end

@implementation WXYZ_HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarDefaultStyle];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Hidden_Tabbar object:@"1"];
    
}

- (void)initialize
{
    [self setNavigationBarTitle:@"历史记录"];
    [self hiddenSeparator];
    UIButton *rightButton;
    [self setNavigationBarRightButton:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton = button;
        [button setTitle:@"清空" forState:UIControlStateNormal];
        [button setTitleColor:kGrayTextColor forState:UIControlStateNormal];
        button.titleLabel.font = kFont14;
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(stepClear) forControlEvents:UIControlEventTouchUpInside];
        button;
    })];
    [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-kMargin);
        make.centerY.equalTo(self.navigationBar.navTitleLabel);
    }];
}

- (void)createSubViews
{
#if WX_Enable_Comic
    WXYZ_HistoryPageViewController *comicVC = [[WXYZ_HistoryPageViewController alloc] init];
    self.comicVC = comicVC;
    comicVC.productionType = WXYZ_ProductionTypeComic;
    [self addChildViewController:comicVC];
#endif
    
#if WX_Enable_Book
    WXYZ_HistoryPageViewController *bookVC = [[WXYZ_HistoryPageViewController alloc] init];
    self.bookVC = bookVC;
    bookVC.productionType = WXYZ_ProductionTypeBook;
    [self addChildViewController:bookVC];
#endif
    
#if WX_Enable_Audio
    WXYZ_HistoryPageViewController *audioVC = [[WXYZ_HistoryPageViewController alloc] init];
    self.audioVC = audioVC;
    audioVC.productionType = WXYZ_ProductionTypeAudio;
    [self addChildViewController:audioVC];
#endif
    
    NSMutableArray *titleArr = [NSMutableArray array];
    NSMutableArray *childArr = [NSMutableArray array];
    
    for (NSNumber *siteNumber in [WXYZ_UtilsHelper getSiteState]) {
#if WX_Enable_Comic
        if ([siteNumber integerValue] == 1) {
            [titleArr addObject:@"漫画"];
            [childArr addObject:comicVC];
        }
#endif
        
#if WX_Enable_Book
        if ([siteNumber integerValue] == 2) {
            [titleArr addObject:@"小说"];
            [childArr addObject:bookVC];
        }
#endif
        
#if WX_Enable_Audio
        if ([siteNumber integerValue] == 3) {
            [titleArr addObject:@"听书"];
            [childArr addObject:audioVC];
        }
#endif
    }
    
    if ([WXYZ_UtilsHelper getSiteState].count <= 1) {
        [titleArr removeAllObjects];
        [titleArr addObject:@"历史记录"];
    }

    self.pageContentCollectionView = [[SGPageContentCollectionView alloc] initWithFrame:CGRectMake(0, PUB_NAVBAR_HEIGHT + self.pageViewHeight, SCREEN_WIDTH, SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT - self.pageViewHeight) parentVC:self childVCs:childArr];
    _pageContentCollectionView.delegatePageContentCollectionView = self;
    [self.view addSubview:self.pageContentCollectionView];
    
    self.pageTitleView = [SGPageTitleView pageTitleViewWithFrame:CGRectMake(0, PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, self.pageViewHeight) delegate:self titleNames:titleArr configure:self.pageConfigure];
    self.pageTitleView.backgroundColor = kWhiteColor;
    [self.view addSubview:_pageTitleView];
}

- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex
{
    [self.pageContentCollectionView setPageContentCollectionViewCurrentIndex:selectedIndex];
}

- (void)pageContentCollectionView:(SGPageContentCollectionView *)pageContentCollectionView index:(NSInteger)index
{
    WXYZ_BasicViewController *vc = [pageContentCollectionView.childViewControllers objectAtIndex:index];
    [vc cancleTableViewCellEditingState];
}

- (void)pageContentCollectionView:(SGPageContentCollectionView *)pageContentCollectionView progress:(CGFloat)progress originalIndex:(NSInteger)originalIndex targetIndex:(NSInteger)targetIndex
{
    [self.pageTitleView setPageTitleViewWithProgress:progress originalIndex:originalIndex targetIndex:targetIndex];
}

// 一键清空历史记录
- (void)stepClear {
    NSInteger index = self.pageTitleView.signBtnIndex;
    switch (index) {
        case 0:
        {
            [self.bookVC stepClear];
        }
            break;
        case 1:
        {
            [self.comicVC stepClear];
        }
            break;
        case 2:
        {
            [self.audioVC stepClear];
        }
            break;
            
        default:
            break;
    }
}

@end

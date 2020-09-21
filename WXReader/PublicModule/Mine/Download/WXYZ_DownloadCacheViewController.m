//
//  WXYZ_DownloadCacheViewController.m
//  WXReader
//
//  Created by Andrew on 2019/6/18.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_DownloadCacheViewController.h"

#import "WXYZ_ComicDownloadManagementViewController.h"
#import "WXYZ_BookDownloadManagementViewController.h"
#import "WXYZ_AudioDownloadCacheViewController.h"

#import "SGPagingView.h"

@interface WXYZ_DownloadCacheViewController () <SGPageTitleViewDelegate, SGPageContentCollectionViewDelegate>

@property (nonatomic, strong) SGPageTitleView *pageTitleView;
@property (nonatomic, strong) SGPageContentCollectionView *pageContentCollectionView;

@property (nonatomic, weak) WXYZ_BookDownloadManagementViewController *bookVC;

@property (nonatomic, weak) WXYZ_ComicDownloadManagementViewController *comicVC;

@property (nonatomic, weak) WXYZ_AudioDownloadCacheViewController *audioVC;

@property (nonatomic, weak) UIButton *rightButton;

@end

@implementation WXYZ_DownloadCacheViewController

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
    [self setNavigationBarTitle:@"下载缓存"];
    [self hiddenSeparator];
    [self setNavigationBarRightButton:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.rightButton = button;
        [button setTitle:@"编辑" forState:UIControlStateNormal];
        button.titleLabel.font = kFont14;
        [button setTitleColor:kGrayTextColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(editEvent) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        button;
    })];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-kMargin);
        make.centerY.equalTo(self.navigationBar.navTitleLabel);
    }];
}

- (void)editEvent {
    NSInteger index = self.pageTitleView.signBtnIndex;
    switch (index) {
        case 0:
        {
            BOOL isEdtting = !self.bookVC.editStateBlock ?: self.bookVC.editStateBlock();
            [self.rightButton setTitle:isEdtting ? @"取消" : @"编辑" forState:UIControlStateNormal];
        }
            break;
        case 1:
        {
            BOOL isEdtting = !self.comicVC.editStateBlock ?: self.comicVC.editStateBlock();
            [self.rightButton setTitle:isEdtting ? @"取消" : @"编辑" forState:UIControlStateNormal];
        }
            break;
        case 2:
        {
            BOOL isEdtting = !self.audioVC.editStateBlock ?: self.audioVC.editStateBlock();
            [self.rightButton setTitle:isEdtting ? @"取消" : @"编辑" forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
}

- (void)createSubViews
{
#if WX_Enable_Book
    WXYZ_BookDownloadManagementViewController *bookVC = [[WXYZ_BookDownloadManagementViewController alloc] init];
    self.bookVC = bookVC;
    WS(weakSelf)
    bookVC.changeEditStateBlock = ^(BOOL status) {
        [weakSelf.rightButton setTitle:status ? @"编辑" : @"取消" forState:UIControlStateNormal];
    };
    bookVC.pushFromReader = self.pushFromReader;
    [self addChildViewController:bookVC];
#endif
    
#if WX_Enable_Comic
    WXYZ_ComicDownloadManagementViewController *comicVC = [[WXYZ_ComicDownloadManagementViewController alloc] init];
    self.comicVC = comicVC;
    comicVC.changeEditStateBlock = ^(BOOL status) {
        [weakSelf.rightButton setTitle:status ? @"编辑" : @"取消" forState:UIControlStateNormal];
    };
    [self addChildViewController:comicVC];
#endif
    
#if WX_Enable_Audio
    WXYZ_AudioDownloadCacheViewController *audioVC = [[WXYZ_AudioDownloadCacheViewController alloc] init];
    self.audioVC = audioVC;
    audioVC.changeEditStateBlock = ^(BOOL status) {
        [weakSelf.rightButton setTitle:status ? @"编辑" : @"取消" forState:UIControlStateNormal];
    };
    audioVC.productionType = WXYZ_ProductionTypeAudio;
    [self addChildViewController:audioVC];
#endif
    
    NSMutableArray *titleArr = [NSMutableArray array];
    NSMutableArray *childArr = [NSMutableArray array];
    
    if (self.onlyBookMode) {
        
#if WX_Enable_Book
//        [titleArr addObject:@"小说"];
        [childArr addObject:bookVC];
#endif
        
    } else {
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
            [titleArr addObject:@"下载"];
        }
    }
    
    self.pageContentCollectionView = [[SGPageContentCollectionView alloc] initWithFrame:CGRectMake(0, PUB_NAVBAR_HEIGHT + self.pageViewHeight, SCREEN_WIDTH, SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT - self.pageViewHeight) parentVC:self childVCs:childArr];
    _pageContentCollectionView.delegatePageContentCollectionView = self;
    [self.view addSubview:self.pageContentCollectionView];
    
    if (titleArr.count > 0) {
        self.pageTitleView = [SGPageTitleView pageTitleViewWithFrame:CGRectMake(0, PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, self.pageViewHeight) delegate:self titleNames:titleArr configure:self.pageConfigure];
        self.pageTitleView.backgroundColor = kWhiteColor;
        [self.view addSubview:_pageTitleView];
    } else {
        self.pageContentCollectionView.frame = CGRectMake(0, PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT);
    }
}

- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex
{
    [self.pageContentCollectionView setPageContentCollectionViewCurrentIndex:selectedIndex];
}

- (void)pageContentCollectionView:(SGPageContentCollectionView *)pageContentCollectionView index:(NSInteger)index
{
    WXYZ_BasicViewController *vc = [pageContentCollectionView.childViewControllers objectAtIndex:index];
    [vc cancleTableViewCellEditingState];
    switch (index) {
        case 0:
            [self.rightButton setTitle:self.bookVC.isEditting ? @"取消" : @"编辑" forState:UIControlStateNormal];
            break;
        case 1:
            [self.rightButton setTitle:self.comicVC.isEditting ? @"取消" : @"编辑" forState:UIControlStateNormal];
            break;
        case 2:
            [self.rightButton setTitle:self.audioVC.isEditting ? @"取消" : @"编辑" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

- (void)pageContentCollectionView:(SGPageContentCollectionView *)pageContentCollectionView progress:(CGFloat)progress originalIndex:(NSInteger)originalIndex targetIndex:(NSInteger)targetIndex
{
    
    [self.pageTitleView setPageTitleViewWithProgress:progress originalIndex:originalIndex targetIndex:targetIndex];
}

@end

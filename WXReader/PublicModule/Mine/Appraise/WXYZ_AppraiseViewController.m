//
//  WXYZ_AppraiseViewController.m
//  WXReader
//
//  Created by Andrew on 2019/6/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_AppraiseViewController.h"
#import "WXYZ_AppraisePageViewController.h"

#import "SGPagingView.h"

@interface WXYZ_AppraiseViewController () <SGPageTitleViewDelegate, SGPageContentCollectionViewDelegate>

@property (nonatomic, strong) SGPageTitleView *pageTitleView;
@property (nonatomic, strong) SGPageContentCollectionView *pageContentCollectionView;

@end

@implementation WXYZ_AppraiseViewController

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
    [self setNavigationBarTitle:@"我的评论"];
    [self hiddenSeparator];
}

- (void)createSubViews
{
#if WX_Enable_Book
    WXYZ_AppraisePageViewController *bookVC = [[WXYZ_AppraisePageViewController alloc] init];
    bookVC.productionType = WXYZ_ProductionTypeBook;
    [self addChildViewController:bookVC];
#endif
    
#if WX_Enable_Comic
    WXYZ_AppraisePageViewController *comicVC = [[WXYZ_AppraisePageViewController alloc] init];
    comicVC.productionType = WXYZ_ProductionTypeComic;
    [self addChildViewController:comicVC];
#endif
    
#if WX_Enable_Audio
    WXYZ_AppraisePageViewController *audioVC = [[WXYZ_AppraisePageViewController alloc] init];
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
        [titleArr addObject:@"评论"];
    }
    
    self.pageViewHeight = titleArr.count > 1?self.pageViewHeight:0;
    
    self.pageContentCollectionView = [[SGPageContentCollectionView alloc] initWithFrame:CGRectMake(0, PUB_NAVBAR_HEIGHT + self.pageViewHeight, SCREEN_WIDTH, SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT - self.pageViewHeight) parentVC:self childVCs:childArr];
    _pageContentCollectionView.delegatePageContentCollectionView = self;
    [self.view addSubview:self.pageContentCollectionView];
    
    self.pageTitleView = [SGPageTitleView pageTitleViewWithFrame:CGRectMake(0, PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, self.pageViewHeight) delegate:self titleNames:titleArr configure:self.pageConfigure];
    self.pageTitleView.backgroundColor = kWhiteColor;
    [self.view addSubview:self.pageTitleView];
}

- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex
{
    [self.pageContentCollectionView setPageContentCollectionViewCurrentIndex:selectedIndex];
}

- (void)pageContentCollectionView:(SGPageContentCollectionView *)pageContentCollectionView progress:(CGFloat)progress originalIndex:(NSInteger)originalIndex targetIndex:(NSInteger)targetIndex
{
    [self.pageTitleView setPageTitleViewWithProgress:progress originalIndex:originalIndex targetIndex:targetIndex];
}

@end

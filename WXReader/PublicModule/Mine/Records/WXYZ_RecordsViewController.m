//
//  WXYZ_RecordsViewController.m
//  WXReader
//
//  Created by Andrew on 2018/7/12.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_RecordsViewController.h"
#import "WXYZ_RecordsPageViewController.h"
#import "SGPagingView.h"

@interface WXYZ_RecordsViewController () <SGPageTitleViewDelegate, SGPageContentCollectionViewDelegate>

@property (nonatomic, strong) SGPageTitleView *pageTitleView;
@property (nonatomic, strong) SGPageContentCollectionView *pageContentCollectionView;

@end

@implementation WXYZ_RecordsViewController

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
    [self setNavigationBarTitle:@"流水记录"];
}

- (void)createSubviews
{
    WXYZ_RecordsPageViewController *vc1 = [[WXYZ_RecordsPageViewController alloc] init];
    vc1.unit = @"currencyUnit";
    
    WXYZ_RecordsPageViewController *vc2 = [[WXYZ_RecordsPageViewController alloc] init];
    vc2.unit = @"subUnit";
    
    NSArray *titleArr = @[[NSString stringWithFormat:@"%@", WXYZ_SystemInfoManager.masterUnit], WXYZ_SystemInfoManager.subUnit];
    NSArray *childArr = @[vc1, vc2];
    
    self.pageContentCollectionView = [[SGPageContentCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SCREEN_HEIGHT) parentVC:self childVCs:childArr];
    self.pageContentCollectionView.delegatePageContentCollectionView = self;
    [self.view addSubview:self.pageContentCollectionView];
    
    self.pageTitleView = [SGPageTitleView pageTitleViewWithFrame:CGRectMake(0, PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, 44) delegate:self titleNames:titleArr configure:self.pageConfigure];
    self.pageTitleView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.pageTitleView];
    
    if (self.pageIndex == 1) {
        self.pageTitleView.selectedIndex = 1;
    }
}

- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex
{
    [self.pageContentCollectionView setPageContentCollectionViewCurrentIndex:selectedIndex];
}

- (void)pageContentCollectionView:(SGPageContentCollectionView *)pageContentCollectionView progress:(CGFloat)progress originalIndex:(NSInteger)originalIndex targetIndex:(NSInteger)targetIndex {
    [self.pageTitleView setPageTitleViewWithProgress:progress originalIndex:originalIndex targetIndex:targetIndex];
}

@end

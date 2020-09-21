//
//  WXYZ_ComicMallDetailFooterView.m
//  WXReader
//
//  Created by Andrew on 2019/5/29.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicMallDetailFooterView.h"

#import "WXYZ_ComicListDetailViewController.h"
#import "WXYZ_ComicDirectoryListViewController.h"

#import "SGPagingView.h"

@interface WXYZ_ComicMallDetailFooterView () <SGPageTitleViewDelegate, SGPageContentCollectionViewDelegate>
{
    WXYZ_ComicListDetailViewController *leftVC;
    WXYZ_ComicDirectoryListViewController *rightVC;
}

@property (nonatomic, strong) SGPageTitleView *pageTitleView;

@property (nonatomic, strong) SGPageContentCollectionView *pageContentCollectionView;

@end

@implementation WXYZ_ComicMallDetailFooterView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self hiddenNavigationBar:YES];
    [self createSubViews];
}

- (void)createSubViews
{
    WS(weakSelf)
    leftVC = [[WXYZ_ComicListDetailViewController alloc] init];
    leftVC.pushToComicDetailBlock = ^(NSInteger production_id) {
        if (weakSelf.pushToComicDetailBlock) {
            weakSelf.pushToComicDetailBlock(production_id);
        }
    };
    
    rightVC = [[WXYZ_ComicDirectoryListViewController alloc] init];
    
    NSArray *childArr = @[leftVC, rightVC];
    NSArray *titleArr = @[@"详情", @"目录"];
    
    self.pageContentCollectionView = [[SGPageContentCollectionView alloc] initWithFrame:CGRectMake(0, 44.6, self.view.width, SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT - PUB_TABBAR_OFFSET - 44 - 44.6 - kQuarterMargin) parentVC:self childVCs:childArr];
    self.pageContentCollectionView.delegatePageContentCollectionView = self;
    [self.view addSubview:self.pageContentCollectionView];
    
    self.pageConfigure.bottomSeparatorColor = kGrayLineColor;
    self.pageConfigure.titleFont = kMainFont;
    
    self.pageTitleView = [SGPageTitleView pageTitleViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44) delegate:self titleNames:titleArr configure:self.pageConfigure];
    self.pageTitleView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.pageTitleView];
}

- (void)setDetailModel:(WXYZ_ComicMallDetailModel *)detailModel
{
    _detailModel = detailModel;
    
    leftVC.detailModel = self.detailModel;
    rightVC.comicModel = self.detailModel.productionModel;
}

- (void)setCanScroll:(BOOL)canScroll
{
    leftVC.canScroll = canScroll;
    rightVC.canScroll = canScroll;
}

- (void)setContentOffSetY:(CGFloat)contentOffSetY
{
    rightVC.contentOffSetY = contentOffSetY;
}

- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex {
    [self.pageContentCollectionView setPageContentCollectionViewCurrentIndex:selectedIndex];
}

- (void)pageContentCollectionView:(SGPageContentCollectionView *)pageContentCollectionView progress:(CGFloat)progress originalIndex:(NSInteger)originalIndex targetIndex:(NSInteger)targetIndex {
    [self.pageTitleView setPageTitleViewWithProgress:progress originalIndex:originalIndex targetIndex:targetIndex];
}

@end

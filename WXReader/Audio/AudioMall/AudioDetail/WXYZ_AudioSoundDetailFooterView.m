//
//  WXYZ_AudioSoundDetailFooterView.m
//  WXReader
//
//  Created by Andrew on 2020/3/12.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AudioSoundDetailFooterView.h"

#import "WXYZ_AudioSoundRecommendedViewController.h"
#import "WXYZ_AudioSoundDirectoryViewController.h"

#import "SGPagingView.h"

@interface WXYZ_AudioSoundDetailFooterView () <SGPageTitleViewDelegate, SGPageContentCollectionViewDelegate>
{
    WXYZ_AudioSoundRecommendedViewController *rightVC;
    WXYZ_AudioSoundDirectoryViewController *leftVC;
}

@property (nonatomic, strong) SGPageTitleView *pageTitleView;

@property (nonatomic, strong) SGPageContentCollectionView *pageContentCollectionView;

@end

@implementation WXYZ_AudioSoundDetailFooterView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self hiddenNavigationBar:YES];
    [self createSubViews];
}

- (void)createSubViews
{
    leftVC = [[WXYZ_AudioSoundDirectoryViewController alloc] init];
    leftVC.directoryModel = self.directoryModel;
    [self addChildViewController:leftVC];
    
    rightVC = [[WXYZ_AudioSoundRecommendedViewController alloc] init];
    rightVC.productionType = WXYZ_ProductionTypeAudio;
    [self addChildViewController:rightVC];
    
    NSArray *childArr = @[leftVC, rightVC];
    NSArray *titleArr = @[@"目录", @"推荐"];
    
    self.pageContentCollectionView = [[SGPageContentCollectionView alloc] initWithFrame:CGRectMake(0, 44.6, self.view.width, SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT - 44) parentVC:self childVCs:childArr];
    self.pageContentCollectionView.delegatePageContentCollectionView = self;
    [self.view addSubview:self.pageContentCollectionView];
    
    self.pageConfigure.bottomSeparatorColor = kGrayLineColor;
    self.pageConfigure.titleFont = kMainFont;
    self.pageConfigure.titleSelectedColor = kBlackColor;
    
    self.pageTitleView = [SGPageTitleView pageTitleViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44) delegate:self titleNames:titleArr configure:self.pageConfigure];
    self.pageTitleView.backgroundColor = [UIColor whiteColor];
    [self.pageTitleView addRoundingCornersWithRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)];
    [self.view addSubview:self.pageTitleView];
}

- (void)setDirectoryModel:(WXYZ_ProductionModel *)directoryModel
{
    _directoryModel = directoryModel;
    leftVC.directoryModel = directoryModel;
}

- (void)setAudio_id:(NSInteger)audio_id
{
    _audio_id = audio_id;
    leftVC.audio_id = self.audio_id;
}

- (void)setCanScroll:(BOOL)canScroll
{
    rightVC.canScroll = canScroll;
    leftVC.canScroll = canScroll;
}

- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex {
    [self.pageContentCollectionView setPageContentCollectionViewCurrentIndex:selectedIndex];
}

- (void)pageContentCollectionView:(SGPageContentCollectionView *)pageContentCollectionView progress:(CGFloat)progress originalIndex:(NSInteger)originalIndex targetIndex:(NSInteger)targetIndex {
    [self.pageTitleView setPageTitleViewWithProgress:progress originalIndex:originalIndex targetIndex:targetIndex];
}

@end

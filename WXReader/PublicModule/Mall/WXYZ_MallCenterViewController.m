//
//  WXYZ_MallCenterViewController.m
//  WXReader
//
//  Created by Andrew on 2019/5/24.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_MallCenterViewController.h"
#import "AppDelegate.h"

#if WX_Enable_Comic
    #import "WXYZ_ComicMallCenterViewController.h"
#endif

#if WX_Enable_Book
    #import "WXYZ_BookMallCenterViewController.h"
#endif

#if WX_Enable_Audio
    #import "WXYZ_AudioMallCenterViewController.h"
    #import "WXYZ_AudioSoundPlayPageViewController.h"
#endif

#import "WXYZ_SearchViewController.h"
#import "WXYZ_LimitTimeFreeViewController.h"
#import "WXYZ_WebViewViewController.h"

#import "SGPagingView.h"

#import "WXYZ_ProductionCollectionManager.h"
#import "WXYZ_InsterestBookModel.h"

#import "NSObject+Observer.h"
#import "AppDelegate+StartTimes.h"


@interface WXYZ_MallCenterViewController () <SGPageTitleViewDelegate, SGPageContentCollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray *childArr;

@end

@implementation WXYZ_MallCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubViews];
    
    // 首次安装增加推荐书籍
    WS(weakSelf)
    [WXYZ_NetworkReachabilityManager networkingStatus:^(BOOL status) {
        if (status) {
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            if ([delegate startTimes] == 1) {
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    [weakSelf netRequest];
                });
            }
        }
    }];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self changeNavBarColorWithContentOffsetY:_contentOffsetY];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self changeNavBarColorWithContentOffsetY:_contentOffsetY];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Show_Tabbar object:nil];
}

- (void)initialize
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushFromMallCenter:) name:NSNotification_Rack_JumpToMallCenter object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSearchBar) name:Notification_Reload_Mall_Hot_Word object:nil];
    
    [self hiddenNavigationBarLeftButton];
    [self hiddenSeparator];
}

- (void)createSubViews
{
    self.navigationBar.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    
    WS(weakSelf)
#if WX_Enable_Book
    WXYZ_BookMallCenterViewController *bookVC = [[WXYZ_BookMallCenterViewController alloc] init];
    bookVC.productionType = WXYZ_ProductionTypeBook;
    bookVC.channel = 0;
    [bookVC addObserver:KEY_PATH(bookVC, scrollViewContentOffsetY) complete:^(WXYZ_BookMallCenterViewController * _Nonnull obj, id  _Nullable oldVal, id  _Nullable newVal) {
        [weakSelf changeNavBarColorWithContentOffsetY:[newVal floatValue]];
    }];
    [self addChildViewController:bookVC];
#endif
    
#if WX_Enable_Comic
    WXYZ_ComicMallCenterViewController *comicVC = [[WXYZ_ComicMallCenterViewController alloc] init];
    comicVC.productionType = WXYZ_ProductionTypeComic;
    comicVC.channel = 0;
    [comicVC addObserver:KEY_PATH(comicVC, scrollViewContentOffsetY) complete:^(WXYZ_ComicMallCenterViewController * _Nonnull obj, id  _Nullable oldVal, id  _Nullable newVal) {
        [weakSelf changeNavBarColorWithContentOffsetY:[newVal floatValue]];
    }];
    [self addChildViewController:comicVC];
#endif
    
#if WX_Enable_Audio
    WXYZ_AudioMallCenterViewController *audioVC = [[WXYZ_AudioMallCenterViewController alloc] init];
    audioVC.productionType = WXYZ_ProductionTypeAudio;
    audioVC.channel = 0;
    [audioVC addObserver:KEY_PATH(audioVC, scrollViewContentOffsetY) complete:^(WXYZ_AudioMallCenterViewController * _Nonnull obj, id  _Nullable oldVal, id  _Nullable newVal) {
        [weakSelf changeNavBarColorWithContentOffsetY:[newVal floatValue]];
    }];
    [self addChildViewController:audioVC];
#endif
    
    NSMutableArray *titleArr = [NSMutableArray array];
    self.childArr = [NSMutableArray array];
    
    // 临时记录单站点状态
    NSMutableArray *t_titleArr = [NSMutableArray array];
    NSMutableArray *t_chailArr = [NSMutableArray array];
    
    for (NSNumber *siteNumber in [WXYZ_UtilsHelper getSiteState]) {
#if WX_Enable_Book
        if ([siteNumber integerValue] == 1) {
            [titleArr addObject:@"小说"];
            [self.childArr addObject:bookVC];
            
            WXYZ_BookMallCenterViewController *boyVC = [[WXYZ_BookMallCenterViewController alloc] init];
            boyVC.channel = 1;
            boyVC.productionType = WXYZ_ProductionTypeBook;
            [boyVC addObserver:KEY_PATH(boyVC, scrollViewContentOffsetY) complete:^(WXYZ_BookMallCenterViewController * _Nonnull obj, id  _Nullable oldVal, id  _Nullable newVal) {
                [weakSelf changeNavBarColorWithContentOffsetY:[newVal floatValue]];
            }];

            WXYZ_BookMallCenterViewController *girlVC = [[WXYZ_BookMallCenterViewController alloc] init];
            girlVC.channel = 2;
            girlVC.productionType = WXYZ_ProductionTypeBook;
            [girlVC addObserver:KEY_PATH(girlVC, scrollViewContentOffsetY) complete:^(WXYZ_BookMallCenterViewController * _Nonnull obj, id  _Nullable oldVal, id  _Nullable newVal) {
                [weakSelf changeNavBarColorWithContentOffsetY:[newVal floatValue]];
            }];

            [t_titleArr addObjectsFromArray:@[@"男生", @"女生"]];
            [t_chailArr addObjectsFromArray:@[boyVC, girlVC]];
        }
#endif
        
#if WX_Enable_Comic
        if ([siteNumber integerValue] == 2) {
            [titleArr addObject:@"漫画"];
            [self.childArr addObject:comicVC];
            
            WXYZ_ComicMallCenterViewController *boyVC = [[WXYZ_ComicMallCenterViewController alloc] init];
            boyVC.channel = 1;
            boyVC.productionType = WXYZ_ProductionTypeComic;
            [boyVC addObserver:KEY_PATH(boyVC, scrollViewContentOffsetY) complete:^(WXYZ_ComicMallCenterViewController * _Nonnull obj, id  _Nullable oldVal, id  _Nullable newVal) {
                [weakSelf changeNavBarColorWithContentOffsetY:[newVal floatValue]];
            }];
            
            WXYZ_ComicMallCenterViewController *girlVC = [[WXYZ_ComicMallCenterViewController alloc] init];
            girlVC.channel = 2;
            girlVC.productionType = WXYZ_ProductionTypeComic;
            [girlVC addObserver:KEY_PATH(girlVC, scrollViewContentOffsetY) complete:^(WXYZ_ComicMallCenterViewController * _Nonnull obj, id  _Nullable oldVal, id  _Nullable newVal) {
                [weakSelf changeNavBarColorWithContentOffsetY:[newVal floatValue]];
            }];
            
            [t_titleArr addObjectsFromArray:@[@"男生", @"女生"]];
            [t_chailArr addObjectsFromArray:@[boyVC, girlVC]];
        }
#endif
        
#if WX_Enable_Audio
        if ([siteNumber integerValue] == 3) {
            [titleArr addObject:@"听书"];
            [self.childArr addObject:audioVC];
            
            WXYZ_AudioMallCenterViewController *boyVC = [[WXYZ_AudioMallCenterViewController alloc] init];
            boyVC.channel = 1;
            boyVC.productionType = WXYZ_ProductionTypeAudio;
            [boyVC addObserver:KEY_PATH(boyVC, scrollViewContentOffsetY) complete:^(WXYZ_AudioMallCenterViewController * _Nonnull obj, id  _Nullable oldVal, id  _Nullable newVal) {
                [weakSelf changeNavBarColorWithContentOffsetY:[newVal floatValue]];
            }];
            
            WXYZ_AudioMallCenterViewController *girlVC = [[WXYZ_AudioMallCenterViewController alloc] init];
            girlVC.channel = 2;
            girlVC.productionType = WXYZ_ProductionTypeAudio;
            [girlVC addObserver:KEY_PATH(girlVC, scrollViewContentOffsetY) complete:^(WXYZ_AudioMallCenterViewController * _Nonnull obj, id  _Nullable oldVal, id  _Nullable newVal) {
                [weakSelf changeNavBarColorWithContentOffsetY:[newVal floatValue]];
            }];
            
            [t_titleArr addObjectsFromArray:@[@"男生", @"女生"]];
            [t_chailArr addObjectsFromArray:@[boyVC, girlVC]];
        }
#endif
    }
    
    if ([WXYZ_UtilsHelper getSiteState].count == 1) {
        titleArr = t_titleArr;
        self.childArr = t_chailArr;
    }

    self.pageContentCollectionView = [[SGPageContentCollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) parentVC:self childVCs:self.childArr];
    _pageContentCollectionView.delegatePageContentCollectionView = self;
    [self.view addSubview:self.pageContentCollectionView];
    
    self.pageConfigure.indicatorColor = [UIColor whiteColor];
    self.pageConfigure.indicatorStyle = SGIndicatorStyleDynamic;
    self.pageConfigure.indicatorHeight = 3;
    self.pageConfigure.indicatorFixedWidth = 10;
    self.pageConfigure.indicatorDynamicWidth = 14;
    self.pageConfigure.indicatorToBottomDistance = 3;
    self.pageConfigure.titleSelectedColor = [UIColor whiteColor];
    self.pageConfigure.titleFont = kBoldFont16;
    self.pageConfigure.titleTextZoom = YES;
    self.pageConfigure.titleTextZoomRatio = 0.5;
    self.pageConfigure.titleColor = kColorRGBA(255, 255, 255, 0.9);
    
    self.pageTitleView = [SGPageTitleView pageTitleViewWithFrame:CGRectMake(kHalfMargin, (is_iPhoneX?kQuarterMargin:kHalfMargin) + kHalfMargin + PUB_NAVBAR_OFFSET, self.childArr.count * 60, pageView_H) delegate:self titleNames:titleArr configure:self.pageConfigure];
    self.pageTitleView.backgroundColor = [UIColor clearColor];
    [self.pageTitleView setTitleColor:kWhiteColor];
    [self.navigationBar addSubview:_pageTitleView];
    
    if ([WXYZ_UtilsHelper getSiteState].count > 1) {
        self.sexChooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.sexChooseButton.adjustsImageWhenHighlighted = NO;
        [self.sexChooseButton setImageEdgeInsets:UIEdgeInsetsMake(10, 20, 10, 0)];
        [self.sexChooseButton addTarget:self action:@selector(secChooseButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationBar addSubview:self.sexChooseButton];
        
        if (WXYZ_SystemInfoManager.sexChannel == 1) { // 男
            [self.sexChooseButton setImage:[UIImage imageNamed:@"comic_mall_boy_dark"] forState:UIControlStateNormal];
        } else { // 女
            [self.sexChooseButton setImage:[UIImage imageNamed:@"comic_mall_girl_dark"] forState:UIControlStateNormal];
        }
        
        [self.sexChooseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.navigationBar.mas_right).with.offset(- kHalfMargin - kQuarterMargin);
            make.centerY.mas_equalTo(self.pageTitleView.mas_centerY).with.offset(2);
            make.width.height.mas_equalTo(44);
        }];
    }
    
    self.searchView = [[WXYZ_SearchView alloc] init];
    [self.searchView addTarget:self action:@selector(searchClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:self.searchView];
    
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.pageTitleView.mas_right).with.offset(kHalfMargin);
        make.centerY.mas_equalTo(self.pageTitleView.mas_centerY).with.offset(2);
        if ([WXYZ_UtilsHelper getSiteState].count > 1) {
            make.right.mas_equalTo(self.sexChooseButton.mas_left).with.offset(- kQuarterMargin);
        } else {
            make.right.mas_equalTo(self.navigationBar.mas_right).with.offset(- kHalfMargin - kQuarterMargin);
        }
        make.height.mas_equalTo(24);
    }];
}

- (void)searchClick
{
    WXYZ_SearchViewController *vc = [[WXYZ_SearchViewController alloc] init];
    vc.placeholder = self.searchView.currentPlaceholder;
    vc.productionType = self.productionType;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)secChooseButtonClick
{
    if (WXYZ_SystemInfoManager.sexChannel == 1) { // 男
        if (self.isNavDark) {
            [self.sexChooseButton setImage:[UIImage imageNamed:@"comic_mall_girl"] forState:UIControlStateNormal];
        } else {
            [self.sexChooseButton setImage:[UIImage imageNamed:@"comic_mall_girl_dark"] forState:UIControlStateNormal];
        }
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"已切换至女频"];
        WXYZ_SystemInfoManager.sexChannel = 2;
    } else { // 女
        if (self.isNavDark) {
            [self.sexChooseButton setImage:[UIImage imageNamed:@"comic_mall_boy"] forState:UIControlStateNormal];
        } else {
            [self.sexChooseButton setImage:[UIImage imageNamed:@"comic_mall_boy_dark"] forState:UIControlStateNormal];
        }
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"已切换至男频"];
        WXYZ_SystemInfoManager.sexChannel = 1;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Channel_Change object:nil];
}

- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex
{
    [self.pageContentCollectionView setPageContentCollectionViewCurrentIndex:selectedIndex];
}

- (void)pageContentCollectionView:(SGPageContentCollectionView *)pageContentCollectionView progress:(CGFloat)progress originalIndex:(NSInteger)originalIndex targetIndex:(NSInteger)targetIndex
{
    [self.pageTitleView setPageTitleViewWithProgress:progress originalIndex:originalIndex targetIndex:targetIndex];
}

- (void)pageContentCollectionView:(SGPageContentCollectionView *)pageContentCollectionView index:(NSInteger)index
{
    [self reloadSearchBar];
}

- (void)reloadSearchBar
{
    WXYZ_BasicViewController *vc = [self.childArr objectOrNilAtIndex:self.pageTitleView.signBtnIndex];
    self.productionType = vc.productionType;
    self.searchView.placeholderArray = [vc valueForKey:@"hotwordArray"];
    CGFloat contentOffsetY = [[vc valueForKey:@"scrollViewContentOffsetY"] integerValue];
    [self changeNavBarColorWithContentOffsetY:contentOffsetY];
}

- (void)netRequest
{
    // 书架增加推荐书籍
    [WXYZ_NetworkRequestManger POST:Shelf_Recommend parameters:nil model:WXYZ_InsterestBookModel.class success:^(BOOL isSuccess, WXYZ_InsterestBookModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] getAllCollection].count == 0) {
                for (WXYZ_ProductionModel *model in t_model.book) {
                    model.productionType = WXYZ_ProductionTypeBook;
                    model.is_recommend = YES;
                    [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] addCollectionWithProductionModel:model atIndex:0];
                }
            }
            
            if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] getAllCollection].count == 0) {
                for (WXYZ_ProductionModel *model in t_model.comic) {
                    model.productionType = WXYZ_ProductionTypeComic;
                    model.is_recommend = YES;
                    [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] addCollectionWithProductionModel:model atIndex:0];
                }
            }
            
            if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] getAllCollection].count == 0) {
                for (WXYZ_ProductionModel *model in t_model.audio) {
                    model.productionType = WXYZ_ProductionTypeAudio;
                    model.is_recommend = YES;
                    [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] addCollectionWithProductionModel:model atIndex:0];
                }
            }
        }
    } failure:nil];
}

- (void)changeNavBarColorWithContentOffsetY:(CGFloat)contentOffsetY
{
    _contentOffsetY = contentOffsetY;
    CGFloat alpha = [WXYZ_ColorHelper getAlphaWithContentOffsetY:fabs(contentOffsetY)];
    CGFloat rbgColor = [WXYZ_ColorHelper getColorWithContentOffsetY:fabs(contentOffsetY)];
    
    self.navigationBar.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:alpha];
    
    [self.pageTitleView resetTitleColor:kColorRGBA(rbgColor, rbgColor, rbgColor, 1) titleSelectedColor:kColorRGBA(rbgColor, rbgColor, rbgColor, 1) indicatorColor:kColorRGBA(rbgColor, rbgColor, rbgColor, 1)];
    
    if (fabs(contentOffsetY) > 60) {
        self.isNavDark = YES;
    } else {
        self.isNavDark = NO;
    }
}

- (void)setIsNavDark:(BOOL)isNavDark
{
    if (isNavDark) {
        self.searchView.searchViewDarkColor = YES;
        if ([[WXYZ_ViewHelper getCurrentViewController] isEqual:self]) {
            [self setStatusBarDefaultStyle];
        }
        
        if ([WXYZ_UtilsHelper getSiteState].count > 1) {
            if (WXYZ_SystemInfoManager.sexChannel == 1) { // 男
                [self.sexChooseButton setImage:[UIImage imageNamed:@"comic_mall_boy"] forState:UIControlStateNormal];
            } else { // 女
                [self.sexChooseButton setImage:[UIImage imageNamed:@"comic_mall_girl"] forState:UIControlStateNormal];
            }
        }
    } else {
        self.searchView.searchViewDarkColor = NO;
        
        if ([[WXYZ_ViewHelper getCurrentViewController] isEqual:self]) {
            [self setStatusBarLightContentStyle];
        }
        
        if ([WXYZ_UtilsHelper getSiteState].count > 1) {
            if (WXYZ_SystemInfoManager.sexChannel == 1) { // 男
                [self.sexChooseButton setImage:[UIImage imageNamed:@"comic_mall_boy_dark"] forState:UIControlStateNormal];
            } else { // 女
                [self.sexChooseButton setImage:[UIImage imageNamed:@"comic_mall_girl_dark"] forState:UIControlStateNormal];
            }
        }
    }
    _isNavDark = isNavDark;
}

- (void)pushFromMallCenter:(NSNotification *)noti
{
#if WX_Enable_Comic
    // 跳转到漫画相关内容
    if ([noti.object isEqualToString:@"comic"]) {
        for (NSInteger i = 0; i < self.pageContentCollectionView.childViewControllers.count ; i ++) {
            if ([[self.pageContentCollectionView.childViewControllers objectOrNilAtIndex:i] isKindOfClass:[WXYZ_ComicMallCenterViewController class]]) {
                self.pageTitleView.resetSelectedIndex = i;
                break;
            }
        }
    }
#endif
    
#if WX_Enable_Book
    // 跳转到小说相关内容
    if ([noti.object isEqualToString:@"book"]) {
        for (NSInteger i = 0; i < self.pageContentCollectionView.childViewControllers.count ; i ++) {
            if ([[self.pageContentCollectionView.childViewControllers objectOrNilAtIndex:i] isKindOfClass:[WXYZ_BookMallCenterViewController class]]) {
                self.pageTitleView.resetSelectedIndex = i;
                break;
            }
        }
    }
#endif
    
#if WX_Enable_Audio
    // 跳转到听书相关内容
    if ([noti.object isEqualToString:@"audio"]) {
        for (NSInteger i = 0; i < self.pageContentCollectionView.childViewControllers.count ; i ++) {
            if ([[self.pageContentCollectionView.childViewControllers objectOrNilAtIndex:i] isKindOfClass:[WXYZ_AudioMallCenterViewController class]]) {
                self.pageTitleView.resetSelectedIndex = i;
                break;
            }
        }
    }
#endif
    
}

@end

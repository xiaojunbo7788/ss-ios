//
//  WXYZ_BasicViewController.m
//  fuck
//
//  Created by Andrew on 2017/8/11.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "XHNetworkCache.h"

@interface WXYZ_BasicViewController ()
{
    BOOL hiddenHomeIndicator;
}
@end

@implementation WXYZ_BasicViewController

#pragma mark - 属性
- (NSMutableArray *)dataSourceArray
{
    if (!_dataSourceArray) {
        _dataSourceArray = [NSMutableArray array];
    }
    return _dataSourceArray;
}

- (NSMutableDictionary *)adCellDictionary
{
    if (!_adCellDictionary) {
        _adCellDictionary = [NSMutableDictionary dictionary];
    }
    return _adCellDictionary;
}

- (int)currentPageNumber
{
    if (!_currentPageNumber) {
        _currentPageNumber = 1;
    }
    return _currentPageNumber;
}

- (CGFloat)pageViewHeight
{
#if WX_Enable_PageControl
    _pageViewHeight = 44;
#else
    _pageViewHeight = 0;
#endif
    
    if ([WXYZ_UtilsHelper getSiteState].count <= 1) {
        _pageViewHeight = 0;
    }

    return _pageViewHeight;
}

#pragma mark - 控件
- (WXYZ_BasicNavBarView *)navigationBar
{
    if (!_navigationBar) {
        _navigationBar = [[WXYZ_BasicNavBarView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, PUB_NAVBAR_HEIGHT)];
        _navigationBar.navCurrentController = self;
        _navigationBar.backgroundColor = [UIColor whiteColor];
        _navigationBar.userInteractionEnabled = YES;
        [_navigationBar setSmallSeparator];
    }
    return _navigationBar;
}

- (UITableView *)mainTableView
{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.showsVerticalScrollIndicator = NO;
        _mainTableView.showsHorizontalScrollIndicator = NO;
        _mainTableView.estimatedRowHeight = 100;
        _mainTableView.sectionFooterHeight = 10;
        _mainTableView.rowHeight = UITableViewAutomaticDimension;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        if (@available(iOS 11.0, *)) {
            _mainTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
    return _mainTableView;
}

- (UITableView *)mainTableViewGroup
{
    if (!_mainTableViewGroup) {
        _mainTableViewGroup = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _mainTableViewGroup.backgroundColor = [UIColor clearColor];
        _mainTableViewGroup.showsVerticalScrollIndicator = NO;
        _mainTableViewGroup.showsHorizontalScrollIndicator = NO;
        _mainTableViewGroup.estimatedRowHeight = 100;
        _mainTableViewGroup.sectionFooterHeight = 10;
        _mainTableViewGroup.rowHeight = UITableViewAutomaticDimension;
        _mainTableViewGroup.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        if (@available(iOS 11.0, *)) {
            _mainTableViewGroup.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
    return _mainTableViewGroup;
}

- (UICollectionView *)mainCollectionView
{
    if (!_mainCollectionView) {
        _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.mainCollectionViewFlowLayout];
        _mainCollectionView.userInteractionEnabled = YES;
        _mainCollectionView.backgroundColor = [UIColor clearColor];
        _mainCollectionView.showsVerticalScrollIndicator = NO;
        _mainCollectionView.showsHorizontalScrollIndicator = NO;
        _mainCollectionView.alwaysBounceVertical = YES;
        if (@available(iOS 11.0, *)) {
            _mainCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
    return _mainCollectionView;
}

- (UICollectionViewFlowLayout *)mainCollectionViewFlowLayout
{
    if (!_mainCollectionViewFlowLayout) {
        _mainCollectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _mainCollectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _mainCollectionViewFlowLayout;
}

- (SGPageTitleViewConfigure *)pageConfigure
{
    if (!_pageConfigure) {
        _pageConfigure = [SGPageTitleViewConfigure pageTitleViewConfigure];
        _pageConfigure.needBounces = NO;
        _pageConfigure.showBottomSeparator = YES;
        _pageConfigure.bottomSeparatorColor = kGrayLineColor;
        _pageConfigure.bottomSeparatorColor = [UIColor clearColor];
        _pageConfigure.titleFont = kFont15;
        _pageConfigure.titleColor = kBlackColor;
        _pageConfigure.titleSelectedColor = kMainColor;
        _pageConfigure.indicatorDynamicWidth = 10;
        _pageConfigure.indicatorStyle = SGIndicatorStyleDynamic;
        _pageConfigure.indicatorHeight = 4;
        _pageConfigure.indicatorCornerRadius = 2;
        _pageConfigure.indicatorToBottomDistance = 5;
        _pageConfigure.indicatorColor = kMainColor;
    }
    return _pageConfigure;
}

#pragma mark - 公共方法
// 返回上一页
- (void)popViewController
{
    [self.navigationBar popViewController];
}

// 是否可右滑返回
- (void)navigationCanSlidingBack:(BOOL)canSlidingBack;
{
    if (self.navigationController) {
        ((WXYZ_NavigationController *)(self.navigationController)).enableSlidingBack = canSlidingBack;
    }
}

// 空白占位图
- (void)setEmptyOnView:(UIScrollView *)scrollView title:(NSString *)title tapBlock:(void(^)(void))tapBlock
{
    [self setEmptyOnView:scrollView imageName:@"" title:title detailTitle:@"" buttonTitle:@"" centerY:-1 tapBlock:tapBlock];
}

- (void)setEmptyOnView:(UIScrollView *)scrollView title:(NSString *)title centerY:(CGFloat)centerY tapBlock:(void(^)(void))tapBlock {
    [self setEmptyOnView:scrollView imageName:@"" title:title detailTitle:@"" buttonTitle:@"" centerY:200 tapBlock:tapBlock];
}

// 空白占位图
- (void)setEmptyOnView:(UIScrollView *)scrollView title:(NSString *)title buttonTitle:(NSString *)buttonTitle tapBlock:(void(^)(void))tapBlock
{
    [self setEmptyOnView:scrollView imageName:@"" title:title detailTitle:@"" buttonTitle:buttonTitle centerY:-1 tapBlock:tapBlock];
}

// 空白占位图
- (void)setEmptyOnView:(UIScrollView *)scrollView title:(NSString *)title detailTitle:(NSString *)detailTitle buttonTitle:(NSString *)buttonTitle tapBlock:(void(^)(void))tapBlock
{
    [self setEmptyOnView:scrollView imageName:@"" title:title detailTitle:detailTitle buttonTitle:buttonTitle centerY:-1 tapBlock:tapBlock];
}

// 空白占位图
- (void)setEmptyOnView:(UIScrollView *)scrollView imageName:(NSString *)imageName title:(NSString *)title detailTitle:(NSString *)detailTitle buttonTitle:(NSString *)buttonTitle centerY:(CGFloat)centerY tapBlock:(void(^)(void))tapBlock
{
    if ([imageName isEqualToString:@""]) {
        imageName = @"public_no_data.png";
    }
    
    LYEmptyView *emptyView = [LYEmptyView emptyActionViewWithImageStr:imageName titleStr:title detailStr:detailTitle btnTitleStr:buttonTitle btnClickBlock:^{
        if (tapBlock) {
            tapBlock();
        }
    }];
    centerY = centerY == -1 ? 100 : centerY;
    emptyView.contentViewY = centerY;
    emptyView.imageSize = CGSizeMake(200, 200);
    emptyView.autoShowEmptyView = NO;
    emptyView.titleLabFont = kMainFont;
    emptyView.titleLabTextColor = kGrayTextColor;
    emptyView.promptImageView.tintColor = kMainColor;
    emptyView.actionBtnBorderWidth = 1;
    emptyView.actionBtnBorderColor = kMainColor;
    emptyView.actionBtnTitleColor = kMainColor;
    emptyView.actionBtnHeight = 35;
    emptyView.actionBtnHorizontalMargin = 20;
    scrollView.ly_emptyView = emptyView;
    [scrollView ly_startLoading];
    _emptyView = emptyView;
}

// 取消cell左滑删除状态
- (void)cancleTableViewCellEditingState
{
    if (self.mainTableView.isEditing) {
        [self.mainTableView setEditing:NO animated:YES];
    }
    
    if (self.mainTableViewGroup.isEditing) {
        [self.mainTableViewGroup setEditing:NO animated:YES];
    }
}


#pragma mark - 导航栏设置

- (void)hiddenNavigationBar:(BOOL)hidden
{
    _navigationBar.hidden = hidden;
    
    if (hidden) {
        [self hiddenSeparator];
    }
}

- (void)setNavigationBarBackgroundColor:(UIColor *)color
{
    [_navigationBar setBackgroundColor:color];
}

- (void)setNavigationBarTitle:(NSString *)title
{
    [_navigationBar setNavigationBarTitle:title];
}

- (void)setNavigationBarTintColor:(UIColor *)tintColor
{
    [_navigationBar setNavigationBarTintColor:tintColor];
}

- (void)hiddenNavigationBarLeftButton
{
    [_navigationBar hiddenLeftBarButton];
}

- (void)setNavigationBarRightButton:(UIButton *)rightButton
{
    [_navigationBar setRightBarButton:rightButton];
}

// 设置导航栏左侧按钮
- (void)setNavigationBarLeftButton:(UIButton *)leftButton
{
    [_navigationBar setLeftBarButton:leftButton];
}

- (void)hiddenSeparator
{
    [_navigationBar hiddenSeparator];
}

- (void)setNavSmallSeparator
{
    [_navigationBar setSmallSeparator];
}

- (void)setNavLargeSeparator
{
    [_navigationBar setLargeSeparator];
}

#pragma mark - 状态栏设置

- (void)setStatusBarLightContentStyle
{
    [WXYZ_ViewHelper setStateBarLightStyle];
}

- (void)setStatusBarDefaultStyle
{
    [WXYZ_ViewHelper setStateBarDefaultStyle];
}

// 隐藏home条
- (void)hiddenHomeIndicator
{
    if (is_iPhoneX) {
        if (@available(iOS 11.0, *)) {
            hiddenHomeIndicator = YES;
            [self prefersHomeIndicatorAutoHidden];
        } else {
            // Fallback on earlier versions
        }
    }
}

// 显示home条
- (void)showHomeIndicator
{
    if (is_iPhoneX) {
        if (@available(iOS 11.0, *)) {
            hiddenHomeIndicator = NO;
            [self prefersHomeIndicatorAutoHidden];
        } else {
            // Fallback on earlier versions
        }
    }
}

#pragma mark - 接口数据缓存
- (void)asyncCacheNetworkWithURLString:(NSString *)URLString response:(NSDictionary *)response
{
    [XHNetworkCache save_asyncJsonResponseToCacheFile:response andURL:URLString completed:^(BOOL result) {
        if (result) {
        }
    }];
}

- (NSDictionary *)getCacheWithURLString:(NSString *)URLString
{
    return [XHNetworkCache cacheJsonWithURL:URLString];
}

#pragma mark - 生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kWhiteColor;
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self.view addSubview:self.navigationBar];
    
    [self hiddenSeparator];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.navigationBar && !self.navigationBar.hidden) {
        [self.view bringSubviewToFront:self.navigationBar];
    }
    ((WXYZ_NavigationController *)(self.navigationController)).enableSlidingBack = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [WXYZ_TopAlertManager hiddenAlert];
}

- (BOOL)prefersHomeIndicatorAutoHidden
{
    return hiddenHomeIndicator;
}

@end

//
//  DPPagerViewController.h
//  WXReader
//
//  Created by Andrew on 2018/7/22.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WXYZ_ScorllPageViewController;

typedef NS_ENUM(NSUInteger, DPPageRollingDirection) {
    DPPageRollingDirectionNone    = 0,    // 未知状态
    DPPageRollingDirectionLeft    = 1,    // 上一页
    DPPageRollingDirectionRight   = 2     // 下一页
};

// 注意：！！！！！！！！！！！！！！
// 在以下所有提供的方法中 包含View和Controller的方法只需要实现其中之一就可以了
// 比如：contentModeController = YES （默认）只需要实现所有的Controller方法即可
// contentModeController = NO （可自己根据实际需求设置）只需要实现所有的View方法即可
// 控件支持数据源分段加载 比如小说阅读时 可以先加载一部分展示后计算准确页数在reload

/**
 SZPageController数据源代理
 */
@protocol WXScrollPageControlDataSource <NSObject>

/**
 总页数
 
 @param pageController pageController
 @return 总页数
 */
- (NSInteger)dp_numberOfPagesInPageController:(nonnull WXYZ_ScorllPageViewController *)pageController;

/**
 将要展示页需要的内容 contentModeController = YES
 
 @param pageController pageController
 @param index 将要展示页的索引
 @return 展示内容的控制器
 */
- (nullable UIView *)dp_pageController:(nonnull WXYZ_ScorllPageViewController *)pageController viewForIndex:(NSInteger)index direction:(DPPageRollingDirection)rollingDirection;

@end


/**
 DPPageController控制交互代理
 */
@protocol WXScrollPageControlDelegate <NSObject>

@optional

/**
 当前显示的view
 
 @param pageController pageController
 @param currentView 当前显示的view
 @param currentIndex 当前页面的索引
 */
- (void)dp_pageController:(nonnull WXYZ_ScorllPageViewController *)pageController currentView:(nullable UIView *)currentView currentIndex:(NSInteger)currentIndex;


/**
 已切换到第一页
 
 @param pageController pageController
 */
- (void)dp_pageControllerDidSwitchToFirst:(nonnull WXYZ_ScorllPageViewController *)pageController;

/**
 已切换到最后一页
 
 @param pageController pageController
 */
- (void)dp_pageControllerDidSwitchToLast:(nonnull WXYZ_ScorllPageViewController *)pageController;

/**
 控制器不能切换到上一页
 
 @param pageController pageController
 */
- (void)dp_pageControllerSwitchToLastDisabled:(nonnull WXYZ_ScorllPageViewController *)pageController;

/**
 控制器不能切换到上一页
 
 @param pageController pageController
 */
- (void)dp_pageControllerSwitchToNextDisabled:(nonnull WXYZ_ScorllPageViewController *)pageController;

@end

@interface WXYZ_ScorllPageViewController : UIViewController

/*! 数据源代理 */
@property(nonatomic, weak, nullable) id<WXScrollPageControlDataSource> dataSource;

/*! 代理 */
@property(nonatomic, weak, nullable) id<WXScrollPageControlDelegate> delegate;

/*! 动画开启状态 default：YES */
@property(nonatomic) BOOL switchAnimated;

/*! 滑动切换启用状态 default：YES */
@property(nonatomic) BOOL switchSlideEnabled;

/*! 单击切换启用状态 default：YES */
@property(nonatomic) BOOL switchTapEnabled;

/*! 循环切换启用状态 default：YES */
@property(nonatomic) BOOL circleSwitchEnabled;

/*! 上一页切换启用状态 default：YES */
@property(nonatomic) BOOL switchToLastEnabled;

/*! 下一页切换启用状态 default：YES */
@property(nonatomic) BOOL switchToNextEnabled;

@property(nonatomic, strong, readonly, nullable) UIView *currentView;

/*! 是否正在动画中 */
@property(nonatomic, readonly) BOOL isAnimating;


#pragma mark - Method

/**
 数据源刷新
 在 (currentIndex != 0 && currentIndex < numberOfPages) 时此方法可以追加总页数而不影响当前页以前的内容
 否则 此方法强制刷新到第一页
 */
- (void)reloadData;

/**
 数据源刷新 此方法强制刷新到第一页
 */
- (void)reloadDataToFirst;

/**
 判断能否切换到某一页
 
 @param index 某一页索引
 @return BOOL结果
 */
- (BOOL)canSwitchToIndex:(NSInteger)index;

/**
 切换到某一页 需要先做判断 即先调用canSwitchToIndex:index 否则可能发生崩溃
 
 @param index 某一页索引
 @param animated 是否需要动画效果
 */
- (void)switchToIndex:(NSInteger)index animated:(BOOL)animated;

@end

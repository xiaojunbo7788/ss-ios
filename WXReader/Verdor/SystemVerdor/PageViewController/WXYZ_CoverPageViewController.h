//
//  SZPageController.h
//  SZPageController
//
//  Created by zxc on 2017/5/14.
//  Copyright © 2017年 StenpZ. All rights reserved.
//


#import <UIKit/UIKit.h>

@class WXYZ_CoverPageViewController;

typedef NS_ENUM(NSUInteger, PageRollingDirection) {
    PageRollingDirectionNone    = 0,    // 未知状态
    PageRollingDirectionLeft    = 1,    // 上一页
    PageRollingDirectionRight   = 2     // 下一页
};

// 注意：！！！！！！！！！！！！！！
// 在以下所有提供的方法中 包含View和Controller的方法只需要实现其中之一就可以了
// 比如：contentModeController = YES （默认）只需要实现所有的Controller方法即可
// contentModeController = NO （可自己根据实际需求设置）只需要实现所有的View方法即可
// 控件支持数据源分段加载 比如小说阅读时 可以先加载一部分展示后计算准确页数在reload

/**
 SZPageController数据源代理
 */
@protocol WXCoverPageControlDataSource <NSObject>

@required

/**
 总页数

 @param pageController pageController
 @return 总页数
 */
- (NSInteger)numberOfPagesInPageController:(nonnull WXYZ_CoverPageViewController *)pageController;

@optional

/**
 将要展示页需要的内容 contentModeController = YES

 @param pageController pageController
 @param index 将要展示页的索引
 @return 展示内容的控制器
 */
- (nullable UIViewController *)pageController:(nonnull WXYZ_CoverPageViewController *)pageController controllerForIndex:(NSInteger)index;

/**
 将要展示页需要的内容 contentModeController = NO
 
 @param pageController pageController
 @param index 将要展示页的索引
 @return 展示内容的视图
 */
- (nullable UIView *)pageController:(nonnull WXYZ_CoverPageViewController *)pageController viewForIndex:(NSInteger)index direction:(PageRollingDirection)rollingDirection;

@end


/**
 SZPageController控制交互代理
 */
@protocol WXCoverPageControlDelegate <NSObject>

@optional

/**
 当前显示的Controller

 @param pageController pageController
 @param currentController 当前显示的Controller
 @param currentIndex 当前页面的索引
 */
- (void)pageController:(nonnull WXYZ_CoverPageViewController *)pageController currentController:(nullable UIViewController *)currentController currentIndex:(NSInteger)currentIndex;

/**
 当前显示的View

 @param pageController pageController
 @param currentView 当前显示的View
 @param currentIndex 当前页面的索引
 */
- (void)pageController:(nonnull WXYZ_CoverPageViewController *)pageController currentView:(nullable UIView *)currentView currentIndex:(NSInteger)currentIndex direction:(PageRollingDirection)rollingDirection;


/**
 已切换到第一页

 @param pageController pageController
 */
- (void)pageControllerDidSwitchToFirst:(nonnull WXYZ_CoverPageViewController *)pageController;

/**
 已切换到最后一页

 @param pageController pageController
 */
- (void)pageControllerDidSwitchToLast:(nonnull WXYZ_CoverPageViewController *)pageController;

/**
 控制器不能切换到上一页

 @param pageController pageController
 */
- (void)pageControllerSwitchToLastDisabled:(nonnull WXYZ_CoverPageViewController *)pageController;

/**
 控制器不能切换到上一页

 @param pageController pageController
 */
- (void)pageControllerSwitchToNextDisabled:(nonnull WXYZ_CoverPageViewController *)pageController;

@end


/**
 SZPageController
 */
@interface WXYZ_CoverPageViewController : UIViewController

/*! 数据源代理 */
@property(nonatomic, weak, nullable) id<WXCoverPageControlDataSource> dataSource;

/*! 代理 */
@property(nonatomic, weak, nullable) id<WXCoverPageControlDelegate> delegate;

/*! Controller内容模式 default YES / View内容模式 NO  */
@property(nonatomic) BOOL contentModeController;

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

/*! 当前控制器 */
@property(nonatomic, strong, readonly, nullable) UIViewController *currentController;

/*! 当前显示的View */
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

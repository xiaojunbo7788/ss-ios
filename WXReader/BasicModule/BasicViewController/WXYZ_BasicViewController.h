//
//  WXYZ_BasicViewController.h
//  fuck
//
//  Created by Andrew on 2017/8/11.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_BasicNavBarView.h"
#import "LYEmptyView.h"
#import "SGPagingView.h"

#define pageView_H 44

typedef NS_ENUM(NSUInteger, WXYZ_ProductionType) {
    WXYZ_ProductionTypeBook     = 0,
    WXYZ_ProductionTypeComic    = 1,
    WXYZ_ProductionTypeAudio    = 2,
    WXYZ_ProductionTypeAi       = 3
};

@interface WXYZ_BasicViewController : UIViewController

#pragma mark - 属性

@property (nonatomic, strong) NSMutableArray *dataSourceArray;

@property (nonatomic, strong) NSMutableDictionary *adCellDictionary;

@property (nonatomic, assign) int currentPageNumber;

@property (nonatomic, assign) WXYZ_ProductionType productionType;

@property (nonatomic, assign) CGFloat pageViewHeight;

#pragma mark - 控件

@property (nonatomic, strong) WXYZ_BasicNavBarView *navigationBar;

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) UITableView *mainTableViewGroup;

@property (nonatomic, strong) UICollectionViewFlowLayout *mainCollectionViewFlowLayout;

@property (nonatomic, strong) UICollectionView *mainCollectionView;

@property (nonatomic, strong) SGPageTitleViewConfigure *pageConfigure;

@property (nonatomic, strong) LYEmptyView *emptyView;

@property (nonatomic, copy) NSString *navTitle;

@property (nonatomic, assign) BOOL isPresentState;

#pragma mark - 公共方法
// 返回上一页
- (void)popViewController;

// 是否可右滑返回
- (void)navigationCanSlidingBack:(BOOL)canSlidingBack;

// 空白占位图
- (void)setEmptyOnView:(UIScrollView *)scrollView title:(NSString *)title tapBlock:(void(^)(void))tapBlock;

// 空白占位图，自定义Y值
- (void)setEmptyOnView:(UIScrollView *)scrollView title:(NSString *)title centerY:(CGFloat)centerY tapBlock:(void(^)(void))tapBlock;

// 空白占位图
- (void)setEmptyOnView:(UIScrollView *)scrollView title:(NSString *)title buttonTitle:(NSString *)buttonTitle tapBlock:(void(^)(void))tapBlock;

// 空白占位图
- (void)setEmptyOnView:(UIScrollView *)scrollView title:(NSString *)title detailTitle:(NSString *)detailTitle buttonTitle:(NSString *)buttonTitle tapBlock:(void(^)(void))tapBlock;

// 空白占位图
- (void)setEmptyOnView:(UIScrollView *)scrollView imageName:(NSString *)imageName title:(NSString *)title detailTitle:(NSString *)detailTitle buttonTitle:(NSString *)buttonTitle centerY:(CGFloat)centerY tapBlock:(void(^)(void))tapBlock;

// 取消cell左滑删除状态
- (void)cancleTableViewCellEditingState;

#pragma mark - 导航栏设置
// 隐藏导航条
- (void)hiddenNavigationBar:(BOOL)hidden;

// 设置导航条背景色
- (void)setNavigationBarBackgroundColor:(UIColor *)color;

// 设置导航条标题
- (void)setNavigationBarTitle:(NSString *)title;

// 设置导航条标题颜色
- (void)setNavigationBarTintColor:(UIColor *)tintColor;

// 隐藏返回按钮
- (void)hiddenNavigationBarLeftButton;

// 设置导航栏右侧按钮
- (void)setNavigationBarRightButton:(UIButton *)rightButton;

// 设置导航栏左侧按钮
- (void)setNavigationBarLeftButton:(UIButton *)leftButton;

// 设置导航栏线条 - 无
- (void)hiddenSeparator;

// 设置导航栏线条 - 细
- (void)setNavSmallSeparator;

// 设置导航栏线条 - 粗
- (void)setNavLargeSeparator;

// 隐藏home条
- (void)hiddenHomeIndicator;

// 显示home条
- (void)showHomeIndicator;

#pragma mark - 状态栏设置
// 状态条白色
- (void)setStatusBarLightContentStyle;

// 设置状态条黑色
- (void)setStatusBarDefaultStyle;

#pragma mark - 接口数据缓存
- (void)asyncCacheNetworkWithURLString:(NSString *)URLString response:(NSDictionary *)response;

- (NSDictionary *)getCacheWithURLString:(NSString *)URLString;

@end

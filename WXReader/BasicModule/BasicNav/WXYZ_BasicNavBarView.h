//
//  WXYZ_BasicNavBarView.h
//  WXDating
//
//  Created by Andrew on 2017/8/13.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXYZ_BasicNavBarView : UIView

@property (nonatomic, weak) UIViewController *navCurrentController;

// 标题
@property (nonatomic, strong) UILabel *navTitleLabel;

@property (nonatomic, assign) BOOL isPresentState;

// 透过点击
@property (nonatomic, assign) BOOL touchEnabled;

/**
 隐藏返回按钮
 */
- (void)hiddenLeftBarButton;

/**
 白色返回按钮
 */
- (void)setLightLeftButton;

/**
 设置返回按钮颜色
 */
- (void)setLeftButtonTintColor:(UIColor *)tintColor;

/**
 设置导航栏左侧按钮
 */
- (void)setLeftBarButton:(UIButton *)leftButton;

/**
 设置导航栏右侧按钮
 */
- (void)setRightBarButton:(UIButton *)rightButton;

/**
 分割线(细)
 */
- (void)setSmallSeparator;

/**
 分割线(粗)
 */
- (void)setLargeSeparator;

/**
 分割线(无)
 */
- (void)hiddenSeparator;

/**
 设置导航栏标题
 */
- (void)setNavigationBarTitle:(NSString *)title;


/**
 设置导航栏标题颜色
 */
- (void)setNavigationBarTintColor:(UIColor *)tintColor;


/**
 设置导航栏标题字号
 */
- (void)setNavigationBarTintFont:(UIFont *)font;

/*
 返回界面
 **/
- (void)popViewController;

@end

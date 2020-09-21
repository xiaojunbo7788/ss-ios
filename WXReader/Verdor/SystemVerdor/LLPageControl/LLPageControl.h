//
//  LLPageControl.h
//  iOSHelper
//
//  Created by LL on 2020/5/3.
//  Copyright © 2020 Chair. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 自定义UIPageControl
@interface LLPageControl : UIView

@property (nonatomic, assign) NSUInteger numberOfPages;

@property (nonatomic, assign) NSUInteger currentPage;

/// 小圆的半径，决定了圆的大小和控件默认宽度
@property (nonatomic, assign) CGFloat radius;

/// 小圆与小圆之间的间距，决定了控件默认宽度
@property (nonatomic, assign) CGFloat spacing;

@property(nonatomic, strong, nullable) UIColor *pageIndicatorTintColor;

@property(nonatomic, strong, nullable) UIColor *currentPageIndicatorTintColor;

/// 点击事件回调
@property (nonatomic, copy) void(^clickBlock)(LLPageControl *pageControl, NSUInteger index);

+ (instancetype)pageControlWithRadius:(CGFloat)radius spacing:(CGFloat)spacing numberOfPages:(NSUInteger)numberOfPages;

@end

NS_ASSUME_NONNULL_END

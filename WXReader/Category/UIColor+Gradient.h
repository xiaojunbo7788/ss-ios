//
//  UIColor+Gradient.h
//  iOSHelper
//
//  Created by LL on 2020/6/12.
//  Copyright © 2020 Chair. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LLGradientChangeDirection) {/**渐变方向*/
    LLGradientChangeDirectionLevel              = 0,/**水平方向上渐变*/
    LLGradientChangeDirectionVertical           = 1,/**竖直方向上渐变*/
    LLGradientChangeDirectionUpwardDiagonalLine = 2,/**向下对角线渐变*/
    LLGradientChangeDirectionDownDiagonalLine   = 3,/**向上对角线渐变*/
};

@interface UIColor (Gradient)

/// 创建渐变颜色
/// @param size 渐变区域
/// @param direction 渐变方向
/// @param startcolor 开始渐变颜色
/// @param endColor 结束的渐变颜色
+ (instancetype)colorGradientChangeWithSize:(CGSize)size
                                     direction:(LLGradientChangeDirection)direction
                                    startColor:(UIColor *)startcolor
                                      endColor:(UIColor *)endColor;

+ (instancetype)colorGradientChangeWithSize:(CGSize)size
                                  direction:(LLGradientChangeDirection)direction
                                   colorArr:(NSArray<UIColor *> *)colorArr;

@end

NS_ASSUME_NONNULL_END

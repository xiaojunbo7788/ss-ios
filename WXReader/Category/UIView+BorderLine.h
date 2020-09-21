//
//  UIView+BorderLine.h
//  WXReader
//
//  Created by Andrew on 2018/5/24.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, UIBorderSideType) {
    UIBorderSideTypeAll     = 0,        // 全边框
    UIBorderSideTypeTop     = 1 << 0,   // 上侧边框
    UIBorderSideTypeBottom  = 1 << 1,   // 下侧边框
    UIBorderSideTypeLeft    = 1 << 2,   // 左侧边框
    UIBorderSideTypeRight   = 1 << 3,   // 右侧边框
};

typedef NS_OPTIONS(NSUInteger, UIBorderConnerType) {
    UIBorderConnerTypeLeftTop       = 0,        // 左上
    UIBorderConnerTypeLeftBottom    = 1 << 0,   // 左下
    UIBorderConnerTypeRightTop      = 1 << 1,   // 右上
    UIBorderConnerTypeRightBottom   = 1 << 2,   // 右下
    UIBorderConnerTypeTopLeft       = 1 << 3,   // 上左
    UIBorderConnerTypeTopRight      = 1 << 4,   // 上右
    UIBorderConnerTypeBottomLeft    = 1 << 5,   // 下左
    UIBorderConnerTypeBottomRight   = 1 << 6,   // 下右
};

@interface UIView (BorderLine)

/**
 增加边框

 @param borderWidth 边框宽度
 @param borderColor 边框颜色
 @param cornerRadius 边框圆角
 */
- (void)addBorderLineWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor cornerRadius:(CGFloat)cornerRadius;

/**
 增加边框

 @param borderWidth 边框宽度
 @param borderColor 边框颜色
 @param cornerRadius 边框圆角
 @param borderType 边框类型
 */
- (void)addBorderLineWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor cornerRadius:(CGFloat)cornerRadius borderType:(UIBorderSideType)borderType;

/**
 增加边框

 @param borderWidth 边框宽度
 @param borderColor 边框颜色
 @param cornerRadius 边框圆角
 @param borderType 边框类型
 @param connerSpaceWidth 角边距离
 @param connerType 角边类型
 */
- (void)addBorderLineWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor cornerRadius:(CGFloat)cornerRadius borderType:(UIBorderSideType)borderType connerSpaceWidth:(CGFloat)connerSpaceWidth connerType:(UIBorderConnerType)connerType;

// 设置正常背景色
- (void)normalBackgroundColor;

// 设置选中背景色
- (void)selectBackgroundColor;

// 添加圆角
- (void)addRoundingCornersWithRoundingCorners:(UIRectCorner)corners;

@end

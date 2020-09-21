//
//  WXYZ_ViewHelper.h
//  WXReader
//
//  Created by Andrew on 2019/7/9.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ViewHelper : NSObject

/**
 上传图片处理
 */

+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;

+ (NSString *)getBase64StringWithImageData:(NSData *)imageData;

+ (UIImage *)fixOrientation:(UIImage *)aImage;

+ (NSString *)imageExtensionWithFormatString:(NSString *)formatString;

+ (NSString *)audioExtensionWithFormatString:(NSString *)formatString;

+ (NSMutableAttributedString *)getSubContentWithOriginalContent:(NSMutableAttributedString *)originalContent labelWidth:(CGFloat)labelWidth labelMaxLine:(NSInteger)labelMaxLine;

+ (CGFloat)boundsWithFont:(UIFont *)font attributedText:(NSAttributedString *)attributedText needWidth:(CGFloat)needWidth lineSpacing:(CGFloat)lineSpacing;
/*
 自适应frame
 */

// width
+ (CGFloat)getDynamicWidthWithLabel:(UILabel *)label;

+ (CGFloat)getDynamicWidthWithLabel:(UILabel *)label maxWidth:(CGFloat)maxWidth;

+ (CGFloat)getDynamicWidthWithLabelFont:(UIFont *)labelFont labelHeight:(CGFloat)labelHeight labelText:(NSString *)labelText;

+ (CGFloat)getDynamicWidthWithLabelFont:(UIFont *)labelFont labelHeight:(CGFloat)labelHeight labelText:(NSString *)labelText maxWidth:(CGFloat)maxWidth;

// height
+ (CGFloat)getDynamicHeightWithLabel:(UILabel *)label;

+ (CGFloat)getDynamicHeightWithLabel:(UILabel *)label maxHeight:(CGFloat)maxHeight;

+ (CGFloat)getDynamicHeightWithLabelFont:(UIFont *)labelFont labelWidth:(CGFloat)labelWidth labelText:(NSString *)labelText;

+ (CGFloat)getDynamicHeightWithLabelFont:(UIFont *)labelFont labelWidth:(CGFloat)labelWidth labelText:(NSString *)labelText maxHeight:(CGFloat)maxHeight;

#pragma mark - 特殊字体

// 添加删除线
+ (NSMutableAttributedString *)addPartionLineWithString:(NSString *)string range:(NSRange)range;

// 添加下划线
+ (NSMutableAttributedString *)addUnderLineWithString:(NSString *)string range:(NSRange)range;

// 添加字体变大
+ (NSMutableAttributedString *)resetFontWithFont:(UIFont *)font string:(NSString *)string range:(NSRange)range;

// 添加字体变色
+ (NSMutableAttributedString *)resetColorWithColor:(UIColor *)color string:(NSString *)string range:(NSRange)range;

// 字体加粗
+ (NSMutableAttributedString *)resetBoldFontWithString:(NSString *)string range:(NSRange)range;

/*
 window
 */

+ (UIViewController *)getWindowRootController;

+ (UIViewController *)getCurrentViewController;

+ (UINavigationController * _Nullable)getCurrentNavigationController;

/*
 view
*/

+ (void)setStateBarLightStyle;

+ (void)setStateBarDefaultStyle;

@end

NS_ASSUME_NONNULL_END

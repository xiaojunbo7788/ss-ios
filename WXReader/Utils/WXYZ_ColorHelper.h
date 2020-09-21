//
//  WXYZ_ColorHelper.h
//  WXReader
//
//  Created by Andrew on 2018/5/24.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXYZ_ColorHelper : NSObject

+ (UIColor *)getImageColorWithImage:(UIImage *)image atPixel:(CGPoint)point;

+ (UIColor *)getImageTopColorWithImage:(UIImage *)image;

+ (CGFloat)getColorWithContentOffsetY:(CGFloat)contentOffsetY;

+ (CGFloat)getAlphaWithContentOffsetY:(CGFloat)contentOffsetY;

@end

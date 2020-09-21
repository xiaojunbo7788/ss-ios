//
//  WXYZ_ColorHelper.m
//  WXReader
//
//  Created by Andrew on 2018/5/24.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_ColorHelper.h"

@implementation WXYZ_ColorHelper

+ (UIColor *)getImageTopColorWithImage:(UIImage *)image
{
    return [[self class] getImageColorWithImage:image atPixel:CGPointMake(image.size.width / 2, 3)];
}

//获取图片某一点的颜色
+ (UIColor *)getImageColorWithImage:(UIImage *)image atPixel:(CGPoint)point
{
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = image.CGImage;
    NSUInteger width = image.size.width;
    NSUInteger height = image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast |     kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat)getColorWithContentOffsetY:(CGFloat)contentOffsetY
{
    CGFloat alpha = contentOffsetY;
    CGFloat rbgColor = 0;
    if (alpha > 100) {
        alpha = 100;
    } else if (alpha < 0) {
        alpha = 0;
    }
    rbgColor = (255 - alpha * 2.55);
    
    if (contentOffsetY >= 0 && contentOffsetY <= 100) {
        return rbgColor;
    } else if (contentOffsetY > 100) {
        return 0;
    } else if (contentOffsetY < 0) {
        return 255;
    } else {
        return 0;
    }
}

+ (CGFloat)getAlphaWithContentOffsetY:(CGFloat)contentOffsetY
{
    CGFloat alpha = contentOffsetY;
    if (alpha > 100) {
        alpha = 100;
    } else if (alpha < 0) {
        alpha = 0;
    }
    
    if (contentOffsetY >= 0 && contentOffsetY <= 100) {
        return alpha / 100;
    } else if (contentOffsetY > 100) {
        return 1;
    } else if (contentOffsetY < 0) {
        return 0;
    } else {
        return 1;
    }
}

@end

//
//  UIColor+Gradient.m
//  iOSHelper
//
//  Created by LL on 2020/6/12.
//  Copyright © 2020 Chair. All rights reserved.
//

#import "UIColor+Gradient.h"

@implementation UIColor (Gradient)

+ (instancetype)colorGradientChangeWithSize:(CGSize)size
                                     direction:(LLGradientChangeDirection)direction
                                    startColor:(UIColor *)startcolor
                                      endColor:(UIColor *)endColor {
    
    if (CGSizeEqualToSize(size, CGSizeZero) || !startcolor || !endColor ||
        startcolor == endColor) {
        return nil;
    }
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, size.width, size.height);

    CGPoint startPoint = CGPointZero;
    if (direction == LLGradientChangeDirectionDownDiagonalLine) {
        startPoint = CGPointMake(0.0, 1.0);
    }
    gradientLayer.startPoint = startPoint;
    
    CGPoint endPoint = CGPointZero;
    switch (direction) {
        case LLGradientChangeDirectionLevel:
            endPoint = CGPointMake(1.0, 0.0);
            break;
        case LLGradientChangeDirectionVertical:
            endPoint = CGPointMake(0.0, 1.0);
            break;
        case LLGradientChangeDirectionUpwardDiagonalLine:
            endPoint = CGPointMake(1.0, 1.0);
            break;
        case LLGradientChangeDirectionDownDiagonalLine:
            endPoint = CGPointMake(1.0, 0.0);
            break;
        default:
            break;
    }
    gradientLayer.endPoint = endPoint;
    
    gradientLayer.colors = @[(__bridge id)startcolor.CGColor, (__bridge id)endColor.CGColor];
    UIGraphicsBeginImageContext(size);
    [gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [UIColor colorWithPatternImage:image];
}

+ (instancetype)colorGradientChangeWithSize:(CGSize)size
                                  direction:(LLGradientChangeDirection)direction
                                   colorArr:(NSArray<UIColor *> *)colorArr {
    if (CGSizeEqualToSize(size, CGSizeZero) || colorArr.count == 0) {
        return nil;
    }
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, size.width, size.height);

    CGPoint startPoint = CGPointZero;
    if (direction == LLGradientChangeDirectionDownDiagonalLine) {
        startPoint = CGPointMake(0.0, 1.0);
    }
    gradientLayer.startPoint = startPoint;
    
    CGPoint endPoint = CGPointZero;
    switch (direction) {
        case LLGradientChangeDirectionLevel:
            endPoint = CGPointMake(1.0, 0.0);
            break;
        case LLGradientChangeDirectionVertical:
            endPoint = CGPointMake(0.0, 1.0);
            break;
        case LLGradientChangeDirectionUpwardDiagonalLine:
            endPoint = CGPointMake(1.0, 1.0);
            break;
        case LLGradientChangeDirectionDownDiagonalLine:
            endPoint = CGPointMake(1.0, 0.0);
            break;
        default:
            break;
    }
    gradientLayer.endPoint = endPoint;
    
    NSMutableArray *t_arr = [NSMutableArray array];
    for (UIColor *color in colorArr) {
        [t_arr addObject:(id)color.CGColor];
    }
    gradientLayer.colors = [t_arr copy];
    UIGraphicsBeginImageContext(size);
    [gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [UIColor colorWithPatternImage:image];
}

@end

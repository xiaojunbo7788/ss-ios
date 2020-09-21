//
//  UIView+BorderLine.m
//  WXReader
//
//  Created by Andrew on 2018/5/24.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "UIView+BorderLine.h"

@implementation UIView (BorderLine)

- (void)addBorderLineWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor cornerRadius:(CGFloat)cornerRadius borderType:(UIBorderSideType)borderType connerSpaceWidth:(CGFloat)connerSpaceWidth connerType:(UIBorderConnerType)connerType
{
    
}

- (void)addBorderLineWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor cornerRadius:(CGFloat)cornerRadius borderType:(UIBorderSideType)borderType
{
    CGFloat space = borderWidth / 2;
    
    switch (borderType) {
        case UIBorderSideTypeAll: {
            CAShapeLayer *lineBorder  = [[CAShapeLayer alloc] init];
            lineBorder.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            [lineBorder setLineWidth:borderWidth];
            [lineBorder setStrokeColor:borderColor.CGColor];
            [lineBorder setFillColor:[UIColor clearColor].CGColor];
            
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:lineBorder.frame byRoundingCorners:UIRectCornerAllCorners cornerRadii:(CGSizeMake(cornerRadius, cornerRadius))];
            lineBorder.path = path.CGPath;
            [self.layer addSublayer:lineBorder];
        }
            break;
        case UIBorderSideTypeLeft: {
            [self.layer addSublayer:[self addLineOriginPoint:CGPointMake(0.f, 0.f + space) toPoint:CGPointMake(0.0f, self.frame.size.height - space) color:borderColor borderWidth:borderWidth]];
        }
            break;
        case UIBorderSideTypeRight: {
            [self.layer addSublayer:[self addLineOriginPoint:CGPointMake(self.frame.size.width, 0.0f + space) toPoint:CGPointMake(self.frame.size.width, self.frame.size.height - space) color:borderColor borderWidth:borderWidth]];
        }
            break;
        case UIBorderSideTypeTop: {
            [self.layer addSublayer:[self addLineOriginPoint:CGPointMake(0.0f + space, 0.0f) toPoint:CGPointMake(self.frame.size.width - space, 0.0f) color:borderColor borderWidth:borderWidth]];
        }
            break;
        case UIBorderSideTypeBottom: {
            [self.layer addSublayer:[self addLineOriginPoint:CGPointMake(0.0f + space, self.frame.size.height) toPoint:CGPointMake(self.frame.size.width - space, self.frame.size.height) color:borderColor borderWidth:borderWidth]];
        }
            break;
            
        default:
            break;
    }
}

- (void)addBorderLineWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor cornerRadius:(CGFloat)cornerRadius
{
    [self addBorderLineWithBorderWidth:borderWidth borderColor:borderColor cornerRadius:cornerRadius borderType:UIBorderSideTypeAll];
}

- (CAShapeLayer *)addLineOriginPoint:(CGPoint)p0 toPoint:(CGPoint)p1 color:(UIColor *)color borderWidth:(CGFloat)borderWidth {
    
    /// 线的路径
    UIBezierPath * bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:p0];
    [bezierPath addLineToPoint:p1];
    
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = color.CGColor;
    shapeLayer.fillColor  = [UIColor clearColor].CGColor;
    /// 添加路径
    shapeLayer.path = bezierPath.CGPath;
    /// 线宽度
    shapeLayer.lineWidth = borderWidth;
    return shapeLayer;
}

- (void)normalBackgroundColor
{
    //创建一个渐变的图层
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithHexString:@"#ffb084"].CGColor, (__bridge id)[UIColor colorWithHexString:@"#fd9a63"].CGColor];
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1.0);
    gradientLayer.frame = self.bounds;
    gradientLayer.name = @"gradientLayer";
    
    //生成一个image
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    [gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    //设置背景颜色
    self.backgroundColor = [UIColor colorWithPatternImage:img];
}

- (void)selectBackgroundColor
{
    self.backgroundColor = kColorRGBA(0, 0, 0, 0.2);
}

// 添加圆角
- (void)addRoundingCornersWithRoundingCorners:(UIRectCorner)corners
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(12, 12)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

@end

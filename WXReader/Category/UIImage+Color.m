//
//  UIImage+Color.m
//  WXReader
//
//  Created by LL on 2020/6/4.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (Color)

- (instancetype)imageWithColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *t_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return t_image;
}

@end

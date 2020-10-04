//
//  UILabel+WXCreate.m
//  xqzh
//
//  Created by Ahh on 2019/7/7.
//  Copyright © 2019 Ahh. All rights reserved.
//

#import "UILabel+WXCreate.h"

@implementation UILabel (WXCreate)

+ (UILabel *)creatByColor:(UIColor *)color withFont:(UIFont *)font {
    UILabel *label = [[UILabel alloc]init];
    label.textColor = color;
    label.font = font;
    return label;
}

@end

//
//  UIScrollView+UITouch.m
//  WXReader
//
//  Created by Andrew on 2018/7/7.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "UIScrollView+UITouch.h"

@implementation UIScrollView (UITouch)

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 选其一即可
    [super touchesBegan:touches withEvent:event];
    //    [[self nextResponder] touchesBegan:touches withEvent:event];
}

@end

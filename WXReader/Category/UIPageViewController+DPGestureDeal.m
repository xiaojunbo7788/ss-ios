//
//  UIPageViewController+DPGestureDeal.m
//  WXReader
//
//  Created by Andrew on 2018/5/30.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "UIPageViewController+DPGestureDeal.h"
#import "NSObject+YYAdd.h"

@implementation UIPageViewController (DPGestureDeal)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] &&
        [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}

@end

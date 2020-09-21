//
//  WXYZ_NightModeView.m
//  WXReader
//
//  Created by Andrew on 2019/6/7.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_NightModeView.h"

@implementation WXYZ_NightModeView

implementation_singleton(WXYZ_NightModeView)

- (instancetype)init
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.backgroundColor = kBlackTransparentColor;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return nil;
}

@end

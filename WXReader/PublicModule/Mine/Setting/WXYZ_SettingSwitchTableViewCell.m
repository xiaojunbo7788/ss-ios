//
//  WXYZ_SettingSwitchTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2018/7/11.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_SettingSwitchTableViewCell.h"

@implementation WXYZ_SettingSwitchTableViewCell

- (void)createSubviews
{
    [super createSubviews];
    
    self.switchButton = [[KLSwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 51 - kHalfMargin - kQuarterMargin, 10, 51, 31)];
    self.switchButton.transform = CGAffineTransformMakeScale(0.7, 0.7);//缩放
    self.switchButton.onTintColor = kMainColor;
    [self.contentView addSubview:self.switchButton];
    
}

@end

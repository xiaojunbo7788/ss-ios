//
//  WXYZ_SettingLogoutTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2018/7/11.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_SettingLogoutTableViewCell.h"

@implementation WXYZ_SettingLogoutTableViewCell

- (void)createSubviews
{
    [super createSubviews];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.leftTitleLabel.text = @"退出登录";
    self.leftTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.leftTitleLabel.textColor = kWhiteColor;
    self.leftTitleLabel.backgroundColor = kRedColor;
    self.leftTitleLabel.layer.cornerRadius = 4;
    self.leftTitleLabel.clipsToBounds = YES;
    
    [self.leftTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
    }];
}

@end

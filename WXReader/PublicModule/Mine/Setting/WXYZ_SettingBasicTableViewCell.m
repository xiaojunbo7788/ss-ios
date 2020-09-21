//
//  WXYZ_SettingBasicTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2018/7/11.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_SettingBasicTableViewCell.h"

@implementation WXYZ_SettingBasicTableViewCell

- (void)createSubviews
{
    [super createSubviews];
    
    self.leftTitleLabel = [[UILabel alloc] init];
    self.leftTitleLabel.font = kMainFont;
    self.leftTitleLabel.textColor = kBlackColor;
    self.leftTitleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.leftTitleLabel];
    
    [self.leftTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kMargin);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.height.mas_equalTo(50);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).priorityLow();
    }];
}

- (void)setLeftTitleText:(NSString *)leftTitleText
{
    _leftTitleText = leftTitleText;
    self.leftTitleLabel.text = leftTitleText;
}

@end

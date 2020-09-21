//
//  WXYZ_SettingNormalTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2018/7/11.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_SettingNormalTableViewCell.h"

@implementation WXYZ_SettingNormalTableViewCell
{
    UILabel *rightTitleLabel;
}

- (void)createSubviews
{
    [super createSubviews];
    
    UIImageView *connerImage = [[UIImageView alloc] init];
    connerImage.image = [UIImage imageNamed:@"public_more"];
    [self.contentView addSubview:connerImage];

    [connerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.height.mas_equalTo(10);
    }];

    rightTitleLabel = [[UILabel alloc] init];
    rightTitleLabel.font = kFont12;
    rightTitleLabel.textColor = kGrayTextColor;
    rightTitleLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:rightTitleLabel];

    [rightTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_centerX);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.right.mas_equalTo(connerImage.mas_left).with.offset(- 5);
        make.height.mas_equalTo(self.leftTitleLabel.mas_height);
    }];
}

- (void)setRightTitleText:(NSString *)rightTitleText
{
    rightTitleLabel.text = rightTitleText;
}

@end

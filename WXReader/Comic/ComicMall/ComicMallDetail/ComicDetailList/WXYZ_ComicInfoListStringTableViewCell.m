//
//  WXYZ_ComicInfoListStringTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/8/17.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ComicInfoListStringTableViewCell.h"

@implementation WXYZ_ComicInfoListStringTableViewCell
{
    UILabel *leftTitleLabel;
    
    UILabel *rightDetailLabel;
}

- (void)createSubviews
{
    [super createSubviews];
    
    leftTitleLabel = [[UILabel alloc] init];
    leftTitleLabel.textColor = kBlackColor;
    leftTitleLabel.textAlignment = NSTextAlignmentRight;
    leftTitleLabel.font = kMainFont;
    [self.contentView addSubview:leftTitleLabel];
    
    [leftTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kHalfMargin);
        make.width.mas_equalTo(66);
        make.height.mas_equalTo(40);
    }];
    
    rightDetailLabel = [[UILabel alloc] init];
    rightDetailLabel.font = kFont12;
    rightDetailLabel.textAlignment = NSTextAlignmentLeft;
    rightDetailLabel.textColor = kGrayTextColor;
    [self.contentView addSubview:rightDetailLabel];
    
    [rightDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.left.mas_equalTo(leftTitleLabel.mas_right).with.offset(kHalfMargin);
        make.width.mas_equalTo(SCREEN_WIDTH - 70 - kHalfMargin - kMargin);
        make.height.mas_equalTo(40);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).priorityLow();
    }];
}

- (void)setLeftTitleString:(NSString *)leftTitleString
{
    _leftTitleString = leftTitleString;
    
    leftTitleLabel.text = leftTitleString;
}

- (void)setRightTitleString:(NSString *)rightTitleString
{
    _rightTitleString = rightTitleString;
    
    rightDetailLabel.text = rightTitleString;
}

@end

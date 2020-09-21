//
//  WXYZ_AudioPlayPageMenuTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/3/18.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AudioPlayPageMenuTableViewCell.h"

@implementation WXYZ_AudioPlayPageMenuTableViewCell
{
    UILabel *titleLabel;
    UIImageView *chooseIndicator;
}

- (void)createSubviews
{
    [super createSubviews];
    
    chooseIndicator = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"audio_menu_choose"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    chooseIndicator.userInteractionEnabled = YES;
    chooseIndicator.hidden = YES;
    chooseIndicator.tintColor = kMainColor;
    [self.contentView addSubview:chooseIndicator];
    
    [chooseIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.height.mas_equalTo(20);
    }];
    
    titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = kBlackColor;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = kMainFont;
    [self.contentView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kMargin);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.right.mas_equalTo(chooseIndicator.mas_left).with.offset(- kHalfMargin);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
}

- (void)setCellTitleString:(NSString *)cellTitleString
{
    _cellTitleString = cellTitleString;
    titleLabel.text = cellTitleString;
}

- (void)setCellSelected:(BOOL)cellSelected
{
    _cellSelected = cellSelected;
    chooseIndicator.hidden = !cellSelected;
}

@end

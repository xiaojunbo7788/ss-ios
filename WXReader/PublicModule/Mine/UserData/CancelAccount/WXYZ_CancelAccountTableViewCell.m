//
//  WXYZ_CancelAccountTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/12/23.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_CancelAccountTableViewCell.h"

@implementation WXYZ_CancelAccountTableViewCell
{
    UIImageView *pointView;
    UILabel *cellTitleLabel;
    UILabel *cellDetailLabel;
}

- (void)createSubviews
{
    [super createSubviews];
    
    cellTitleLabel = [[UILabel alloc] init];
    cellTitleLabel.textColor = kBlackColor;
    cellTitleLabel.textAlignment = NSTextAlignmentLeft;
    cellTitleLabel.font = kBoldMainFont;
    cellTitleLabel.numberOfLines = 1;
    [self.contentView addSubview:cellTitleLabel];
    
    [cellTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.top.mas_equalTo(self.contentView.mas_top).with.offset(kHalfMargin);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kHalfMargin);
        make.height.mas_equalTo(30);
    }];
    
    cellDetailLabel = [[UILabel alloc] init];
    cellDetailLabel.textColor = kGrayTextColor;
    cellDetailLabel.textAlignment = NSTextAlignmentLeft;
    cellDetailLabel.font = kMainFont;
    cellDetailLabel.numberOfLines = 0;
    [self.contentView addSubview:cellDetailLabel];
    
    [cellDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cellTitleLabel.mas_left);
        make.top.mas_equalTo(cellTitleLabel.mas_bottom);
        make.right.mas_equalTo(cellTitleLabel.mas_right);
        make.height.mas_equalTo(10);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).priorityLow();
    }];
    
    pointView = [[UIImageView alloc] init];
    pointView.image = [UIImage imageNamed:@"cancel_point"];
    [self.contentView addSubview:pointView];
    
    [pointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(cellTitleLabel.mas_left);
        make.centerY.mas_equalTo(cellTitleLabel.mas_centerY);
        make.width.height.mas_equalTo(20);
    }];
    
}

- (void)setTitleString:(NSString *)titleString
{
    _titleString = titleString;
    cellTitleLabel.text = titleString;
}

- (void)setDetailString:(NSString *)detailString
{
    _detailString = detailString;
    cellDetailLabel.text = detailString;
    
    [cellDetailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([WXYZ_ViewHelper getDynamicHeightWithLabel:cellDetailLabel]);
    }];
}

@end

//
//  WXYZ_ChapterBottomPayBarTitleTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/7/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ChapterBottomPayBarTitleTableViewCell.h"

@implementation WXYZ_ChapterBottomPayBarTitleTableViewCell
{
    UILabel *payBarTitleLabel;
    
    // 打折信息
    UILabel *discountTitleLabel;
}

- (void)createSubviews
{
    [super createSubviews];
    
    payBarTitleLabel = [[UILabel alloc] init];
    payBarTitleLabel.text = @"从本章开始购买";
    payBarTitleLabel.textColor = kBlackColor;
    payBarTitleLabel.font = kMainFont;
    payBarTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:payBarTitleLabel];
    
    [payBarTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.centerX.mas_equalTo(self.contentView.mas_centerX).with.offset(CGFLOAT_MIN);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
    
    discountTitleLabel = [[UILabel alloc] init];
    discountTitleLabel.textColor = kWhiteColor;
    discountTitleLabel.textAlignment = NSTextAlignmentCenter;
    discountTitleLabel.font = kFont10;
    discountTitleLabel.backgroundColor = kRedColor;
    discountTitleLabel.layer.cornerRadius = 2;
    discountTitleLabel.clipsToBounds = YES;
    [self.contentView addSubview:discountTitleLabel];
    
    [discountTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(payBarTitleLabel.mas_right).with.offset(kQuarterMargin);
        make.centerY.mas_equalTo(payBarTitleLabel.mas_centerY);
        make.width.mas_equalTo(CGFLOAT_MIN);
        make.height.mas_equalTo(16);
    }];
}

- (void)setBuyOptionModel:(WXYZ_ChapterPayBarOptionModel *)buyOptionModel
{
    _buyOptionModel = buyOptionModel;
    
    payBarTitleLabel.text = buyOptionModel.label?:@"从本章开始购买";
    
    if (buyOptionModel.discount.length > 0 && buyOptionModel.discount) {
        discountTitleLabel.text = buyOptionModel.discount?:@"";
        
        CGFloat t_width = [WXYZ_ViewHelper getDynamicWidthWithLabel:discountTitleLabel] + kQuarterMargin;
        [discountTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(t_width);
        }];
        
        [payBarTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView.mas_centerX).with.offset(- t_width / 2);
            make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:payBarTitleLabel]);
        }];
    } else {
        [discountTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(CGFLOAT_MIN);
        }];
        
        [payBarTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView.mas_centerX).with.offset(CGFLOAT_MIN);
            make.width.mas_equalTo(SCREEN_WIDTH);
        }];
    }
}

@end

//
//  WXYZ_AboutTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2018/10/15.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "WXYZ_AboutTableViewCell.h"

@implementation WXYZ_AboutTableViewCell
{
    UILabel *titleLabel;
    UILabel *detailTitleLabel;
    UIImageView *connerImage;
}

- (void)createSubviews
{
    [super createSubviews];
    
    titleLabel = [[UILabel alloc] init];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = kBlackColor;
    titleLabel.font = kMainFont;
    [self.contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.mas_equalTo(self.contentView.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(kLabelHeight);
    }];
    
    connerImage = [[UIImageView alloc] init];
    connerImage.image = [UIImage imageNamed:@"public_more"];
    connerImage.hidden = NO;
    [self.contentView addSubview:connerImage];
    [connerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.height.mas_equalTo(10);
    }];
    
    detailTitleLabel = [[UILabel alloc] init];
    detailTitleLabel.textAlignment = NSTextAlignmentRight;
    detailTitleLabel.textColor = kGrayTextColor;
    detailTitleLabel.font = kFont12;
    [self.contentView addSubview:detailTitleLabel];
    [detailTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.mas_equalTo(self.contentView.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(kLabelHeight);
    }];
}

- (void)setContactInfoModel:(WXYZ_ContactInfoModel *)contactInfoModel
{
    _contactInfoModel = contactInfoModel;
    
    titleLabel.text = contactInfoModel.title?:@"";
    if (![contactInfoModel.action isEqualToString:@"url"]) {
        detailTitleLabel.text = contactInfoModel.content?:@"";
        connerImage.hidden = YES;
    } else {
        detailTitleLabel.text = @"";
        connerImage.hidden = NO;
    }
    
}

@end

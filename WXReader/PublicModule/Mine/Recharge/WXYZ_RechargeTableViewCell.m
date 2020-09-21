//
//  WXYZ_RechargeTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/4/21.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_RechargeTableViewCell.h"

@implementation WXYZ_RechargeTableViewCell
{
    UIView *backView;
    
    UIImageView *tagImageView;
    UILabel *tagTitleLabel;
    
    UILabel *cellTitleLabel;
    UILabel *priceTitleLabel;
    UILabel *originPriceTitleLabel;
}

- (void)createSubviews
{
    [super createSubviews];
    
    tagImageView = [[UIImageView alloc] init];
    tagImageView.hidden = YES;
    tagImageView.backgroundColor = [UIColor clearColor];
    UIImage *tagImage = [UIImage imageNamed:@"member_tag.png"];
    tagImageView.image = [tagImage resizableImageWithCapInsets:UIEdgeInsetsMake(tagImage.size.height * 0.5, tagImage.size.width * 0.5, tagImage.size.height * 0.5 - 1.0, tagImage.size.width * 0.5 - 1.0)];
    [self.contentView addSubview:tagImageView];
    
    tagTitleLabel = [[UILabel alloc] init];
    tagTitleLabel.textColor = kWhiteColor;
    tagTitleLabel.textAlignment = NSTextAlignmentCenter;
    tagTitleLabel.font = kFont10;
    tagTitleLabel.hidden = YES;
    [self.contentView addSubview:tagTitleLabel];
    
    [tagTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kHalfMargin);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(CGFLOAT_MIN);
    }];
    
    [tagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(tagTitleLabel);
    }];
    
    backView = [[UIView alloc] init];
    backView.backgroundColor = kWhiteColor;
    backView.layer.cornerRadius = 4;
    backView.layer.borderWidth = 1;
    backView.layer.borderColor = kColorRGB(243, 231, 213).CGColor;
    [self.contentView addSubview:backView];
    
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tagTitleLabel.mas_left);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kHalfMargin);
        make.top.mas_equalTo(tagTitleLabel.mas_centerY);
        make.height.mas_equalTo(80);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- kHalfMargin).priorityLow();
    }];
    
    cellTitleLabel = [[UILabel alloc] init];
    cellTitleLabel.textColor = kColorRGB(101, 101, 101);
    cellTitleLabel.textAlignment = NSTextAlignmentLeft;
    cellTitleLabel.font = kBoldMainFont;
    [self.contentView addSubview:cellTitleLabel];
    
    [cellTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(backView.mas_centerY);
        make.left.mas_equalTo(backView.mas_left).with.offset(kMargin);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(backView.mas_height).multipliedBy(0.3);
    }];
    
    originPriceTitleLabel = [[UILabel alloc] init];
    originPriceTitleLabel.textColor = kColorRGB(153, 153, 153);
    originPriceTitleLabel.textAlignment = NSTextAlignmentLeft;
    originPriceTitleLabel.numberOfLines = 0;
    originPriceTitleLabel.font = kFont10;
    [self.contentView addSubview:originPriceTitleLabel];
    
    [originPriceTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(backView.mas_centerY);
        make.left.mas_equalTo(cellTitleLabel.mas_left);
        make.width.mas_equalTo(cellTitleLabel.mas_width);
        make.height.mas_equalTo(backView.mas_height).multipliedBy(0.3);
    }];
    
    priceTitleLabel = [[UILabel alloc] init];
    priceTitleLabel.textColor = kColorRGB(232, 165, 72);
    priceTitleLabel.textAlignment = NSTextAlignmentRight;
    priceTitleLabel.font = kBoldMainFont;
    [self.contentView addSubview:priceTitleLabel];
    
    [priceTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(backView.mas_right).with.offset(- kHalfMargin);
        make.left.mas_equalTo(cellTitleLabel.mas_right).with.offset(kHalfMargin);
        make.centerY.mas_equalTo(backView.mas_centerY);
        make.height.mas_equalTo(backView.mas_height);
    }];
    
    [self.contentView bringSubviewToFront:tagImageView];
    [self.contentView bringSubviewToFront:tagTitleLabel];
}

- (void)setGoodsModel:(WXYZ_GoodsModel *)goodsModel
{
    _goodsModel = goodsModel;
    
    if (goodsModel.tag.count > 0) {
        if ([goodsModel.tag firstObject].tab.length > 0) {
            tagImageView.hidden = NO;
            tagTitleLabel.hidden = NO;
            tagTitleLabel.text =[goodsModel.tag firstObject].tab?:@"";
            [tagTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:tagTitleLabel] + kMargin);
            }];
        }
    } else {
        tagImageView.hidden = YES;
        tagTitleLabel.hidden = YES;
    }
    
    cellTitleLabel.text = goodsModel.title?:@"";
    originPriceTitleLabel.text = goodsModel.note?:@"";
    if (goodsModel.fat_price.length > 0) {
        priceTitleLabel.attributedText = [WXYZ_ViewHelper resetFontWithFont:kBoldFont25 string:goodsModel.fat_price?:@"" range:NSMakeRange(1, goodsModel.fat_price.length - 1)];
    } else {
        priceTitleLabel.text = @"0";
    }
    
}

- (void)setCellSelected:(BOOL)cellSelected
{
    _cellSelected = cellSelected;
    
    if (cellSelected) {
        backView.backgroundColor = kColorRGB(255, 247, 235);
        backView.layer.borderColor = kColorRGB(223, 174, 103).CGColor;
        cellTitleLabel.textColor = kColorRGB(88, 48, 0);
        originPriceTitleLabel.textColor = kColorRGB(130, 106, 80);
    } else {
        backView.backgroundColor = kWhiteColor;
        backView.layer.borderColor = kColorRGB(243, 231, 213).CGColor;
        cellTitleLabel.textColor = kColorRGB(101, 101, 101);
        originPriceTitleLabel.textColor = kColorRGB(153, 153, 153);
    }
}

@end

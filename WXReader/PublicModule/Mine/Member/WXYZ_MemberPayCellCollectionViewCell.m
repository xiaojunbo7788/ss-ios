//
//  WXYZ_MemberPayCellCollectionViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/4/21.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_MemberPayCellCollectionViewCell.h"

@implementation WXYZ_MemberPayCellCollectionViewCell
{
    UIView *backView;
    
    UIImageView *tagImageView;
    UILabel *tagTitleLabel;
    
    UILabel *cellTitleLabel;
    UILabel *priceTitleLabel;
    UILabel *originPriceTitleLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    backView = [[UIView alloc] init];
    backView.backgroundColor = kWhiteColor;
    backView.layer.cornerRadius = 4;
    backView.layer.borderWidth = 1;
    backView.layer.borderColor = kColorRGB(243, 231, 213).CGColor;
    [self addSubview:backView];
    
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.mas_equalTo(self.mas_width);
        make.height.mas_equalTo(self.mas_height);
    }];
    
    // 设置端盖的值
    tagImageView = [[UIImageView alloc] init];
    tagImageView.hidden = YES;
    tagImageView.backgroundColor = [UIColor clearColor];
    UIImage *tagImage = [UIImage imageNamed:@"member_tag.png"];
    tagImageView.image = [tagImage resizableImageWithCapInsets:UIEdgeInsetsMake(tagImage.size.height * 0.5, tagImage.size.width * 0.5, tagImage.size.height * 0.5 - 1.0, tagImage.size.width * 0.5 - 1.0) resizingMode:UIImageResizingModeTile];
    [self addSubview:tagImageView];
    
    tagTitleLabel = [[UILabel alloc] init];
    tagTitleLabel.textColor = kWhiteColor;
    tagTitleLabel.textAlignment = NSTextAlignmentCenter;
    tagTitleLabel.font = kFont10;
    tagTitleLabel.hidden = YES;
    [self addSubview:tagTitleLabel];
    
    [tagTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(backView.mas_top);
        make.left.mas_equalTo(backView.mas_left);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(CGFLOAT_MIN);
    }];
    
    [tagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(tagTitleLabel);
    }];
    
    priceTitleLabel = [[UILabel alloc] init];
    priceTitleLabel.textColor = kColorRGB(232, 165, 72);
    priceTitleLabel.textAlignment = NSTextAlignmentCenter;
    priceTitleLabel.font = kBoldMainFont;
    [self addSubview:priceTitleLabel];
    
    [priceTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backView.mas_left).with.offset(kQuarterMargin);
        make.right.mas_equalTo(backView.mas_right).with.offset(- kQuarterMargin);
        make.centerY.mas_equalTo(backView.mas_centerY);
        make.height.mas_equalTo(backView.mas_height).multipliedBy(0.2);
    }];
    
    cellTitleLabel = [[UILabel alloc] init];
    cellTitleLabel.textColor = kColorRGB(101, 101, 101);
    cellTitleLabel.textAlignment = NSTextAlignmentCenter;
    cellTitleLabel.font = kBoldMainFont;
    [self addSubview:cellTitleLabel];
    
    [cellTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(backView.mas_top);
        make.left.mas_equalTo(priceTitleLabel.mas_left);
        make.width.mas_equalTo(priceTitleLabel.mas_width);
        make.height.mas_equalTo(backView.mas_height).multipliedBy(0.4);
    }];
    
    originPriceTitleLabel = [[UILabel alloc] init];
    originPriceTitleLabel.textColor = kColorRGB(153, 153, 153);
    originPriceTitleLabel.textAlignment = NSTextAlignmentCenter;
    originPriceTitleLabel.numberOfLines = 2;
    originPriceTitleLabel.font = kFont10;
    [self addSubview:originPriceTitleLabel];
    
    [originPriceTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(priceTitleLabel.mas_bottom);
        make.left.mas_equalTo(priceTitleLabel.mas_left);
        make.width.mas_equalTo(priceTitleLabel.mas_width);
        make.height.mas_equalTo(backView.mas_height).multipliedBy(0.4);
    }];
    
}

- (void)setGoodsModel:(WXYZ_GoodsModel *)goodsModel
{
    _goodsModel = goodsModel;
    
    if (goodsModel.tag.count > 0) {
        if ([goodsModel.tag firstObject].tab.length > 0) {
            tagImageView.hidden = NO;
            tagTitleLabel.hidden = NO;
            tagTitleLabel.text = [goodsModel.tag firstObject].tab?:@"";
            [tagTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:tagTitleLabel] + kMargin);
            }];
        }
    } else {
        tagImageView.hidden = YES;
        tagTitleLabel.hidden = YES;
    }
    
    cellTitleLabel.text = goodsModel.title?:@"";
    originPriceTitleLabel.text = goodsModel.sub_title?:@"";
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

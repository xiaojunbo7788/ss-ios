//
//  WXYZ_ChapterBottomPayBarCostTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/7/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ChapterBottomPayBarCostTableViewCell.h"

@implementation WXYZ_ChapterBottomPayBarCostTableViewCell
{
    UIButton *buyChapterButton;
    UILabel *buyPriceLabel;
    UILabel *buyOriginalPriceLabel;
}

- (void)createSubviews
{
    [super createSubviews];
    
    self.contentView.backgroundColor = kColorRGBA(247, 248, 250, 1);
    
    buyChapterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    buyChapterButton.layer.cornerRadius = 4;
    buyChapterButton.clipsToBounds = YES;
    buyChapterButton.backgroundColor = kMainColor;
    [buyChapterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buyChapterButton.titleLabel setFont:kMainFont];
    [buyChapterButton addTarget:self action:@selector(buyChapterButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:buyChapterButton];
    
    [buyChapterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(100);
    }];
    
    buyOriginalPriceLabel = [[UILabel alloc] init];
    buyOriginalPriceLabel.backgroundColor = [UIColor clearColor];
    buyOriginalPriceLabel.font = kFont12;
    buyOriginalPriceLabel.textAlignment = NSTextAlignmentLeft;
    buyOriginalPriceLabel.numberOfLines = 1;
    buyOriginalPriceLabel.textColor = kBlackColor;
    [self.contentView addSubview:buyOriginalPriceLabel];
    
    [buyOriginalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kMargin);
        make.right.mas_equalTo(buyChapterButton.mas_left).with.offset(- kHalfMargin);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- kHalfMargin);
        make.height.mas_equalTo(20);
    }];
    
    buyPriceLabel = [[UILabel alloc] init];
    buyPriceLabel.backgroundColor = [UIColor clearColor];
    buyPriceLabel.font = kMainFont;
    buyPriceLabel.textAlignment = NSTextAlignmentLeft;
    buyPriceLabel.numberOfLines = 1;
    [self.contentView addSubview:buyPriceLabel];
    
    [buyPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(buyOriginalPriceLabel.mas_left);
        make.right.mas_equalTo(buyOriginalPriceLabel.mas_right);
        make.top.mas_equalTo(self.contentView.mas_top).with.offset(kHalfMargin);
        make.bottom.mas_equalTo(buyOriginalPriceLabel.mas_top);
    }];
}

- (void)setBuyOptionModel:(WXYZ_ChapterPayBarOptionModel *)buyOptionModel
{
    _buyOptionModel = buyOptionModel;
    
    if (WXYZ_UserInfoManager.isLogin) {
        if (self.base_info.remain - buyOptionModel.total_price >= 0) {
            [buyChapterButton setTitle:@"确认购买" forState:UIControlStateNormal];
            [buyChapterButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
                make.centerY.mas_equalTo(self.contentView.mas_centerY);
                make.height.mas_equalTo(35);
                make.width.mas_equalTo(100);
            }];
        } else {
            [buyChapterButton setTitle:@"获取VIP无限看" forState:UIControlStateNormal];
            [buyChapterButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
                make.centerY.mas_equalTo(self.contentView.mas_centerY);
                make.height.mas_equalTo(35);
                make.width.mas_equalTo(120);
            }];
        }
    } else {
        [buyChapterButton setTitle:@"登录后购买" forState:UIControlStateNormal];
        [buyChapterButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.height.mas_equalTo(35);
            make.width.mas_equalTo(100);
        }];
    }
    
    // 实付
    buyPriceLabel.attributedText = [self getPriceString];
    
    // 原价
    buyOriginalPriceLabel.attributedText = [self getOriginalPriceString];
    
    if (buyOptionModel.discount.length > 0) {
        [buyOriginalPriceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(20);
        }];
    } else {
        [buyOriginalPriceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(CGFLOAT_MIN);
        }];
    }
}

- (void)setBase_info:(WXYZ_ChapterPayBarInfoModel *)base_info
{
    _base_info = base_info;
}

- (void)buyChapterButtonClick
{
    if (self.buyChapterClickBlock) {
        self.buyChapterClickBlock((self.base_info.remain - self.buyOptionModel.total_price <= 0));
    }
}

- (NSMutableAttributedString *)getPriceString
{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] init];
    
    if (self.buyOptionModel.actual_cost.gold_cost == 0 && self.buyOptionModel.actual_cost.silver_cost > 0) {
        [attributedStr appendString:[NSString stringWithFormat:@"实付：%@%@", [WXYZ_UtilsHelper formatStringWithInteger:self.buyOptionModel.actual_cost.silver_cost], self.base_info.subUnit?:@""]];
    } else if (self.buyOptionModel.actual_cost.gold_cost > 0 && self.buyOptionModel.actual_cost.silver_cost == 0) {
        [attributedStr appendString:[NSString stringWithFormat:@"实付：%@%@", [WXYZ_UtilsHelper formatStringWithInteger:self.buyOptionModel.actual_cost.gold_cost], self.base_info.unit?:@""]];
    } else {
        [attributedStr appendString:[NSString stringWithFormat:@"实付：%@%@ + %@%@", [WXYZ_UtilsHelper formatStringWithInteger:self.buyOptionModel.actual_cost.gold_cost], self.base_info.unit?:@"", [WXYZ_UtilsHelper formatStringWithInteger:self.buyOptionModel.actual_cost.silver_cost], self.base_info.subUnit?:@""]];
    }
    
    [attributedStr addAttribute:NSForegroundColorAttributeName value:kMainColor range:NSMakeRange(3, attributedStr.length - 3)];
    return attributedStr;
}

- (NSMutableAttributedString *)getOriginalPriceString
{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] init];
    
    if (self.buyOptionModel.original_cost.gold_cost == 0 && self.buyOptionModel.original_cost.silver_cost > 0) {
        [attributedStr appendString:[NSString stringWithFormat:@"原价：%@%@", [WXYZ_UtilsHelper formatStringWithInteger:self.buyOptionModel.original_cost.silver_cost], self.base_info.subUnit?:@""]];
    } else if (self.buyOptionModel.original_cost.gold_cost > 0 && self.buyOptionModel.original_cost.silver_cost == 0) {
        [attributedStr appendString:[NSString stringWithFormat:@"原价：%@%@", [WXYZ_UtilsHelper formatStringWithInteger:self.buyOptionModel.original_cost.gold_cost], self.base_info.unit?:@""]];
    } else {
        [attributedStr appendString:[NSString stringWithFormat:@"原价：%@%@ + %@%@", [WXYZ_UtilsHelper formatStringWithInteger:self.buyOptionModel.original_cost.gold_cost], self.base_info.unit?:@"", [WXYZ_UtilsHelper formatStringWithInteger:self.buyOptionModel.original_cost.silver_cost], self.base_info.subUnit?:@""]];
    }
    
    [attributedStr addAttribute:NSForegroundColorAttributeName value:kGrayTextColor range:NSMakeRange(0, attributedStr.length)];
    [attributedStr addAttributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlinePatternSolid | NSUnderlineStyleSingle), NSBaselineOffsetAttributeName : @(0)} range:NSMakeRange(3, attributedStr.length - 3)];
    return attributedStr;
}

@end

//
//  WXYZ_ChapterBottomPayBarBalanceTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/7/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ChapterBottomPayBarBalanceTableViewCell.h"

@implementation WXYZ_ChapterBottomPayBarBalanceTableViewCell
{
    UILabel *balanceDetailTitleLabel;
}

- (void)createSubviews
{
    [super createSubviews];
    
    UILabel *balanceTitleLabel = [[UILabel alloc] init];
    balanceTitleLabel.text = @"账户余额";
    balanceTitleLabel.textColor = kBlackColor;
    balanceTitleLabel.font = kMainFont;
    balanceTitleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:balanceTitleLabel];
    
    [balanceTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kMargin);
        make.width.mas_equalTo(150);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
    
    balanceDetailTitleLabel = [[UILabel alloc] init];
    balanceDetailTitleLabel.text = [NSString stringWithFormat:@"0%@", Main_Unit_Name];
    balanceDetailTitleLabel.textColor = kGrayTextColor;
    balanceDetailTitleLabel.font = kFont12;
    balanceDetailTitleLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:balanceDetailTitleLabel];
    
    [balanceDetailTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(balanceTitleLabel.mas_right);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.top.mas_equalTo(balanceTitleLabel.mas_top);
        make.height.mas_equalTo(balanceTitleLabel.mas_height);
    }];
}

- (void)setBase_info:(WXYZ_ChapterPayBarInfoModel *)base_info
{
    if (_base_info != base_info) {
        _base_info = base_info;
        
        if (WXYZ_UserInfoManager.isLogin) {
            NSString *constString = @"";
            if (base_info.gold_remain == 0 && base_info.silver_remain > 0) {
                constString = [constString stringByAppendingString:[NSString stringWithFormat:@"%@%@", [WXYZ_UtilsHelper formatStringWithInteger:base_info.silver_remain], base_info.subUnit?:@""]];
            } else if (base_info.gold_remain > 0 && base_info.silver_remain == 0) {
                constString = [constString stringByAppendingString:[NSString stringWithFormat:@"%@%@", [WXYZ_UtilsHelper formatStringWithInteger:base_info.gold_remain], base_info.unit?:@""]];
            } else {
                constString = [constString stringByAppendingString:[NSString stringWithFormat:@"%@%@ + %@%@", [WXYZ_UtilsHelper formatStringWithInteger:base_info.gold_remain], base_info.unit?:@"", [WXYZ_UtilsHelper formatStringWithInteger:base_info.silver_remain], base_info.subUnit?:@""]];
            }
            balanceDetailTitleLabel.text = constString;
        }
    }
}

@end

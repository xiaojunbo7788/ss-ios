//
//  WXYZ_RechargeHeaderView.m
//  WXReader
//
//  Created by Andrew on 2020/4/21.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_RechargeHeaderView.h"

@implementation WXYZ_RechargeHeaderView
{
    UILabel *goldRemainLabel;
    UILabel *goldUnitLabel;
    
    UILabel *subRemainLabel;
    UILabel *subUnitLabel;
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
    self.backgroundColor = kColorRGB(46, 46, 48);
    
    goldUnitLabel = [[UILabel alloc] init];
    goldUnitLabel.textAlignment = NSTextAlignmentCenter;
    goldUnitLabel.textColor = kColorRGB(231, 185, 117);
    goldUnitLabel.font = kMainFont;
    [self addSubview:goldUnitLabel];
    
    [goldUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).with.offset(kMargin);
        make.bottom.mas_equalTo(self.mas_bottom).with.offset(- kMargin);
        make.width.mas_equalTo((SCREEN_WIDTH - 2 * kMargin) / 2);
        make.height.mas_equalTo(20);
    }];
    
    goldRemainLabel = [[UILabel alloc] init];
    goldRemainLabel.textAlignment = NSTextAlignmentCenter;
    goldRemainLabel.textColor = kColorRGB(231, 185, 117);
    goldRemainLabel.font = kBoldFont30;
    [self addSubview:goldRemainLabel];
    
    [goldRemainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(goldUnitLabel.mas_left);
        make.bottom.mas_equalTo(goldUnitLabel.mas_top).with.offset(- kHalfMargin);
        make.width.mas_equalTo(goldUnitLabel.mas_width);
        make.height.mas_equalTo(30);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = kGrayViewColor;
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(goldRemainLabel.mas_right);
        make.top.mas_equalTo(goldRemainLabel.mas_top);
        make.bottom.mas_equalTo(goldUnitLabel.mas_bottom);
        make.width.mas_equalTo(kCellLineHeight);
    }];
    
    subUnitLabel = [[UILabel alloc] init];
    subUnitLabel.textAlignment = NSTextAlignmentCenter;
    subUnitLabel.textColor = kWhiteColor;
    subUnitLabel.font = kMainFont;
    [self addSubview:subUnitLabel];
    
    [subUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).with.offset(- kMargin);
        make.top.mas_equalTo(goldUnitLabel.mas_top);
        make.width.mas_equalTo(goldUnitLabel.mas_width);
        make.height.mas_equalTo(goldUnitLabel.mas_height);
    }];
    
    subRemainLabel = [[UILabel alloc] init];
    subRemainLabel.textAlignment = NSTextAlignmentCenter;
    subRemainLabel.textColor = kWhiteColor;
    subRemainLabel.font = kBoldFont30;
    [self addSubview:subRemainLabel];
    
    [subRemainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(subUnitLabel.mas_right);
        make.top.mas_equalTo(goldRemainLabel.mas_top);
        make.width.mas_equalTo(subUnitLabel.mas_width);
        make.height.mas_equalTo(goldRemainLabel.mas_height);
    }];
    
}

- (void)setRechargeModel:(WXYZ_RechargeModel *)rechargeModel
{
    _rechargeModel = rechargeModel;
    
    goldUnitLabel.text = rechargeModel.goldUnit?:@"";
    subUnitLabel.text = rechargeModel.silverUnit?:@"";
    
    if (WXYZ_UserInfoManager.isLogin) {
        goldRemainLabel.text = [WXYZ_UtilsHelper formatStringWithInteger:rechargeModel.goldRemain];
        subRemainLabel.text = [WXYZ_UtilsHelper formatStringWithInteger:rechargeModel.silverRemain];
    } else {
        goldRemainLabel.text = @"--";
        subRemainLabel.text = @"--";
    }
}

@end

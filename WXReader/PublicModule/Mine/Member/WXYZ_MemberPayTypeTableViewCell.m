//
//  WXYZ_MemberPayTypeTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/11/12.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_MemberPayTypeTableViewCell.h"

@implementation WXYZ_MemberPayTypeTableViewCell
{
    UIImageView *payIcon;
    UILabel *payTitle;
    
    UIImageView *selectImageView;
}

- (void)createSubviews
{
    [super createSubviews];
    
    payIcon = [[UIImageView alloc] init];
    payIcon.image = HoldImage;
    [self.contentView addSubview:payIcon];
    
    [payIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kHalfMargin);
        make.top.mas_equalTo(self.contentView.mas_top).with.offset(kHalfMargin);
        make.width.height.mas_equalTo(30);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- kHalfMargin);
    }];
    
    payTitle = [[UILabel alloc] init];
    payTitle.textColor = kBlackColor;
    payTitle.textAlignment = NSTextAlignmentLeft;
    payTitle.font = kMainFont;
    [self.contentView addSubview:payTitle];
    
    [payTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(payIcon.mas_right).with.offset(kHalfMargin);
        make.centerY.mas_equalTo(payIcon.mas_centerY);
        make.width.mas_equalTo(self.contentView.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(30);
    }];
    
    selectImageView = [[UIImageView alloc] init];
    selectImageView.image = [UIImage imageNamed:@"pay_unselected"];
    [self.contentView addSubview:selectImageView];
    
    [selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(payIcon.mas_centerY);
        make.width.height.mas_equalTo(15);
    }];
}

- (void)setPayModel:(WXYZ_PayModel *)payModel
{
    _payModel = payModel;
    
    [payIcon setImageWithURL:[NSURL URLWithString:payModel.icon?:@""] placeholder:HoldImage options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
    
    payTitle.text = payModel.title?:@"";
}

- (void)setPaySelected:(BOOL)paySelected
{
    _paySelected = paySelected;
    
    if (paySelected) {
        selectImageView.image = [UIImage imageNamed:@"pay_selected"];
    } else {
        selectImageView.image = [UIImage imageNamed:@"pay_unselected"];
    }
}

@end

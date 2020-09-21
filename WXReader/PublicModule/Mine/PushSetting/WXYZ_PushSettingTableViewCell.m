//
//  WXYZ_PushSettingTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/12/5.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_PushSettingTableViewCell.h"

@implementation WXYZ_PushSettingTableViewCell
{
    UIButton *openButton;
    UIImageView *connerImageView;
}

- (void)createSubviews
{
    [super createSubviews];
    
    connerImageView = [[UIImageView alloc] init];
    connerImageView.image = [UIImage imageNamed:@"public_more"];
    [self.contentView addSubview:connerImageView];
    
    [connerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.height.mas_equalTo(10);
    }];
    
    openButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [openButton setTitle:@"点击开启" forState:UIControlStateNormal];
    [openButton setTitleColor:kBlackColor forState:UIControlStateNormal];
    [openButton.titleLabel setFont:kFont12];
    [openButton addTarget:self action:@selector(permissionsClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:openButton];
    
    [openButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(connerImageView.mas_left).with.offset(- kHalfMargin);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(self.leftTitleLabel.mas_height);
    }];
}

- (void)setAllowedPush:(BOOL)allowedPush
{
    _allowedPush = allowedPush;
    
    if (allowedPush) {
        [openButton setTitle:@"已开启" forState:UIControlStateNormal];
        [openButton setTitleColor:kGrayTextColor forState:UIControlStateNormal];
        [connerImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right).with.offset(CGFLOAT_MIN);
            make.width.mas_equalTo(CGFLOAT_MIN);
        }];
    } else {
        [openButton setTitle:@"点击开启" forState:UIControlStateNormal];
        [openButton setTitleColor:kBlackColor forState:UIControlStateNormal];
        [connerImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
            make.width.mas_equalTo(10);
        }];
    }
}

- (void)permissionsClick
{
    if (!_allowedPush) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }
}

@end

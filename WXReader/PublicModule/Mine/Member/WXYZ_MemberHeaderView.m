//
//  WXYZ_MemberHeaderView.m
//  WXReader
//
//  Created by Andrew on 2018/7/23.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_MemberHeaderView.h"



@implementation WXYZ_MemberHeaderView
{
    UIImageView *userBackImageView;
    
    UIImageView *userAvatar;
    UILabel *userNickname;
    UIImageView *vipImageView;
    UILabel *noticeLabel;
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
    
    userBackImageView = [[UIImageView alloc] init];
    userBackImageView.image = [UIImage imageNamed:@"member_bg"];
    [self addSubview:userBackImageView];
    
    [userBackImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.width.mas_equalTo(SCREEN_WIDTH - kMargin);
        make.height.mas_equalTo(kGeometricHeight(SCREEN_WIDTH - kMargin, 1053, 215));
    }];
    
    userAvatar = [[UIImageView alloc] initWithCornerRadiusAdvance:(kGeometricHeight(SCREEN_WIDTH - kMargin, 1053, 215) - kMargin) / 2 rectCornerType:UIRectCornerAllCorners];
    [userBackImageView addSubview:userAvatar];
    
    [userAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin);
        make.centerY.mas_equalTo(userBackImageView.mas_centerY);
        make.width.height.mas_equalTo(kGeometricHeight(SCREEN_WIDTH - kMargin, 1053, 215) - kMargin);
    }];
    
    userNickname = [[UILabel alloc] init];
    userNickname.backgroundColor = [UIColor clearColor];
    userNickname.textColor = kBlackColor;
    userNickname.font = kMainFont;
    userNickname.textAlignment = NSTextAlignmentLeft;
    [userBackImageView addSubview:userNickname];
    
    [userNickname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(userAvatar.mas_right).with.offset(kHalfMargin);
        make.bottom.mas_equalTo(userAvatar.mas_centerY);
        make.width.mas_equalTo(10);
        make.height.mas_equalTo(20);
    }];
    
    vipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"public_vip_normal"]];
    vipImageView.hidden = YES;
    [userBackImageView addSubview:vipImageView];
    
    [vipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(userNickname.mas_right).with.offset(kQuarterMargin);
        make.centerY.mas_equalTo(userNickname.mas_centerY);
        make.height.mas_equalTo(12);
        make.width.mas_equalTo(kGeometricWidth(12, 138, 48));
    }];
    
    noticeLabel = [[UILabel alloc] init];
    noticeLabel.backgroundColor = [UIColor clearColor];
    noticeLabel.textColor = kColorRGB(225, 162, 70);
    noticeLabel.font = kFont11;
    noticeLabel.textAlignment = NSTextAlignmentLeft;
    [userBackImageView addSubview:noticeLabel];
    
    [noticeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(userNickname.mas_left);
        make.top.mas_equalTo(userAvatar.mas_centerY).with.offset(6);
        make.right.mas_equalTo(userBackImageView.mas_right).with.offset(- kHalfMargin);
        make.height.mas_equalTo(userNickname.mas_height);
    }];
    
}

- (void)setUserModel:(WXYZ_MonthlyInfoModel *)userModel
{
    if (!userModel) {
        userNickname.text = @"未登录";
        noticeLabel.text = @"开通会员免费畅读会员书库";
        return;
    }
    
    [userAvatar setImageWithURL:[NSURL URLWithString:userModel.avatar?:@""] placeholder:HoldUserAvatar options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
    
    noticeLabel.text = userModel.vip_desc;
    
    if (userModel.nickname.length == 0 || !userModel.nickname || !WXYZ_UserInfoManager.isLogin) {
        userNickname.text = @"未登录";
        vipImageView.hidden = YES;
    } else {
        userNickname.text = userModel.nickname?:@"";
        vipImageView.hidden = NO;
        if (userModel.baoyue_status == 1) {
            noticeLabel.text = userModel.expiry_date.length > 0 ? userModel.expiry_date :userModel.vip_desc;
            vipImageView.image = [UIImage imageNamed:@"public_vip_select"];
        } else {
            vipImageView.image = [UIImage imageNamed:@"public_vip_normal"];
        }
    }
    [userNickname mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:userNickname maxWidth:SCREEN_WIDTH * 0.7]);
    }];
}

@end

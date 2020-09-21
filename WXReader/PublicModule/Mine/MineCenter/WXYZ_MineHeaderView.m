//
//  WXYZ_MineHeaderView.m
//  WXReader
//
//  Created by Andrew on 2018/6/20.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_MineHeaderView.h"
#import "WXYZ_UserCenterModel.h"
#import "AppDelegate.h"

#define MenuAvatar_H 70
#define MenuNumLabel_H 30
#define MenuLabel_H 20

@implementation WXYZ_MineHeaderView
{
    NSString *avatarString;
    
    UIButton *userAvatar;
    
    UILabel *userNickname;
    UIImageView *vipImageView;
    
    UILabel *userIDLabel;
    
    UILabel *goldNumLabel;
    UILabel *goldLabel;
    
#if WX_Task_Mode
    UILabel *taskNumLabel;
    
    UILabel *taskLabel;
#endif
    
    UILabel *voucherNumLabel;
    UILabel *voucherLabel;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = kWhiteColor;
#if WX_Recharge_Mode
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 3 * kMargin + PUB_NAVBAR_OFFSET + MenuAvatar_H + MenuNumLabel_H + MenuLabel_H + kHalfMargin);
#else
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 3 * kMargin + PUB_NAVBAR_OFFSET + MenuAvatar_H);
#endif
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    userAvatar = [UIButton buttonWithType:UIButtonTypeCustom];
    userAvatar.layer.cornerRadius = 35;
    userAvatar.clipsToBounds = YES;
    [userAvatar setBackgroundImage:HoldUserAvatar forState:UIControlStateNormal];
    [userAvatar addTarget:self action:@selector(avatarSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:userAvatar];

    [userAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).with.offset(kMargin);
        make.top.mas_equalTo(2 * kMargin + PUB_NAVBAR_OFFSET);
        make.width.mas_equalTo(MenuAvatar_H);
        make.height.mas_equalTo(MenuAvatar_H);
    }];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarSelected)];

    userNickname = [[UILabel alloc] init];
    userNickname.font = kBoldFont24;
    userNickname.backgroundColor = kWhiteColor;
    userNickname.textColor = kBlackColor;
    userNickname.textAlignment = NSTextAlignmentLeft;
    userNickname.userInteractionEnabled = YES;
    if (WXYZ_UserInfoManager.isLogin) {
        userNickname.text = [WXYZ_UserInfoManager shareInstance].nickname;
    } else {
        userNickname.text = @"登录 / 注册";
        userNickname.textColor = kBlackColor;
    }
    [self addSubview:userNickname];
    [userNickname addGestureRecognizer:tap];

    [userNickname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(userAvatar.mas_right).with.offset(kHalfMargin);
        make.width.mas_equalTo(SCREEN_WIDTH - 100);
        make.top.mas_equalTo(userAvatar.mas_top);
        make.height.mas_equalTo(MenuAvatar_H);
    }];

    userIDLabel = [[UILabel alloc] init];
    userIDLabel.backgroundColor = kWhiteColor;
    userIDLabel.textColor = kGrayTextColor;
    userIDLabel.textAlignment = NSTextAlignmentLeft;
    userIDLabel.font = kFont12;
    [self addSubview:userIDLabel];

    [userIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(userAvatar.mas_right).with.offset(kHalfMargin);
        make.top.mas_equalTo(userAvatar.mas_centerY).with.offset(kQuarterMargin + 2);
        make.width.mas_equalTo(CGFLOAT_MIN);
        make.height.mas_equalTo(15);
    }];
    
#if WX_Super_Member_Mode
    vipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"public_vip_normal"]];
    vipImageView.hidden = YES;
    [self addSubview:vipImageView];
    
    [vipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(userIDLabel.mas_right).with.offset(kQuarterMargin);
        make.centerY.mas_equalTo(userIDLabel.mas_centerY);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(kGeometricWidth(10, 138, 48));
    }];
#endif
    
#if WX_Recharge_Mode
    
    goldNumLabel = [[UILabel alloc] init];
    goldNumLabel.text = @"--";
    goldNumLabel.textColor = kMainColor;
    goldNumLabel.textAlignment = NSTextAlignmentCenter;
    goldNumLabel.backgroundColor = kWhiteColor;
    goldNumLabel.font = kMainFont;
    goldNumLabel.userInteractionEnabled = YES;
    [self addSubview:goldNumLabel];
    [goldNumLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goldSelected)]];
    
    {
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = kGrayLineColor;
        [self addSubview:line];
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(goldNumLabel.mas_right);
            make.top.mas_equalTo(goldNumLabel.mas_top).with.offset(5);
            make.width.mas_equalTo(kCellLineHeight);
            make.height.mas_equalTo(40);
        }];
    }
    
#if WX_Task_Mode
    taskNumLabel = [[UILabel alloc] init];
    taskNumLabel.text = @"--";
    taskNumLabel.textColor = kMainColor;
    taskNumLabel.textAlignment = NSTextAlignmentCenter;
    taskNumLabel.backgroundColor = kWhiteColor;
    taskNumLabel.font = kMainFont;
    taskNumLabel.userInteractionEnabled = YES;
    [self addSubview:taskNumLabel];
    [taskNumLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taskSelected)]];
    
    {
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = kGrayLineColor;
        [self addSubview:line];
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(taskNumLabel.mas_right);
            make.top.mas_equalTo(taskNumLabel.mas_top).with.offset(5);
            make.width.mas_equalTo(kCellLineHeight);
            make.height.mas_equalTo(40);
        }];
    }

#endif
    
    voucherNumLabel = [[UILabel alloc] init];
    voucherNumLabel.text = @"--";
    voucherNumLabel.textColor = kMainColor;
    voucherNumLabel.textAlignment = NSTextAlignmentCenter;
    voucherNumLabel.backgroundColor = kWhiteColor;
    voucherNumLabel.font = kMainFont;
    voucherNumLabel.userInteractionEnabled = YES;
    [self addSubview:voucherNumLabel];
    [voucherNumLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(voucherSelected)]];

    AppDelegate *delegate = (AppDelegate *)kRCodeSync([UIApplication sharedApplication].delegate);
    NSMutableArray *labelNumConstraints = [NSMutableArray arrayWithObjects:goldNumLabel,
#if WX_Task_Mode
                                    taskNumLabel,
#endif
                                     nil];
    if (!isMagicState && delegate.checkSettingModel.system_setting.monthly_ticket_switch == 1) {
        [labelNumConstraints addObject:voucherNumLabel];
    }
    [labelNumConstraints mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
    [labelNumConstraints mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.mas_equalTo(userAvatar.mas_bottom).with.offset(kMargin);
        make.height.mas_equalTo(MenuNumLabel_H);
    }];

    goldLabel = [[UILabel alloc] init];
    goldLabel.text = [NSString stringWithFormat:@"%@", WXYZ_SystemInfoManager.masterUnit];
    goldLabel.textColor = kGrayTextColor;
    goldLabel.textAlignment = NSTextAlignmentCenter;
    goldLabel.backgroundColor = kWhiteColor;
    goldLabel.font = kFont12;
    goldLabel.userInteractionEnabled = YES;
    [self addSubview:goldLabel];
    [goldLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goldSelected)]];

#if WX_Task_Mode
    taskLabel = [[UILabel alloc] init];
    taskLabel.text = @"书券";
    taskLabel.textColor = kGrayTextColor;
    taskLabel.textAlignment = NSTextAlignmentCenter;
    taskLabel.backgroundColor = kWhiteColor;
    taskLabel.font = kFont12;
    taskLabel.userInteractionEnabled = YES;
    [self addSubview:taskLabel];
    [taskLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taskSelected)]];
#endif

    voucherLabel = [[UILabel alloc] init];
//    voucherLabel.text = [NSString stringWithFormat:@"%@", [[WXYZ_UserInfoManager sharedManager] getUserInfoWithKey:HOLD_SUB_UNIT]];
    voucherLabel.text = @"月票";
    voucherLabel.textColor = kGrayTextColor;
    voucherLabel.textAlignment = NSTextAlignmentCenter;
    voucherLabel.backgroundColor = kWhiteColor;
    voucherLabel.font = kFont12;
    voucherLabel.userInteractionEnabled = YES;
    [self addSubview:voucherLabel];
    [voucherLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(voucherSelected)]];

    NSMutableArray *labelConstraints = [NSMutableArray arrayWithObjects:goldLabel,
#if WX_Task_Mode
                                 taskLabel,
#endif
                                  nil];
    if (!isMagicState && delegate.checkSettingModel.system_setting.monthly_ticket_switch == 1) {
        [labelConstraints addObject:voucherLabel];
    }
    [labelConstraints mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
    [labelConstraints mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(goldNumLabel.mas_bottom);
        make.height.mas_equalTo(MenuLabel_H);
    }];
    
#endif
}

#pragma mark - 点击事件

- (void)avatarSelected
{
    if (self.avatarSelectedBlock) {
        self.avatarSelectedBlock();
    }
}

- (void)goldSelected
{
    if (self.goldSelectedBlock) {
        self.goldSelectedBlock();
    }
}

- (void)taskSelected
{
    if (self.taskSelectedBlock) {
        self.taskSelectedBlock();
    }
}

- (void)voucherSelected
{
    if (self.voucherSelectedBlock) {
        self.voucherSelectedBlock();
    }
}

#pragma mark - 设置变量

- (void)setAvatarImage:(UIImage *)avatarImage
{
    _avatarImage = avatarImage;
    [userAvatar setBackgroundImage:avatarImage forState:UIControlStateNormal];
}

- (void)setNickName:(NSString *)nickName
{
    _nickName = nickName;
    userNickname.text = nickName;
}

- (void)setUserModel:(WXYZ_UserCenterModel *)userModel
{
    _userModel = userModel;
    
#if WX_Super_Member_Mode
    // VIP
    if (userModel.isVip) {
        vipImageView.image = [UIImage imageNamed:@"public_vip_select"];
    } else {
        vipImageView.image = [UIImage imageNamed:@"public_vip_normal"];
    }
#endif
    
    // 昵称
    if (userModel.nickname.length > 0) {
        userNickname.text = userModel.nickname?:@"";
        userNickname.textColor = kBlackColor;
        userIDLabel.hidden = NO;
        vipImageView.hidden = NO;
        [userNickname mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(40);
        }];
    } else {
        userNickname.text = @"登录 / 注册";
        userNickname.textColor = kBlackColor;
        userIDLabel.hidden = YES;
        vipImageView.hidden = YES;
        [userNickname mas_updateConstraints:^(MASConstraintMaker *make) {
           make.height.mas_equalTo(MenuAvatar_H);
        }];
    }
    
    // 用户id
    if (!userModel.uid) {
        userIDLabel.hidden = YES;
        userIDLabel.text = @"";
    } else {
        userIDLabel.hidden = NO;
        userIDLabel.text = [NSString stringWithFormat:@"ID：%@", [WXYZ_UtilsHelper formatStringWithInteger:userModel.uid]];
    }
    
    [userIDLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:userIDLabel]);
    }];
    
    // 主货币单位
    if (userModel.masterUnit.length > 0) {
        goldLabel.text = [NSString stringWithFormat:@"%@", userModel.masterUnit];
    } else {
        goldLabel.text = [NSString stringWithFormat:@"%@", WXYZ_SystemInfoManager.masterUnit];
    }
    
    // 子货币单位
    if (userModel.subUnit.length > 0) {
        taskLabel.text = [NSString stringWithFormat:@"%@", userModel.subUnit];
    } else {
        taskLabel.text = [NSString stringWithFormat:@"%@", WXYZ_SystemInfoManager.subUnit];
    }
    
    if (userModel.masterRemain <= 0 && !WXYZ_UserInfoManager.isLogin) {
        goldNumLabel.text = @"--";
    } else {
        goldNumLabel.text = [WXYZ_UtilsHelper formatStringWithInteger:userModel.masterRemain];
    }
    
    // 月票数量
    if (userModel.ticketRemain <= 0 && !WXYZ_UserInfoManager.isLogin) {
        voucherNumLabel.text = @"--";
    } else {
        voucherNumLabel.text = [WXYZ_UtilsHelper formatStringWithInteger:userModel.ticketRemain];
    }
    
#if WX_Task_Mode
    // 子货币数量
    if (userModel.subRemain <= 0 && !WXYZ_UserInfoManager.isLogin) {
        taskNumLabel.text = @"--";
    } else {
        taskNumLabel.text = [WXYZ_UtilsHelper formatStringWithInteger:userModel.subRemain];
    }
    
#endif
    
    if (![avatarString isEqualToString:userModel.avatar]) {
        avatarString = userModel.avatar;
        [userAvatar setBackgroundImageWithURL:[NSURL URLWithString:userModel.avatar?:@""] forState:UIControlStateNormal placeholder:HoldUserAvatar];
    }
}

@end

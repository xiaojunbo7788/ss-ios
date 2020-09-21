//
//  WXYZ_FeedbackCenterHeaderView.m
//  WXReader
//
//  Created by Andrew on 2019/12/25.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_FeedbackCenterHeaderView.h"

@implementation WXYZ_FeedbackCenterHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    WXYZ_CustomButton *leftButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"我的反馈" buttonSubTitle:@"" buttonImageName:@"feedback_talk" buttonIndicator:WXYZ_CustomButtonIndicatorTitleRight showMaskView:NO];
    leftButton.graphicDistance = 1;
    leftButton.buttonImageScale = 0.4;
    leftButton.buttonTitleFont = kBoldFont15;
    leftButton.tag = 1;
    [leftButton addTarget:self action:@selector(menuClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftButton];
    
    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.top.mas_equalTo(self.mas_top);
        make.height.mas_equalTo(self.mas_height);
        make.width.mas_equalTo(self.mas_width).multipliedBy(0.5);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = kGrayViewColor;
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftButton.mas_right);
        make.centerY.mas_equalTo(leftButton.mas_centerY);
        make.width.mas_equalTo(2);
        make.height.mas_equalTo(self.mas_height).with.multipliedBy(0.5);
    }];
    
    WXYZ_CustomButton *rightButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"反馈意见" buttonSubTitle:@"" buttonImageName:@"feedback_list" buttonIndicator:WXYZ_CustomButtonIndicatorTitleRight showMaskView:NO];
    rightButton.graphicDistance = 1;
    rightButton.buttonImageScale = 0.4;
    rightButton.buttonTitleFont = kBoldFont15;
    rightButton.tag = 2;
    [rightButton addTarget:self action:@selector(menuClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightButton];
    
    [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right);
        make.top.mas_equalTo(self.mas_top);
        make.height.mas_equalTo(self.mas_height);
        make.width.mas_equalTo(self.mas_width).multipliedBy(0.5);
    }];
}

- (void)menuClick:(UIButton *)sender
{
    if (!WXYZ_UserInfoManager.isLogin) {
        [WXYZ_LoginViewController presentLoginView];
        return;
    }
    
    if (sender.tag == 1) {
        if (self.leftButtonClick) {
            self.leftButtonClick();
        }
    } else if (sender.tag == 2) {
        if (self.rightButtonClick) {
            self.rightButtonClick();
        }
    }
}

@end

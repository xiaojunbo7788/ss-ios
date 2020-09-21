//
//  WXYZ_ComicMenuTopBar.m
//  WXReader
//
//  Created by Andrew on 2019/6/4.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicMenuTopBar.h"

@implementation WXYZ_ComicMenuTopBar
{
    UILabel *navTitleLabel;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, - PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, PUB_NAVBAR_HEIGHT);
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    self.backgroundColor = kWhiteColor;
    
    // 默认左侧显示返回按钮
    UIButton *leftBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBackButton.backgroundColor = [UIColor clearColor];
    [leftBackButton.titleLabel setFont:kMainFont];
    leftBackButton.adjustsImageWhenHighlighted = NO;
    [leftBackButton setImage:[[UIImage imageNamed:@"public_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [leftBackButton setImageEdgeInsets:UIEdgeInsetsMake(12, 6, 12, 18)];
    [leftBackButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [leftBackButton setTintColor:kBlackColor];
    [leftBackButton addTarget:self action:@selector(leftBack) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftBackButton];
    
    [leftBackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin);
        make.bottom.mas_equalTo(self.bottom);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    
    navTitleLabel = [[UILabel alloc] init];
    navTitleLabel.backgroundColor = [UIColor clearColor];
    navTitleLabel.textColor = [UIColor blackColor];
    navTitleLabel.numberOfLines = 1;
    navTitleLabel.font = kFont16;
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:navTitleLabel];
    
    [navTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(leftBackButton.mas_centerY);
        make.width.mas_equalTo(self.mas_width).with.offset(- 4 * kMargin);
        make.height.mas_equalTo(20);
    }];
    
    UIButton *completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    completeButton.backgroundColor = [UIColor clearColor];
    completeButton.adjustsImageWhenHighlighted = NO;
    [completeButton setTitleColor:kMainColor forState:UIControlStateNormal];
    [completeButton setTitle:@"全集" forState:UIControlStateNormal];
    [completeButton.titleLabel setFont:kMainFont];
    [completeButton addTarget:self action:@selector(completeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:completeButton];
    
    [completeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).with.offset(- kHalfMargin);
        make.bottom.mas_equalTo(self.bottom);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    
    UIImageView *navBottomLine = [[UIImageView alloc] init];
    navBottomLine.userInteractionEnabled = YES;
    navBottomLine.image = [UIImage imageNamed:@"navbar_bottom_line"];
    [self addSubview:navBottomLine];
    
    [navBottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(self.mas_bottom);
        make.width.mas_equalTo(self.mas_width);
        make.height.mas_equalTo(1);
    }];
    
}

- (void)showMenuTopBar
{
    [UIView animateWithDuration:kAnimatedDurationFast animations:^{
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, PUB_NAVBAR_HEIGHT);
    }];
}

- (void)hiddenMenuTopBar
{
    [UIView animateWithDuration:kAnimatedDurationFast animations:^{
        self.frame = CGRectMake(0, - PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, PUB_NAVBAR_HEIGHT);
    }];
}

- (void)setNavTitle:(NSString *)titleString
{
    navTitleLabel.text = titleString?:@"";
}

- (void)leftBack
{
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Pop_Comic_Reader object:nil];
}

- (void)completeButtonClick
{
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Push_To_Directory object:nil];
}

@end

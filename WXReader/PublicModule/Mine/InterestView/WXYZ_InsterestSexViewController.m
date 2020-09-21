//
//  WXYZ_InsterestSexViewController.m
//  WXReader
//
//  Created by Andrew on 2018/11/16.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "WXYZ_InsterestSexViewController.h"
#import "WXYZ_InsterestBooksViewController.h"

@interface WXYZ_InsterestSexViewController ()
{
    UIButton *boyButton;
    
    UIButton *girlButton;
}

@property (nonatomic, strong) UIButton *nextStepButton;

@end

@implementation WXYZ_InsterestSexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarDefaultStyle];
}

- (void)initialize
{
    [self hiddenNavigationBar:YES];
    self.view.backgroundColor = kWhiteColor;
}

- (void)createSubviews
{
    YYLabel *titleTop = [[YYLabel alloc] init];
    titleTop.text = @"你终于来了";
    titleTop.textColor = kBlackColor;
    titleTop.textAlignment = NSTextAlignmentCenter;
    titleTop.textVerticalAlignment = YYTextVerticalAlignmentBottom;
    titleTop.font = kFont18;
    [self.view addSubview:titleTop];
    
    [titleTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(PUB_NAVBAR_OFFSET);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(65);
    }];
    
    YYLabel *titleBottom = [[YYLabel alloc] init];
    titleBottom.text = @"现在快选择你的性别吧";
    titleBottom.textColor = kGrayTextColor;
    titleBottom.textAlignment = NSTextAlignmentCenter;
    titleBottom.textVerticalAlignment = YYTextVerticalAlignmentTop;
    titleBottom.font = kMainFont;
    [self.view addSubview:titleBottom];
    
    [titleBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleTop.mas_bottom).with.offset(kHalfMargin);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(titleTop.mas_height);
    }];
    
    boyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    boyButton.adjustsImageWhenHighlighted = NO;
    [boyButton setImage:[UIImage imageNamed:@"insterest_boy_normal.png"] forState:UIControlStateNormal];
    [boyButton addTarget:self action:@selector(boyButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:boyButton];
    
    [boyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.top.mas_equalTo(titleBottom.mas_bottom).with.offset(4 * kMargin);
        make.width.height.mas_equalTo((SCREEN_WIDTH - 2 * kMargin) / 2);
    }];
    
    girlButton = [UIButton buttonWithType:UIButtonTypeCustom];
    girlButton.adjustsImageWhenHighlighted = NO;
    [girlButton setImage:[UIImage imageNamed:@"insterest_girl_normal.png"] forState:UIControlStateNormal];
    [girlButton addTarget:self action:@selector(girlButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:girlButton];
    
    [girlButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).with.offset(- kMargin);
        make.top.mas_equalTo(titleBottom.mas_bottom).with.offset(4 * kMargin);
        make.width.height.mas_equalTo((SCREEN_WIDTH - 2 * kMargin) / 2);
    }];
    
    self.nextStepButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextStepButton.backgroundColor = kColorRGBA(218, 218, 218, 1);
    [self.nextStepButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    self.nextStepButton.layer.cornerRadius = 20;
    self.nextStepButton.userInteractionEnabled = NO;
    [self.nextStepButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.nextStepButton addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextStepButton];
    
    [self.nextStepButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).with.offset(- PUB_NAVBAR_OFFSET - kMargin);
        make.left.mas_equalTo(2 * kMargin);
        make.width.mas_equalTo(self.view.mas_width).with.offset(- 4 * kMargin);
        make.height.mas_equalTo(40);
    }];
}

- (void)nextStep
{
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Insterest_Change object:@"step_one"];
}

- (void)boyButtonClick:(UIButton *)sender
{
    [WXYZ_UserInfoManager shareInstance].gender = 2;
    girlButton.selected = NO;
    self.nextStepButton.backgroundColor = kMainColor;
    self.nextStepButton.userInteractionEnabled = YES;
    
    [girlButton setImage:[UIImage imageNamed:@"insterest_girl_normal.png"] forState:UIControlStateNormal];
    [boyButton setImage:[UIImage imageNamed:@"insterest_boy_select.png"] forState:UIControlStateNormal];
    sender.selected = YES;
    
    WXYZ_SystemInfoManager.sexChannel = 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Channel_Change object:nil];
    WXYZ_SystemInfoManager.firstGenderSelecte = @"1";
}

- (void)girlButtonClick:(UIButton *)sender
{
    [WXYZ_UserInfoManager shareInstance].gender = 1;
    boyButton.selected = NO;
    self.nextStepButton.backgroundColor = kMainColor;
    self.nextStepButton.userInteractionEnabled = YES;
    
    [girlButton setImage:[UIImage imageNamed:@"insterest_girl_select.png"] forState:UIControlStateNormal];
    [boyButton setImage:[UIImage imageNamed:@"insterest_boy_normal.png"] forState:UIControlStateNormal];
    sender.selected = YES;
    
    WXYZ_SystemInfoManager.sexChannel = 2;
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Channel_Change object:nil];
    WXYZ_SystemInfoManager.firstGenderSelecte = @"2";
}

@end

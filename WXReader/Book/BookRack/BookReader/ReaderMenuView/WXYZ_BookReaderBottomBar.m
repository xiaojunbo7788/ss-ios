//
//  WXYZ_BookReaderBottomBar.m
//  WXReader
//
//  Created by Andrew on 2018/6/12.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BookReaderBottomBar.h"
#import "WXYZ_SliderView.h"
#import "WXYZ_BookReaderMenuBar.h"
#import "WXYZ_BookReaderBottomSettingBar.h"
#import "WXYZ_ReaderSettingHelper.h"
#import "WXYZ_ReaderBookManager.h"
#import "WXYZ_BookReaderTopBar.h"
#import "AppDelegate.h"
#import "WXYZ_WebViewViewController.h"

#define ToolBar_Normal_Height (60 + PUB_TABBAR_OFFSET)

#define ToolBarSettingView_Height ((50 * 4) + kHalfMargin)

#define ToolBarAutoReadView_Height (ToolBar_Normal_Height + 20 + kMargin)

#define ToolBar_Large_Height (ToolBar_Normal_Height + ToolBarSettingView_Height)

#define animateDuration 0.2f

@interface WXYZ_BookReaderBottomBar () <DPSliderViewDelegate>
{
    // 菜单按钮
    UIView *menuView;
    
    // 菜单栏设置背景
    WXYZ_BookReaderBottomSettingBar *settingBackView;
    
    // 自动阅读按钮
    WXYZ_CustomButton *autoReadButton;
    
    // 分割线
    UIView *grayLine;
    
    // 亮度滑块
    WXYZ_SliderView *brightnessSlider;
    
    // 阅读速度滑块
    WXYZ_SliderView *autoReadSpeedSlider;
    
    // 夜间模式
    UIButton *nightModeButton;
    
    WXYZ_ReaderSettingHelper *functionalManager;
    
    WXYZ_CustomButton *directoryButton;
    WXYZ_CustomButton *brightnessButton;
    WXYZ_CustomButton *fontSetButton;
    
#if WX_Comments_Mode
    WXYZ_CustomButton *commentButton;
#endif
    
}

@end

@implementation WXYZ_BookReaderBottomBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self initialize];
        
        [self createSubViews];
    }
    return self;
}

- (void)initialize
{
    self.backgroundColor = [UIColor whiteColor];
    
    functionalManager = [WXYZ_ReaderSettingHelper sharedManager];
}

- (void)createSubViews
{
    UIImageView *topLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, - 10, self.width, 10)];
    topLine.image = [UIImage imageNamed:@"tapbar_top_line"];
    topLine.userInteractionEnabled = YES;
    [self addSubview:topLine];
    
    menuView = [[UIView alloc] init];
    menuView.backgroundColor = [UIColor whiteColor];
    [self addSubview:menuView];
    
    [menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(self.mas_bottom).offset(- PUB_TABBAR_OFFSET);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(ToolBar_Normal_Height - PUB_TABBAR_OFFSET);
    }];
    
#pragma mark - 目录按钮
    directoryButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"目录" buttonImageName:@"book_menu_directory" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
    directoryButton.tag = 0;
    directoryButton.graphicDistance = 5;
    directoryButton.buttonImageScale = 0.5;
    [directoryButton addTarget:self action:@selector(toolBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:directoryButton];
    
#pragma mark - 亮度
    brightnessButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"亮度" buttonImageName:@"book_menu_brightness_higher" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
    brightnessButton.tag = 1;
    brightnessButton.graphicDistance = 5;
    brightnessButton.buttonImageScale = 0.5;
    [brightnessButton addTarget:self action:@selector(toolBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:brightnessButton];
    
#pragma mark - 字体设置
    fontSetButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"设置" buttonImageName:@"book_menu_setting" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
    fontSetButton.tag = 2;
    fontSetButton.graphicDistance = 5.5;
    fontSetButton.buttonImageScale = 0.45;
    [fontSetButton addTarget:self action:@selector(toolBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:fontSetButton];
    
#pragma mark - 评论
    
#if WX_Comments_Mode
    commentButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"评论" buttonImageName:@"book_menu_comment_icon" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
    commentButton.tag = 3;
    commentButton.graphicDistance = 5;
    commentButton.buttonImageScale = 0.45;
    [commentButton addTarget:self action:@selector(toolBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:commentButton];
#endif
    
    NSArray *buttonMenuArr = [NSArray arrayWithObjects:directoryButton, brightnessButton, fontSetButton,
#if WX_Comments_Mode
                              commentButton,
#endif
                              nil];
    
    [buttonMenuArr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:(SCREEN_WIDTH / buttonMenuArr.count) leadSpacing:0 tailSpacing:0];
    [buttonMenuArr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(8);
        make.height.mas_equalTo(menuView.mas_height).with.offset(- 16);
    }];
    
    
#pragma mark - 亮度调节按钮
    brightnessSlider = [[WXYZ_SliderView alloc] initWithFrame:CGRectMake(kMargin, kMargin, SCREEN_WIDTH - 2 * kMargin, ToolBar_Normal_Height - 2 * kMargin - PUB_TABBAR_OFFSET) sliderCutPointCount:1];
    brightnessSlider.minimumValue = 0.01;
    brightnessSlider.tag = 0;
    brightnessSlider.hidden = YES;
    brightnessSlider.sliderValue = [functionalManager getBrightness];
    brightnessSlider.delegate = self;
    brightnessSlider.minimumTintColor = kMainColor;
    brightnessSlider.leftImageName = @"book_menu_brightness_lower";
    brightnessSlider.rightImageName = @"book_menu_brightness_higher";
    [self addSubview:brightnessSlider];
    
#pragma mark - 菜单栏设置背景
    settingBackView = [[WXYZ_BookReaderBottomSettingBar alloc] initWithFrame:CGRectMake(0, 0, self.width, ToolBarSettingView_Height)];
    settingBackView.hidden = YES;
    [self addSubview:settingBackView];
    
#pragma mark - 自动阅读按钮
    autoReadButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"开启自动阅读"  buttonImageName:@"book_menu_auto_read_icon" buttonIndicator:WXYZ_CustomButtonIndicatorTitleRight];
    autoReadButton.graphicDistance = 0;
    autoReadButton.buttonImageScale = 0.4;
    autoReadButton.hidden = YES;
    autoReadButton.buttonTintColor = kBlackColor;
    [autoReadButton addTarget:self action:@selector(autoReadButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:autoReadButton];
    
    [autoReadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).with.offset(- PUB_TABBAR_OFFSET);
        make.centerX.mas_equalTo(settingBackView.mas_centerX);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(45);
    }];
    
    // 横线
    grayLine = [[UIView alloc] init];
    grayLine.hidden = YES;
    grayLine.backgroundColor = kColorRGBA(247, 247, 247, 1);
    [self addSubview:grayLine];
    
    [grayLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(autoReadButton.mas_top);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(5);
    }];
    
#pragma mark - 阅读速度调节
    autoReadSpeedSlider = [[WXYZ_SliderView alloc] initWithFrame:CGRectMake(kMargin, kHalfMargin, SCREEN_WIDTH - 2 * kMargin, 30) sliderCutPointCount:10];
    autoReadSpeedSlider.tag = 1;
    autoReadSpeedSlider.hidden = YES;
    autoReadSpeedSlider.stepSlider = YES;
    autoReadSpeedSlider.delegate = self;
    autoReadSpeedSlider.invertedValue = YES;
    autoReadSpeedSlider.sliderValue = 10 - [functionalManager getReadSpeed] / 5;
    autoReadSpeedSlider.leftImageName = @"book_menu_auto_read_slow";
    autoReadSpeedSlider.rightImageName = @"book_menu_auto_read_fast";
    [self addSubview:autoReadSpeedSlider];
    
    nightModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nightModeButton.tag = 10000;
    nightModeButton.adjustsImageWhenHighlighted = NO;
    nightModeButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    nightModeButton.contentHorizontalAlignment = UIControlContentVerticalAlignmentFill;
    if ([functionalManager getNightModeState] == WXReaderPatternModeNight) {
        [nightModeButton setImage:[UIImage imageNamed:@"book_menu_reader_night"] forState:UIControlStateNormal];
    } else {
        [nightModeButton setImage:[UIImage imageNamed:@"book_menu_reader_day"] forState:UIControlStateNormal];
    }
    [nightModeButton addTarget:self action:@selector(nightModeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nightModeButton];
    
    [nightModeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.right.mas_equalTo(self.mas_right).with.offset(- kMargin);
        make.bottom.mas_equalTo(menuView.mas_top).with.offset(- kMargin);
    }];
    
}

- (void)reloadTabbar
{
    [self removeAllSubviews];
    
    [self createSubViews];
}

// 菜单栏按钮点击
- (void)toolBarButtonClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 0:// 目录
            [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Reader_Push object:@"WXBookDirectoryViewController"];
            [self hiddenToolBar];
            break;
        case 1:// 亮度
            brightnessSlider.hidden = NO;
            break;
        case 2:// 设置
            settingBackView.hidden = NO;
            [self showLargeToolBar];
            break;
        case 3:// 评论
            [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Reader_Push object:@"WXYZ_CommentsViewController"];
            [self hiddenToolBar];
            break;
        default:
            break;
    }
    [self hiddenMenuView];
}

// 显示底部菜单按钮
- (void)showMenuView
{
    menuView.hidden = NO;
}

// 隐藏底部菜单按钮
- (void)hiddenMenuView
{
    [self hiddenNavBar];
    menuView.hidden = YES;
}

// 夜间模式
- (void)nightModeClick:(UIButton *)sender
{
    if ([functionalManager getNightModeState] == WXReaderPatternModeNight) {
        [functionalManager setNightModeState:WXReaderPatternModeDaytime];
        [sender setImage:[UIImage imageNamed:@"book_menu_reader_day"] forState:UIControlStateNormal];
    } else {
        [functionalManager setNightModeState:WXReaderPatternModeNight];
        [sender setImage:[UIImage imageNamed:@"book_menu_reader_night"] forState:UIControlStateNormal];
    }
    
    [[WXYZ_BookReaderMenuBar sharedManager] hiddend];
}

// 隐藏导航栏
- (void)hiddenNavBar
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Hidden_ToolNav object:nil];
}

// 显示工具栏
- (void)showToolBar
{
    self.hidden = NO;
    menuView.hidden = NO;
    if ([functionalManager getNightModeState] == WXReaderPatternModeNight) {
        [nightModeButton setImage:[UIImage imageNamed:@"book_menu_reader_night"] forState:UIControlStateNormal];
    } else {
        [nightModeButton setImage:[UIImage imageNamed:@"book_menu_reader_day"] forState:UIControlStateNormal];
    }
    [UIView animateWithDuration:animateDuration animations:^{
        self.frame = CGRectMake(0, SCREEN_HEIGHT - ToolBar_Normal_Height, SCREEN_WIDTH, ToolBar_Normal_Height);
        self->nightModeButton.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
}

// 显示自动阅读栏
- (void)showAutoReadToolBar
{
    nightModeButton.alpha = 0;
    self.hidden = NO;
    [UIView animateWithDuration:animateDuration animations:^{
        self.frame = CGRectMake(0, SCREEN_HEIGHT - ToolBarAutoReadView_Height, SCREEN_WIDTH, ToolBarAutoReadView_Height);
    } completion:^(BOOL finished) {
        self->autoReadButton.hidden = NO;
        self->autoReadSpeedSlider.hidden = NO;
        self->settingBackView.hidden = YES;
        self->grayLine.hidden = NO;
    }];
}

// 显示多选工具栏
- (void)showLargeToolBar
{
    nightModeButton.alpha = 0;
    [UIView animateWithDuration:animateDuration animations:^{
        self.frame = CGRectMake(0, SCREEN_HEIGHT - ToolBar_Large_Height, SCREEN_WIDTH, ToolBar_Large_Height);
    } completion:^(BOOL finished) {
        self->grayLine.hidden = NO;
        self->autoReadButton.hidden = NO;
    }];
}

// 隐藏工具栏
- (void)hiddenToolBar
{
    brightnessSlider.hidden = YES;
    settingBackView.hidden = YES;
    grayLine.hidden = YES;
    autoReadButton.hidden = YES;
    autoReadSpeedSlider.hidden = YES;
    
    if (_autoReading && functionalManager.state == WXReaderAutoReadStatePause) {
        [functionalManager setAutoReaderState:WXReaderAutoReadStateResume];
    }
    
    [UIView animateWithDuration:animateDuration animations:^{
        self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, ToolBar_Normal_Height);
        self->nightModeButton.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

#pragma mark - 按钮点击事件
- (void)sliderValueEndChanged:(CGFloat)endValue slider:(WXYZ_SliderView *)sender
{
    // 设置亮度
    if (sender.tag == 0) {
        [functionalManager setBrightness:endValue];
        
    } else {// 设置阅读速度
        [functionalManager setReadSpeed:(NSInteger)((endValue + 1) * 5)];
    }
}

// 关闭自动阅读
- (void)stopAutoRead
{
    if (_autoReading) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"自动阅读已关闭"];
    }
    _autoReading = NO;
    [functionalManager setAutoReaderState:WXReaderAutoReadStateStop];
    autoReadButton.buttonImageName = @"book_menu_auto_read_icon";
    autoReadButton.buttonTitle = @"开启自动阅读";
    autoReadButton.buttonTintColor = kBlackColor;
    [self hiddenToolBar];
    [self hiddenNavBar];
    [[WXYZ_BookReaderMenuBar sharedManager] hiddend];
    
}

// 自动阅读
- (void)autoReadButtonClick
{
    if (_autoReading) {
        [self stopAutoRead];
    } else {
        _autoReading = YES;
        autoReadButton.buttonImageName = @"book_menu_auto_read_exit";
        autoReadButton.buttonTitle = @"关闭自动阅读";
        autoReadButton.buttonTintColor = [UIColor colorWithRed: 241.0/255.0 green: 83.0/255.0 blue: 29.0/255.0 alpha: 1.0];
        [functionalManager setAutoReaderState:WXReaderAutoReadStateStart];
        [self hiddenToolBar];
        [self hiddenNavBar];
        [[WXYZ_BookReaderMenuBar sharedManager] hiddend];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        // 超出父视图的按钮tag值为10000
        CGPoint tempoint = [[self viewWithTag:10000] convertPoint:point fromView:self];
        if (CGRectContainsPoint([self viewWithTag:10000].bounds, tempoint)) {
            view = [self viewWithTag:10000];
        }
    }
    return view;
}

@end

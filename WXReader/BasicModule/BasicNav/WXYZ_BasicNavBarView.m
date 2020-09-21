//
//  WXYZ_BasicNavBarView.m
//  WXDating
//
//  Created by Andrew on 2017/8/13.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "WXYZ_BasicNavBarView.h"
#import "WXYZ_AudioSettingHelper.h"

@interface WXYZ_BasicNavBarView ()

// 默认返回按钮
@property (nonatomic, strong) UIButton *defaultLeftButton;

// 导航栏边线
@property (nonatomic, strong) UIImageView *navBottomLine;

@end

@implementation WXYZ_BasicNavBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    [self addSubview:self.navTitleLabel];
    
    [self addSubview:self.defaultLeftButton];

    [self addSubview:self.navBottomLine];
    
}

#pragma mark - public
/**
 隐藏返回按钮
 */
- (void)hiddenLeftBarButton
{
    self.defaultLeftButton.hidden = YES;
}

/**
 白色返回按钮
 */
- (void)setLightLeftButton
{
    [self.defaultLeftButton setTintColor:kWhiteColor];
}

/**
 设置返回按钮颜色
 */
- (void)setLeftButtonTintColor:(UIColor *)tintColor
{
    [self.defaultLeftButton setTintColor:tintColor];
}

/**
 设置导航栏左侧按钮
 */
- (void)setLeftBarButton:(UIButton *)leftButton
{
    if (self.defaultLeftButton) {
        [self.defaultLeftButton removeFromSuperview];
    }
    
    [self addSubview:leftButton];
}

/**
 设置导航栏右侧按钮
 */
- (void)setRightBarButton:(UIButton *)rightButton
{
    [self addSubview:rightButton];
}

/**
 分割线(细)
 */
- (void)setSmallSeparator
{
    self.navBottomLine.frame = CGRectMake(0, PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, 1);
    self.navBottomLine.hidden = NO;
}

/**
 分割线(粗)
 */
- (void)setLargeSeparator
{
    self.navBottomLine.frame = CGRectMake(0, PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, 5);
    self.navBottomLine.hidden = NO;
}

/**
 分割线(无)
 */
- (void)hiddenSeparator
{
    self.navBottomLine.frame = CGRectMake(0, PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, 0);
    self.navBottomLine.hidden = YES;
}

/**
 设置导航栏标题
 */
- (void)setNavigationBarTitle:(NSString *)title
{
    [self.navTitleLabel setText:title];
    self.navTitleLabel.frame = CGRectMake((SCREEN_WIDTH - 240) / 2.0, PUB_NAVBAR_OFFSET + 20, 240, 44);
}


/**
 设置导航栏标题颜色
 */
- (void)setNavigationBarTintColor:(UIColor *)tintColor
{
    [self.navTitleLabel setTextColor:tintColor];
}


/**
 设置导航栏标题字号
 */
- (void)setNavigationBarTintFont:(UIFont *)font
{
    [self.navTitleLabel setFont:font];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.navTitleLabel.backgroundColor = backgroundColor;
}

#pragma mark - lazy

- (UILabel *)navTitleLabel
{
    if (!_navTitleLabel) {
        _navTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _navTitleLabel.backgroundColor = [UIColor clearColor];
        _navTitleLabel.textColor = [UIColor blackColor];
        _navTitleLabel.numberOfLines = 1;
        _navTitleLabel.font = kFont16;
        _navTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _navTitleLabel;
}

- (UIButton *)defaultLeftButton
{
    if (!_defaultLeftButton) {
        _defaultLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _defaultLeftButton.backgroundColor = [UIColor clearColor];
        _defaultLeftButton.frame = CGRectMake(kHalfMargin, PUB_NAVBAR_OFFSET + 20, 44, 44);
        _defaultLeftButton.adjustsImageWhenHighlighted = NO;
        [_defaultLeftButton.titleLabel setFont:kMainFont];
        [_defaultLeftButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_defaultLeftButton setImageEdgeInsets:UIEdgeInsetsMake(12, 6, 12, 18)];
        [_defaultLeftButton setImage:[[UIImage imageNamed:@"public_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_defaultLeftButton setTintColor:kBlackColor];
        [_defaultLeftButton addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    }
    return _defaultLeftButton;
}

- (UIImageView *)navBottomLine
{
    if (!_navBottomLine) {
        _navBottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, 5)];
        _navBottomLine.userInteractionEnabled = YES;
        _navBottomLine.image = [UIImage imageNamed:@"navbar_bottom_line"];
    }
    return _navBottomLine;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (self.touchEnabled && hitView == self) {
        return nil;
    }
    return hitView;
}

#pragma mark -  pop

- (void)popViewController
{
    BOOL pop = NO;
    NSArray *viewcontrollers = self.navCurrentController.navigationController.viewControllers;
    if (viewcontrollers.count > 1) {
        if ([viewcontrollers objectAtIndex:viewcontrollers.count - 1] == self) {
            pop = YES;
            [self.navCurrentController.navigationController popViewControllerAnimated:YES];
        }
    } else {
        if ([self.navCurrentController isKindOfClass:[NSClassFromString(@"WXYZ_BookAiPlayPageViewController") class]]) {
            [[WXYZ_AudioSettingHelper sharedManager] playPageViewShow:NO productionType:WXYZ_ProductionTypeAi];
        }
        
        if ([self.navCurrentController isKindOfClass:[NSClassFromString(@"WXYZ_AudioSoundPlayPageViewController") class]]) {
            [[WXYZ_AudioSettingHelper sharedManager] playPageViewShow:NO productionType:WXYZ_ProductionTypeAudio];
        }
        
        [self.navCurrentController dismissViewControllerAnimated:YES completion:nil];
    }
    
    if (!pop) {
        [self.navCurrentController.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dealloc
{
    if (_navCurrentController) {
        [_navCurrentController willMoveToParentViewController:nil];
        [_navCurrentController.view removeFromSuperview];
        [_navCurrentController removeFromParentViewController];
    }
}


@end

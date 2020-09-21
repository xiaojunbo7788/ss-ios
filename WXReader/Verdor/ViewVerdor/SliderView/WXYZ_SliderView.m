//
//  DPSliderView.m
//  WXReader
//
//  Created by Andrew on 2018/6/5.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_SliderView.h"
#import "TTRangeSlider.h"

#define point_Height 4
#define ThumbImage_Height 20

@interface WXYZ_SliderView ()

@property (nonatomic, strong) UIImageView *leftIconImageView;

@property (nonatomic, strong) UIImageView *rightIconImageView;

@end

@implementation WXYZ_SliderView
{
    TTRangeSlider *slider;
    NSUInteger _cutPointCout;
}

- (instancetype)initWithFrame:(CGRect)frame sliderCutPointCount:(NSUInteger)cutPointCount
{
    if (self = [super initWithFrame:frame]) {
        _cutPointCout = cutPointCount;
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    _leftIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.height)];
    _leftIconImageView.bounds = CGRectMake(0, 0, CGRectGetWidth(_leftIconImageView.frame) + 5, CGRectGetHeight(_leftIconImageView.frame) + 5);
    [self addSubview:_leftIconImageView];
    
    slider = [[TTRangeSlider alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width - 2 * self.bounds.size.height, 10)];
    slider.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    slider.handleImage = [UIImage imageNamed:@"book_menu_slider_icon"];
    slider.minValue = CGFLOAT_MIN;
    slider.maxValue = _cutPointCout <= 0?10:_cutPointCout;
    slider.selectedMinimum = CGFLOAT_MIN;
    slider.selectedMaximum = _cutPointCout <= 0?10:_cutPointCout;
    slider.hideLabels = YES;
    slider.disableRange = YES;
    slider.enableStep = NO;
    slider.step = 1;
    slider.handleDiameter = 25;
    slider.selectedHandleDiameterMultiplier = 1.2;
    slider.lineBackGroundColor = kGrayTextDeepColor;
    slider.tintColorBetweenHandles = kMainColor;
    [slider addTarget:self action:@selector(sliderEndChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:slider];
    
    _rightIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - self.bounds.size.height, 0, self.bounds.size.height, self.bounds.size.height)];
    [self addSubview:_rightIconImageView];
}

- (void)sliderEndChanged:(TTRangeSlider *)sender
{
    if ([self.delegate respondsToSelector:@selector(sliderValueEndChanged:slider:)]) {
        [self.delegate sliderValueEndChanged:_invertedValue?fabs(sender.selectedMaximum - _cutPointCout):sender.selectedMaximum slider:self];
    }
}

- (void)slider:(UISlider *)sender
{
    sender.value = (int)roundf(sender.value);
}

- (void)setStepSlider:(BOOL)stepSlider
{
    if (stepSlider) {
        
        slider.tintColorBetweenHandles = [UIColor clearColor];
        slider.lineBackGroundColor = [UIColor clearColor];
        slider.enableStep = YES;
        
        NSUInteger buttonNum = _cutPointCout + 1;//每行多少按钮
        CGFloat button_W = point_Height;//按钮宽
        CGFloat button_H = point_Height;//按钮高
        CGFloat margin_X = ThumbImage_Height / 2;//第一个按钮的X坐标
        CGFloat margin_Y = (slider.height - point_Height) / 2;//第一个按钮的Y坐标
        CGFloat space_X = (slider.width - (3 * margin_X) - point_Height * (_cutPointCout + 1)) / _cutPointCout;//按钮间距
        for (NSUInteger i = 0; i < _cutPointCout + 1; i++) {
            NSUInteger row = i / buttonNum;//行号
            NSUInteger loc = i % buttonNum;//列号
            CGFloat button_X = margin_X + (space_X + button_W) * loc;
            CGFloat button_Y = margin_Y + button_H * row;
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(button_X, button_Y, button_W, button_H)];
            view.backgroundColor = [UIColor blackColor];
            view.layer.cornerRadius = point_Height / 2;
            view.clipsToBounds = YES;
            [slider addSubview:view];
            [slider sendSubviewToBack:view];
        }
        
    }
}

- (void)setMinimumTintColor:(UIColor *)minimumTintColor
{
    slider.tintColorBetweenHandles = minimumTintColor;
}

- (void)setMaximumTintColor:(UIColor *)maximumTintColor
{
    slider.tintColorBetweenHandles = maximumTintColor;
}

- (void)setLeftImage:(UIImage *)leftImage
{
    _leftIconImageView.image = leftImage;
}

- (void)setLeftImageName:(NSString *)leftImageName
{
    _leftIconImageView.image = [UIImage imageNamed:leftImageName];
}

- (void)setRightImage:(UIImage *)rightImage
{
    _rightIconImageView.image = rightImage;
}

- (void)setRightImageName:(NSString *)rightImageName
{
    _rightIconImageView.image = [UIImage imageNamed:rightImageName];
}

- (void)setMinimumValue:(CGFloat)minimumValue
{
    slider.minValue = minimumValue;
}

- (void)setMaximumValue:(CGFloat)maximumValue
{
    slider.maxValue = maximumValue;
}

- (void)setSliderValue:(CGFloat)sliderValue
{
    slider.selectedMaximum = sliderValue;
}

@end

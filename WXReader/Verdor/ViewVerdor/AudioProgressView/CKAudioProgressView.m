//
//  CKAudioProgressView.m
//  CKAudioProgress
//
//  Created by guo on 2019/5/14.
//  Copyright © 2019 guo. All rights reserved.
//

#import "CKAudioProgressView.h"
#import "CALayer+CKViewCategory.h"

@interface CKAudioProgressView()

@property (nonatomic, assign) BOOL    isSliding;
@property (nonatomic, assign) NSInteger audioLength;

@property (nonatomic, strong) UIView  *slideView;
@property (nonatomic, strong) UILabel *lb_time;
// 进度指示器
@property (nonatomic, strong) UILabel *lb_indicator;
@property (nonatomic, strong) CALayer *bgLayer;
@property (nonatomic, strong) CALayer *cachedLayer;
@property (nonatomic, strong) UIView *progressLineView;

@end

@implementation CKAudioProgressView

- (instancetype)initWithFrame:(CGRect)frame type:(CKAudioProgressType)progressType {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    
    [self.layer addSublayer:self.bgLayer];
    [self.layer addSublayer:self.cachedLayer];
    [self addSubview:self.progressLineView];
    
    [self addSubview:self.lb_indicator];
    
    [self addSubview:self.lb_time];
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)]];

    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat originY = (self.bounds.size.height-2)/2;
    self.bgLayer.ckOriginY = originY;
    self.bgLayer.ckWidth = self.frame.size.width;
    self.cachedLayer.ckOriginY = originY;
    self.progressLineView.ckOriginY = originY;
    
    _lb_time.ckOriginY = (self.bounds.size.height-_lb_time.bounds.size.height)/2;
}

#pragma mark - Action
static CGFloat percent = 0.0;
- (void)timeLabelPanGesture:(UIPanGestureRecognizer *)gesture
{
    UIGestureRecognizerState state = gesture.state;
    if (UIGestureRecognizerStateBegan == state) {
        _isSliding = YES;
        percent = 0.0;
        if (_delegate && [_delegate respondsToSelector:@selector(audioProgressTouchBegin)]) {
            [_delegate audioProgressTouchBegin];
        }
        
        [UIView animateWithDuration:kAnimatedDurationFast animations:^{
            self.lb_indicator.alpha = 1;
        }];
        
    }  else if (UIGestureRecognizerStateChanged == state) {
        CGPoint translation = [gesture translationInView:self];
        CGPoint slideViewCenter = CGPointMake(gesture.view.center.x+ translation.x, gesture.view.center.y);
        slideViewCenter.x = MAX(gesture.view.bounds.size.width/2, slideViewCenter.x);
        slideViewCenter.x = MIN(self.bounds.size.width-gesture.view.bounds.size.width/2, slideViewCenter.x);
        gesture.view.center = slideViewCenter;
        [gesture setTranslation:CGPointZero inView:self];
        
        _progressLineView.width = gesture.view.frame.origin.x;
        
        CGFloat totalWith = self.bounds.size.width - _lb_time.bounds.size.width;
        NSInteger audioProgress = gesture.view.frame.origin.x / totalWith * self.audioLength;
        
        percent = gesture.view.frame.origin.x / totalWith;
        
        [self setProgress:audioProgress total:self.audioLength];
        
        self.lb_indicator.ckOriginY = _lb_time.origin.y - 45;
        self.lb_indicator.ckCenterX = _lb_time.center.x;
        
    } else if (UIGestureRecognizerStateEnded == state || UIGestureRecognizerStateCancelled == state) {
        _isSliding = NO;
        
        NSInteger audioProgress = gesture.view.frame.origin.x / (self.bounds.size.width - _lb_time.bounds.size.width) * self.audioLength;
        
        [UIView animateWithDuration:kAnimatedDurationFast animations:^{
            self.lb_indicator.alpha = 0;
        }];
        
        if (_delegate && [_delegate respondsToSelector:@selector(audioProgresstouchEndhCurrentTime:totalTime:)]) {
            [_delegate audioProgresstouchEndhCurrentTime:audioProgress totalTime:self.audioLength];
        }
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture
{
    CGPoint translation = [gesture locationInView:self];
    
    NSInteger audioProgress = translation.x / self.bounds.size.width * self.audioLength;
    
    [self setProgress:audioProgress total:self.audioLength];
    
    if (_delegate && [_delegate respondsToSelector:@selector(audioProgresstouchEndhCurrentTime:totalTime:)]) {
        [_delegate audioProgresstouchEndhCurrentTime:audioProgress totalTime:self.audioLength];
    }
}

- (void)setProgress:(NSInteger)progress total:(NSInteger)total
{
    NSString *title = @"";
    if (total >= 3600) {
        title = [NSString stringWithFormat:@"%@/%@", [WXYZ_UtilsHelper getHourTimeTransformationWithTotalTimeLenght:progress], [WXYZ_UtilsHelper getHourTimeTransformationWithTotalTimeLenght:total]];
    } else {
        title = [NSString stringWithFormat:@"%@/%@", [WXYZ_UtilsHelper getMinuteTimeTransformationWithTotalTimeLenght:progress], [WXYZ_UtilsHelper getMinuteTimeTransformationWithTotalTimeLenght:total]];
    }
    _lb_time.text = title;
    
    if (self.lb_indicator.alpha > 0) {
        self.lb_indicator.text = title;
    }
}

- (void)updateProgress:(CGFloat)progress audioLength:(NSInteger)audioLength
{
    if (isnan(percent) || isinf(percent)) {
        percent = 0;
    }
    if (audioLength <= 0) {
        _lb_time.text = @"00:00/00:00";
        self.lb_indicator.text = @"00:00/00:00";
        _lb_time.ly_x = 0;
        _progressLineView.ly_width = 0;
        return;
    }
    
    if (progress > 1) {
        percent = 1;
    } else if (progress < 0) {
        percent = 0;
    } else {
        percent = progress;
    }
    
    if (!_isSliding) {
        
        self.audioLength = audioLength;
        
        [self setProgress:(NSInteger)(percent*audioLength) total:audioLength];
        
        CGFloat totalWith = self.bounds.size.width-_lb_time.bounds.size.width;
        CGFloat playedWidth  = totalWith*percent;
        _progressLineView.width = playedWidth;
        _lb_time.ckCenterX = playedWidth+_lb_time.bounds.size.width/2;
    }
}

- (void)updateCacheProgress:(CGFloat)progress
{
    if (!isnan(progress)) {
        self.cachedLayer.ckWidth = self.frame.size.width * progress;        
    }
}

#pragma mark - Getter & Setter

- (void)setCachedBgColor:(UIColor *)cachedBgColor {
    if (cachedBgColor) {
        _cachedBgColor = cachedBgColor;
        self.cachedLayer.backgroundColor = cachedBgColor.CGColor;
    }
}
- (void)setProgressBgColor:(UIColor *)progressBgColor {
    if (progressBgColor) {
        _progressBgColor = progressBgColor;
        self.bgLayer.backgroundColor = progressBgColor.CGColor;
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.cornerRadius = cornerRadius;
    self.bgLayer.cornerRadius = cornerRadius;
    self.cachedLayer.cornerRadius = cornerRadius;
    self.progressLineView.layer.cornerRadius = cornerRadius;
}

- (void)setColors:(NSArray *)colors {
    if (!_playedBgColor && colors) {
        _colors = colors;
    }
}
- (void)setPlayedBgColor:(UIColor *)playedBgColor {
    if (!_colors && playedBgColor) {
        _playedBgColor = playedBgColor;
        self.progressLineView.backgroundColor = playedBgColor;
    }
}

- (void)setSlideViewBounds:(CGRect)slideViewBounds {
    if (slideViewBounds.size.width > 0) {
        _slideViewBounds = slideViewBounds;
        
        self.lb_time.bounds = slideViewBounds;
        [self setNeedsLayout];
    }
}

- (void)setTotalTimeLength:(NSInteger)totalTimeLength
{
    _totalTimeLength = totalTimeLength;
    if (totalTimeLength >= 0) {
        
        NSString *title = @"";
        if (totalTimeLength >= 3600) {
            title = [NSString stringWithFormat:@"%@/%@", [WXYZ_UtilsHelper getHourTimeTransformationWithTotalTimeLenght:totalTimeLength], [WXYZ_UtilsHelper getHourTimeTransformationWithTotalTimeLenght:totalTimeLength]];
        } else {
            title = [NSString stringWithFormat:@"%@/%@", [WXYZ_UtilsHelper getMinuteTimeTransformationWithTotalTimeLenght:totalTimeLength], [WXYZ_UtilsHelper getMinuteTimeTransformationWithTotalTimeLenght:totalTimeLength]];
        }
        _lb_time.ly_width = [WXYZ_ViewHelper getDynamicWidthWithLabelFont:[UIFont systemFontOfSize:10] labelHeight:20 labelText:title] + kHalfMargin;
        _lb_indicator.ly_width = [WXYZ_ViewHelper getDynamicWidthWithLabelFont:kFont12 labelHeight:30 labelText:title] + kHalfMargin;
    }
}

- (CALayer *)bgLayer {
    if (!_bgLayer) {
        _bgLayer = [CALayer layer];
        _bgLayer.backgroundColor = _progressBgColor ? _progressBgColor.CGColor : [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1].CGColor;
        _bgLayer.frame = CGRectMake(0, (self.bounds.size.height-2)/2, self.bounds.size.width, 2);
    }
    return _bgLayer;
}

- (CALayer *)cachedLayer {
    if (!_cachedLayer) {
        _cachedLayer = [CALayer layer];
        _cachedLayer.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0].CGColor;
        _cachedLayer.frame = CGRectMake(0, (self.bounds.size.height-2)/2, 0, 2);
    }
    return _cachedLayer;
}

- (UIView *)progressLineView {
    if (!_progressLineView) {
        _progressLineView = [[UIView alloc] init];
        _progressLineView.frame = CGRectMake(0, (self.bounds.size.height - 2 ) / 2, 0, 2);
    }
    return _progressLineView;
}

- (UIView *)slideView {
    if (!_slideView) {
        _slideView = [UIView new];
        _slideView.frame = CGRectMake(-(24-24/2-12/2), 0, 24, 24);
        CAShapeLayer *dotLayer = [CAShapeLayer layer];
        dotLayer.fillColor = [UIColor whiteColor].CGColor;
        dotLayer.frame = CGRectMake((24-12)/2, (24-12)/2, 12, 12);
        dotLayer.cornerRadius = 6;
        dotLayer.shadowColor = [UIColor colorWithRed:255/255.0 green:120/255.0 blue:2/255.0 alpha:1.0].CGColor;
        dotLayer.shadowOffset = CGSizeMake(0,0);
        dotLayer.shadowOpacity = 1;
        dotLayer.shadowRadius = 10;
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:dotLayer.bounds];
        dotLayer.path = path.CGPath;
        [_slideView.layer addSublayer:dotLayer];
    }
    return _slideView;
}

- (UILabel *)lb_indicator
{
    if (!_lb_indicator) {
        _lb_indicator = [[UILabel alloc] init];
        _lb_indicator.font = kFont12;
        _lb_indicator.textAlignment = NSTextAlignmentCenter;
        _lb_indicator.textColor = kWhiteColor;
        _lb_indicator.frame = CGRectMake(0, 0, 92, 30);
        _lb_indicator.alpha = 0;
        _lb_indicator.layer.cornerRadius = 15;
        _lb_indicator.layer.backgroundColor = kColorRGBA(0, 0, 0, 0.7).CGColor;
        _lb_indicator.userInteractionEnabled = YES;
    }
    return _lb_indicator;
}

- (UILabel *)lb_time {
    if (!_lb_time) {
        _lb_time = [UILabel new];
        _lb_time.font = [UIFont systemFontOfSize:10];
        _lb_time.textAlignment = NSTextAlignmentCenter;
        _lb_time.textColor = kGrayTextDeepColor;
        _lb_time.frame = CGRectMake(0, 0, 72, 20);
        _lb_time.layer.cornerRadius = 10;
        _lb_time.layer.shadowColor = [UIColor colorWithRed:87/255.0 green:92/255.0 blue:111/255.0 alpha:0.5].CGColor;
        _lb_time.layer.shadowOffset = CGSizeMake(0,0);
        _lb_time.layer.shadowOpacity = 3;
        _lb_time.layer.shadowRadius = 1;
        _lb_time.layer.backgroundColor = kWhiteColor.CGColor;
        _lb_time.userInteractionEnabled = YES;
        [_lb_time addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(timeLabelPanGesture:)]];
    }
    return _lb_time;
}

@end

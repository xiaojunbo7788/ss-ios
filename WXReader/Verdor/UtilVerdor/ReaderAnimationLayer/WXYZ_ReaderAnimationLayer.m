//
//  WXReaderAnimationLayer.m
//  WXReader
//
//  Created by Andrew on 2018/6/8.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_ReaderAnimationLayer.h"
#import "WXYZ_ReaderSettingHelper.h"

#define animationKey @"wxreader_animation_layer_key"

@interface WXYZ_ReaderAnimationLayer () <CAAnimationDelegate>
{
    CFTimeInterval _animationDuration;
    UIView *_layerView;
}

@property (nonatomic, assign) WXReaderAnimationState state;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, strong) CABasicAnimation *pathAnimation;

@end

@implementation WXYZ_ReaderAnimationLayer

- (instancetype)initWithView:(UIView *)keyView
{
    if (self = [super init]) {
        _layerView = keyView;
        _animationDuration = [[WXYZ_ReaderSettingHelper sharedManager] getReadSpeed];

    }
    return self;
}

// 开始动画
- (void)startReadingAnimation
{
    self.state = WXReaderAnimationStateRunning;
    [self.shapeLayer addAnimation:self.pathAnimation forKey:animationKey];
    [_layerView.layer addSublayer:self.shapeLayer];
}

//暂停动画
- (void)pauseAnimation
{
    self.state = WXReaderAnimationStatePausing;
    CFTimeInterval pausedTime = [self.shapeLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.shapeLayer.speed = 0.0;
    self.shapeLayer.timeOffset = pausedTime;
}

//继续动画
- (void)resumeAnimation
{
    if (self.state == WXReaderAnimationStateStoped) {
        [self startReadingAnimation];
    }
    self.state = WXReaderAnimationStateRunning;
    CFTimeInterval pausedTime = [self.shapeLayer timeOffset];
    self.shapeLayer.speed = 1.0;
    self.shapeLayer.timeOffset = 0.0;
    self.shapeLayer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [self.shapeLayer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.shapeLayer.beginTime = timeSincePause;
}

// 停止动画
- (void)stopAnimation
{
    self.state = WXReaderAnimationStateStoped;
    self.pathAnimation = nil;
    [self.shapeLayer removeAnimationForKey:animationKey];
    [self.shapeLayer removeFromSuperlayer];
    self.shapeLayer = nil;
}

// 重启动画
- (void)resetAnimation
{
    if (self.state == WXReaderAnimationStateRunning) {
        [self resetDuration:_animationDuration];
    }
}

// 重置时间
- (void)resetDuration:(CFTimeInterval)animationDuration
{
    _animationDuration = animationDuration;
    
    if (self.state == WXReaderAnimationStatePausing || self.state == WXReaderAnimationStateStoped) {
        [self stopAnimation];
        return;
    }
    [self startReadingAnimation];
}

// 动画代理回调
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag == YES) {
        [self.shapeLayer addAnimation:self.pathAnimation forKey:animationKey];
        if (self.state == WXReaderAnimationStateRunning && self.readerAutoReadBlock) {
            self.readerAutoReadBlock();
        }
    }
}

- (UIBezierPath *)layerPath
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (is_iPhoneX) {
        CGFloat lineWidth = 2;
        
        // 屏幕左上角圆角半径
        CGFloat radius1 = 44;
        // 刘海顶部圆角半径
        CGFloat radius2 = 6;
        // 刘海底部圆角半径
        CGFloat radius3 = 20;
        // 刘海高度
        CGFloat hairHeight = 30;
        // 刘海顶部宽度
        CGFloat hairTopWidth = 209;
        // 刘海左侧空隙
        CGFloat hairLeftWidth = (SCREEN_WIDTH - hairTopWidth) / 2;
        // 刘海右侧空隙
        CGFloat hairRightWidth = hairLeftWidth;
                
        [path moveToPoint:CGPointMake(lineWidth, radius1)];
        [path addQuadCurveToPoint:CGPointMake(radius1, lineWidth) controlPoint:CGPointMake(lineWidth, lineWidth)];
        
        [path addLineToPoint:CGPointMake(hairLeftWidth - radius2, lineWidth)];
        [path addQuadCurveToPoint:CGPointMake(hairLeftWidth - lineWidth, radius2) controlPoint:CGPointMake(hairLeftWidth - lineWidth, lineWidth)];
        
        [path addLineToPoint:CGPointMake(hairLeftWidth - lineWidth, hairHeight - radius3)];
        [path addQuadCurveToPoint:CGPointMake(hairLeftWidth + radius3, hairHeight + lineWidth) controlPoint:CGPointMake(hairLeftWidth, hairHeight)];
        
        [path addLineToPoint:CGPointMake(SCREEN_WIDTH - hairRightWidth - radius3, hairHeight + lineWidth)];
        [path addQuadCurveToPoint:CGPointMake(SCREEN_WIDTH - hairRightWidth + lineWidth, hairHeight - radius3) controlPoint:CGPointMake(SCREEN_WIDTH - hairRightWidth, hairHeight)];
        
        [path addLineToPoint:CGPointMake(SCREEN_WIDTH - hairRightWidth + lineWidth, radius2)];
        [path addQuadCurveToPoint:CGPointMake(SCREEN_WIDTH - hairRightWidth + radius2, lineWidth) controlPoint:CGPointMake(SCREEN_WIDTH - hairRightWidth + lineWidth, lineWidth)];
        
        [path addLineToPoint:CGPointMake(SCREEN_WIDTH - radius1, lineWidth)];
        [path addQuadCurveToPoint:CGPointMake(SCREEN_WIDTH - lineWidth, radius1) controlPoint:CGPointMake(SCREEN_WIDTH - lineWidth, lineWidth)];
    } else {
        [path moveToPoint:CGPointMake(0, 2)];
        [path addLineToPoint:CGPointMake(SCREEN_WIDTH,2)];
    }
    return path;
}

- (CAShapeLayer *)shapeLayer
{
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.lineWidth = 4;
        _shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        _shapeLayer.strokeColor = kColorRGBA(255, 102, 0, 1).CGColor;
        _shapeLayer.path = [self layerPath].CGPath;
    }
    return _shapeLayer;
}

- (CABasicAnimation *)pathAnimation
{
    if (!_pathAnimation) {
        _pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        _pathAnimation.duration = _animationDuration;
        _pathAnimation.repeatCount = 1;
        _pathAnimation.delegate = self;
        _pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        _pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    }
    return _pathAnimation;
}

@end

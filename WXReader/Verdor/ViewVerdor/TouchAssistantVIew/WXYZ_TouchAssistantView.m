//
//  WXYZ_TouchAssistantView.m
//  WXReader
//
//  Created by Andrew on 2020/3/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_TouchAssistantView.h"

#if WX_Enable_Ai
    #import "WXYZ_BookAiPlayPageViewController.h"
#endif

#if WX_Enable_Audio
    #import "WXYZ_AudioSoundPlayPageViewController.h"
#endif

#if __has_include(<iflyMSC/IFlyMSC.h>)
#import "iflyMSC/IFlyMSC.h"
#endif
#import "WXYZ_Player.h"

#define kSystemKeyboardWindowLevel 10000000
#define kRotationalAnimationKey @"rotationAnimation"

@interface WXYZ_TouchAssistantView ()
{
    CGPoint beginCenter;            //记录首次点击坐标
    UITapGestureRecognizer *tapGR;  //点击手势
    WXYZ_ProductionType _productionType;
    BOOL _isPause;
}

@property (nonatomic, strong) UIWindow *mainWindow;
@property (nonatomic, strong) UIView *miniPlayPageView;   // 小助手
@property (nonatomic, strong) UIImageView *miniPlayIcon; // 作品图标
@property (nonatomic, strong) CABasicAnimation *rotationAnimation; // 作品旋转动画
@property (nonatomic, strong) UIButton *miniPlayButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) CAShapeLayer *rewardLayer;
@property (nonatomic, copy) NSString *cacheCover;

@end

@implementation WXYZ_TouchAssistantView

implementation_singleton(WXYZ_TouchAssistantView)

- (instancetype)init
{
    if (self = [super init]) {
        [self createSubviews];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

- (void)createSubviews
{
    self.mainWindow = kMainWindow;
    
    //点击手势
    tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tapGR.numberOfTouchesRequired = 1;
    tapGR.numberOfTapsRequired = 1;
    tapGR.enabled = YES;
    
    //拖动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.minimumNumberOfTouches = 1;
    
    self.miniPlayPageView = [[UIView alloc] initWithFrame:[self assistiveViewFrame]];
    self.miniPlayPageView.hidden = YES;
    self.miniPlayPageView.backgroundColor = kColorRGBA(255, 255, 255, 0.9);
    self.miniPlayPageView.layer.cornerRadius = [self assistiveViewFrame].size.height / 2;
    self.miniPlayPageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.miniPlayPageView.layer.shadowOffset = CGSizeMake(0, 0);
    self.miniPlayPageView.layer.shadowOpacity = 0.1f;
    self.miniPlayPageView.layer.shadowRadius = 4.0f;
    self.miniPlayPageView.userInteractionEnabled = YES;
    self.miniPlayPageView.tag = 31415926.0;
    [self.miniPlayPageView addGestureRecognizer:pan];
    [self.miniPlayPageView addGestureRecognizer:tapGR];
    [self.mainWindow addSubview:self.miniPlayPageView];
    
    self.miniPlayIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [self assistiveViewFrame].size.height, [self assistiveViewFrame].size.height)];
    self.miniPlayIcon.contentMode = UIViewContentModeScaleAspectFill;
    [self.miniPlayIcon zy_cornerRadiusAdvance:[self assistiveViewFrame].size.height / 2 rectCornerType:UIRectCornerAllCorners];
    [self.miniPlayIcon zy_attachBorderWidth:3 color:kWhiteColor];
    [self.miniPlayPageView addSubview:self.miniPlayIcon];
    
    UIView *icon = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self assistiveViewFrame].size.height, [self assistiveViewFrame].size.height)];
    icon.backgroundColor = [UIColor clearColor];
    [self.miniPlayPageView addSubview:icon];
    
    self.rewardLayer = [CAShapeLayer layer];
    self.rewardLayer.frame = CGRectMake(0, 0, self.miniPlayIcon.height, self.miniPlayIcon.height);
    self.rewardLayer.strokeColor = kMainColor.CGColor;
    self.rewardLayer.fillColor = [[UIColor clearColor] CGColor];
    self.rewardLayer.lineWidth = 3;
    self.rewardLayer.lineCap = @"round";
    [icon.layer addSublayer:self.rewardLayer];
    
    self.miniPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.miniPlayButton.frame = CGRectMake(self.miniPlayIcon.right, self.miniPlayIcon.top, self.miniPlayIcon.width, self.miniPlayIcon.height);
    self.miniPlayButton.adjustsImageWhenHighlighted = NO;
    self.miniPlayButton.tintColor = kGrayTextColor;
    [self.miniPlayButton setImage:[[UIImage imageNamed:@"audio_mini_play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.miniPlayButton setImageEdgeInsets:UIEdgeInsetsMake(13, 20, 13, 6)];
    [self.miniPlayButton addTarget:self action:@selector(miniPlayButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.miniPlayPageView addSubview:self.miniPlayButton];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.frame = CGRectMake(self.miniPlayButton.right, self.miniPlayButton.top, self.miniPlayButton.width, self.miniPlayButton.height);
    self.closeButton.adjustsImageWhenHighlighted = NO;
    self.closeButton.tintColor = kGrayTextColor;
    [self.closeButton setImage:[[UIImage imageNamed:@"audio_mini_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.closeButton setImageEdgeInsets:UIEdgeInsetsMake(17, 15, 17, 19)];
    [self.closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.miniPlayPageView addSubview:self.closeButton];
}

#pragma mark - 点击事件
- (void)tap:(UITapGestureRecognizer *)gr
{
    if ([[WXYZ_ViewHelper getCurrentViewController] isKindOfClass:[NSClassFromString(@"WXYZ_BookReaderViewController") class]]) {
        
        BOOL skip = NO;
        for (UIViewController *t_vc in [WXYZ_ViewHelper getCurrentViewController].navigationController.viewControllers) {
            if ([t_vc isKindOfClass:[NSClassFromString(@"WXYZ_BookAiPlayPageViewController") class]] || [t_vc isKindOfClass:[NSClassFromString(@"WXYZ_AudioSoundPlayPageViewController") class]]) {
                skip = YES;
            }
        }
        
        if (skip) {
            [[WXYZ_ViewHelper getCurrentViewController].navigationController popViewControllerAnimated:YES];
            return;
        }
    }
    
    if (_productionType == WXYZ_ProductionTypeBook) {
#if WX_Enable_Ai
        WXYZ_BookAiPlayPageViewController *vc = [WXYZ_BookAiPlayPageViewController sharedManager];
        if (vc.stoped) {
            [vc loadDataWithBookModel:nil chapterModel:nil];
        }
        WXYZ_NavigationController *nav = [[WXYZ_NavigationController alloc] initWithRootViewController:vc];
        if ([[WXYZ_ViewHelper getCurrentViewController] isKindOfClass:[NSClassFromString(@"WXYZ_BookReaderViewController") class]]) {
            nav.view.tag = 2345;
        }
        [[WXYZ_ViewHelper getWindowRootController] presentViewController:nav animated:YES completion:nil];
#endif
    }
    
    if (_productionType == WXYZ_ProductionTypeAudio) {
#if WX_Enable_Audio
        WXYZ_AudioSoundPlayPageViewController *vc = [WXYZ_AudioSoundPlayPageViewController sharedManager];
        if (vc.stoped) {
            [vc loadDataWithAudio_id:0 chapter_id:0];
        }
        WXYZ_NavigationController *nav = [[WXYZ_NavigationController alloc] initWithRootViewController:vc];
        if ([[WXYZ_ViewHelper getCurrentViewController] isKindOfClass:[NSClassFromString(@"WXYZ_BookReaderViewController") class]]) {
            nav.view.tag = 2345;
        }
        [[WXYZ_ViewHelper getWindowRootController] presentViewController:nav animated:YES completion:nil];
#endif
    }
}

#pragma mark - 通知
//屏幕旋转通知
- (void)changeRotate:(NSNotification *)notification
{
    [self calculateAssistiveCenter:self.miniPlayPageView.center];
}

#pragma mark - 拖动事件(动画逻辑)

- (void)pan:(UIPanGestureRecognizer *)recognizer
{
    //移动点
    CGPoint point = [recognizer translationInView:self.mainWindow];
    CGPoint center = self.miniPlayPageView.center;
    center.x += point.x;
    center.y += point.y;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {//开始
        
        beginCenter = self.miniPlayPageView.center;
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {//改变
        
        [self setAssistiveViewCenter:center];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled ) {//结束 || 取消
        [self calculateAssistiveCenter:center];
        
    } else if (recognizer.state == UIGestureRecognizerStateFailed) {//失败
        [self setAssistiveViewCenter:beginCenter];
    }
}

#pragma mark - 小助手坐标计算方法
- (void)calculateAssistiveCenter:(CGPoint)center
{
    CGFloat topSide = center.y - [self assistiveViewFrame].size.height / 2;//上边 y 坐标值
    CGFloat bottomSide = center.y + [self assistiveViewFrame].size.height / 2;//下边 y 坐标值
    CGFloat margin = 0;
    
    [UIView animateWithDuration:kAnimatedDuration animations:^{
        
        if (center.x <= SCREEN_WIDTH / 2) { // 贴左处理
            
            if (topSide < PUB_NAVBAR_HEIGHT) { // 贴左上
                [self setAssistiveViewOrigin:CGPointMake(margin, PUB_NAVBAR_HEIGHT)];
            } else if (bottomSide > SCREEN_HEIGHT - PUB_TABBAR_HEIGHT) {    // 贴左下
                [self setAssistiveViewOrigin:CGPointMake(margin, SCREEN_HEIGHT - PUB_TABBAR_HEIGHT - [self assistiveViewFrame].size.height)];
            } else { // 正常贴左
                [self setAssistiveViewOrigin:CGPointMake(margin, topSide)];
            }
            
        } else if (center.x > SCREEN_WIDTH / 2) { // 贴右处理
            
            if (topSide < PUB_NAVBAR_HEIGHT) { // 贴右上
                [self setAssistiveViewOrigin:CGPointMake(SCREEN_WIDTH - [self assistiveViewFrame].size.width - margin, PUB_NAVBAR_HEIGHT)];
            } else if (bottomSide > SCREEN_HEIGHT - PUB_TABBAR_HEIGHT) {    // 贴右下
                [self setAssistiveViewOrigin:CGPointMake(SCREEN_WIDTH - [self assistiveViewFrame].size.width - margin, SCREEN_HEIGHT - PUB_TABBAR_HEIGHT - [self assistiveViewFrame].size.height)];
            } else { // 正常贴右
                [self setAssistiveViewOrigin:CGPointMake(SCREEN_WIDTH - [self assistiveViewFrame].size.width - margin, topSide)];
            }
            
        }
    }];
}

- (void)miniPlayButtonClick
{
    if (_productionType == WXYZ_ProductionTypeBook) {
#if WX_Enable_Ai
        WXYZ_BookAiPlayPageViewController *vc = [WXYZ_BookAiPlayPageViewController sharedManager];
        if (vc.speaking) {
            [[IFlySpeechSynthesizer sharedInstance] pauseSpeaking];
        } else if (!vc.stoped) {
            [[IFlySpeechSynthesizer sharedInstance] resumeSpeaking];
        } else {
            [vc loadDataWithBookModel:nil chapterModel:nil];
            WXYZ_NavigationController *nav = [[WXYZ_NavigationController alloc] initWithRootViewController:vc];
            [[WXYZ_ViewHelper getWindowRootController] presentViewController:nav animated:YES completion:nil];
        }
#endif
    }
    
    if (_productionType == WXYZ_ProductionTypeAudio) {
#if WX_Enable_Audio
        WXYZ_AudioSoundPlayPageViewController *vc = [WXYZ_AudioSoundPlayPageViewController sharedManager];
        if (vc.speaking) {
            [[WXYZ_Player sharedPlayer] pause];
        } else if (!vc.stoped) {
            [[WXYZ_Player sharedPlayer] play];
        } else {
            [vc loadDataWithAudio_id:0 chapter_id:0];
            WXYZ_NavigationController *nav = [[WXYZ_NavigationController alloc] initWithRootViewController:vc];
            [[WXYZ_ViewHelper getWindowRootController] presentViewController:nav animated:YES completion:nil];
        }
#endif
    }
}

- (void)closeButtonClick
{
//    if (_productionType == WXYZ_ProductionTypeBook) {
#if __has_include(<iflyMSC/IFlyMSC.h>)
        [[IFlySpeechSynthesizer sharedInstance] pauseSpeaking];
#endif
//    }
    
//    if (_productionType == WXYZ_ProductionTypeAudio) {
        [[WXYZ_Player sharedPlayer] pause];
//    }
    
    self.cacheCover = nil;
    
    [self stopPlayerState];
    
    [self hiddenAssistiveTouchView];
    
    kCodeSync([[UIApplication sharedApplication] endReceivingRemoteControlEvents]);
}

#pragma mark - 变量
- (CGRect)assistiveViewFrame
{
    return CGRectMake(0, SCREEN_HEIGHT - 200, 45 * 3, 45);
}

//设置小助手 && 菜单栏Center
- (void)setAssistiveViewCenter:(CGPoint)newCenter
{
    self.miniPlayPageView.center = newCenter;
}

- (void)setAssistiveViewOrigin:(CGPoint)newPoint
{
    self.miniPlayPageView.origin = newPoint;
}

- (CABasicAnimation *)rotationAnimation
{
    if (!_rotationAnimation) {
        CABasicAnimation *rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
        rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
        rotationAnimation.duration = 10;
        rotationAnimation.repeatCount = HUGE_VALF;
        rotationAnimation.removedOnCompletion = NO;
        _rotationAnimation = rotationAnimation;
    }
    return _rotationAnimation;
}

// 暂停动画
- (void)pauseAnimate
{
    if (_isPause) return;
    _isPause = YES;

    CFTimeInterval pauseTime = [self.miniPlayIcon.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.miniPlayIcon.layer.speed = 0;
    self.miniPlayIcon.layer.timeOffset = pauseTime;
}

// 继续动画
- (void)resumeAnimate
{
    if (!_isPause) return;
    _isPause = NO;
    
    CFTimeInterval pauseTime = self.miniPlayIcon.layer.timeOffset;
    self.miniPlayIcon.layer.speed = 1.0;
    self.miniPlayIcon.layer.timeOffset = 0.0;
    self.miniPlayIcon.layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [self.miniPlayIcon.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pauseTime;
    self.miniPlayIcon.layer.beginTime = timeSincePause;
}

// 停止动画
- (void)stopAnimate
{
    self.rewardLayer.path = [UIBezierPath bezierPathWithArcCenter:self.miniPlayIcon.center radius:(self.miniPlayIcon.height - 2) / 2 startAngle:- M_PI_2 endAngle:- M_PI_2 clockwise:YES].CGPath;
    [self.miniPlayIcon.layer removeAnimationForKey:kRotationalAnimationKey];
}

// 开始动画
- (void)startAnimate
{
    if (![self.miniPlayIcon.layer animationForKey:kRotationalAnimationKey]) {
        [self.miniPlayIcon.layer addAnimation:self.rotationAnimation forKey:kRotationalAnimationKey];
    }
    [self resumeAnimate];
}

// 显示小助手
- (void)showAssistiveTouchViewWithImageCover:(NSString *)imageCover productionType:(WXYZ_ProductionType)productionType
{
    _productionType = productionType;
    
    if (self.cacheCover != imageCover) {
        self.cacheCover = imageCover;
        [self stopAnimate];
    }
    
    [self showAssistiveTouchView];
}

- (void)showAssistiveTouchView
{
    if (self.cacheCover.length == 0 || !self.cacheCover) {
        return;
    }
#if WX_Enable_Audio
    WXYZ_AudioSoundPlayPageViewController *audioViewController = [WXYZ_AudioSoundPlayPageViewController sharedManager];
#endif
#if WX_Enable_Ai
    WXYZ_BookAiPlayPageViewController *aiViewController = [WXYZ_BookAiPlayPageViewController sharedManager];
#endif
    
    [self.miniPlayIcon setImageWithURL:[NSURL URLWithString:self.cacheCover] placeholder:HoldImage options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
    
    if (_productionType == WXYZ_ProductionTypeBook) {
#if WX_Enable_Ai
        if (aiViewController.speaking) {
            [self playPlayerState];
        } else {
            if (!audioViewController.speaking) {
                [self pausePlayerState];
            }
        }
        self.rewardLayer.hidden = YES;
#endif
    }
    
    if (_productionType == WXYZ_ProductionTypeAudio) {
#if WX_Enable_Audio
        if (audioViewController.speaking) {
            [self playPlayerState];
        } else {
            if (!aiViewController.speaking) {
                [self pausePlayerState];
            }
        }
#endif
        self.rewardLayer.hidden = NO;
    }
    
    self.miniPlayPageView.hidden = NO;
    
    [self.mainWindow bringSubviewToFront:self.miniPlayPageView];
}

- (void)setPlayerProductionType:(WXYZ_ProductionType)productionType
{
    _productionType = productionType;
}

// 隐藏小助手
- (void)hiddenAssistiveTouchView
{
    self.miniPlayPageView.hidden = YES;
}

- (void)changePlayProgress:(CGFloat)progress
{
    WS(weakSelf)
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.rewardLayer.path = [UIBezierPath bezierPathWithArcCenter:weakSelf.miniPlayIcon.center
                                                                   radius:(weakSelf.miniPlayIcon.height - 2) / 2
                                                               startAngle:- M_PI_2 endAngle:(M_PI * 2)* progress - M_PI_2
                                                                clockwise:YES].CGPath;
    });
    
}

- (void)playPlayerState
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startAnimate];
        [self.miniPlayButton setImage:[[UIImage imageNamed:@"audio_mini_pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    });
}

- (void)pausePlayerState
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self pauseAnimate];
        [self.miniPlayButton setImage:[[UIImage imageNamed:@"audio_mini_play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    });
}

- (void)stopPlayerState
{
#if WX_Enable_Audio
    WXYZ_AudioSoundPlayPageViewController *audioViewController = [WXYZ_AudioSoundPlayPageViewController sharedManager];
#endif
#if WX_Enable_Ai
    WXYZ_BookAiPlayPageViewController *aiViewController = [WXYZ_BookAiPlayPageViewController sharedManager];
    if (!aiViewController.speaking && !audioViewController.speaking) {
        [self coerceStopPlayerState];
    }
#endif
}

// 强制停止
- (void)coerceStopPlayerState
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopAnimate];
        [self.miniPlayButton setImage:[[UIImage imageNamed:@"audio_mini_play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    });
}

@end

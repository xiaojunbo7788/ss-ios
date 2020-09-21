//
//  DPSendCodeButton.m
//  demo
//
//  Created by Andrew on 2017/8/15.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "WXYZ_SendCodeButton.h"
#import "WXYZ_GCDTimer.h"

/** 倒计时时长 */
static NSInteger const countdown_time = 60;

@interface WXYZ_SendCodeButton ()

@property (nonatomic, strong) WXYZ_GCDTimer *countdownTimer;

@property (nonatomic, copy) NSString *identifyString;

@property (nonatomic, assign) NSUInteger originalTime;

@end

@implementation WXYZ_SendCodeButton

- (instancetype)initWithFrame:(CGRect)frame identify:(NSString *)identifyString
{
    if (self = [super initWithFrame:frame]) {
        [self.titleLabel setFont:kFont14];
        [self setTitle:@"获取验证码" forState:UIControlStateNormal];
        
        //App进入前台
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ApplicationBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        //App进入后台
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ApplicationEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        _identifyString = identifyString;
        
        if ([self getSaveTime] > 1) {
            self.originalTime = [self getSaveTime];
            [self startTiming];
        } else {
            self.originalTime = countdown_time;
        }
    }
    return self;
}

- (void)startTiming
{
    self.enabled = NO;
    
    [self.countdownTimer startTimerWithTimeDuration:self.originalTime];

    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(160);
    }];
}

- (void)stopTiming
{
    self.enabled = YES;
    [self.countdownTimer stopTimer];
    [self setTitle:@"重新发送" forState:UIControlStateNormal];
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.intrinsicContentSize.width + kMargin);
    }];
}

- (BOOL)countdownState {
    return self.countdownTimer.timerState == WXYZ_GCDTimerStateRunning;
}

+ (BOOL)shouldStartTimingWithIdentifySting:(NSString *)identifyString
{
    if ([[self alloc] getSaveTimeWithIdentifySting:identifyString] == 0) {
        return YES;
    }
    return NO;
}

- (void)allowTimingAtBackgound:(BOOL)allow
{
    if (allow) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidBecomeActiveNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidEnterBackgroundNotification
                                                      object:nil];
    }
}

#pragma mark -  private

- (NSUInteger)getSaveTime
{
    return [self getSaveTimeWithIdentifySting:_identifyString];
}

- (NSUInteger)getSaveTimeWithIdentifySting:(NSString *)identifyString
{
    
    if (!identifyString) {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:@"VerCodeButtonTime"] integerValue];
    }
    return [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"VerCodeButtonTime-%@",identifyString]] integerValue];
}

- (void)saveTime:(NSUInteger)ktime
{
    if (!_identifyString || _identifyString == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:[WXYZ_UtilsHelper formatStringWithInteger:ktime] forKey:@"VerCodeButtonTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:[WXYZ_UtilsHelper formatStringWithInteger:ktime] forKey:[NSString stringWithFormat:@"VerCodeButtonTime-%@",_identifyString]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)ApplicationBecomeActive
{
//    [self.countdownTimer resumeTimer];
}

- (void)ApplicationEnterBackground
{
//    [self.countdownTimer suspendTimer];
}

- (WXYZ_GCDTimer *)countdownTimer
{
    if (!_countdownTimer) {
        WS(weakSelf);
        _countdownTimer = [[WXYZ_GCDTimer alloc] initCountdownTimerWithTimeDuration:10 immediatelyCallBack:YES];
        _countdownTimer.timerFinishedBlock = ^{
            weakSelf.originalTime = countdown_time;
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.enabled = YES;
                [weakSelf setTitle:@"重新发送" forState:UIControlStateNormal];
                [weakSelf mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(weakSelf.intrinsicContentSize.width + kMargin);
                }];
            });
        };
        
        _countdownTimer.timerRunningBlock = ^(NSUInteger runTimes, CGFloat currentTime) {
            [weakSelf saveTime:currentTime];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf setTitle:[NSString stringWithFormat:@"(%@)秒后可重新发送", [WXYZ_UtilsHelper formatStringWithInteger:currentTime]] forState:UIControlStateNormal];
            });
        };
    }
    return _countdownTimer;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


//
//  WXYZ_GCDTimer.m
//  WXReader
//
//  Created by Andrew on 2020/6/18.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_GCDTimer.h"

@interface WXYZ_GCDTimer ()
{
    dispatch_source_t __block timer;
    WXYZ_GCDTimerState _timerState;
    
    double _timeDuration;
    double _interval;
    BOOL _immediatelyCallBack;
}

@end

@implementation WXYZ_GCDTimer

// 循环定时器（每秒循环一次）
- (instancetype)initCycleTimerWithImmediatelyCallBack:(BOOL)immediatelyCallBack
{
    if (self = [super init]) {
        _timerState = WXYZ_GCDTimerStateStoped;
        _immediatelyCallBack = immediatelyCallBack;
        _timeDuration = 0;
        _interval = 1;
    }
    return self;
}

// 循环计时器
- (instancetype)initCycleTimerWithInterval:(double)interval immediatelyCallBack:(BOOL)immediatelyCallBack
{
    if (self = [super init]) {
        _timerState = WXYZ_GCDTimerStateStoped;
        _immediatelyCallBack = immediatelyCallBack;
        _timeDuration = 0;
        _interval = interval;
    }
    return self;
}

// 倒计时计时器（每秒循环一次）
- (instancetype)initCountdownTimerWithTimeDuration:(double)timeDuration immediatelyCallBack:(BOOL)immediatelyCallBack
{
    if (self = [super init]) {
        _timerState = WXYZ_GCDTimerStateStoped;
        _immediatelyCallBack = immediatelyCallBack;
        _timeDuration = timeDuration;
        _interval = 1;
    }
    return self;
}

// 设定时间间隔倒计时计时器
- (instancetype)initCountdownTimerWithTimeDuration:(double)timeDuration interval:(double)interval immediatelyCallBack:(BOOL)immediatelyCallBack
{
    if (self = [super init]) {
        _timerState = WXYZ_GCDTimerStateStoped;
        _immediatelyCallBack = immediatelyCallBack;
        _timeDuration = timeDuration;
        _interval = interval;
    }
    return self;
}

/**
 *   定时器开启
 */
- (void)startTimer
{
    if (timer && _timerState == WXYZ_GCDTimerStatePausing) {
        [self resumeTimer];
    }
    
    [self stopTimer];
    [self createTimer];
}

- (void)startTimerWithTimeDuration:(double)timeDuration
{
    _timeDuration = timeDuration;
    [self startTimer];
}

/**
 *  定时器停止
 */
- (void)stopTimer
{
    if(timer) {
        if (_timerState == WXYZ_GCDTimerStateRunning) {
            dispatch_source_cancel(timer);
            timer = nil;
            _timerState = WXYZ_GCDTimerStateStoped;
            if (self.timerTerminateBlock) {
                self.timerTerminateBlock();
            }
        }
    }
}

/**
 *  定时器恢复
 */
- (void)resumeTimer
{
    if(timer) {
        if (_timerState == WXYZ_GCDTimerStatePausing) {
            dispatch_resume(timer);
            _timerState = WXYZ_GCDTimerStateRunning;
            if (self.timerResumeBlock) {
                self.timerResumeBlock();
            }
        }
    }
}

/**
 *  定时器暂停
 */
- (void)suspendTimer
{
    if(timer){
        if (_timerState == WXYZ_GCDTimerStateRunning) {
            dispatch_suspend(timer);
            _timerState = WXYZ_GCDTimerStatePausing;
            if (self.timerSuspendBlock) {
                self.timerSuspendBlock();
            }
        }
    }
}

#pragma privite

/**
 *  定时器任务完成
 */
- (void)finishTimer
{
    if(timer) {
        if (_timerState == WXYZ_GCDTimerStateRunning) {
            dispatch_source_cancel(timer);
            timer = nil;
            _timerState = WXYZ_GCDTimerStateStoped;
            if (self.timerFinishedBlock) {
                self.timerFinishedBlock();
            }
        }
    }
}

- (void)createTimer
{
    
    BOOL __block kImmediatelyCallBack = _immediatelyCallBack;
    double __block kTimeDuration = _timeDuration <= 0 ? HUGE_VAL : _timeDuration;
    
    // 计时器时间不正确
    if (kTimeDuration <= 0) {
        if (self.timerFinishedBlock) {
            self.timerFinishedBlock();
        }
        return;
    }
    
    if (_interval == 0) {
        _interval = 1;
    }
    
    NSUInteger __block runTimes = 0;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer,dispatch_walltime(NULL, 0), _interval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        [self songShuTimer:runTimes kImmediatelyCallBack:kImmediatelyCallBack kTimeDuration:kTimeDuration];
    });
    dispatch_resume(timer);
    
    if (self.timerStartBlock) {
        self.timerStartBlock();
    }
}

- (void)songShuTimer:(NSUInteger)runTimes kImmediatelyCallBack:(BOOL)kImmediatelyCallBack kTimeDuration:(double)kTimeDuration {
    runTimes ++;
    
    _timerState = WXYZ_GCDTimerStateRunning;
    
    if (kTimeDuration <= 0) {
        [self finishTimer];
        
    } else {
        kTimeDuration = kTimeDuration - _interval;
        if (kImmediatelyCallBack) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (self.timerRunningBlock) {
                    self.timerRunningBlock(runTimes, kTimeDuration != INFINITY ?kTimeDuration:0.f);
                }
            });
            
        }
        kImmediatelyCallBack = YES;
    }
}

@end

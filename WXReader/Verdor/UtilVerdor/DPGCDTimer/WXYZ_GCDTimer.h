//
//  WXYZ_GCDTimer.h
//  WXReader
//
//  Created by Andrew on 2020/6/18.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WXYZ_GCDTimerState) {
    WXYZ_GCDTimerStateStoped,
    WXYZ_GCDTimerStateRunning,
    WXYZ_GCDTimerStatePausing
};

@interface WXYZ_GCDTimer : NSObject

@property (nonatomic, copy) void (^timerStartBlock)(void);      // 定时器开始回调

@property (nonatomic, copy) void (^timerSuspendBlock)(void);    // 定时器暂停回调

@property (nonatomic, copy) void (^timerResumeBlock)(void);     // 定时器恢复回调

@property (nonatomic, copy) void (^timerTerminateBlock)(void);  // 定时器终止回调

@property (nonatomic, copy) void (^timerFinishedBlock)(void);   // 定时器完成回调

@property (nonatomic, copy) void (^timerRunningBlock)(NSUInteger runTimes, CGFloat currentTime);   // 定时器运行回调

@property (nonatomic, assign, readonly) WXYZ_GCDTimerState timerState;    // 定时器状态

/**
循环定时器（每秒循环一次）

@param immediatelyCallBack 开启定时器时是否立即进行运行回调
*/
- (instancetype)initCycleTimerWithImmediatelyCallBack:(BOOL)immediatelyCallBack;

/**
循环计时器

@param interval 计时间隔
@param immediatelyCallBack 开启定时器时是否立即进行运行回调
*/
- (instancetype)initCycleTimerWithInterval:(double)interval immediatelyCallBack:(BOOL)immediatelyCallBack;

/**
倒计时计时器（每秒循环一次）

@param timeDuration 倒计时时长
@param immediatelyCallBack 开启定时器时是否立即进行运行回调
*/
- (instancetype)initCountdownTimerWithTimeDuration:(double)timeDuration immediatelyCallBack:(BOOL)immediatelyCallBack;

/**
倒计时计时器

@param timeDuration 倒计时时长
@param interval 计时间隔
@param immediatelyCallBack 开启定时器时是否立即进行运行回调
*/
- (instancetype)initCountdownTimerWithTimeDuration:(double)timeDuration interval:(double)interval immediatelyCallBack:(BOOL)immediatelyCallBack;

- (instancetype)init NS_UNAVAILABLE;

/**
 *   定时器开启
 */
- (void)startTimer;

/**
 *   定时器开启
 */
- (void)startTimerWithTimeDuration:(double)timeDuration;

/**
 *  定时器停止
 */
- (void)stopTimer;

/**
 *  定时器恢复
 */
- (void)resumeTimer;

/**
 *  定时器暂停
 */
- (void)suspendTimer;

@end

NS_ASSUME_NONNULL_END

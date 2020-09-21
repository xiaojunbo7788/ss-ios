//
//  WXReaderAnimationLayer.h
//  WXReader
//
//  Created by Andrew on 2018/6/8.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WXReaderAnimationState) {
    WXReaderAnimationStateStoped    = 0,
    WXReaderAnimationStateRunning   = 1,
    WXReaderAnimationStatePausing   = 2
};

typedef void(^ReaderAutoReadBlock)(void);

@interface WXYZ_ReaderAnimationLayer : NSObject

// 触发自动翻页
@property (nonatomic, copy) ReaderAutoReadBlock readerAutoReadBlock;

- (instancetype)initWithView:(UIView *)keyView;

// 开始动画
- (void)startReadingAnimation;

//暂停动画
- (void)pauseAnimation;

//继续动画
- (void)resumeAnimation;

// 停止动画
- (void)stopAnimation;

// 重启动画
- (void)resetAnimation;

// 重置时间
- (void)resetDuration:(CFTimeInterval)animationDuration;

@end

//
//  WXYZ_Player.h
//  WXYZ_Player
//
//  Created by ihoudf on 2017/7/18.
//  Copyright © 2017年 ihoudf. All rights reserved.
//
//
//  WXYZ_Player当前版本：2.0.2
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "WXYZ_PlayerModel.h"
#import "WXYZ_BasicPlayPageHeaderView.h"

//播放模式
typedef NS_ENUM(NSInteger, WXYZ_PlayerMode){
    WXYZ_PlayerModeOnlyOnce,       //单曲只播放一次，默认
    WXYZ_PlayerModeSingleCycle,    //单曲循环
    WXYZ_PlayerModeOrderCycle,     //顺序循环
    WXYZ_PlayerModeShuffleCycle    //随机循环
};

@class WXYZ_Player;

@protocol WXYZ_PlayerDataSource <NSObject>

@required

/**
 数据源1：音频数组
 
 @param player WXYZ_Player
 */
- (NSArray<WXYZ_PlayerModel *> *)audioDataForPlayer:(WXYZ_Player *)player;

@optional

/**
 数据源2：音频信息
 调用playWithAudioId时，WXYZ_Player会调用此方法请求当前音频的信息
 根据player.currentAudioModel.audioId获取音频在数组中的位置,传入对应的音频信息model
 
 @param player WXYZ_Player
 */
- (WXYZ_PlayerInfoModel *)audioInfoForPlayer:(WXYZ_Player *)player;

@end


@protocol WXYZ_PlayerDelegate <NSObject>

@optional
/**
 代理1：音频已经加入播放队列
 
 @param player WXYZ_Player
 */
- (void)playerAudioAddToPlayQueue:(WXYZ_Player *)player;

/**
 代理2：准备播放
 
 @param player WXYZ_Player
 */
- (void)playerReadyToPlay:(WXYZ_Player *)player;

/**
 代理3：缓冲进度代理  (属性isObserveBufferProgress(默认YES)为YES时有效）
 
 @param player WXYZ_Player
 @param bufferProgress 缓冲进度
 */
- (void)player:(WXYZ_Player *)player bufferProgress:(CGFloat)bufferProgress;

/**
 代理4：播放进度代理 （属性isObserveProgress(默认YES)为YES时有效）
 
 @param player WXYZ_Player
 @param progress 播放进度
 @param currentTime 当前播放到的时间
 */
- (void)player:(WXYZ_Player *)player progress:(CGFloat)progress currentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime;

/**
 代理5：播放结束代理
 （默认播放结束后调用next，如果实现此代理，播放结束逻辑由您处理）
 
 @param player FPlayer
 */
- (void)playerDidPlayToEndTime:(WXYZ_Player *)player;

/**
 代理7：播放器被系统打断代理
 （默认被系统打断暂停播放，打断结束检测能够播放则恢复播放，如果实现此代理，打断逻辑由您处理）
 
 @param player WXYZ_Player
 @param isInterrupted YES:被系统打断开始  NO:被系统打断结束
 */
- (void)player:(WXYZ_Player *)player isInterrupted:(BOOL)isInterrupted;

/**
 代理8：监听耳机插入拔出代理
 
 @param player WXYZ_Player
 @param isHeadphone YES:插入 NO:拔出
 */
- (void)player:(WXYZ_Player *)player isHeadphone:(BOOL)isHeadphone;

/**
 代理9：播放状态改变
 */
- (void)playerStateChange:(WXYZ_PlayPagePlayerState)playerState;

// 远程控制切换上一首作品
- (void)audioPlayerRemoteCenterSwitchToPrevious;

// 远程控制切换下一首作品
- (void)audioPlayerRemoteCenterSwitchToNext;

@end

/**
 WXYZ_Player播放管理器
 */
@interface WXYZ_Player : NSObject

#pragma mark - 初始化和操作

@property (nonatomic, weak) id<WXYZ_PlayerDataSource> dataSource;

@property (nonatomic, weak) id<WXYZ_PlayerDelegate> delegate;

// 是否禁止上一首远程控制键可用
@property (nonatomic, assign) BOOL remoteCenterPreviousEnable;

// 是否禁止下一首远程控制键可用
@property (nonatomic, assign) BOOL remoteCenterNextEnable;

/**
 播放模式，默认WXYZ_PlayerModeOnlyOnce。
 */
@property (nonatomic, assign) WXYZ_PlayerMode playMode;

/**
 播放倍速
*/
@property (nonatomic, assign) CGFloat playRate;

/**
 单例
 */
+ (WXYZ_Player *)sharedPlayer;

/**
 初始化播放器
 */
- (void)initPlayerWithUserId:(NSString *)userId;

/**
 刷新数据源数据
 */
- (void)reloadData;

/**
 选择audioId对应的音频开始播放。
 说明：WXYZ_Player通过数据源方法提前获取数据，通过playWithAudioId选择对应音频播放。
 而在删除、增加音频后需要调用[[WXYZ_Player shareInstance] reloadData];刷新数据。
 */
- (void)playWithAudioId:(NSUInteger)audioId;

/**
 播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 下一首
 */
- (void)next;

/**
 上一首
 */
- (void)last;

/**
 音频跳转
 
 @param value 时间百分比
 @param completionBlock seek结束
 */
- (void)seekToTime:(CGFloat)value completionBlock:(void(^)(void))completionBlock;

/**
 倍速播放（iOS10之后系统支持的倍速常数有0.50, 0.67, 0.80, 1.0, 1.25, 1.50和2.0）
 @param rate 倍速
 */
- (void)setRate:(CGFloat)rate;

/**
 释放播放器，还原其他播放器
 */
- (void)deallocPlayer;


#pragma mark - 状态类

/**
 播放器状态
 */
@property (nonatomic, readonly, assign) WXYZ_PlayPagePlayerState state;

/**
 当前正在播放的音频model
 */
@property (nonatomic, readonly, strong) WXYZ_PlayerModel *currentAudioModel;

/**
 当前正在播放的音频信息model
 */
@property (nonatomic, readonly, strong) WXYZ_PlayerInfoModel *currentAudioInfoModel;

/**
 当前音频缓冲进度
 */
@property (nonatomic, readonly, assign) CGFloat bufferProgress;

/**
 当前音频播放进度
 */
@property (nonatomic, readonly, assign) CGFloat progress;

/**
 当前音频当前时间
 */
@property (nonatomic, readonly, assign) CGFloat currentTime;

/**
 当前音频总时长
 */
@property (nonatomic, readonly, assign) CGFloat totalTime;

@end





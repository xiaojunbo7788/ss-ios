//
//  WXYZ_Player.m
//  WXYZ_Player
//
//  Created by ihoudf on 2017/7/18.
//  Copyright © 2017年 ihoudf. All rights reserved.
//

#import "WXYZ_Player.h"
#import <MediaPlayer/MediaPlayer.h>
#import "WXYZ_TouchAssistantView.h"

#define WXYZ_PlayerHighGlobalQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
#define WXYZ_PlayerDefaultGlobalQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

/**Asset KEY*/
NSString * const WXYZPlayableKey                  = @"playable";
/**PlayerItem KEY*/
NSString * const WXYZStatusKey                    = @"status";
NSString * const WXYZLoadedTimeRangesKey          = @"loadedTimeRanges";
NSString * const WXYZPlaybackBufferEmptyKey       = @"playbackBufferEmpty";
NSString * const WXYZPlaybackLikelyToKeepUpKey    = @"playbackLikelyToKeepUp";

@interface WXYZ_Player()
{
    BOOL _isOtherPlaying; // 其他应用是否正在播放
    BOOL _isBackground; // 是否进入后台
    BOOL _isSeek; // 正在seek
    BOOL _isNaturalToEndTime; // 是否是自然结束
    dispatch_group_t _netGroupQueue; // 组队列-网络
    dispatch_group_t _dataGroupQueue; // 组队列-数据
    CGFloat _seekValue; // seek value
    NSMutableDictionary *_remoteInfoDictionary;//控制中心信息
}
/** player */
@property (nonatomic, strong) AVPlayer          *player;
/** playerItem */
@property (nonatomic, strong) AVPlayerItem      *playerItem;
/** 播放进度监测 */
@property (nonatomic, strong) id                timeObserver;
/** model数据数组 */
@property (nonatomic, strong) NSMutableArray<WXYZ_PlayerModel *> *playerModelArray;

@property (nonatomic, copy) void(^seekCompletionBlock)(void);

@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTaskId;

@property (nonatomic, readwrite, strong) WXYZ_PlayerModel *currentAudioModel;
@property (nonatomic, readwrite, strong) WXYZ_PlayerInfoModel *currentAudioInfoModel;
@property (nonatomic, readwrite, assign) WXYZ_PlayPagePlayerState state;
@property (nonatomic, readwrite, assign) CGFloat bufferProgress;
@property (nonatomic, readwrite, assign) CGFloat progress;
@property (nonatomic, readwrite, assign) CGFloat currentTime;
@property (nonatomic, readwrite, assign) CGFloat totalTime;

@end

@implementation WXYZ_Player

#pragma mark - 初始化
+ (WXYZ_Player *)sharedPlayer {
    static WXYZ_Player *player = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        player = [[[self class] alloc] init];
    });
    return player;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    UIBackgroundTaskIdentifier taskID = [[UIApplication sharedExtensionApplication] beginBackgroundTaskWithExpirationHandler:^{}];
    if (taskID != UIBackgroundTaskInvalid) {
        [[UIApplication sharedExtensionApplication] endBackgroundTask:taskID];
    }
}

#pragma mark - 初始化播放器
- (void)initPlayerWithUserId:(NSString *)userId{
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    _isOtherPlaying = [AVAudioSession sharedInstance].otherAudioPlaying;
    
    self.playMode = WXYZ_PlayerModeOnlyOnce;
    self.state = WXYZ_PlayPagePlayerStateStoped;
    _isBackground   = NO;
    
    _netGroupQueue  = dispatch_group_create();
    _dataGroupQueue = dispatch_group_create();
    
    [self addPlayerObserver];
    [self addRemoteControlHandler];
}

- (void)addPlayerObserver{
    //将要进入后台
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(playerWillResignActive)
                               name:UIApplicationWillResignActiveNotification
                             object:nil];
    //已经进入前台
    [notificationCenter addObserver:self
                           selector:@selector(playerDidEnterForeground)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
    //监测耳机
    [notificationCenter addObserver:self
                           selector:@selector(playerAudioRouteChange:)
                               name:AVAudioSessionRouteChangeNotification
                             object:nil];
    //监听播放器被打断（别的软件播放音乐，来电话）
    [notificationCenter addObserver:self
                           selector:@selector(playerAudioBeInterrupted:)
                               name:AVAudioSessionInterruptionNotification
                             object:[AVAudioSession sharedInstance]];
}

- (void)playerWillResignActive{
    _isBackground = YES;
    _bgTaskId = [self backgroundPlayerID:_bgTaskId];
}

- (UIBackgroundTaskIdentifier)backgroundPlayerID:(UIBackgroundTaskIdentifier)backTaskId {
    // 设置并激活音频会话类别
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    // 允许应用程序接收远程控制
    // 设置后台任务ID
    UIBackgroundTaskIdentifier taskId = UIBackgroundTaskInvalid;
    taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    if(taskId != UIBackgroundTaskInvalid &&
       backTaskId != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:backTaskId];
    }
    return taskId;
}

- (void)playerDidEnterForeground{
    _isBackground = NO;
}

- (void)playerAudioRouteChange:(NSNotification *)notification{
    NSInteger routeChangeReason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable://耳机插入
            if (self.delegate && [self.delegate respondsToSelector:@selector(player:isHeadphone:)]) {
                [self.delegate player:self isHeadphone:YES];
            }
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable://耳机拔出，停止播放操作
            if (self.delegate && [self.delegate respondsToSelector:@selector(player:isHeadphone:)]) {
                [self.delegate player:self isHeadphone:NO];
            }else{
                [self pause];
            }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            //
            break;
        default:
            break;
    }
}

- (void)playerAudioBeInterrupted:(NSNotification *)notification{
    NSDictionary *dic = notification.userInfo;
    if ([dic[AVAudioSessionInterruptionTypeKey] integerValue] == 1) {//打断开始
        if (self.delegate && [self.delegate respondsToSelector:@selector(player:isInterrupted:)]) {
            [self.delegate player:self isInterrupted:YES];
        }else{
            [self pause];
        }
    }else {//打断结束
        if (self.delegate && [self.delegate respondsToSelector:@selector(player:isInterrupted:)]) {
            [self.delegate player:self isInterrupted:NO];
        }else{
            if ([notification.userInfo[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue] == 1) {
                [self play];
            }
        }
    }
}

-(void)playerDidPlayToEndTime:(NSNotification *)notification{
    // 其他音视频播放结束也会触发回调，例如穿山甲的激励视频。
    if (notification.object != self.playerItem) return;
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidPlayToEndTime:)]) {
        [self.delegate playerDidPlayToEndTime:self];
    }else{
        _isNaturalToEndTime = YES;
        [self next];
    }
}

/**远程线控*/
- (void)addRemoteControlHandler
{
    if (@available (iOS 7.1, *)) {
        kCodeSync([[UIApplication sharedApplication] endReceivingRemoteControlEvents]);
        kCodeSync([[UIApplication sharedApplication] beginReceivingRemoteControlEvents]);
        MPRemoteCommandCenter *center = [MPRemoteCommandCenter sharedCommandCenter];
        [self addRemoteCommand:center.playCommand selector:@selector(play)];
        [self addRemoteCommand:center.pauseCommand selector:@selector(pause)];
        [self addRemoteCommand:center.previousTrackCommand selector:@selector(last)];
        [self addRemoteCommand:center.nextTrackCommand selector:@selector(next)];
        [center.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
            if ([WXYZ_Player sharedPlayer].state == WXYZ_PlayPagePlayerStatePlaying) {
                [[WXYZ_Player sharedPlayer] pause];
            }else{
                [[WXYZ_Player sharedPlayer] play];
            }
            return MPRemoteCommandHandlerStatusSuccess;
        }];
        
        if (@available (iOS 9.1,*)) {
            [center.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
                MPChangePlaybackPositionCommandEvent *positionEvent = (MPChangePlaybackPositionCommandEvent *)event;
                if (self.totalTime > 0) {
                    [self seekToTime:positionEvent.positionTime / self.totalTime completionBlock:nil];
                }
                return MPRemoteCommandHandlerStatusSuccess;
            }];
        }
    }
}

- (void)addRemoteCommand:(MPRemoteCommand *)command selector:(SEL)selector{
    [command addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if ([self respondsToSelector:selector]) {
            IMP imp = [self methodForSelector:selector];
            void (*func)(id, SEL) = (void *)imp;
            func(self, selector);
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
}

- (void)setRemoteCenterPreviousEnable:(BOOL)remoteCenterPreviousEnable
{
    _remoteCenterPreviousEnable = remoteCenterPreviousEnable;
    [MPRemoteCommandCenter sharedCommandCenter].previousTrackCommand.enabled = remoteCenterPreviousEnable;
}

- (void)setRemoteCenterNextEnable:(BOOL)remoteCenterNextEnable
{
    _remoteCenterNextEnable = remoteCenterNextEnable;
    [MPRemoteCommandCenter sharedCommandCenter].nextTrackCommand.enabled = remoteCenterNextEnable;
}

#pragma mark - 数据源

- (void)reloadData{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(audioDataForPlayer:)]) {
        if (!self.playerModelArray) {
            self.playerModelArray = [NSMutableArray array];
        }
        if (self.playerModelArray.count != 0) {
            [self.playerModelArray removeAllObjects];
        }
        dispatch_group_enter(_dataGroupQueue);
        dispatch_group_async(_dataGroupQueue, WXYZ_PlayerHighGlobalQueue, ^{
            dispatch_async(WXYZ_PlayerHighGlobalQueue, ^{
                
                [self.playerModelArray addObjectsFromArray:[self.dataSource audioDataForPlayer:self]];
                
                //更新currentAudioId
                if (self.currentAudioModel.audioUrl) {
                    [self.playerModelArray enumerateObjectsWithOptions:(NSEnumerationConcurrent) usingBlock:^(WXYZ_PlayerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj.audioUrl.absoluteString isEqualToString:self.currentAudioModel.audioUrl.absoluteString]) {
                            self.currentAudioModel.audioId = idx;
                            *stop = YES;
                        }
                    }];
                }
                dispatch_group_leave(self->_dataGroupQueue);
            });
        });
    }
}

#pragma mark - 播放 IMPORTANT

- (void)playWithAudioId:(NSUInteger)audioId{
    dispatch_group_notify(_dataGroupQueue, WXYZ_PlayerHighGlobalQueue, ^{
        if (self.playerModelArray.count > audioId) {
            self.currentAudioModel = self.playerModelArray[audioId];
            [self audioPrePlay];
        }
    });
}

- (void)audioPrePlay{
    [self reset];

    if (self.dataSource && [self.dataSource respondsToSelector:@selector(audioInfoForPlayer:)]) {
        self.currentAudioInfoModel = [self.dataSource audioInfoForPlayer:self];
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(playerAudioAddToPlayQueue:)]) {
        [self.delegate playerAudioAddToPlayQueue:self];
    }
    
    [self loadPlayerItemWithURL:self.currentAudioModel.audioUrl];
}

- (void)loadPlayerItemWithURL:(NSURL *)URL{
    self.playerItem = [[AVPlayerItem alloc] initWithURL:URL];
    [self loadPlayer];
}

- (void)loadPlayerItemWithAsset:(AVURLAsset *)asset{
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self loadPlayer];
}

- (void)loadPlayer{
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    if (@available(iOS 10.0,*)) {
        self.player.automaticallyWaitsToMinimizeStalling = NO;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 处理章节开始播放,但监听还未执行的问题
        [self play];
    });
    [self addProgressObserver];
    [self addPlayingCenterInfo];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (object == self.player.currentItem) {
        if ([keyPath isEqualToString:WXYZStatusKey]) {
            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            switch (status) {
                case AVPlayerItemStatusUnknown:
                    self.state = WXYZ_PlayPagePlayerStateStoped;
                    if (self.delegate && [self.delegate respondsToSelector:@selector(playerStateChange:)]) {
                        [self.delegate playerStateChange:self.state];
                    }
                    break;
                case AVPlayerItemStatusReadyToPlay:
                    if (self.delegate && [self.delegate respondsToSelector:@selector(playerReadyToPlay:)]) {
                        if (self.state != WXYZ_PlayPagePlayerStatePause) {
                            [self.delegate playerReadyToPlay:self];
                        }
                    }
                    break;
                case AVPlayerItemStatusFailed:
                    self.state = WXYZ_PlayPagePlayerStateFail;
                    if (self.delegate && [self.delegate respondsToSelector:@selector(playerStateChange:)]) {
                        [self.delegate playerStateChange:self.state];
                    }
                    break;
                default:
                    break;
            }
        } else if ([keyPath isEqualToString:WXYZLoadedTimeRangesKey]) {
            [self addBufferProgressObserver];
        } else if ([keyPath isEqualToString:WXYZPlaybackBufferEmptyKey]) {
            
        } else if ([keyPath isEqualToString:WXYZPlaybackLikelyToKeepUpKey]) {
            
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - 缓冲进度 播放进度 歌曲锁屏信息 音频跳转

- (void)addBufferProgressObserver{
    self.totalTime = CMTimeGetSeconds(self.playerItem.asset.duration);

    CMTimeRange timeRange   = [self.playerItem.loadedTimeRanges.firstObject CMTimeRangeValue];
    CGFloat startSeconds    = CMTimeGetSeconds(timeRange.start);
    CGFloat durationSeconds = CMTimeGetSeconds(timeRange.duration);
    if (self.totalTime != 0) {//避免出现inf
        self.bufferProgress = (startSeconds + durationSeconds) / self.totalTime;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(player:bufferProgress:)]) {
        [self.delegate player:self bufferProgress:self.bufferProgress];
    }
}

- (void)addProgressObserver
{
    WS(weakSelf)
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, 1.0) queue:nil usingBlock:^(CMTime time){
        SS(sSelf)
        AVPlayerItem *currentItem = sSelf.playerItem;
        NSArray *loadedRanges = currentItem.seekableTimeRanges;
        if (loadedRanges.count > 0 && currentItem.duration.timescale != 0){
            
            if (sSelf.state != WXYZ_PlayPagePlayerStatePlaying && sSelf.state != WXYZ_PlayPagePlayerStatePause) {
                sSelf.state = WXYZ_PlayPagePlayerStatePlaying;
                if (sSelf.delegate && [sSelf.delegate respondsToSelector:@selector(playerStateChange:)]) {
                    [sSelf.delegate playerStateChange:sSelf.state];
                }
            }
            
            CGFloat currentT = (CGFloat)CMTimeGetSeconds(time);
            sSelf.currentTime = currentT + (sSelf.totalTime > 1?1:0);
            if (sSelf.totalTime != 0 && !isnan(sSelf.totalTime)) {// 避免出现inf
                sSelf.progress = (CMTimeGetSeconds([currentItem currentTime]) + (sSelf.totalTime > 1?1:0)) / sSelf.totalTime;
            }
            
            if (sSelf.delegate && [sSelf.delegate respondsToSelector:@selector(player:progress:currentTime:totalTime:)]) {
                [sSelf.delegate player:sSelf progress:sSelf.progress currentTime:currentT totalTime:sSelf.totalTime];
            }

            [sSelf updatePlayingCenterInfo];
        }
    }];
}

- (void)addPlayingCenterInfo{
    _remoteInfoDictionary = [NSMutableDictionary dictionary];
    
    if (self.currentAudioInfoModel.audioName) {
        _remoteInfoDictionary[MPMediaItemPropertyTitle] = self.currentAudioInfoModel.audioName;
    }
    if (self.currentAudioInfoModel.audioAlbum) {
        _remoteInfoDictionary[MPMediaItemPropertyAlbumTitle] = self.currentAudioInfoModel.audioAlbum;
    }
    if (self.currentAudioInfoModel.audioSinger) {
        _remoteInfoDictionary[MPMediaItemPropertyArtist] = self.currentAudioInfoModel.audioSinger;
    }
    if ([self.currentAudioInfoModel.audioImage isKindOfClass:[UIImage class]] && self.currentAudioInfoModel.audioImage) {
        
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:CGSizeMake(BOOK_WIDTH, BOOK_HEIGHT) requestHandler:^UIImage * _Nonnull(CGSize size) {
            return self.currentAudioInfoModel.audioImage;
        }];
        
        _remoteInfoDictionary[MPMediaItemPropertyArtwork] = artwork;
    }
    _remoteInfoDictionary[MPNowPlayingInfoPropertyPlaybackRate] = [NSNumber numberWithFloat:1.0];
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = _remoteInfoDictionary;
}

- (void)updatePlayingCenterInfo{
    if (!_isBackground) {return;}
    
    if ([WXYZ_TouchAssistantView sharedManager].productionType == WXYZ_ProductionTypeAudio) {
        _remoteInfoDictionary[MPNowPlayingInfoPropertyElapsedPlaybackTime] = [NSNumber numberWithDouble:CMTimeGetSeconds(self.playerItem.currentTime)];
        _remoteInfoDictionary[MPMediaItemPropertyPlaybackDuration] = [NSNumber numberWithDouble:CMTimeGetSeconds(self.playerItem.duration)];
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = _remoteInfoDictionary;        
    }
}

- (void)seekToTime:(CGFloat)value completionBlock:(void (^)(void))completionBlock{
    _isSeek = YES;
    // 先暂停
    BOOL resumePlay = NO;
    if (self.state == WXYZ_PlayPagePlayerStatePlaying || self.state == WXYZ_PlayPagePlayerStateLoading) {
        self.state = WXYZ_PlayPagePlayerStatePause;
        [self.player pause];
        resumePlay = YES;
    }
    
    [self didSeekToTime:value resumePlay:resumePlay completionBlock:completionBlock];
}

- (void)didSeekToTime:(CGFloat)value resumePlay:(BOOL)resumePlay completionBlock:(void (^)(void))completionBlock
{
    [self.player seekToTime:CMTimeMake(floorf(self.totalTime * value), 1)
            toleranceBefore:kCMTimeZero
             toleranceAfter:kCMTimeZero
          completionHandler:^(BOOL finished) {
        if (finished) {
            self->_isSeek = NO;
            [self play];
            if (!resumePlay) {
                [self pause];
            }
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
}

/**倍速播放*/
- (void)setRate:(CGFloat)rate {
    _playRate = rate;
    for (AVPlayerItemTrack *track in self.playerItem.tracks){
        if ([track.assetTrack.mediaType isEqual:AVMediaTypeAudio]){
            track.enabled = YES;
        }
    }
    
    if (self.state == WXYZ_PlayPagePlayerStatePlaying) {
        self.player.rate = rate;        
    }
}

/**释放播放器*/
- (void)deallocPlayer{
    
    [self reset];
    
    self.state = WXYZ_PlayPagePlayerStateStoped;
    
    if (@available(iOS 7.1, *)) {
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
        MPRemoteCommandCenter *center = [MPRemoteCommandCenter sharedCommandCenter];
        [[center playCommand] removeTarget:self];
        [[center pauseCommand] removeTarget:self];
        [[center nextTrackCommand] removeTarget:self];
        [[center previousTrackCommand] removeTarget:self];
        [[center togglePlayPauseCommand] removeTarget:self];
        if(@available(iOS 9.1, *)) {
            [center.changePlaybackPositionCommand removeTarget:self];
        }
    }
    
    if (_isOtherPlaying) {
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    }else{
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    
    if (self.playerModelArray) {
        self.playerModelArray = nil;
    }
    
    if (self.playerItem) {
        self.playerItem = nil;
    }
    
    if (self.player) {
        self.player = nil;
    }
}

- (void)reset{
    if (self.state == WXYZ_PlayPagePlayerStatePlaying) {
        [self.player pause];
    }
    
    //移除进度观察者
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
    
    //重置
    self.progress = .0f;
    self.bufferProgress = .0f;
    self.currentTime = .0f;
    self.totalTime = .0f;
}

#pragma mark - 播放 暂停 下一首 上一首
/**播放*/
- (void)play
{
    [self.player play];
    self.player.rate = self.playRate;
    self.state = WXYZ_PlayPagePlayerStateLoading;
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerStateChange:)]) {
        [self.delegate playerStateChange:self.state];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    });
}

/**暂停*/
- (void)pause
{
    [self.player pause];
    self.state = WXYZ_PlayPagePlayerStatePause;
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerStateChange:)]) {
        [self.delegate playerStateChange:self.state];
    }
}

/**下一首*/
- (void)next
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayerRemoteCenterSwitchToNext)]) {
        [self.delegate audioPlayerRemoteCenterSwitchToNext];
    }
}

/**上一首*/
- (void)last
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayerRemoteCenterSwitchToPrevious)]) {
        [self.delegate audioPlayerRemoteCenterSwitchToPrevious];
    }
}

#pragma mark - setter

- (void)setCategory:(AVAudioSessionCategory)category{
    [[AVAudioSession sharedInstance] setCategory:category error:nil];
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem{
    if (_playerItem == playerItem) {
        return;
    }
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [_playerItem removeObserver:self forKeyPath:WXYZStatusKey];
        [_playerItem removeObserver:self forKeyPath:WXYZLoadedTimeRangesKey];
        [_playerItem removeObserver:self forKeyPath:WXYZPlaybackBufferEmptyKey];
        [_playerItem removeObserver:self forKeyPath:WXYZPlaybackLikelyToKeepUpKey];
    }
    _playerItem = playerItem;
    if (playerItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [playerItem addObserver:self forKeyPath:WXYZStatusKey options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:WXYZLoadedTimeRangesKey options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:WXYZPlaybackBufferEmptyKey options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:WXYZPlaybackLikelyToKeepUpKey options:NSKeyValueObservingOptionNew context:nil];
    }
}

@end

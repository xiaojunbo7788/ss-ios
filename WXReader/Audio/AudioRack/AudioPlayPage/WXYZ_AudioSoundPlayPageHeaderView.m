//
//  WXYZ_AudioSoundPlayPageHeaderView.m
//  WXReader
//
//  Created by Andrew on 2020/3/17.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AudioSoundPlayPageHeaderView.h"
#import "WXYZ_BookAiPlayPageViewController.h"
#import "WXYZ_AudioSettingHelper.h"
#import "WXYZ_ProductionReadRecordManager.h"
#import "WXYZ_AudioDownloadManager.h"

#import "WXYZ_ChapterBottomPayBar.h"
#import "WXYZ_TouchAssistantView.h"
#import "CKAudioProgressView.h"
#import "WXYZ_PlayPageModel.h"

#if __has_include(<iflyMSC/IFlyMSC.h>)
#import "iflyMSC/IFlyMSC.h"
#endif
#import "WXYZ_Player.h"

@interface WXYZ_AudioSoundPlayPageHeaderView () <WXYZ_PlayerDelegate, WXYZ_PlayerDataSource, CKAudioProgressViewDelegate>

@end

@implementation WXYZ_AudioSoundPlayPageHeaderView

- (instancetype)initWithProductionType:(WXYZ_ProductionType)productionType
{
    [self initAVAudio];
    
    return [super initWithProductionType:productionType];
}

- (void)initAVAudio
{
    [[WXYZ_Player sharedPlayer] initPlayerWithUserId:nil];
    [WXYZ_Player sharedPlayer].dataSource = self;
    [WXYZ_Player sharedPlayer].delegate = self;
    [WXYZ_Player sharedPlayer].playMode = WXYZ_PlayerModeOnlyOnce;
}

- (void)createSubviews
{
    [super createSubviews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relationViewTitleChange) name:Notification_Change_AiBook_Chapter object:nil];
}

- (void)setProductionChapterModel:(WXYZ_ProductionChapterModel *)productionChapterModel
{
    [super setProductionChapterModel:productionChapterModel];
    
    WS(weakSelf)
    [[WXYZ_AudioSettingHelper sharedManager] getCurrentTimingBlock:^(NSUInteger currentTime) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.timingButton.buttonTitle = [NSString stringWithFormat:@"%02zd:%02zd", (NSInteger)(currentTime / 60), (NSInteger)(currentTime % 60)];
        });
    } finishBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[WXYZ_AudioSettingHelper sharedManager] getReadTiming] == 1) {
                weakSelf.timingButton.buttonTitle = @"听完本章节";
            } else if ([[WXYZ_AudioSettingHelper sharedManager] getReadTiming] == 0) {
                weakSelf.timingButton.buttonTitle = @"定时";
                if (weakSelf.playerState == WXYZ_PlayPagePlayerStatePlaying) {
                    [[WXYZ_Player sharedPlayer] pause];
                }
            }
        });
    }];
    
    if ([WXYZ_NetworkReachabilityManager networkingStatus] == NO) {
        
        if (![[WXYZ_AudioDownloadManager sharedManager] isChapterDownloadedWithProduction_id:productionChapterModel.production_id chapter_id:productionChapterModel.chapter_id]) {
            
            [[WXYZ_TouchAssistantView sharedManager] stopPlayerState];
            [[WXYZ_TouchAssistantView sharedManager] changePlayProgress:0];
            
            [[WXYZ_Player sharedPlayer] deallocPlayer];
            self.playerState = WXYZ_PlayPagePlayerStateStoped;
            
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"当前为离线状态，只可查看缓存内容哦"];
            return;
        }
    }
    
    // 如果是付费章节,弹出付费,停止播放
    if (self.temp_chapterModel.chapter_id == productionChapterModel.chapter_id && self.temp_chapterModel.is_preview == productionChapterModel.is_preview) {
        
        if (productionChapterModel.is_preview == 1) {
            [self showPayView];
        }
        
        return;
    }
    
    if ([WXYZ_BookAiPlayPageViewController sharedManager].speaking && ![[WXYZ_AudioSettingHelper sharedManager] isPlayPageShowingWithProductionType:WXYZ_ProductionTypeAi]) {
#if __has_include(<iflyMSC/IFlyMSC.h>)
        [[IFlySpeechSynthesizer sharedInstance] pauseSpeaking];
#endif
        [[WXYZ_Player sharedPlayer] play];
    }
    
    if ([[WXYZ_AudioSettingHelper sharedManager] isPlayPageShowingWithProductionType:WXYZ_ProductionTypeAi]) {
        [[WXYZ_AudioSettingHelper sharedManager] playPageViewShow:NO productionType:WXYZ_ProductionTypeAi];
        if ([WXYZ_BookAiPlayPageViewController sharedManager].speaking) {
            self.playerState = WXYZ_PlayPagePlayerStateStoped;
        }
        return;
    }
    
    self.temp_chapterModel = productionChapterModel;
    
    [WXYZ_Player sharedPlayer].remoteCenterPreviousEnable = !(productionChapterModel.last_chapter == 0);
    [WXYZ_Player sharedPlayer].remoteCenterNextEnable = !(productionChapterModel.next_chapter == 0);
    
    if (productionChapterModel.is_preview == 1) {
        
        [[WXYZ_TouchAssistantView sharedManager] stopPlayerState];
        [[WXYZ_TouchAssistantView sharedManager] changePlayProgress:0];
        
        [[WXYZ_Player sharedPlayer] deallocPlayer];
        self.playerState = WXYZ_PlayPagePlayerStateStoped;
        
        [self showPayView];
        
        return;
    }
    
    [[WXYZ_Player sharedPlayer] reloadData]; // 需在传入数据源后调用
    [[WXYZ_Player sharedPlayer] playWithAudioId:0];
}

- (void)relationViewTitleChange
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setRelationViewTitle:[[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAi] getReadingRecordChapterTitleWithProduction_id:self.relationModel.production_id]?:self.relationModel.chapter_title?:@""];
    });
}

#pragma mark - WXYZ_PlayerDelegate

- (NSArray<WXYZ_PlayerModel *> *)audioDataForPlayer:(WXYZ_Player *)player
{
    WXYZ_PlayerModel *playerModel = [[WXYZ_PlayerModel alloc] init];
    
    NSString *localAudioFilePath = [[WXYZ_AudioDownloadManager sharedManager] chapterDownloadedFilePathWithProduction_id:self.productionChapterModel.production_id chapter_id:self.productionChapterModel.chapter_id chapter_update_time:self.productionChapterModel.update_time];
    // 使用本地环境播放
    if ([[NSFileManager defaultManager] fileExistsAtPath:localAudioFilePath]) {
        playerModel.audioUrl = [NSURL fileURLWithPath:[[WXYZ_AudioDownloadManager sharedManager] chapterDownloadedFilePathWithProduction_id:self.productionChapterModel.production_id chapter_id:self.productionChapterModel.chapter_id chapter_update_time:self.productionChapterModel.update_time]];
    } else if ([WXYZ_NetworkReachabilityManager networkingStatus] == YES) {
        playerModel.audioUrl = [NSURL URLWithString:self.productionChapterModel.content?:@""];
    } else {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"作品未下载"];
        self.playerState = WXYZ_PlayPagePlayerStateStoped;
        return @[];
    }
    playerModel.audioId = 0;
    return @[playerModel];
}

- (WXYZ_PlayerInfoModel *)audioInfoForPlayer:(WXYZ_Player *)player
{
    WXYZ_PlayerInfoModel *infoModel = [[WXYZ_PlayerInfoModel alloc] init];
    infoModel.audioName = self.productionChapterModel.chapter_title;
    infoModel.audioAlbum = self.productionChapterModel.name;
    infoModel.audioImage = [[YYImageCache sharedCache] getImageForKey:self.productionChapterModel.cover];
    return infoModel;
}

// 远程控制切换上一首
- (void)audioPlayerRemoteCenterSwitchToPrevious
{
    [self skipToLastChapter];
}

// 远程控制切换下一首
- (void)audioPlayerRemoteCenterSwitchToNext
{
    [self skipToNextChapter];
}

// 准备播放
- (void)playerReadyToPlay:(WXYZ_Player *)player
{
    [[WXYZ_Player sharedPlayer] setRate:[[[[WXYZ_AudioSettingHelper sharedManager] getReadSpeedValuesWithProducitionType:self.productionType] objectAtIndex:[[WXYZ_AudioSettingHelper sharedManager] getReadSpeedWithProducitionType:self.productionType]] floatValue]];
    
    self.playerState = WXYZ_PlayPagePlayerStateLoading;
    
    if ([[WXYZ_AudioSettingHelper sharedManager] isPlayPageShowingWithProductionType:WXYZ_ProductionTypeBook] && [[WXYZ_AudioSettingHelper sharedManager] isPlayPageShowingWithProductionType:WXYZ_ProductionTypeAudio] && [WXYZ_BookAiPlayPageViewController sharedManager].speaking) {
        [[WXYZ_Player sharedPlayer] pause];
    } else {
        if ([WXYZ_BookAiPlayPageViewController sharedManager].speaking) {
#if __has_include(<iflyMSC/IFlyMSC.h>)
            [[IFlySpeechSynthesizer sharedInstance] pauseSpeaking];
#endif
        }
    }
    
    // 播放进度记录百分比 0 - 1
    CGFloat progress = [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] getPlayingProgressWithProduction_id:self.productionChapterModel.production_id chapter_id:self.productionChapterModel.chapter_id];
    if (progress > 0.05) {
        [[WXYZ_Player sharedPlayer] seekToTime:progress completionBlock:nil];
    }
    
}

// 播放结束
- (void)playerDidPlayToEndTime:(WXYZ_Player *)player
{
    // 听完本章结束播放
    if ([[WXYZ_AudioSettingHelper sharedManager] getReadTiming] == 1) {
        [[WXYZ_AudioSettingHelper sharedManager] setReadTimingWithIndex:0];
        self.timingButton.buttonTitle = @"定时";
        [[WXYZ_Player sharedPlayer] pause];
        
    } else {
        if (self.productionChapterModel.next_chapter > 0 && self.productionChapterModel.next_chapter) {
            [self skipToNextChapter];
        }
    }
}

//播放进度代理
- (void)player:(WXYZ_Player *)player progress:(CGFloat)progress currentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime
{
    [[WXYZ_TouchAssistantView sharedManager] changePlayProgress:progress];
    [self.timelineProgress updateProgress:progress audioLength:totalTime];
    
    // 记录阅读进度
    [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] addPlayingProgress:progress production_id:self.productionChapterModel.production_id chapter_id:self.productionChapterModel.chapter_id];
}

// 缓冲进度
- (void)player:(WXYZ_Player *)player bufferProgress:(CGFloat)bufferProgress
{
    [self.timelineProgress updateCacheProgress:bufferProgress];
}

- (void)playerStateChange:(WXYZ_PlayPagePlayerState)playerState
{
    self.playerState = playerState;
}

@end

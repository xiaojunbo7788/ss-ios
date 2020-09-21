//
//  WXYZ_BookAiPlayPageHeaderView.m
//  WXReader
//
//  Created by Andrew on 2020/3/11.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BookAiPlayPageHeaderView.h"

#import "WXYZ_AudioSoundPlayPageViewController.h"
#import "WXYZ_ReaderBookManager.h"
#import "WXYZ_ProductionReadRecordManager.h"
#import "WXYZ_AudioSettingHelper.h"
#import "WXYZ_PlayingInfoCenter.h"

#import "WXYZ_TouchAssistantView.h"
#import "WXYZ_Player.h"
#if __has_include(<iflyMSC/IFlyMSC.h>)
#import "iflyMSC/IFlyMSC.h"
#endif

@interface WXYZ_BookAiPlayPageHeaderView () <WXYZ_PlayingInfoCenterDelegate
#if __has_include(<iflyMSC/IFlyMSC.h>)
, IFlySpeechSynthesizerDelegate
#endif
>

// 分割字符,讯飞只能解析8000字符,把小说章节内容拆分为数组解析
@property (nonatomic, strong) NSMutableArray __block *segmentCharacterArray;

#if __has_include(<iflyMSC/IFlyMSC.h>)
@property (nonatomic, strong) IFlySpeechSynthesizer *iFlySpeechSynthesizer;
#endif

@end

@implementation WXYZ_BookAiPlayPageHeaderView

#if __has_include(<iflyMSC/IFlyMSC.h>)
- (void)createSubviews
{
    [super createSubviews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relationViewTitleChange) name:Notification_Change_Audio_Chapter object:nil];
    
    [WXYZ_PlayingInfoCenter sharedManager].delegate = self;
    
    WS(weakSelf)
    self.resetPlayerBlock = ^(BOOL immediateReset) {
        if (immediateReset) {
            [weakSelf initIFlySpeech];
        } else if (weakSelf.segmentCharacterArray.count == 0) {
            [weakSelf initIFlySpeech];
        }
    };
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
            } else {
                weakSelf.timingButton.buttonTitle = @"定时";
#if __has_include(<iflyMSC/IFlyMSC.h>)
                if (weakSelf.playerState == WXYZ_PlayPagePlayerStatePlaying) {
                    [[IFlySpeechSynthesizer sharedInstance] pauseSpeaking];                    
                }
#endif
            }
        });
    }];
    
    if (productionChapterModel.chapter_id == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"章节正在更新中"];
        });
        self.playerState = WXYZ_PlayPagePlayerStateStoped;
        return;
    }
    
    if (self.temp_chapterModel.chapter_id == productionChapterModel.chapter_id && self.temp_chapterModel.is_preview == productionChapterModel.is_preview && ![WXYZ_UserInfoManager shareInstance].auto_sub) {
        if ([WXYZ_Player sharedPlayer].state == WXYZ_PlayPagePlayerStatePlaying && ![[WXYZ_AudioSettingHelper sharedManager] isPlayPageShowingWithProductionType:WXYZ_ProductionTypeAudio]) {
            [[IFlySpeechSynthesizer sharedInstance] resumeSpeaking];
            [[WXYZ_Player sharedPlayer] pause];
        }
        return;
    }
    
    if ([[WXYZ_AudioSettingHelper sharedManager] isPlayPageShowingWithProductionType:WXYZ_ProductionTypeAudio]) {
        [[WXYZ_AudioSettingHelper sharedManager] playPageViewShow:NO productionType:WXYZ_ProductionTypeAudio];
        if ([WXYZ_AudioSoundPlayPageViewController sharedManager].speaking) {
            self.playerState = WXYZ_PlayPagePlayerStateStoped;
        }
        return;
    }
    
    self.temp_chapterModel = [productionChapterModel modelCopy];
    
    if (productionChapterModel.is_preview && ![WXYZ_UserInfoManager shareInstance].auto_sub) {
        self.playerState = WXYZ_PlayPagePlayerStateStoped;
        [self.iFlySpeechSynthesizer stopSpeaking];
        [self showPayView];
        return;
    }
    
    [self initIFlySpeech];
    
}

- (void)initIFlySpeech
{
    //设置在线工作方式
    [self.iFlySpeechSynthesizer setParameter:[IFlySpeechConstant TYPE_CLOUD]
     forKey:[IFlySpeechConstant ENGINE_TYPE]];
    
    [self.iFlySpeechSynthesizer setParameter:@"wxyz.pcm"
    forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
    
    // 语速
    WXYZ_AudioSettingHelper *audioTool = [WXYZ_AudioSettingHelper sharedManager];
    [self.iFlySpeechSynthesizer setParameter:[WXYZ_UtilsHelper formatStringWithInteger:[[[audioTool getReadSpeedValuesWithProducitionType:self.productionType] objectAtIndex:[audioTool getReadSpeedWithProducitionType:self.productionType]] floatValue] * 50] forKey:[IFlySpeechConstant SPEED]];
    //设置音量，取值范围 0~100
    
    [self.iFlySpeechSynthesizer setParameter:@"1" forKey:[IFlySpeechConstant MPPLAYINGINFOCENTER]];
    
    // 音量
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [self.iFlySpeechSynthesizer setParameter:[WXYZ_UtilsHelper formatStringWithInteger:audioSession.outputVolume * 100] forKey: [IFlySpeechConstant VOLUME]];
    
    // 发音人
    [self.iFlySpeechSynthesizer setParameter:[[audioTool getReadVoiceValuesWithProducitionType:self.productionType] objectAtIndex:[audioTool getReadVoiceWithProducitionType:self.productionType]] forKey: [IFlySpeechConstant VOICE_NAME]];
    
    WS(weakSelf)
    [[WXYZ_ReaderBookManager sharedManager] getChapterTextWithBook_id:self.productionChapterModel.production_id chapter_index:[self.productionChapterModel.display_order integerValue] completionHandler:^(NSString *content) {
        
        [weakSelf.segmentCharacterArray removeAllObjects];
        
        content = [content stringByReplacingOccurrencesOfString:@"W$$X" withString:@""];
        content = [content stringByReplacingOccurrencesOfString:k_Chapter_RequstFail withString:@""];
        
        // 分割长度
        NSInteger segmentLength = 3500;
        
        // 分割数量
        NSInteger segmentCount = content.length / segmentLength + (content.length % segmentLength > 0?1:0);
        
        // 整数量分割
        if (segmentCount == 1) {
            [weakSelf.segmentCharacterArray addObject:content];
        } else {
            for (int i = 0; i < segmentCount; i ++) {
                if (segmentCount - 1 == i) {
                    [weakSelf.segmentCharacterArray addObject:[content substringWithRange:NSMakeRange(i * segmentLength, content.length % segmentLength)]];
                } else {
                    [weakSelf.segmentCharacterArray addObject:[content substringWithRange:NSMakeRange(i * segmentLength, segmentLength)]];
                }
            }
        }
        
        if (weakSelf.segmentCharacterArray.count > 0) {
            [weakSelf.iFlySpeechSynthesizer startSpeaking:[weakSelf.segmentCharacterArray firstObject]];
        }
        
        [[WXYZ_PlayingInfoCenter sharedManager] showPlayingInfoCenterWithProductionChapterModel:weakSelf.productionChapterModel];
    }];
}

#pragma mark - WXYZ_PlayingInfoCenterDelegate

- (void)playRemoteCommand
{
    if ([WXYZ_TouchAssistantView sharedManager].productionType == WXYZ_ProductionTypeBook) {
        if (self.playerState == WXYZ_PlayPagePlayerStatePause) {
            [self.iFlySpeechSynthesizer resumeSpeaking];
        }
    }
}

- (void)pauseRemoteCommand
{
    if ([WXYZ_TouchAssistantView sharedManager].productionType == WXYZ_ProductionTypeBook) {
        if (self.playerState == WXYZ_PlayPagePlayerStatePlaying) {
            [self.iFlySpeechSynthesizer pauseSpeaking];
        }
    }
}

- (void)lastRemoteCommand
{
    if ([WXYZ_TouchAssistantView sharedManager].productionType == WXYZ_ProductionTypeBook) {
        [self skipToLastChapter];
    }
}

- (void)nextRemoteCommand
{
    if ([WXYZ_TouchAssistantView sharedManager].productionType == WXYZ_ProductionTypeBook) {
        [self skipToNextChapter];
    }
}

#pragma mark - IFlySpeechDelegate

- (void)onCompleted:(IFlySpeechError *)error
{
    if (error) {
        if ([WXYZ_NetworkReachabilityManager networkingStatus] == NO) {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"当前为离线状态，只可查看缓存内容哦"];
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"播放出错"];
        }
        self.playerState = WXYZ_PlayPagePlayerStateStoped;
    }
}

// 合成开始
- (void)onSpeakBegin
{
    self.playerState = WXYZ_PlayPagePlayerStatePlaying;
    
    if ([[WXYZ_AudioSettingHelper sharedManager] isPlayPageShowingWithProductionType:WXYZ_ProductionTypeAudio] && [[WXYZ_AudioSettingHelper sharedManager] isPlayPageShowingWithProductionType:WXYZ_ProductionTypeBook] && [WXYZ_Player sharedPlayer].state == WXYZ_PlayPagePlayerStatePlaying) {
        [self.iFlySpeechSynthesizer pauseSpeaking];
    } else {
        if ([WXYZ_Player sharedPlayer].state == WXYZ_PlayPagePlayerStatePlaying) {
            [[WXYZ_Player sharedPlayer] pause];
        }
    }
    
    [[WXYZ_PlayingInfoCenter sharedManager] showPlayingInfoCenterWithProductionChapterModel:self.productionChapterModel];
}

// 合成播放进度
- (void)onSpeakProgress:(int)progress beginPos:(int)beginPos endPos:(int)endPos
{
    if (progress == 100) { // 片段播放结束
        [self.segmentCharacterArray removeFirstObject];
        if (self.segmentCharacterArray.count == 0) {
            if ([[WXYZ_AudioSettingHelper sharedManager] getReadTiming] == 1) {
                [[WXYZ_AudioSettingHelper sharedManager] setReadTimingWithIndex:0];
                self.timingButton.buttonTitle = @"定时";
                [self.iFlySpeechSynthesizer pauseSpeaking];
                self.playerState = WXYZ_PlayPagePlayerStatePause;
            } else {
                if (self.productionChapterModel.next_chapter > 0 && self.productionChapterModel.next_chapter) {
                    [self skipToNextChapter];
                }
            }
        } else {
            [self.iFlySpeechSynthesizer startSpeaking:[self.segmentCharacterArray firstObject]];
        }
    }
}

// 暂停播放回调
- (void)onSpeakPaused
{
    self.playerState = WXYZ_PlayPagePlayerStatePause;
    [[WXYZ_PlayingInfoCenter sharedManager] hiddenPlayingInfoCenter];
}

// 恢复播放回调
- (void)onSpeakResumed
{
    self.playerState = WXYZ_PlayPagePlayerStatePlaying;
    [[WXYZ_PlayingInfoCenter sharedManager] showPlayingInfoCenterWithProductionChapterModel:self.productionChapterModel];
}

// 取消播放
- (void)onSpeakCancel
{
    self.playerState = WXYZ_PlayPagePlayerStateStoped;
    [[WXYZ_PlayingInfoCenter sharedManager] hiddenPlayingInfoCenter];
}

- (void)relationViewTitleChange
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setRelationViewTitle:[[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] getReadingRecordChapterTitleWithProduction_id:self.relationModel.production_id]?:self.relationModel.chapter_title?:@""];
    });
}

#pragma mark - lazy

- (IFlySpeechSynthesizer *)iFlySpeechSynthesizer
{
    if (!_iFlySpeechSynthesizer) {
        _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
        
        //设置协议委托对象
        _iFlySpeechSynthesizer.delegate = self;
        
    }
    return _iFlySpeechSynthesizer;
}

- (NSMutableArray *)segmentCharacterArray
{
    if (!_segmentCharacterArray) {
        _segmentCharacterArray = [NSMutableArray array];
    }
    return _segmentCharacterArray;
}
#endif

@end

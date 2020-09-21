//
//  WXYZ_AudioSettingHelper.m
//  WXReader
//
//  Created by Andrew on 2020/3/18.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AudioSettingHelper.h"
#import "WXYZ_Player.h"
#import "WXYZ_GCDTimer.h"
#import <MediaPlayer/MediaPlayer.h>

@interface WXYZ_AudioSettingHelper ()

@property (nonatomic, strong) WXYZ_GCDTimer *countdownTimer;
 
@property (nonatomic, assign) NSInteger read_timing;  // 听书倒计时(有声和ai的计时同步)

@end

@implementation WXYZ_AudioSettingHelper

implementation_singleton(WXYZ_AudioSettingHelper)

// 倒计时
- (NSInteger)getReadTiming
{
    return self.read_timing;
}

- (void)setReadTimingWithIndex:(NSInteger)readTimingIndex
{
    _read_timing = readTimingIndex;
}

- (NSArray *)getReadTimingKeys
{
    return @[@"不开启", @"听完本章节", @"15分钟", @"30分钟", @"60分钟", @"90分钟"];
}

- (NSArray *)getReadTimingValues
{
    return @[@"0", @"1", @"900", @"1800", @"3600", @"5400"];
}

// 声音
- (NSString *)getReadVoiceTitleWithProducitionType:(WXYZ_ProductionType)productionType
{
    return [[self getReadVoiceKeysWithProducitionType:productionType] objectAtIndex:[self getReadVoiceWithProducitionType:productionType]];
}

- (NSInteger)getReadVoiceWithProducitionType:(WXYZ_ProductionType)productionType
{
    if (productionType == WXYZ_ProductionTypeAudio) {
        return 0;
    } else {
        NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:@"wx_ai_read_voice"];
        return string?[string integerValue]:0;
    }
}

- (void)setReadVoiceWithIndex:(NSInteger)readVoiceIndex producitionType:(WXYZ_ProductionType)productionType
{
    if (productionType == WXYZ_ProductionTypeAudio) {
        
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:[WXYZ_UtilsHelper formatStringWithInteger:readVoiceIndex] forKey:@"wx_ai_read_voice"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSArray *)getReadVoiceKeysWithProducitionType:(WXYZ_ProductionType)productionType
{
    if (productionType == WXYZ_ProductionTypeAudio) {
        return @[];
    } else {
        return @[@"情感女声", @"标准女声", @"标准男声"];
    }
}

- (NSArray *)getReadVoiceValuesWithProducitionType:(WXYZ_ProductionType)productionType
{
    if (productionType == WXYZ_ProductionTypeAudio) {
        return @[];
    } else {
        return @[@"xiaoyan", @"vixq", @"vixf"];
    }
}

// 语速
- (NSInteger)getReadSpeedWithProducitionType:(WXYZ_ProductionType)productionType
{
    if (productionType == WXYZ_ProductionTypeAudio) {
        NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:@"wx_audio_read_speed"];
        return string?[string integerValue]:2;
    } else {
        NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:@"wx_ai_read_speed"];
        return string?[string integerValue]:2;
    }
}

- (void)setReadSpeedWithIndex:(NSInteger)readSpeedIndex producitionType:(WXYZ_ProductionType)productionType
{
    if (productionType == WXYZ_ProductionTypeAudio) {
        [[NSUserDefaults standardUserDefaults] setObject:[WXYZ_UtilsHelper formatStringWithInteger:readSpeedIndex] forKey:@"wx_audio_read_speed"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:[WXYZ_UtilsHelper formatStringWithInteger:readSpeedIndex] forKey:@"wx_ai_read_speed"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSArray *)getReadSpeedKeysWithProducitionType:(WXYZ_ProductionType)productionType
{
    if (productionType == WXYZ_ProductionTypeAudio) {
        return @[@"0.5倍", @"0.75倍", @"1倍", @"1.25倍", @"1.5倍"];
    } else {
        return @[@"0.5倍", @"0.75倍", @"1倍", @"1.25倍", @"1.5倍"];
    }
}

- (NSArray *)getReadSpeedValuesWithProducitionType:(WXYZ_ProductionType)productionType
{
    if (productionType == WXYZ_ProductionTypeAudio) {
        return @[@"0.5", @"0.80", @"1.0", @"1.25", @"1.5"];
    } else {
        return @[@"0.5", @"0.80", @"1.0", @"1.25", @"1.5"];
    }
}

- (void)startTimingFinishBlock:(void(^)(void))finishBlock
{
    CGFloat duration = [[[self getReadTimingValues] objectAtIndex:self.read_timing] floatValue];

    if (self.read_timing == 0 || self.read_timing == 1) {
        [self.countdownTimer stopTimer];
        if (finishBlock) {
            finishBlock();
        }
        return;
    }
    
    [self.countdownTimer stopTimer];
    [self.countdownTimer startTimerWithTimeDuration:duration];
}

- (void)getCurrentTimingBlock:(void(^)(NSUInteger currentTime))currentTimeBlock finishBlock:(void(^)(void))finishBlock
{
//    if ((self.read_timing == 0 || self.read_timing == 1) && ) {
//        if (finishBlock) {
//            finishBlock();
//        }
//    }
    
    self.countdownTimer.timerRunningBlock = ^(NSUInteger runTimes, CGFloat currentTime) {
        if (currentTimeBlock) {
            currentTimeBlock([[NSNumber numberWithFloat:currentTime] integerValue]);
        }
    };
    
    WS(weakSelf)
    self.countdownTimer.timerFinishedBlock = ^{
        weakSelf.read_timing = 0;

        if (finishBlock) {
            finishBlock();
        }
    };
}

- (WXYZ_GCDTimer *)countdownTimer
{
    if (!_countdownTimer) {
        _countdownTimer = [[WXYZ_GCDTimer alloc] initCountdownTimerWithTimeDuration:10 immediatelyCallBack:YES];
    }
    return _countdownTimer;
}

static BOOL aiPlayPageShow = NO;
static BOOL audioPlayPageShow = NO;
- (void)playPageViewShow:(BOOL)show productionType:(WXYZ_ProductionType)productionType
{
    if (productionType == WXYZ_ProductionTypeAi) {
        aiPlayPageShow = show;
    }
    
    if (productionType == WXYZ_ProductionTypeAudio) {
        audioPlayPageShow = show;
    }
}

- (BOOL)isPlayPageShowingWithProductionType:(WXYZ_ProductionType)productionType
{
    if (productionType == WXYZ_ProductionTypeAi) {
        return aiPlayPageShow;
    }
    
    if (productionType == WXYZ_ProductionTypeAudio) {
        return audioPlayPageShow;
    }
    
    return NO;
}

@end

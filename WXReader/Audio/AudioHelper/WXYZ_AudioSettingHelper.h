//
//  WXYZ_AudioSettingHelper.h
//  WXReader
//
//  Created by Andrew on 2020/3/18.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_AudioSettingHelper : NSObject

interface_singleton

// 倒计时
- (NSInteger)getReadTiming;

- (void)setReadTimingWithIndex:(NSInteger)readTimingIndex;

- (NSArray *)getReadTimingKeys;

- (NSArray *)getReadTimingValues;

// 开始倒计时
- (void)startTimingFinishBlock:(void(^)(void))finishBlock;

- (void)getCurrentTimingBlock:(void(^)(NSUInteger currentTime))currentTimeBlock finishBlock:(void(^)(void))finishBlock;

// 声音
- (NSString *)getReadVoiceTitleWithProducitionType:(WXYZ_ProductionType)productionType;

- (NSInteger)getReadVoiceWithProducitionType:(WXYZ_ProductionType)productionType;

- (void)setReadVoiceWithIndex:(NSInteger)readVoiceIndex producitionType:(WXYZ_ProductionType)productionType;

- (NSArray *)getReadVoiceKeysWithProducitionType:(WXYZ_ProductionType)productionType;

- (NSArray *)getReadVoiceValuesWithProducitionType:(WXYZ_ProductionType)productionType;

// 语速
- (NSInteger)getReadSpeedWithProducitionType:(WXYZ_ProductionType)productionType;

- (void)setReadSpeedWithIndex:(NSInteger)readSpeedIndex producitionType:(WXYZ_ProductionType)productionType;

- (NSArray *)getReadSpeedKeysWithProducitionType:(WXYZ_ProductionType)productionType;

- (NSArray *)getReadSpeedValuesWithProducitionType:(WXYZ_ProductionType)productionType;


- (void)playPageViewShow:(BOOL)show productionType:(WXYZ_ProductionType)productionType;

- (BOOL)isPlayPageShowingWithProductionType:(WXYZ_ProductionType)productionType;

@end

NS_ASSUME_NONNULL_END

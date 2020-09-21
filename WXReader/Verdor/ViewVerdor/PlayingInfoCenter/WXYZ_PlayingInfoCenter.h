//
//  WXYZ_PlayingInfoCenter.h
//  WXReader
//
//  Created by Andrew on 2020/4/18.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WXYZ_PlayingInfoCenterDelegate <NSObject>

@optional

// 播放
- (void)playRemoteCommand;

// 暂停
- (void)pauseRemoteCommand;

// 上一首
- (void)lastRemoteCommand;

// 下一首
- (void)nextRemoteCommand;

@end

@interface WXYZ_PlayingInfoCenter : NSObject

@property (nullable, nonatomic, weak) id <WXYZ_PlayingInfoCenterDelegate> delegate;

interface_singleton

- (void)showPlayingInfoCenterWithProductionChapterModel:(WXYZ_ProductionChapterModel *)productionChapterModel;

- (void)hiddenPlayingInfoCenter;

@end

NS_ASSUME_NONNULL_END

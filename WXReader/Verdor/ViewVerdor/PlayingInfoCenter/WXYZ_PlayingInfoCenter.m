//
//  WXYZ_PlayingInfoCenter.m
//  WXReader
//
//  Created by Andrew on 2020/4/18.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_PlayingInfoCenter.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface WXYZ_PlayingInfoCenter ()

@property (nonatomic, strong) MPRemoteCommand *playCommand;

@property (nonatomic, strong) MPRemoteCommand *pauseCommand;

@property (nonatomic, strong) MPRemoteCommand *lastCommand;

@property (nonatomic, strong) MPRemoteCommand *nextCommand;

@end

@implementation WXYZ_PlayingInfoCenter

implementation_singleton(WXYZ_PlayingInfoCenter)

- (void)showPlayingInfoCenterWithProductionChapterModel:(WXYZ_ProductionChapterModel *)productionChapterModel
{
    if (!productionChapterModel) {
        kCodeSync([[UIApplication sharedApplication] endReceivingRemoteControlEvents]);
        return;
    }
    
    kCodeSync([[UIApplication sharedApplication] endReceivingRemoteControlEvents]);
    kCodeSync([[UIApplication sharedApplication] beginReceivingRemoteControlEvents]);
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [self.playCommand setEnabled:YES];
    
    [self.pauseCommand setEnabled:YES];
    
    if (productionChapterModel.last_chapter > 0 && productionChapterModel.last_chapter) {
        [self.lastCommand setEnabled:YES];
    } else {
        [self.lastCommand setEnabled:NO];
    }
    
    if (productionChapterModel.next_chapter > 0 && productionChapterModel.next_chapter) {
        [self.nextCommand setEnabled:YES];
    } else {
        [self.nextCommand setEnabled:NO];
    }
    
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:CGSizeMake(BOOK_WIDTH, BOOK_HEIGHT) requestHandler:^UIImage * _Nonnull(CGSize size) {
        return [[YYImageCache sharedCache] getImageForKey:productionChapterModel.cover];
    }];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:productionChapterModel.chapter_title?:@"" forKey:MPMediaItemPropertyTitle];
    [info setObject:productionChapterModel.name?:@"" forKey:MPMediaItemPropertyArtist];
    [info setObject:artwork forKey:MPMediaItemPropertyArtwork];
    //完成设置
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:info];
}

- (void)hiddenPlayingInfoCenter
{
//    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

- (MPRemoteCommand *)playCommand
{
    if (!_playCommand) {
        WS(weakSelf)
        MPRemoteCommand *playCommand = [[MPRemoteCommandCenter sharedCommandCenter] playCommand];
        [playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
            if ([weakSelf.delegate respondsToSelector:@selector(playRemoteCommand)]) {
                [weakSelf.delegate playRemoteCommand];
            }
            return MPRemoteCommandHandlerStatusSuccess;
        }];
        _playCommand = playCommand;
    }
    return _playCommand;
}

- (MPRemoteCommand *)pauseCommand
{
    if (!_pauseCommand) {
        WS(weakSelf)
        MPRemoteCommand *pauseCommand = [[MPRemoteCommandCenter sharedCommandCenter] pauseCommand];
        [pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
            if ([weakSelf.delegate respondsToSelector:@selector(pauseRemoteCommand)]) {
                [weakSelf.delegate pauseRemoteCommand];
            }
            return MPRemoteCommandHandlerStatusSuccess;
        }];
        _pauseCommand = pauseCommand;
    }
    return _pauseCommand;
}

- (MPRemoteCommand *)lastCommand
{
    if (!_lastCommand) {
        WS(weakSelf)
        MPRemoteCommand *lastCommand = [[MPRemoteCommandCenter sharedCommandCenter] previousTrackCommand];
        [lastCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
            if ([weakSelf.delegate respondsToSelector:@selector(lastRemoteCommand)]) {
                [weakSelf.delegate lastRemoteCommand];
            }
            return MPRemoteCommandHandlerStatusSuccess;
        }];
        _lastCommand = lastCommand;
    }
    return _lastCommand;
}

- (MPRemoteCommand *)nextCommand
{
    if (!_nextCommand) {
        WS(weakSelf)
        MPRemoteCommand *nextCommand = [[MPRemoteCommandCenter sharedCommandCenter] nextTrackCommand];
        [nextCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
            if ([weakSelf.delegate respondsToSelector:@selector(nextRemoteCommand)]) {
                [weakSelf.delegate nextRemoteCommand];
            }
            return MPRemoteCommandHandlerStatusSuccess;
        }];
        _nextCommand = nextCommand;
    }
    return _nextCommand;
}

@end

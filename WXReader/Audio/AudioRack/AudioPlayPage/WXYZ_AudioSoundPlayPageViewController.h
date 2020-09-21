//
//  WXYZ_AudioSoundPlayPageViewController.h
//  WXReader
//
//  Created by Andrew on 2020/3/9.
//  Copyright © 2020 Andrew. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

@class WXYZ_ProductionChapterModel;

@interface WXYZ_AudioSoundPlayPageViewController : WXYZ_BasicViewController

@property (nonatomic, strong) NSArray <WXYZ_ProductionChapterModel *> *chapter_list;

@property (nonatomic, assign, readonly) BOOL speaking;

@property (nonatomic, assign, readonly) BOOL stoped; // 暂停不可播放状态

@property (nonatomic, assign, readonly) NSInteger chapter_id;

interface_singleton

- (void)loadDataWithAudio_id:(NSInteger)audio_id chapter_id:(NSInteger)chapter_id;

@end

NS_ASSUME_NONNULL_END

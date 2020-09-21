//
//  WXYZ_AudioDownloadManager.h
//  WXReader
//
//  Created by Andrew on 2020/3/28.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_DownloadHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_AudioDownloadManager : NSObject <WXYZ_DownloadManagerProtocol>

@property (nonatomic, copy) void (^downloadDeleteFinishBlock)(NSArray *success_chapter_ids, NSArray *fail_chapter);

// 章节下载状态改变
@property (nonatomic, copy) void (^downloadChapterStateChangeBlock)(WXYZ_DownloadChapterState state, NSInteger production_id, NSInteger chapter_id);

// 总体任务下载完成
@property (nonatomic, copy) void (^downloadMissionStateChangeBlock)(WXYZ_DownloadMissionState state, NSInteger production_id, NSArray *chapter_ids);

interface_singleton

// 获取已下载音频文件路径
- (NSString *)chapterDownloadedFilePathWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id chapter_update_time:(NSString *)chapter_update_time;

@end

NS_ASSUME_NONNULL_END

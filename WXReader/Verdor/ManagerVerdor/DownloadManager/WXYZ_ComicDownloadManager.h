//
//  WXYZ_ComicDownloadManager.h
//  WXReader
//
//  Created by Andrew on 2020/3/29.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_DownloadHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ComicDownloadManager : NSObject <WXYZ_DownloadManagerProtocol>

@property (nonatomic, copy) void (^downloadDeleteFinishBlock)(NSArray *success_chapter_ids, NSArray *fail_chapter);

// 章节下载状态改变
@property (nonatomic, copy) void (^downloadChapterStateChangeBlock)(WXYZ_DownloadChapterState state, NSInteger production_id, NSInteger chapter_id);

// 总体任务下载完成
@property (nonatomic, copy) void (^downloadMissionStateChangeBlock)(WXYZ_DownloadMissionState state, NSInteger production_id, NSArray *chapter_ids);

interface_singleton

- (NSArray *)getDownloadChapterModelArrayWithProduction_id:(NSInteger)production_id;

// 获取本地图片
- (UIImage *)getDownloadLocalImageWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id image_id:(NSInteger)image_id image_update_time:(NSInteger)image_update_time;

@end

NS_ASSUME_NONNULL_END

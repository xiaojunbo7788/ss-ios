//
//  WXYZ_BBBBBBBManager.h
//  WXReader
//
//  Created by Andrew on 2020/7/10.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXYZ_DownloadHelper.h"
#import "WXYZ_BookDownloadTaskListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_BookDownloadManager : NSObject <WXYZ_DownloadManagerEnumProtocol>

@property (nonatomic, copy) void (^downloadDeleteFinishBlock)(NSArray *success_chapter_ids, NSArray *fail_chapter);

// 总体任务下载回调
@property (nonatomic, copy) void (^downloadMissionStateChangeBlock)(WXYZ_DownloadMissionState state, NSInteger production_id, WXYZ_DownloadTaskModel *downloadTaskModel, NSArray<NSNumber *> * _Nullable chapterIDArray);

interface_singleton

/*
 增
 **/

// 下载章节(不支持自动订阅 && 支持多章下载)
- (void)downloadChaptersWithProductionModel:(WXYZ_ProductionModel *)productionModel downloadTaskModel:(WXYZ_DownloadTaskModel *)downloadTaskModel production_id:(NSInteger)production_id start_chapter_id:(NSInteger)start_chapter_id downloadNum:(NSInteger)downloadNum;

/*
 删
 **/

// 删除本地已下载作品
- (BOOL)removeDownloadProductionWithProduction_id:(NSInteger)production_id;

/*
 查
 **/
// 获取已下载文件路径
- (NSString *)getChapterFilePathWithChapterModel:(WXYZ_ProductionChapterModel *)chapterModel;

// 获取章节内容
- (NSString *)getFileContentsWithChapterModel:(WXYZ_ProductionChapterModel * __nullable)chapterModel;

// 存储章节内容
- (void)storingFilesWithChapterModel:(WXYZ_ProductionChapterModel * __nullable)chapterModel storingCompletionHandler:(void (^)(BOOL finishStoring))completionHandler;

// 获取下载状态
- (WXYZ_ProductionDownloadState)getDownloadMissionStateWithProduction_id:(NSInteger)production_id downloadTaskModel:(WXYZ_DownloadTaskModel *)downloadTaskModel;

// 获取某一已下载作品model
- (WXYZ_BookDownloadTaskListModel *)getDownloadProductionModelWithProduction_id:(NSInteger)production_id;

@end

NS_ASSUME_NONNULL_END

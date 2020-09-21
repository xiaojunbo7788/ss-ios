//
//  WXYZ_BBBBBBBManager.m
//  WXReader
//
//  Created by Andrew on 2020/7/10.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BookDownloadManager.h"
#import "WXYZ_ProductionChapterModel.h"

// 下载总任务列表model
#define TaskListKey @"task_list_key"

@interface WXYZ_BookDownloadManager ()

@property (nonatomic, assign) BOOL requesting;

@property (nonatomic, strong) NSMutableArray *requestOrderArray;

@end

@implementation WXYZ_BookDownloadManager

implementation_singleton(WXYZ_BookDownloadManager)

/*
 增
 **/

// 下载多个章节
- (void)downloadChaptersWithProductionModel:(WXYZ_ProductionModel *)productionModel downloadTaskModel:(WXYZ_DownloadTaskModel *)downloadTaskModel production_id:(NSInteger)production_id start_chapter_id:(NSInteger)start_chapter_id downloadNum:(NSInteger)downloadNum
{
    
    // 作品开始下载标记
    [[WXYZ_DownloadHelper sharedManager] recordDownloadProductionWithProductionModel:productionModel productionType:WXYZ_ProductionTypeBook];
    
    // 任务加入任务队列
    /*
     @{
        production_id:@[起始章节id, 下载章节数量, 下载任务对象]
     }
     */
    [self.requestOrderArray addObject:@{[WXYZ_UtilsHelper formatStringWithInteger:production_id]:@[[WXYZ_UtilsHelper formatStringWithInteger:start_chapter_id], [WXYZ_UtilsHelper formatStringWithInteger:downloadNum], downloadTaskModel]}];
    
    if (!self.requesting) {
        // 开始下载任务
        [self downloadTaskRequest];
    }
}

/*
 删
 **/

// 删除本地整本已下载作品
- (BOOL)removeDownloadProductionWithProduction_id:(NSInteger)production_id
{
    // 删除作品文件夹
    [[WXYZ_DownloadHelper sharedManager] removeDownloadProductionFolderWithProduction_id:production_id productionType:WXYZ_ProductionTypeBook];
    
    [[self bookDownloadTaskDictionaryWithProduction_id:production_id] removeAllObjects];
    
    return YES;
}

/*
 查
 **/

// 获取已下载小说文件路径
- (NSString *)getChapterFilePathWithChapterModel:(WXYZ_ProductionChapterModel *)chapterModel
{
    // 章节图片名称
    NSString *fileName = [WXYZ_UtilsHelper stringToMD5:[NSString stringWithFormat:@"%@%@%@%@", [WXYZ_UtilsHelper formatStringWithInteger:chapterModel.production_id], [WXYZ_UtilsHelper formatStringWithInteger:chapterModel.chapter_id], [WXYZ_UtilsHelper formatStringWithInteger:chapterModel.is_preview], chapterModel.update_time]];
    
    NSString *filePath = [[[WXYZ_DownloadHelper sharedManager] getDownloadChapterFolderPathWithProduction_id:chapterModel.production_id chapter_id:chapterModel.chapter_id productionType:WXYZ_ProductionTypeBook] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", fileName]];
    
    return filePath;
}

// 获取章节内容
- (NSString *)getFileContentsWithChapterModel:(WXYZ_ProductionChapterModel *)chapterModel
{
    // 数据不正确
    if (!chapterModel || chapterModel.production_id == 0 || chapterModel.chapter_id == 0 || !chapterModel.update_time) {
        return k_Chapter_RequstFail;
    }
    
    // 本地文件地址
    NSString *filePath = [self getChapterFilePathWithChapterModel:chapterModel];
    
    // 如果文件存在则返回文件内容
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        NSString *body = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:filePath] usedEncoding:nil error:nil];
        if (body) {
            return body;
        }
        //如果之前不能解码，现在使用GBK解码
        body = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:filePath] encoding:0x80000632 error:nil];
        if (body) {
            return body;
        }
        //再使用GB18030解码
        body = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:filePath] encoding:0x80000631 error:nil];
        if (body) {
            return body;
        } else {
            return k_Chapter_RequstFail;
        }
    } else {
        return k_Chapter_RequstFail;
    }
}

// 存储章节内容
- (void)storingFilesWithChapterModel:(WXYZ_ProductionChapterModel *)chapterModel storingCompletionHandler:(void (^)(BOOL finishStoring))completionHandler
{
    // 数据不正确
    if (!chapterModel || chapterModel.production_id == 0 || chapterModel.chapter_id == 0 || !chapterModel.update_time) {
        if (completionHandler) {
            completionHandler(NO);
        }
        return;
    }
    
    // 文件已存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self getChapterFilePathWithChapterModel:chapterModel]]) {
        
        // 如果当前获取的是非预览章节内容,则寻找是否有预览章节文件进行删除,节省空间
        chapterModel.is_preview = 1;
        if ([self getChapterFilePathWithChapterModel:chapterModel]) {
            [[NSFileManager defaultManager] removeItemAtPath:[self getChapterFilePathWithChapterModel:chapterModel] error:nil];
        }
        
        if (completionHandler) {
            completionHandler(NO);
        }
        
        return;
    }
    
    // 文件不存在则存储文件
    
    // 解析标题
    NSString *chapter_title_string = @"";
    if (chapterModel.chapter_title && chapterModel.chapter_title.length > 0) {
        chapter_title_string = [NSString stringWithFormat:@"W$$X%@W$$X", chapterModel.chapter_title];
        chapter_title_string = [chapter_title_string stringByAppendingString:@"\n\n"];
    }
    
    // 解析内容
    NSString *chapter_content_string = @"";
    if (chapterModel.content && chapterModel.content.length > 0) {
        chapter_content_string = chapterModel.content;
    }
    
    // 文件内容
    NSString *chapter_file_content = [NSString stringWithFormat:@"%@%@",chapter_title_string, chapter_content_string];
    
    if ([chapter_file_content writeToFile:[self getChapterFilePathWithChapterModel:chapterModel] atomically:NO encoding:NSUTF8StringEncoding error:nil]) {
        if (completionHandler) {
            completionHandler(YES);
        }
    } else {
        if (completionHandler) {
            completionHandler(NO);
        }
    }
    
}

// 获取下载状态
- (WXYZ_ProductionDownloadState)getDownloadMissionStateWithProduction_id:(NSInteger)production_id downloadTaskModel:(WXYZ_DownloadTaskModel *)downloadTaskModel
{
    NSMutableDictionary *t_dic = [self bookDownloadTaskDictionaryWithProduction_id:production_id];
    if ([[t_dic objectForKey:downloadTaskModel.file_name] isEqual:identify_downloading]) {
        return WXYZ_ProductionDownloadStateDownloading;
    }

    if ([[t_dic objectForKey:downloadTaskModel.file_name] isKindOfClass:[WXYZ_DownloadTaskModel class]]) {
        return WXYZ_ProductionDownloadStateDownloaded;
    }
    
    WXYZ_BookDownloadTaskListModel *taskListModel = [self getDownloadProductionModelWithProduction_id:production_id];
    if (taskListModel.task_list.count > 0) {
        for (WXYZ_DownloadTaskModel *t_taskModel in taskListModel.task_list) {
            if (downloadTaskModel.start_order >= t_taskModel.start_order && downloadTaskModel.end_order <= t_taskModel.end_order) {
                return WXYZ_ProductionDownloadStateDownloaded;
            }
        }
    }
    
    return WXYZ_ProductionDownloadStateNormal;
}

// 获取某一已下载作品model
- (WXYZ_BookDownloadTaskListModel *)getDownloadProductionModelWithProduction_id:(NSInteger)production_id
{
    WXYZ_BookDownloadTaskListModel *taskListModel = [[WXYZ_BookDownloadTaskListModel alloc] init];
    taskListModel.productionModel = [[WXYZ_DownloadHelper sharedManager] getDownloadProductionModelWithProduction_id:production_id productionType:WXYZ_ProductionTypeBook];
    taskListModel.task_list = [[self getDownloadProductionArrayWithProduction_id:production_id] mutableCopy];
    return taskListModel;
}

// 获取某一作品的全部下载model
- (NSArray <WXYZ_DownloadTaskModel *> *)getDownloadProductionArrayWithProduction_id:(NSInteger)production_id
{
    NSMutableArray *t_arr = [NSMutableArray array];
    for (id taskModel in [self bookDownloadTaskDictionaryWithProduction_id:production_id].allValues) {
        if ([taskModel isKindOfClass:[WXYZ_DownloadTaskModel class]]) {
            [t_arr addObject:taskModel];
        }
    }
    
    for (int i = 0; i < t_arr.count; i ++) {
        WXYZ_DownloadTaskModel *taskModel = [t_arr objectAtIndex:i];
        // 是否需要合并
        BOOL isMerged = NO;
        
        // 无交集
        BOOL noIntersection = YES;
        
        do {
            
            isMerged = NO;
            
            // 遍历数组 组成队列
            NSMutableArray *array = [NSMutableArray array];
            for (NSInteger i = taskModel.start_order; i < taskModel.end_order + 3; i++) {
                [array addObject:[WXYZ_UtilsHelper formatStringWithInteger:i - 1]];
            }
            
            for (int i = 0; i < t_arr.count; i ++) {
                WXYZ_DownloadTaskModel *t_task = [t_arr objectOrNilAtIndex:i];
                
                if (t_task.start_order != taskModel.start_order || t_task.end_order != taskModel.end_order) {
                    if ([array containsObject:[WXYZ_UtilsHelper formatStringWithInteger:t_task.start_order]]) {
                        
                        WXYZ_DownloadTaskModel *tt_task = [[WXYZ_DownloadTaskModel alloc] init];
                        tt_task.url = taskModel.url;
                        tt_task.file_name = taskModel.file_name;
                        tt_task.download_title = [NSString stringWithFormat:@"%@ — %@章", [array objectOrNilAtIndex:1], [WXYZ_UtilsHelper formatStringWithInteger:t_task.end_order > taskModel.end_order?t_task.end_order:taskModel.end_order]];
                        tt_task.dateString = [WXYZ_UtilsHelper currentDateStringWithFormat:@"yyyy-MM-dd"];
                        tt_task.file_size = taskModel.file_size + t_task.file_size;
                        tt_task.start_order = [[array objectOrNilAtIndex:1] integerValue];
                        tt_task.end_order = t_task.end_order > taskModel.end_order?t_task.end_order:taskModel.end_order;
                        
                        [t_arr replaceObjectAtIndex:i withObject:tt_task];
                        [t_arr removeObject:taskModel];
                        isMerged = YES;
                        noIntersection = NO;
                    } else if ([array containsObject:[WXYZ_UtilsHelper formatStringWithInteger:t_task.end_order]]) {
                        WXYZ_DownloadTaskModel *tt_task = [[WXYZ_DownloadTaskModel alloc] init];
                        tt_task.url = taskModel.url;
                        tt_task.file_name = taskModel.file_name;
                        tt_task.download_title = [NSString stringWithFormat:@"%@ — %@章", [WXYZ_UtilsHelper formatStringWithInteger:t_task.start_order], [WXYZ_UtilsHelper formatStringWithInteger:t_task.end_order > taskModel.end_order?t_task.end_order:taskModel.end_order]];
                        tt_task.dateString = [WXYZ_UtilsHelper currentDateStringWithFormat:@"yyyy-MM-dd"];
                        tt_task.file_size = taskModel.file_size + t_task.file_size;
                        tt_task.start_order = t_task.start_order;
                        tt_task.end_order = t_task.end_order > taskModel.end_order?t_task.end_order:taskModel.end_order;
                        
                        [t_arr replaceObjectAtIndex:i withObject:tt_task];
                        [t_arr removeObject:taskModel];
                        isMerged = YES;
                        noIntersection = NO;
                        
                    }
                    
                    if (isMerged) {
                        taskModel = [t_arr objectOrNilAtIndex:0];
                        break;
                    }
                    
                } else if (t_task.start_order == taskModel.start_order && t_task.end_order == taskModel.end_order) {
                    [t_arr replaceObjectAtIndex:i withObject:taskModel];
                    noIntersection = NO;
                }
            }
            
        } while (isMerged);
        
        if (noIntersection) {
            [t_arr addObject:taskModel];
        }
    }
    
    return [t_arr copy];
}

- (void)downloadTaskRequest
{
    if (self.requestOrderArray.count == 0) {
        return;
    }

    self.requesting = YES;

    NSDictionary *orderDic = [self.requestOrderArray firstObject];
    NSInteger production_id = [[orderDic.allKeys firstObject] integerValue];
    NSString *start_chapter_id = [orderDic objectForKey:[WXYZ_UtilsHelper formatStringWithInteger:production_id]][0];
    NSString *downloadNum = [orderDic objectForKey:[WXYZ_UtilsHelper formatStringWithInteger:production_id]][1];
    WXYZ_DownloadTaskModel *taskModel = [orderDic objectForKey:[WXYZ_UtilsHelper formatStringWithInteger:production_id]][2];

    [self.requestOrderArray removeFirstObject];

    WS(weakSelf)

    [WXYZ_NetworkRequestManger POST:Book_Download_Multiple_Chapters parameters:@{@"book_id":[WXYZ_UtilsHelper formatStringWithInteger:production_id], @"chapter_id":start_chapter_id, @"num":downloadNum} model:nil success:^(BOOL isSuccess, NSDictionary * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            if (weakSelf.requestOrderArray.count == 0) {
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"已加入下载队列"];
            }
            
            // 开始下载
            [[self bookDownloadTaskDictionaryWithProduction_id:production_id] setObject:identify_downloading forKey:taskModel.file_name];
            [self bookWriteToPlistWithProduction_id:production_id];
            
            // 任务开始
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.downloadMissionStateChangeBlock) {
                    self.downloadMissionStateChangeBlock(WXYZ_DownloadStateMissionStart, production_id, taskModel, nil);
                }
            });
            
            // 下载章节合集文件
            AFURLSessionManager *manager = [[AFURLSessionManager alloc] init];
            manager.operationQueue.maxConcurrentOperationCount = 1;
            manager.completionQueue = dispatch_queue_create("com.wxyz.book_queue", NULL);
            NSURL *URL = [NSURL URLWithString:[requestModel.data objectForKey:@"file_url"]];

            NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:[NSURLRequest requestWithURL:URL] progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {

                // 创建临时存储文件
                if (![[NSFileManager defaultManager] fileExistsAtPath:[[WXYZ_DownloadHelper sharedManager] getDownloadProductionFolderPathWithProduction_id:production_id productionType:WXYZ_ProductionTypeBook]]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:[[WXYZ_DownloadHelper sharedManager] getDownloadProductionFolderPathWithProduction_id:production_id productionType:WXYZ_ProductionTypeBook] withIntermediateDirectories:YES attributes:nil error:nil];
                }

                // 临时文件地址
                NSString *tempFilePath = [[[WXYZ_DownloadHelper sharedManager] getDownloadProductionFolderPathWithProduction_id:production_id productionType:WXYZ_ProductionTypeBook] stringByAppendingPathComponent:[requestModel.data objectForKey:@"file_name"]];

                return [NSURL fileURLWithPath:tempFilePath];
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                weakSelf.requesting = NO;
                if (error) {

                    // 任务下载失败删除记录
                    [[self bookDownloadTaskDictionaryWithProduction_id:production_id] removeObjectForKey:taskModel.file_name];
                    [self bookWriteToPlistWithProduction_id:production_id];

                    // 任务下载失败
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (weakSelf.downloadMissionStateChangeBlock) {
                            weakSelf.downloadMissionStateChangeBlock(WXYZ_DownloadStateMissionFail, production_id, taskModel, nil);
                        }
                    });
                } else {

                    NSString *fileContent = [NSString stringWithContentsOfFile:filePath.path encoding:NSUTF8StringEncoding error:nil];
                    if (fileContent.length > 0) {
                        NSArray *chapterModelArray = [NSArray modelArrayWithClass:[WXYZ_ProductionChapterModel class] json:fileContent];

                        if (chapterModelArray.count > 0) {
                            for (int i = 0; i < chapterModelArray.count; i ++) {

                                WXYZ_ProductionChapterModel *chapterModel = [chapterModelArray objectAtIndex:i];

                                // 文件请求成功,解析文件内容
                                [self storingFilesWithChapterModel:chapterModel storingCompletionHandler:^(BOOL finishStoring) {
                                    
                                }];
                            }

                            
                            // 存储下载任务列表
                            taskModel.file_size = [WXYZ_UtilsHelper getFileSize:filePath.path];
                            [[self bookDownloadTaskDictionaryWithProduction_id:production_id] setObject:taskModel forKey:taskModel.file_name];
                            [self bookWriteToPlistWithProduction_id:production_id];

                            // 任务下载完成
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (weakSelf.downloadMissionStateChangeBlock) {
                                    NSArray<NSNumber *> *t_arr = [chapterModelArray valueForKeyPath:@"chapter_id"];
                                    weakSelf.downloadMissionStateChangeBlock(WXYZ_DownloadStateMissionFinished, production_id, taskModel, t_arr);
                                }
                            });

                        } else {

                            // 任务下载失败删除记录
                            [[self bookDownloadTaskDictionaryWithProduction_id:production_id] removeObjectForKey:taskModel.file_name];
                            [self bookWriteToPlistWithProduction_id:production_id];

                            // 任务下载失败
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (weakSelf.downloadMissionStateChangeBlock) {
                                    weakSelf.downloadMissionStateChangeBlock(WXYZ_DownloadStateMissionFail, production_id, taskModel, nil);
                                }
                            });
                        }
                    }
                }

                // 移除临时文件
                [[NSFileManager defaultManager] removeItemAtPath:filePath.path error:nil];
            }];
            [downloadTask resume];
        } else if (Compare_Json_isEqualTo(requestModel.code, 701)) {
            weakSelf.requesting = NO;

            // 任务下载失败删除记录
            [[self bookDownloadTaskDictionaryWithProduction_id:production_id] removeObjectForKey:taskModel.file_name];
            [self bookWriteToPlistWithProduction_id:production_id];
            
            // 任务下载失败
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.downloadMissionStateChangeBlock) {
                    weakSelf.downloadMissionStateChangeBlock(WXYZ_DownloadStateMissionShouldPay, production_id, taskModel, nil);
                }
            });
        } else {
            weakSelf.requesting = NO;
            
            // 任务下载失败删除记录
            [[self bookDownloadTaskDictionaryWithProduction_id:production_id] removeObjectForKey:taskModel.file_name];
            [self bookWriteToPlistWithProduction_id:production_id];

            // 任务下载失败
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.downloadMissionStateChangeBlock) {
                    weakSelf.downloadMissionStateChangeBlock(WXYZ_DownloadStateMissionFail, production_id, taskModel, nil);
                }
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        weakSelf.requesting = NO;
        
        // 任务下载失败删除记录
        [[self bookDownloadTaskDictionaryWithProduction_id:production_id] removeObjectForKey:taskModel.file_name];
        [self bookWriteToPlistWithProduction_id:production_id];

        // 任务下载失败
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.downloadMissionStateChangeBlock) {
                weakSelf.downloadMissionStateChangeBlock(WXYZ_DownloadStateMissionFail, production_id, taskModel, nil);
            }
        });
    }];
}

- (NSMutableArray *)requestOrderArray
{
    if (!_requestOrderArray) {
        _requestOrderArray = [NSMutableArray array];
    }
    return _requestOrderArray;
}

- (NSMutableDictionary *)bookDownloadTaskDictionaryWithProduction_id:(NSUInteger)production_id
{
    return [[WXYZ_DownloadHelper sharedManager] chaptersRecordDownloadDictionaryWithProduction_id:production_id productionType:WXYZ_ProductionTypeBook modelClass:[WXYZ_DownloadTaskModel class]];
}

- (BOOL)bookWriteToPlistWithProduction_id:(NSUInteger)production_id
{
    return [[WXYZ_DownloadHelper sharedManager] writeToChapterPlistFileWithProduction_id:production_id productionType:WXYZ_ProductionTypeBook modelClass:[WXYZ_DownloadTaskModel class]];
}

@end

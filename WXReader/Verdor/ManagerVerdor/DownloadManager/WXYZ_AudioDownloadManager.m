//
//  WXYZ_AudioDownloadManager.m
//  WXReader
//
//  Created by Andrew on 2020/3/28.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AudioDownloadManager.h"

static dispatch_group_t url_session_manager_completion_group() {
    static dispatch_group_t af_url_session_manager_completion_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_url_session_manager_completion_group = dispatch_group_create();
    });

    return af_url_session_manager_completion_group;
}

@interface WXYZ_AudioDownloadManager () <NSURLSessionDataDelegate>

@property (nonatomic, assign) BOOL requesting;

@property (nonatomic, strong) NSMutableArray *requestOrderArray;

@end

@implementation WXYZ_AudioDownloadManager

implementation_singleton(WXYZ_AudioDownloadManager)

/*
 增
 **/

// 下载章节
- (void)downloadChapterWithProductionModel:(WXYZ_ProductionModel *)productionModel production_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id
{
    [self downloadChaptersWithProductionModel:productionModel production_id:production_id chapter_ids:@[[WXYZ_UtilsHelper formatStringWithInteger:chapter_id]]];
}

// 下载多个章节
- (void)downloadChaptersWithProductionModel:(WXYZ_ProductionModel *)productionModel production_id:(NSInteger)production_id chapter_ids:(NSArray <NSString *>*)chapter_ids
{
    [[WXYZ_DownloadHelper sharedManager] recordDownloadProductionWithProductionModel:productionModel productionType:WXYZ_ProductionTypeAudio];
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Audio_Chapter_Download parameters:@{@"audio_id":[WXYZ_UtilsHelper formatStringWithInteger:production_id], @"chapter_id":[chapter_ids componentsJoinedByString:@","]} model:nil success:^(BOOL isSuccess, NSDictionary * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 任务开始
                if (weakSelf.downloadMissionStateChangeBlock) {
                    weakSelf.downloadMissionStateChangeBlock(WXYZ_DownloadStateMissionStart, production_id, chapter_ids);
                }
                // 任务加入任务队列
                NSArray *taskArray = [t_model objectForKey:@"data"];
                if (taskArray.count > 0) {
                    
                    for (NSDictionary *t_dic in taskArray) {
                        WXYZ_ProductionChapterModel *imageCollectionModel = [WXYZ_ProductionChapterModel modelWithDictionary:t_dic];
                        if (imageCollectionModel) {
                            // 开始下载
                            [[self audioChaptersRecordDictionaryWithProduction_id:imageCollectionModel.production_id] setObject:identify_downloading forKey:chapterRecordKey(imageCollectionModel.production_id, imageCollectionModel.chapter_id)];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (self.downloadChapterStateChangeBlock) {
                                    self.downloadChapterStateChangeBlock(WXYZ_DownloadStateChapterDownloadStart, imageCollectionModel.production_id, imageCollectionModel.chapter_id);
                                }
                            });
                        }
                    }
                    
                    [weakSelf.requestOrderArray addObject:taskArray];
                    
                    if (!weakSelf.requesting) {
                        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"已加入下载列表"];
                    }
                    
                    // 开始下载任务
                    [weakSelf downloadTaskRequest];
                } else {
                    // 任务失败
                    if (weakSelf.downloadMissionStateChangeBlock) {
                        weakSelf.downloadMissionStateChangeBlock(WXYZ_DownloadStateMissionFail, production_id, chapter_ids);
                    }
                }
                
            });
            
            
        } else if (Compare_Json_isEqualTo(requestModel.code, 701)) { // 请求购买
            
            // 任务失败
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.downloadMissionStateChangeBlock) {
                    weakSelf.downloadMissionStateChangeBlock(WXYZ_DownloadStateMissionShouldPay, production_id, chapter_ids);
                }
            });
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
            
            // 任务失败
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.downloadMissionStateChangeBlock) {
                    weakSelf.downloadMissionStateChangeBlock(WXYZ_DownloadStateMissionFail, production_id, chapter_ids);
                }
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        // 任务失败
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.downloadMissionStateChangeBlock) {
                weakSelf.downloadMissionStateChangeBlock(WXYZ_DownloadStateMissionFail, production_id, chapter_ids);
            }
        });
    }];
}

/*
 删
 **/

// 删除本地已下载作品
- (BOOL)removeDownloadProductionWithProduction_id:(NSInteger)production_id
{
    // 删除作品文件夹
    [[WXYZ_DownloadHelper sharedManager] removeDownloadProductionFolderWithProduction_id:production_id productionType:WXYZ_ProductionTypeAudio];
    
    // 删除缓存
    [[self audioChaptersRecordDictionaryWithProduction_id:production_id] removeAllObjects];
    
    // 写入
    [self audioRecordWriteToPlistWithProduction_id:production_id];
    
    return YES;
}

// 删除本地多个已下载章节
- (void)removeDownloadChaptersWithProduction_id:(NSInteger)production_id chapter_ids:(NSArray <NSString *> *)chapter_ids
{
    if (chapter_ids.count == 0) {
        return;
    }
    
    // 删除文件夹
    [[WXYZ_DownloadHelper sharedManager] removeDownloadChapterFolderWithProduction_id:production_id chapter_ids:chapter_ids productionType:WXYZ_ProductionTypeAudio];
    
    // 删除下载记录
    NSMutableDictionary *t_dic = [self audioChaptersRecordDictionaryWithProduction_id:production_id];
    
    NSMutableArray *t_delete_arr = [NSMutableArray array];
    for (NSString *chapter_id in chapter_ids) {
        [t_delete_arr addObject:chapterRecordKey(production_id, [chapter_id integerValue])];
    }
    
    [t_dic removeObjectsForKeys:t_delete_arr];
    
    // 如果全部章节已经删除,则删除整体作品文件夹
    if ([self getDownloadChapterCountWithProduction_id:production_id] == 0) {
        [self removeDownloadProductionWithProduction_id:production_id];
    } else {
        [self audioRecordWriteToPlistWithProduction_id:production_id];
    }
    
    // 删除回调
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.downloadDeleteFinishBlock) {
            self.downloadDeleteFinishBlock(chapter_ids, @[]);
        }
    });
}

/*
 查
 **/

// 获取下载章节数
- (NSInteger)getDownloadChapterCountWithProduction_id:(NSInteger)production_id
{
    return [[WXYZ_DownloadHelper sharedManager] getDownloadChapterCountWithProduction_id:production_id productionType:WXYZ_ProductionTypeAudio];
}

// 获取全部已下载章节model
- (NSArray *)getDownloadChapterModelArrayWithProduction_id:(NSInteger)production_id
{
    NSMutableDictionary *t_dic = [self audioChaptersRecordDictionaryWithProduction_id:production_id];
    
    NSMutableArray *t_arr = [NSMutableArray array];
    for (id value in t_dic.allValues) {
        if ([value isKindOfClass:[WXYZ_ProductionChapterModel class]]) {
            [t_arr addObject:value];
        }
    }
    return [t_arr copy];
}

// 获取已下载章节model
- (id)getDownloadChapterModelWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id
{
    NSMutableDictionary *t_dic = [self audioChaptersRecordDictionaryWithProduction_id:production_id];

    id value = [t_dic objectForKey:chapterRecordKey(production_id, chapter_id)];
    
    if ([value isKindOfClass:[WXYZ_ProductionChapterModel class]]) {
        return value;
    }
    
    return nil;
}

// 获取章节下载状态
- (WXYZ_ProductionDownloadState)getChapterDownloadStateWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id
{
    NSMutableDictionary *t_dic = [self audioChaptersRecordDictionaryWithProduction_id:production_id];
    if ([[t_dic objectForKey:chapterRecordKey(production_id, chapter_id)] isEqual:identify_downloading]) {
        return WXYZ_ProductionDownloadStateDownloading;
    }

    if ([[t_dic objectForKey:chapterRecordKey(production_id, chapter_id)] isKindOfClass:[WXYZ_ProductionChapterModel class]]) {
        return WXYZ_ProductionDownloadStateDownloaded;
    }
    
    return WXYZ_ProductionDownloadStateNormal;
}

// 作品章节是否下载
- (BOOL)isChapterDownloadedWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id
{
    return [[WXYZ_DownloadHelper sharedManager] isChapterDownloadedWithProduction_id:production_id chapter_id:chapter_id productionType:WXYZ_ProductionTypeAudio];
}

// 获取文件地址
- (NSString *)chapterDownloadedFilePathWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id chapter_update_time:(NSString *)chapter_update_time
{
    // 章节文件名称
    NSString *chapterFileName = [WXYZ_UtilsHelper stringToMD5:[NSString stringWithFormat:@"%@%@%@", [WXYZ_UtilsHelper formatStringWithInteger:production_id], [WXYZ_UtilsHelper formatStringWithInteger:chapter_id], [WXYZ_UtilsHelper formatStringWithObject:chapter_update_time]]];
    
    NSString *chapterFilePath = @"";
    NSArray *extensionArr = @[@"mp3", @"wav", @"wma"];
    for (NSString *extension in extensionArr) {
        chapterFilePath = [[[WXYZ_DownloadHelper sharedManager] getDownloadChapterFolderPathWithProduction_id:production_id chapter_id:chapter_id productionType:WXYZ_ProductionTypeAudio] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", chapterFileName, extension]];
        if (chapterFilePath && chapterFilePath.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:chapterFilePath]) {
            return chapterFilePath;
        }
    }
    
    return chapterFilePath;
}

- (void)downloadTaskRequest
{
    if (self.requestOrderArray.count == 0) {
        return;
    }
    
    if (self.requesting) {
        return;
    }
    self.requesting = YES;
    
    NSArray *taskArray = [self.requestOrderArray firstObject];
    [self.requestOrderArray removeFirstObject];
    
    WS(weakSelf)
    dispatch_group_async(url_session_manager_completion_group(), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_queue_t audio_queue = dispatch_queue_create("wxyz_audio_queue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_group_t audio_group = dispatch_group_create();
        
        for (NSDictionary *t_dic in taskArray) {
            dispatch_group_async(audio_group, audio_queue, ^{
            
                dispatch_group_enter(audio_group);
                
                WXYZ_ProductionChapterModel *t_model = [WXYZ_ProductionChapterModel modelWithDictionary:t_dic];
                
                if (!t_model) {
                    // 单个章节下载失败
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (weakSelf.downloadChapterStateChangeBlock) {
                            weakSelf.downloadChapterStateChangeBlock(WXYZ_DownloadStateChapterDownloadFail, t_model.production_id, t_model.chapter_id);
                        }
                    });
                }
                
                AFURLSessionManager *manager = [[AFURLSessionManager alloc] init];
                manager.operationQueue.maxConcurrentOperationCount = 2;
                NSURL *URL = [NSURL URLWithString:t_model.content];
                
                NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:[NSURLRequest requestWithURL:URL] progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                    
                    // 存储文件夹创建
                    if (![[NSFileManager defaultManager] fileExistsAtPath:[[WXYZ_DownloadHelper sharedManager] getDownloadChapterFolderPathWithProduction_id:t_model.production_id chapter_id:t_model.chapter_id productionType:WXYZ_ProductionTypeAudio]]) {
                        [[NSFileManager defaultManager] createDirectoryAtPath:[[WXYZ_DownloadHelper sharedManager] getDownloadChapterFolderPathWithProduction_id:t_model.production_id chapter_id:t_model.chapter_id productionType:WXYZ_ProductionTypeAudio] withIntermediateDirectories:YES attributes:nil error:nil];
                    }
                    
                    // 获取图片名称
                    NSString *audioFileName = [WXYZ_UtilsHelper stringToMD5:[NSString stringWithFormat:@"%@%@%@", [WXYZ_UtilsHelper formatStringWithInteger:t_model.production_id], [WXYZ_UtilsHelper formatStringWithInteger:t_model.chapter_id], [WXYZ_UtilsHelper formatStringWithObject:t_model.update_time]]];
                    
                    // 图片地址
                    NSString *audioFilePath = [[[WXYZ_DownloadHelper sharedManager] getDownloadChapterFolderPathWithProduction_id:t_model.production_id chapter_id:t_model.chapter_id productionType:WXYZ_ProductionTypeAudio] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", audioFileName, [WXYZ_ViewHelper audioExtensionWithFormatString:[response MIMEType]]]];
                    
                    return [NSURL fileURLWithPath:audioFilePath];
                } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                    if (error) {
                        // 删除出错章节文件夹
                        [[WXYZ_DownloadHelper sharedManager] removeDownloadChapterFolderWithProduction_id:t_model.production_id chapter_ids:@[[WXYZ_UtilsHelper formatStringWithInteger:t_model.chapter_id]] productionType:WXYZ_ProductionTypeAudio];
                        [[weakSelf audioChaptersRecordDictionaryWithProduction_id:t_model.production_id] setObject:identify_fail forKey:chapterRecordKey(t_model.production_id, t_model.chapter_id)];
                        [weakSelf audioRecordWriteToPlistWithProduction_id:t_model.production_id];
                        
                        // 章节下载失败
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (weakSelf.downloadChapterStateChangeBlock) {
                                weakSelf.downloadChapterStateChangeBlock(WXYZ_DownloadStateChapterDownloadFail, t_model.production_id, t_model.chapter_id);
                            }
                        });
                        
                    } else {
                        // 下载成功 覆盖临时下载记录
                        [[weakSelf audioChaptersRecordDictionaryWithProduction_id:t_model.production_id] setObject:t_model forKey:chapterRecordKey(t_model.production_id, t_model.chapter_id)];
                        [weakSelf audioRecordWriteToPlistWithProduction_id:t_model.production_id];
                        
                        // 章节下载成功
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (weakSelf.downloadChapterStateChangeBlock) {
                                weakSelf.downloadChapterStateChangeBlock(WXYZ_DownloadStateChapterDownloadFinished, t_model.production_id, t_model.chapter_id);
                            }
                        });
                    }
                    
                    dispatch_group_leave(audio_group);
                }];
                [downloadTask resume];
            });
        }
        dispatch_group_notify(audio_group, audio_queue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.requesting = NO;
                if (weakSelf.requestOrderArray.count == 0) {
                    
                    // 任务完成
                    if (weakSelf.downloadMissionStateChangeBlock) {
                        weakSelf.downloadMissionStateChangeBlock(WXYZ_DownloadStateMissionFinished, 0, @[]);
                    }
                } else {
                    [weakSelf downloadTaskRequest];
                }
            });
        });
    });
}

- (NSMutableArray *)requestOrderArray
{
    if (!_requestOrderArray) {
        _requestOrderArray = [NSMutableArray array];
    }
    return _requestOrderArray;
}

- (NSMutableDictionary *)audioChaptersRecordDictionaryWithProduction_id:(NSUInteger)production_id
{
    return [[WXYZ_DownloadHelper sharedManager] chaptersRecordDownloadDictionaryWithProduction_id:production_id productionType:WXYZ_ProductionTypeAudio modelClass:[WXYZ_ProductionChapterModel class]];
}

- (BOOL)audioRecordWriteToPlistWithProduction_id:(NSUInteger)production_id
{
    return [[WXYZ_DownloadHelper sharedManager] writeToChapterPlistFileWithProduction_id:production_id productionType:WXYZ_ProductionTypeAudio modelClass:[WXYZ_ProductionChapterModel class]];
}

@end

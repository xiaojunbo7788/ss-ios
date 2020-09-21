//
//  WXYZ_ComicDownloadManager.m
//  WXReader
//
//  Created by Andrew on 2020/3/29.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ComicDownloadManager.h"

static dispatch_group_t url_session_manager_completion_group() {
    static dispatch_group_t af_url_session_manager_completion_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_url_session_manager_completion_group = dispatch_group_create();
    });

    return af_url_session_manager_completion_group;
}

@interface WXYZ_ComicDownloadManager ()

@property (nonatomic, assign) BOOL requesting;

@property (nonatomic, strong) NSMutableArray *requestOrderArray;

@end

@implementation WXYZ_ComicDownloadManager

implementation_singleton(WXYZ_ComicDownloadManager)

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
    // 作品开始下载标记
    [[WXYZ_DownloadHelper sharedManager] recordDownloadProductionWithProductionModel:productionModel productionType:WXYZ_ProductionTypeComic];
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Comic_Download parameters:@{@"comic_id":[WXYZ_UtilsHelper formatStringWithInteger:production_id], @"chapter_id":[chapter_ids componentsJoinedByString:@","]} model:nil success:^(BOOL isSuccess, NSDictionary * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
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
                            [[self comicChaptersRecordDictionaryWithProduction_id:imageCollectionModel.production_id] setObject:identify_downloading forKey:chapterRecordKey(imageCollectionModel.production_id, imageCollectionModel.chapter_id)];
                            
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
                    [weakSelf downloadTaskRequestWithProduction_id:production_id];
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

// 删除本地整本已下载作品
- (BOOL)removeDownloadProductionWithProduction_id:(NSInteger)production_id
{
    // 删除作品文件夹
    [[WXYZ_DownloadHelper sharedManager] removeDownloadProductionFolderWithProduction_id:production_id productionType:WXYZ_ProductionTypeComic];
    
    // 删除缓存
    [[self comicChaptersRecordDictionaryWithProduction_id:production_id] removeAllObjects];
    
    // 写入
    [self comicRecordWriteToPlistWithProduction_id:production_id];
    
    return YES;
}

// 删除本地多个已下载章节
- (void)removeDownloadChaptersWithProduction_id:(NSInteger)production_id chapter_ids:(NSArray <NSString *> *)chapter_ids
{
    if (chapter_ids.count == 0) {
        return;
    }
    
    // 删除文件夹
    [[WXYZ_DownloadHelper sharedManager] removeDownloadChapterFolderWithProduction_id:production_id chapter_ids:chapter_ids productionType:WXYZ_ProductionTypeComic];
    
    // 删除下载记录
    NSMutableDictionary *t_dic = [self comicChaptersRecordDictionaryWithProduction_id:production_id];
    
    NSMutableArray *t_delete_arr = [NSMutableArray array];
    for (NSString *chapter_id in chapter_ids) {
        [t_delete_arr addObject:chapterRecordKey(production_id, [chapter_id integerValue])];
    }
    
    [t_dic removeObjectsForKeys:t_delete_arr];
    
    // 如果全部章节已经删除,则删除整体作品文件夹
    if ([self getDownloadChapterCountWithProduction_id:production_id] == 0) {
        [self removeDownloadProductionWithProduction_id:production_id];
    } else {
        [self comicRecordWriteToPlistWithProduction_id:production_id];
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
    return [[WXYZ_DownloadHelper sharedManager] getDownloadChapterCountWithProduction_id:production_id productionType:WXYZ_ProductionTypeComic];
}

// 获取全部已下载章节model
- (NSArray *)getDownloadChapterModelArrayWithProduction_id:(NSInteger)production_id
{
    NSMutableDictionary *t_dic = [self comicChaptersRecordDictionaryWithProduction_id:production_id];
    
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
    NSMutableDictionary *t_dic = [self comicChaptersRecordDictionaryWithProduction_id:production_id];

    id value = [t_dic objectForKey:chapterRecordKey(production_id, chapter_id)];
    
    if ([value isKindOfClass:[WXYZ_ProductionChapterModel class]]) {
        return value;
    }
    return nil;
}

// 获取下载状态
- (WXYZ_ProductionDownloadState)getChapterDownloadStateWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id
{
    NSMutableDictionary *t_dic = [self comicChaptersRecordDictionaryWithProduction_id:production_id];
    if ([[t_dic objectForKey:chapterRecordKey(production_id, chapter_id)] isEqual:identify_downloading]) {
        return WXYZ_ProductionDownloadStateDownloading;
    }
    
    if ([[t_dic objectForKey:chapterRecordKey(production_id, chapter_id)] isEqual:identify_fail]) {
        return WXYZ_ProductionDownloadStateFail;
    }

    if ([[t_dic objectForKey:chapterRecordKey(production_id, chapter_id)] isKindOfClass:[WXYZ_ProductionChapterModel class]]) {
        return WXYZ_ProductionDownloadStateDownloaded;
    }
    
    return WXYZ_ProductionDownloadStateNormal;
}


// 作品章节是否下载
- (BOOL)isChapterDownloadedWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id
{
    return [[WXYZ_DownloadHelper sharedManager] isChapterDownloadedWithProduction_id:production_id chapter_id:chapter_id productionType:WXYZ_ProductionTypeComic];
}

- (UIImage *)getDownloadLocalImageWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id image_id:(NSInteger)image_id image_update_time:(NSInteger)image_update_time
{
    UIImage *t_image = [UIImage imageWithContentsOfFile:[self chapterImageFilePathWithProduction_id:production_id chapter_id:chapter_id image_id:image_id image_update_time:image_update_time]];
    if (!t_image) {
        return nil;
    }
    return t_image;
}

- (NSString *)chapterImageFilePathWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id image_id:(NSInteger)image_id image_update_time:(NSInteger)image_update_time
{
    // 章节图片名称
    NSString *imageFileName = [WXYZ_UtilsHelper stringToMD5:[NSString stringWithFormat:@"%@%@%@%@", [WXYZ_UtilsHelper formatStringWithInteger:production_id], [WXYZ_UtilsHelper formatStringWithInteger:chapter_id], [WXYZ_UtilsHelper formatStringWithInteger:image_id], [WXYZ_UtilsHelper formatStringWithInteger:image_update_time]]];
 
    NSString *imageFilePath = @"";
    NSArray *extensionArr = @[@"jpeg", @"png", @"gif", @"tiff", @"webp"];
    for (NSString *extension in extensionArr) {
        imageFilePath = [[[WXYZ_DownloadHelper sharedManager] getDownloadChapterFolderPathWithProduction_id:production_id chapter_id:chapter_id productionType:WXYZ_ProductionTypeComic] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageFileName, extension]];
        if (imageFilePath && imageFilePath.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:imageFilePath]) {
            return imageFilePath;
        }
    }
    
    return imageFilePath;
}

- (void)downloadTaskRequestWithProduction_id:(NSInteger)production_id
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
        // 记录出错章节
        NSMutableArray __block *errorChapter = [NSMutableArray array];
        
        dispatch_semaphore_t collection_semaphore = dispatch_semaphore_create(0);
        
        // 记录章节model内容
        NSMutableArray *t_chapterModelArray = [NSMutableArray array];
        
        for (NSDictionary *t_dic in taskArray) {
            dispatch_queue_t image_queue = dispatch_queue_create("wxyz_image_queue", DISPATCH_QUEUE_CONCURRENT);
            dispatch_group_t image_group = dispatch_group_create();
            
            WXYZ_ProductionChapterModel *imageCollectionModel = [WXYZ_ProductionChapterModel modelWithDictionary:t_dic];
            
            if (!imageCollectionModel) {
                
                // 单个章节下载失败
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakSelf.downloadChapterStateChangeBlock) {
                        weakSelf.downloadChapterStateChangeBlock(WXYZ_DownloadStateChapterDownloadFail, imageCollectionModel.production_id, imageCollectionModel.chapter_id);
                    }
                });
                continue;
            }
            [t_chapterModelArray addObject:imageCollectionModel];
            
            // 解析任务 下载一话内的图片组
            for (WXYZ_ImageListModel *imageModel in imageCollectionModel.image_list) {
                dispatch_group_async(image_group, image_queue, ^{
                    
                    dispatch_group_enter(image_group);
                    
                    // 创建图片下载器
                    AFURLSessionManager *manager = [[AFURLSessionManager alloc] init];
                    manager.operationQueue.maxConcurrentOperationCount = 2;
                    NSURL *URL = [NSURL URLWithString:imageModel.image];
                    
                    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:[NSURLRequest requestWithURL:URL] progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                        
                        // 存储文件夹创建
                        if (![[NSFileManager defaultManager] fileExistsAtPath:[[WXYZ_DownloadHelper sharedManager] getDownloadChapterFolderPathWithProduction_id:imageCollectionModel.production_id chapter_id:imageCollectionModel.chapter_id productionType:WXYZ_ProductionTypeComic]]) {
                            [[NSFileManager defaultManager] createDirectoryAtPath:[[WXYZ_DownloadHelper sharedManager] getDownloadChapterFolderPathWithProduction_id:imageCollectionModel.production_id chapter_id:imageCollectionModel.chapter_id productionType:WXYZ_ProductionTypeComic] withIntermediateDirectories:YES attributes:nil error:nil];
                        }
                        
                        // 获取图片名称
                        NSString *imageFileName = [WXYZ_UtilsHelper stringToMD5:[NSString stringWithFormat:@"%@%@%@%@", [WXYZ_UtilsHelper formatStringWithInteger:imageCollectionModel.production_id], [WXYZ_UtilsHelper formatStringWithInteger:imageCollectionModel.chapter_id], [WXYZ_UtilsHelper formatStringWithInteger:imageModel.image_id], [WXYZ_UtilsHelper formatStringWithInteger:imageModel.image_update_time]]];
                        
                        // 图片地址
                        NSString *imageFilePath = [[[WXYZ_DownloadHelper sharedManager] getDownloadChapterFolderPathWithProduction_id:imageCollectionModel.production_id chapter_id:imageCollectionModel.chapter_id productionType:WXYZ_ProductionTypeComic] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageFileName, [WXYZ_ViewHelper imageExtensionWithFormatString:[response MIMEType]]]];
                        
                        return [NSURL fileURLWithPath:imageFilePath];
                    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                        // 如果某一张出错就取消下载,删除该章节文件夹
                        if (error) {
                            [errorChapter addObject:[WXYZ_UtilsHelper formatStringWithInteger:imageCollectionModel.chapter_id]];
                        }
                        dispatch_group_leave(image_group);
                    }];
                    [downloadTask resume];
                });
            }
            dispatch_group_notify(image_group, image_queue, ^{
                
                // 删除图片出错章节
                if (errorChapter.count > 0) {
                    // 删除出错章节文件夹
                    [[WXYZ_DownloadHelper sharedManager] removeDownloadChapterFolderWithProduction_id:imageCollectionModel.production_id chapter_ids:errorChapter productionType:WXYZ_ProductionTypeComic];
                    [[weakSelf comicChaptersRecordDictionaryWithProduction_id:imageCollectionModel.production_id] setObject:identify_fail forKey:chapterRecordKey(imageCollectionModel.production_id, imageCollectionModel.chapter_id)];
                    [weakSelf comicRecordWriteToPlistWithProduction_id:imageCollectionModel.production_id];
                    
                    // 单个章节下载失败
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (weakSelf.downloadChapterStateChangeBlock) {
                            weakSelf.downloadChapterStateChangeBlock(WXYZ_DownloadStateChapterDownloadFail, imageCollectionModel.production_id, imageCollectionModel.chapter_id);
                        }
                    });
                    
                } else {
                    
                    // 下载成功 覆盖临时下载记录
                    [[weakSelf comicChaptersRecordDictionaryWithProduction_id:imageCollectionModel.production_id] setObject:imageCollectionModel forKey:chapterRecordKey(imageCollectionModel.production_id, imageCollectionModel.chapter_id)];
                    [weakSelf comicRecordWriteToPlistWithProduction_id:imageCollectionModel.production_id];
                    
                    // 单个章节下载完成
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (weakSelf.downloadChapterStateChangeBlock) {
                            weakSelf.downloadChapterStateChangeBlock(WXYZ_DownloadStateChapterDownloadFinished, imageCollectionModel.production_id, imageCollectionModel.chapter_id);
                        }
                    });
                }
                
                
                dispatch_semaphore_signal(collection_semaphore);
            });
            
            dispatch_semaphore_wait(collection_semaphore, DISPATCH_TIME_FOREVER);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.requesting = NO;
            if (weakSelf.requestOrderArray.count == 0) {
                
                // 替换已下载记录章节目录内容
                WXYZ_ProductionModel *t_productionModel = [[WXYZ_DownloadHelper sharedManager] getDownloadProductionModelWithProduction_id:production_id productionType:WXYZ_ProductionTypeComic];
                NSMutableArray *t_chapterList = [t_productionModel.chapter_list mutableCopy];
                for (int i = 0; i < t_chapterList.count; i++) {
                    WXYZ_ProductionChapterModel *t_chapterModel = [t_chapterList objectAtIndex:i];
                    for (WXYZ_ProductionChapterModel *tt_chapterModel in t_chapterModelArray) {
                        if (tt_chapterModel.chapter_id == t_chapterModel.chapter_id) {
                            [t_chapterList replaceObjectAtIndex:i withObject:tt_chapterModel];
                            break;
                        }
                    }
                }
                t_productionModel.chapter_list = [t_chapterList copy];
                [[WXYZ_DownloadHelper sharedManager] recordDownloadProductionWithProductionModel:t_productionModel productionType:WXYZ_ProductionTypeComic];
                
                // 任务完成
                if (weakSelf.downloadMissionStateChangeBlock) {
                    weakSelf.downloadMissionStateChangeBlock(WXYZ_DownloadStateMissionFinished, 0, @[]);
                }
            } else {
                [weakSelf downloadTaskRequestWithProduction_id:production_id];
            }
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

- (NSMutableDictionary *)comicChaptersRecordDictionaryWithProduction_id:(NSUInteger)production_id
{
    return [[WXYZ_DownloadHelper sharedManager] chaptersRecordDownloadDictionaryWithProduction_id:production_id productionType:WXYZ_ProductionTypeComic modelClass:[WXYZ_ProductionChapterModel class]];
}

- (BOOL)comicRecordWriteToPlistWithProduction_id:(NSUInteger)production_id
{
    return [[WXYZ_DownloadHelper sharedManager] writeToChapterPlistFileWithProduction_id:production_id productionType:WXYZ_ProductionTypeComic modelClass:[WXYZ_ProductionChapterModel class]];
}

@end

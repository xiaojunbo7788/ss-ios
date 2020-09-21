//
//  WXYZ_DownloadHelper.h
//  WXReader
//
//  Created by Andrew on 2020/4/1.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXYZ_DownloadManagerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

// 章节记录文件key
#define chapterRecordKey(production_id, chapter_id) [WXYZ_UtilsHelper stringToMD5:[NSString stringWithFormat:@"%@%@", [WXYZ_UtilsHelper formatStringWithInteger:production_id], [WXYZ_UtilsHelper formatStringWithInteger:chapter_id]]]


@interface WXYZ_DownloadHelper : NSObject

interface_singleton

/*
 增
 **/

// 作品下载记录
- (void)recordDownloadProductionWithProductionModel:(WXYZ_ProductionModel *)productionModel productionType:(WXYZ_ProductionType)productionType;

/*
 删
 **/

// 删除作品文件夹
- (void)removeDownloadProductionFolderWithProduction_id:(NSInteger)production_id productionType:(WXYZ_ProductionType)productionType;

// 删除章节文件夹
- (BOOL)removeDownloadChapterFolderWithProduction_id:(NSInteger)production_id chapter_ids:(NSArray <NSString *>*)chapter_ids productionType:(WXYZ_ProductionType)productionType;
/*
 查
 **/

// 作品章节是否下载
- (BOOL)isChapterDownloadedWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id productionType:(WXYZ_ProductionType)productionType;

// 下载作品文件夹路径
- (NSString *)getDownloadProductionFolderPathWithProduction_id:(NSInteger)production_id productionType:(WXYZ_ProductionType)productionType;

// 下载章节文件夹路径
- (NSString *)getDownloadChapterFolderPathWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id productionType:(WXYZ_ProductionType)productionType;

// 下载作品记录文件路径
- (NSString *)getDownloadProductionRecordPlistFilePathWithProductionType:(WXYZ_ProductionType)productionType;

// 获取下载章节数
- (NSInteger)getDownloadChapterCountWithProduction_id:(NSInteger)production_id productionType:(WXYZ_ProductionType)productionType;

// 获取类别下的所有下载作品model
- (NSArray <WXYZ_ProductionModel *> *)getDownloadProductionArrayWithProductionType:(WXYZ_ProductionType)productionType;

// 获取某一已下载作品model
- (WXYZ_ProductionModel *)getDownloadProductionModelWithProduction_id:(NSInteger)production_id productionType:(WXYZ_ProductionType)productionType;

// 章节记录缓存变量
- (NSMutableDictionary *)chaptersRecordDownloadDictionaryWithProduction_id:(NSInteger)production_id productionType:(WXYZ_ProductionType)productionType modelClass:(__nullable Class)modelClass;

// 写入章节记录文件
- (BOOL)writeToChapterPlistFileWithProduction_id:(NSInteger)production_id productionType:(WXYZ_ProductionType)productionType modelClass:(Class)modelClass;

@end

NS_ASSUME_NONNULL_END

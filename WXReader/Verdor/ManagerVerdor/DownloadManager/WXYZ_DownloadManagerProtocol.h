//
//  WXYZ_DownloadHelperProtocol.h
//  WXReader
//
//  Created by Andrew on 2020/4/1.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXYZ_DownloadManagerEnumProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol WXYZ_DownloadManagerProtocol <NSObject>

@optional
/*
 增
 **/

// 下载章节
- (void)downloadChapterWithProductionModel:(WXYZ_ProductionModel *)productionModel production_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id;

// 下载多个章节
- (void)downloadChaptersWithProductionModel:(WXYZ_ProductionModel *)productionModel production_id:(NSInteger)production_id chapter_ids:(NSArray <NSString *>*)chapter_ids;

/*
 删
 **/

// 删除本地已下载作品
- (BOOL)removeDownloadProductionWithProduction_id:(NSInteger)production_id;

// 删除本地已下载章节
- (void)removeDownloadChaptersWithProduction_id:(NSInteger)production_id chapter_ids:(NSArray <NSString *> *)chapter_ids;

/*
 查
 **/

// 获取下载章节数
- (NSInteger)getDownloadChapterCountWithProduction_id:(NSInteger)production_id;

// 获取全部已下载章节model
- (NSArray *__nullable)getDownloadChapterModelArrayWithProduction_id:(NSInteger)production_id;

// 获取已下载章节model
- (id)getDownloadChapterModelWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id;

// 获取章节下载状态
- (WXYZ_ProductionDownloadState)getChapterDownloadStateWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id;

// 章节是否下载
- (BOOL)isChapterDownloadedWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id;

@end

NS_ASSUME_NONNULL_END

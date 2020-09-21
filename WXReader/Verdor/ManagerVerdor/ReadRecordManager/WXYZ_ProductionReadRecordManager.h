//
//  WXYZ_ProductionReadRecordManager.h
//  WXReader
//
//  Created by Andrew on 2020/3/24.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXYZ_BookMarkModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ProductionReadRecordManager : NSObject

+ (instancetype)shareManagerWithProductionType:(WXYZ_ProductionType)productionType;

// 添加阅读记录
- (BOOL)addReadingRecordWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id chapterTitle:(NSString *)chapterTitle;

// 获取某个作品当前阅读章节id
- (NSInteger)getReadingRecordChapter_idWithProduction_id:(NSInteger)production_id;

// 获取某个作品当前阅读章节名称
- (NSString *)getReadingRecordChapterTitleWithProduction_id:(NSInteger)production_id;

// 作品章节是否已读
- (BOOL)chapterHasReadedWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id;

// 作品是否已读
- (BOOL)productionHasReadedWithProduction_id:(NSInteger)production_id;

// 设置漫画阅读记录(仅限漫画使用)
- (void)setComicReadingRecord:(NSInteger)comic_id chapter_id:(NSInteger)chapter_id offsetY:(CGFloat)offsetY;

/// 获取漫画阅读记录(章节ID ：offsetY)(仅限漫画使用)
- (NSDictionary *)getComicReadingRecord:(NSInteger)comic_id;

// 设置播放器进度(仅限有声功能使用)
- (void)addPlayingProgress:(CGFloat)progress production_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id;

// 播放作品进度(仅限有声功能使用)
- (CGFloat)getPlayingProgressWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id;

// 是否是当前正在播放的作品(仅限有声功能使用)
- (BOOL)isCurrentPlayingProductionWithProduction_id:(NSInteger)production_id;

// 是否是当前正在播放的章节(仅限有声功能使用)
- (BOOL)isCurrentPlayingChapterWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id;

/* 添加书签
 @param bookID 书籍ID
 @param chapterID 章节ID
 @param chapterSort 章节索引
 @param chapterTitle 章节标题
 @param chapterContent 章节内容
 @param pageContent 当前页内容
 **/
+ (WXYZ_BookMarkModel *)addBookMark:(NSString *)bookID chapterID:(NSString *)chapterID chapterSort:(NSInteger)chapterSort chapterTitle:(NSString *)chapterTitle chapterContent:(NSString *)chapterContent pageContent:(NSString *)pageContent;

/* 获取书籍所有书签
 @param bookID 书籍ID
 **/
+ (NSArray<WXYZ_BookMarkModel *> *)bookMark:(NSString *)bookID;

/* 获取章节所有书签
 @param bookID 书籍ID
 @param chapterID 章节ID
 **/
+ (NSArray<WXYZ_BookMarkModel *> *)bookMark:(NSString *)bookID chapterID:(NSString *)chapterID;

/* 删除指定书签
 @param markModel 书签Model
 **/
+ (void)removeBookMark:(WXYZ_BookMarkModel *)markModel;

@end

NS_ASSUME_NONNULL_END

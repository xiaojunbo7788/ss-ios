//
//  WXReaderMamager.h
//  WXReader
//
//  Created by Andrew on 2018/6/3.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface WXYZ_ReaderBookManager : NSObject

// 当前阅读章节
@property (nonatomic, assign) NSInteger currentChapterIndex;

// 当前页数
@property (nonatomic, assign) NSInteger currentPagerIndex;

// 书籍id
@property (nonatomic, assign) NSInteger book_id;

// 章节id
@property (nonatomic, assign) NSInteger chapter_id;

// 下一页
@property (nonatomic, assign) NSInteger nextPagerIndex;

// 上一页
@property (nonatomic, assign) NSInteger previousPagerIndex;

// 当前章节页数
@property (nonatomic, assign, readonly) NSInteger currentChapterPagerCount;

// 总章节数
@property (nonatomic, assign, readonly) NSInteger totalChapterCount;

// 书籍总页数
@property (nonatomic, assign, readonly) NSInteger totalChapterPagerCount;

@property (nonatomic, strong, readonly) WXYZ_ProductionChapterModel *chapterModel;

@property (nonatomic, strong) WXYZ_ProductionModel *bookModel;

/// 章节末尾投票数
@property (nonatomic, copy, nullable) NSString *reward_num;

/// 章节末尾月票数
@property (nonatomic, copy, nullable) NSString *ticket_num;

/// 书签标记位置
@property (nonatomic, assign) NSInteger markIndex;

interface_singleton

// 获取书籍名称
- (NSString *)getBookName;

// 获取章节名称
- (NSString *)getChapterTitle;

// 是否是预览章节
- (BOOL)isPreviewChapter;

// 是否有下章节
- (BOOL)haveNextChapter;

// 是否有上章节
- (BOOL)havePreChapter;

// 是否是最后一章最后一页
- (BOOL)isTheLastPager;

// 是否是第一章第一页
- (BOOL)isTheFormerPager;

// 是否有下一页
- (BOOL)haveNextPager;

// 上一章是否有缓存
- (BOOL)havePreCache;

// 下一章是否有缓存
- (BOOL)haveNextCache;

// 获取下一页
- (void)getNextPagerAttributedText:(void(^ _Nullable)(NSAttributedString *content))complete;

// 获取上一页
- (void)getPrePagerAttributedText:(void(^ _Nullable)(NSAttributedString * _Nullable content))complete;

// 获取某一章节某一页
- (void)getPagerAttributedTextWithChapterIndex:(NSInteger)chapterIndex pagerIndex:(NSInteger)pageIndex completionHandler:(void(^)(NSAttributedString *content))completionHandler;

// 获取某一章节全部内容
- (void)getChapterTextWithBook_id:(NSInteger)book_id chapter_index:(NSInteger)chapter_index completionHandler:(void(^)(NSString *content))completionHandler;

// 书籍model请求
- (void)requestBookModelWithBookId:(NSUInteger)book_id completionHandler:(void(^ _Nullable)(void))completionHandler;

// 获取章节所有内容
- (NSString *)getChapterContent;

// 获取章节详细内容
- (NSString *)getChapterDetailContent;

- (NSMutableArray *)chapterRangeArray;

// 预加载多个章节(不支持自动订阅 && 支持多章下载)
- (void)downloadPrestrainChaptersWithProductionModel:(WXYZ_ProductionModel *)productionModel production_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id prestrainNumber:(NSInteger)prestrainNumber;

// 预加载章节(支持自动订阅 && 仅支持单章下载)
- (void)downloadPrestrainChapterWithProductionModel:(WXYZ_ProductionModel *)productionModel production_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id completionHandler:(void(^ _Nullable)(NSString *chapterContentString, NSInteger production_id, NSInteger chapter_id))completionHandler;

@end
NS_ASSUME_NONNULL_END

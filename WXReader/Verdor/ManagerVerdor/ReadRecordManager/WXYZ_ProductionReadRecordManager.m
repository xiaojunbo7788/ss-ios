//
//  WXYZ_ProductionReadRecordManager.m
//  WXReader
//
//  Created by Andrew on 2020/3/24.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ProductionReadRecordManager.h"

#import "WXYZ_BookMarkModel.h"

// 当前正在阅读作品id key
#define current_read_production_id_cache_key(type) ([NSString stringWithFormat:@"%@_%@", @"UkhU98p5", [WXYZ_UtilsHelper formatStringWithInteger:type]])

// 某个作品正在阅读的章节标题 key
#define current_read_production_title_cache_key(type, production_id) ([NSString stringWithFormat:@"%@%@%@", @"SOdYb5CO", [WXYZ_UtilsHelper formatStringWithInteger:type], [WXYZ_UtilsHelper formatStringWithInteger:production_id]])

// 某个作品正在阅读的章节id
#define current_read_chapter_id_cache_key(type, production_id) ([NSString stringWithFormat:@"%@_%@_%@", @"KBOwoFvR", [WXYZ_UtilsHelper formatStringWithInteger:type], [WXYZ_UtilsHelper formatStringWithInteger:production_id]])

// 某个章节的播放进度 key
#define current_playing_chapter_progress(type, production_id) ([NSString stringWithFormat:@"%@_%@_%@", @"TLIo2gaz", [WXYZ_UtilsHelper formatStringWithInteger:type], [WXYZ_UtilsHelper formatStringWithInteger:production_id]])

// 某个章节是否已读 key
#define has_readed_cache_key(type, production_id ) ([NSString stringWithFormat:@"%@%@%@", @"KNU5HliF", [WXYZ_UtilsHelper formatStringWithInteger:type], [WXYZ_UtilsHelper formatStringWithInteger:production_id]])

/*
 存储结构说明
 
 {
    小说类型: {
        章节标题:@"标题",
        当前阅读章节id:00001,
        章节播放进度记录: {
            "章节id":0.5,
            "章节id":0.8,
            "章节id":0.1
        }
        当前作品下的所有阅读记录:{
            @"章节id":@"1",
            @"章节id":@"1",
            @"章节id":@"1"
        }
    }
 }
 
 */

@interface WXYZ_ProductionReadRecordManager ()

@property (nonatomic, strong) NSMutableDictionary *readRecordDictionary;

@end

@implementation WXYZ_ProductionReadRecordManager

static WXYZ_ProductionType _productionType;
static WXYZ_ProductionReadRecordManager *_instance_record;
+ (instancetype)shareManagerWithProductionType:(WXYZ_ProductionType)productionType
{
    static dispatch_once_t once_token_record;
    dispatch_once(&once_token_record, ^{
        _instance_record = [[self alloc] init];
    });
    _productionType = productionType;
    return _instance_record;
}

// 添加阅读记录
- (BOOL)addReadingRecordWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id chapterTitle:(NSString *)chapterTitle
{
    // 记录当前正在阅读作品id
    [self.readRecordDictionary setObject:[WXYZ_UtilsHelper formatStringWithInteger:production_id] forKey:current_read_production_id_cache_key(_productionType)];
    
    // 记录当前正在阅读章节id
    [self.readRecordDictionary setObject:[WXYZ_UtilsHelper formatStringWithInteger:chapter_id] forKey:current_read_chapter_id_cache_key(_productionType, production_id)];
    
    // 记录当前阅读章节名称
    [self.readRecordDictionary setObject:chapterTitle?:@"" forKey:current_read_production_title_cache_key(_productionType, production_id)];
    
    // 设置已读作品
    if (![self chapterHasReadedWithProduction_id:production_id chapter_id:chapter_id]) {
        NSMutableDictionary *t_dic = [[self.readRecordDictionary objectForKey:has_readed_cache_key(_productionType, production_id)] mutableCopy];
        if (!t_dic) {
            t_dic = [NSMutableDictionary dictionary];
        }
        [t_dic setObject:@"1" forKey:[WXYZ_UtilsHelper formatStringWithInteger:chapter_id]];

        [self.readRecordDictionary setObject:[t_dic copy] forKey:has_readed_cache_key(_productionType, production_id)];
    }
    
    return [self writeToPlistFile];
}

// 获取某个作品当前阅读章节id
- (NSInteger)getReadingRecordChapter_idWithProduction_id:(NSInteger)production_id
{
    NSString *chapter_id_string = [self.readRecordDictionary objectForKey:current_read_chapter_id_cache_key(_productionType, production_id)];
    return [chapter_id_string integerValue];
}

// 获取某个作品当前阅读章节名称
- (NSString *)getReadingRecordChapterTitleWithProduction_id:(NSInteger)production_id
{
    NSString *chapter_id_string = [self.readRecordDictionary objectForKey:current_read_production_title_cache_key(_productionType, production_id)];
    return chapter_id_string;
}

// 作品章节是否已读
- (BOOL)chapterHasReadedWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id
{
    NSMutableDictionary *t_dic = [[self.readRecordDictionary objectForKey:has_readed_cache_key(_productionType, production_id)] mutableCopy];
    if (t_dic.count == 0) {
        return NO;
    }
    
    return [t_dic objectForKey:[WXYZ_UtilsHelper formatStringWithInteger:chapter_id]]?YES:NO;
}

// 作品是否已读
- (BOOL)productionHasReadedWithProduction_id:(NSInteger)production_id
{
    NSMutableDictionary *t_dic = [[self.readRecordDictionary objectForKey:has_readed_cache_key(_productionType, production_id)] mutableCopy];
    if (t_dic.count == 0) {
        return NO;
    }
    
    return YES;
}

// 设置播放器进度(仅限有声功能使用)
- (void)addPlayingProgress:(CGFloat)progress production_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id
{
    NSMutableDictionary *t_dic = [[self.readRecordDictionary objectForKey:current_playing_chapter_progress(_productionType, production_id)] mutableCopy];
    if (!t_dic) {
        t_dic = [NSMutableDictionary dictionary];
    }
    [t_dic setObject:[WXYZ_UtilsHelper formatStringWithFloat:progress] forKey:[WXYZ_UtilsHelper formatStringWithInteger:chapter_id]];
    
    [self.readRecordDictionary setObject:[t_dic copy] forKey:current_playing_chapter_progress(_productionType, production_id)];
}

// 播放作品进度(仅限有声功能使用)
- (CGFloat)getPlayingProgressWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id
{
    NSDictionary *t_dic = [[self.readRecordDictionary objectForKey:current_playing_chapter_progress(_productionType, production_id)] copy];
    
    NSString *progress = [t_dic objectForKey:[WXYZ_UtilsHelper formatStringWithInteger:chapter_id]];
    if (progress && progress.length > 0) {
        
        if ([progress floatValue] > 0.95) {
            return 0;
        }
        return [progress floatValue];
    }
    return 0.f;
}

// 是否是当前正在播放的作品(仅限有声功能使用)
- (BOOL)isCurrentPlayingProductionWithProduction_id:(NSInteger)production_id
{
    if ([[self.readRecordDictionary objectForKey:current_read_production_id_cache_key(_productionType)] isEqualToString:[WXYZ_UtilsHelper formatStringWithInteger:production_id]]) {
        return YES;
    }
    return NO;
}

// 是否是当前正在播放的章节(仅限有声功能使用)
- (BOOL)isCurrentPlayingChapterWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id
{
    if ([self getReadingRecordChapter_idWithProduction_id:production_id] == chapter_id) {
        return YES;
    }
    return NO;
}

- (NSMutableDictionary *)readRecordDictionary
{
    if (!_readRecordDictionary) {
        _readRecordDictionary = [NSMutableDictionary dictionary];
    }
    
    NSMutableDictionary *t_dic = [_readRecordDictionary objectForKey:[NSString stringWithFormat:@"%@", [WXYZ_UtilsHelper formatStringWithInteger:_productionType]]];
    if (!t_dic) {
        t_dic = [NSMutableDictionary dictionaryWithContentsOfFile:[self cacheFilePath]];
        [_readRecordDictionary setObject:t_dic forKey:[NSString stringWithFormat:@"%@", [WXYZ_UtilsHelper formatStringWithInteger:_productionType]]];
    }
    
    return t_dic;
}

- (NSString *)cacheFilePath
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectOrNilAtIndex:0];
    NSString *rootFloderPath = [documentPath stringByAppendingPathComponent:[@"WXYZ_ReadingRecordFileFloder" md5String]];
    // 创建章节文件夹
    if (![[NSFileManager defaultManager] fileExistsAtPath:rootFloderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:rootFloderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *cacheFilePath = @"";
    switch (_productionType) {
        case WXYZ_ProductionTypeBook:
            cacheFilePath = [rootFloderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", [@"BookReadingRecordFile" md5String]]];
            break;
        case WXYZ_ProductionTypeComic:
            cacheFilePath = [rootFloderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", [@"ComicReadingRecordFile" md5String]]];
            break;
        case WXYZ_ProductionTypeAudio:
            cacheFilePath = [rootFloderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", [@"AudioReadingRecordFile" md5String]]];
            break;
        case WXYZ_ProductionTypeAi:
            cacheFilePath = [rootFloderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", [@"AiReadingRecordFile" md5String]]];
            break;
            
        default:
            break;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        [@{} writeToFile:cacheFilePath atomically:NO];
    }
    
    return cacheFilePath;
}

// 写入文件
- (BOOL)writeToPlistFile
{
    NSDictionary *t_dic = [self.readRecordDictionary copy];
    if (t_dic.count == 0) {
        return NO;
    }
    
    // 写入文件
    if (![t_dic writeToFile:[self cacheFilePath] atomically:NO]) {
        return NO;
    }
    return YES;
}

+ (WXYZ_BookMarkModel *)addBookMark:(NSString *)bookID chapterID:(NSString *)chapterID chapterSort:(NSInteger)chapterSort chapterTitle:(NSString *)chapterTitle chapterContent:(NSString *)chapterContent pageContent:(NSString *)pageContent {
    NSString *fullPath = [[self bookMarkRootPath] stringByAppendingFormat:@"/bookMark_%@.plist", bookID];
    NSMutableDictionary *t_dict = [NSMutableDictionary dictionaryWithContentsOfFile:fullPath];
    if (!t_dict) {
        t_dict = [NSMutableDictionary dictionary];
    }
    
    NSMutableArray<NSString *> *t_arr = t_dict[chapterID];
    if (!t_arr) {
        t_arr = [NSMutableArray array];
    }
    
    WXYZ_BookMarkModel *t_model = [[WXYZ_BookMarkModel alloc] init];
    t_model.chapterID = chapterID;
    t_model.chapterSort = chapterSort;
    t_model.chapterTitle = chapterTitle;
    t_model.timestamp = [WXYZ_UtilsHelper getTimeStamp];
    t_model.pageContent = pageContent;
    t_model.bookID = bookID;
    t_model.specificIndex = [chapterContent rangeOfString:pageContent].location;
    // 将Model转换成String
    NSString *bookMark = [t_model modelToJSONString];
    
    [t_arr addObject:bookMark];
    [t_dict setValue:t_arr forKey:chapterID];
    
    [t_dict writeToFile:fullPath atomically:YES];
    
    return t_model;
}

+ (NSArray<WXYZ_BookMarkModel *> *)bookMark:(NSString *)bookID {
    NSString *fullPath = [[self bookMarkRootPath] stringByAppendingFormat:@"/bookMark_%@.plist", bookID];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) return @[];
    
    NSMutableDictionary *t_dict = [NSMutableDictionary dictionaryWithContentsOfFile:fullPath];
    NSMutableArray<WXYZ_BookMarkModel *> *markArr = [NSMutableArray array];
    for (NSString *key in t_dict) {
        NSArray<NSString *> *t_arr = t_dict[key];
        for (NSString *obj in t_arr) {
            NSDictionary *dict = [WXYZ_UtilsHelper dictionaryWithJsonString:obj];
            WXYZ_BookMarkModel *t_model = [WXYZ_BookMarkModel modelWithDictionary:dict];
            [markArr addObject:t_model];
        }
    }
    
    return markArr;
}

+ (NSArray<WXYZ_BookMarkModel *> *)bookMark:(NSString *)bookID chapterID:(NSString *)chapterID {
    NSString *fullPath = [[self bookMarkRootPath] stringByAppendingFormat:@"/bookMark_%@.plist", bookID];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) return @[];
    
    NSMutableDictionary *t_dict = [NSMutableDictionary dictionaryWithContentsOfFile:fullPath];
    NSArray<NSString *> *t_arr = t_dict[chapterID];
    if (!t_arr) return @[];
    
    NSMutableArray<WXYZ_BookMarkModel *> *markArr = [NSMutableArray array];
    for (NSString *obj in t_arr) {
        NSDictionary *dict = [WXYZ_UtilsHelper dictionaryWithJsonString:obj];
        WXYZ_BookMarkModel *t_model = [WXYZ_BookMarkModel modelWithDictionary:dict];
        [markArr addObject:t_model];
    }
    
    return markArr;
}

+ (void)removeBookMark:(WXYZ_BookMarkModel *)markModel {
    NSString *fullPath = [[self bookMarkRootPath] stringByAppendingFormat:@"/bookMark_%@.plist", markModel.bookID];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) return;
    
    NSMutableDictionary *t_dict = [NSMutableDictionary dictionaryWithContentsOfFile:fullPath];
    NSMutableArray<NSString *> *t_arr = t_dict[markModel.chapterID];
    if (!t_arr) return;
    
    NSString *bookMark = [markModel modelToJSONString];
    [t_arr removeObject:bookMark];
    [t_dict setValue:t_arr forKey:markModel.chapterID];
    [t_dict writeToFile:fullPath atomically:YES];
}

+ (NSString *)bookMarkRootPath {
    NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    rootPath = [rootPath stringByAppendingPathComponent:@"bookMark"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:rootPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:@{} error:nil];
    }
    return rootPath;
}

- (void)setComicReadingRecord:(NSInteger)comic_id chapter_id:(NSInteger)chapter_id offsetY:(CGFloat)offsetY {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    path = [path stringByAppendingPathComponent:@"comic_record.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:[NSData data] attributes:@{}];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    NSDictionary *params = @{
        [NSString stringWithFormat:@"%zd", chapter_id] : [NSString stringWithFormat:@"%f", offsetY]
    };
    [dict setValue:params forKey:[NSString stringWithFormat:@"%zd", comic_id]];
    [dict writeToFile:path atomically:NO];
}

- (NSDictionary *)getComicReadingRecord:(NSInteger)comic_id {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    path = [path stringByAppendingPathComponent:@"comic_record.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return @{};
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    if ([dict valueForKey:[NSString stringWithFormat:@"%zd", comic_id]]) {
        return [dict valueForKey:[NSString stringWithFormat:@"%zd", comic_id]];
    } else {
        return @{};
    }
}

@end

//
//  WXYZ_DownloadHelper.m
//  WXReader
//
//  Created by Andrew on 2020/4/1.
//  Copyright © 2020 Andrew. All rights reserved.
//

/* 下载缓存结构示意
 WXYZ_DownloadFileFolder ━┳━ BookDownloadFileFolder ━┳━ WXYZ_DownloadProductionRecordFile.plist
                          ┃                          ┃
                          ┃                          ┃
                          ┃                          ┣━ 作品文件夹(production_id) ━┳━ WXYZ_DownloadChapterRecordFile.plist
                          ┃                          ┃                           ┃
                          ┃                          ┃                           ┃
                          ┃                          ┃                           ┣━ 章节文件夹(production_id + chapter_id) ━━ 对应文件 比如.txt/.jpg/.png/.mp3
                          ┃                          ┃                           ┃
                          ┃                          ┃                           ┃
                          ┃                          ┃                           ┗━ 章节文件夹(production_id + chapter_id) ━━ 对应文件 比如.txt/.jpg/.png/.mp3
                          ┃                          ┃
                          ┃                          ┗━ 作品文件夹(production_id)
                          ┃
                          ┃
                          ┣━ ComicDownloadFileFolder ━┳━ WXYZ_DownloadProductionRecordFile.plist
                          ┃                           ┃
                          ┃                           ┃
                          ┃                           ┣━ 作品文件夹(production_id) ━┳━ WXYZ_DownloadChapterRecordFile.plist
                          ┃                           ┃                           ┃
                          ┃                           ┃                           ┃
                          ┃                           ┃                           ┣━ 章节文件夹(production_id + chapter_id) ━━ 对应文件 比如.txt/.jpg/.png/.mp3
                          ┃                           ┃                           ┃
                          ┃                           ┃                           ┃
                          ┃                           ┃                           ┗━ 章节文件夹(production_id + chapter_id) ━━ 对应文件 比如.txt/.jpg/.png/.mp3
                          ┃                           ┃
                          ┃                           ┗━ 作品文件夹(production_id)
                          ┃
                          ┗━ AudioDownloadFileFolder ━┳━ WXYZ_DownloadProductionRecordFile.plist
                                                      ┃
                                                      ┃
                                                      ┣━ 作品文件夹(production_id) ━┳━ WXYZ_DownloadChapterRecordFile.plist
                                                      ┃                           ┃
                                                      ┃                           ┃
                                                      ┃                           ┣━ 章节文件夹(production_id + chapter_id) ━━ 对应文件 比如.txt/.jpg/.png/.mp3
                                                      ┃                           ┃
                                                      ┃                           ┃
                                                      ┃                           ┗━ 章节文件夹(production_id + chapter_id) ━━ 对应文件 比如.txt/.jpg/.png/.mp3
                                                      ┃
                                                      ┗━ 作品文件夹(production_id)
                          
*/


#import "WXYZ_DownloadHelper.h"

@implementation WXYZ_DownloadHelper

implementation_singleton(WXYZ_DownloadHelper)

// 作品下载记录
- (void)recordDownloadProductionWithProductionModel:(WXYZ_ProductionModel *)productionModel productionType:(WXYZ_ProductionType)productionType
{
    if (!productionModel) {
        return;
    }
    
    NSMutableArray *t_arr = [self productionRecordDownloadArrayWithProductionType:productionType];
    for (WXYZ_ProductionModel *t_model in t_arr) {
        if (t_model.production_id == productionModel.production_id) {
            return;
        }
    }
    
    [[self productionRecordDownloadArrayWithProductionType:productionType] addObject:productionModel];
    [self writeToPlistFileWithProductionType:productionType];
}

// 删除作品下载记录
- (void)removeRecordDownloadProductionWithProduction_id:(NSInteger)production_id productionType:(WXYZ_ProductionType)productionType
{
    NSMutableArray *t_arr = [[self productionRecordDownloadArrayWithProductionType:productionType] mutableCopy];
    for (WXYZ_ProductionModel *t_model in t_arr) {
        if (t_model.production_id == production_id) {
            [[self productionRecordDownloadArrayWithProductionType:productionType] removeObject:t_model];
            [self writeToPlistFileWithProductionType:productionType];
            return;
        }
    }
}

// 删除章节下载记录(返回是否成功,如果成功那么需要在对应的downloadManager中,重置记录变量,从本地重新获取)
- (BOOL)removeRecordDownloadChapterWithProduction_id:(NSInteger)production_id chapter_ids:(NSArray <NSString *>*)chapter_ids productionType:(WXYZ_ProductionType)productionType
{
    NSMutableDictionary *localCacheDic = [NSMutableDictionary dictionaryWithContentsOfFile:[[WXYZ_DownloadHelper sharedManager] getDownloadChapterRecordPlistFilePathWithProduction_id:production_id productionType:productionType]];
    for (NSString *chapter_id in chapter_ids) {
        [localCacheDic removeObjectForKey:chapterRecordKey(production_id, [chapter_id integerValue])];
    }
    
    NSMutableDictionary *save_dic = [NSMutableDictionary dictionary];
    for (NSString *key in localCacheDic.allKeys) {
        
        id value = [localCacheDic objectForKey:key];
        
        if ([value isKindOfClass:[NSClassFromString(@"WXYZ_ComicReaderModel") class]]) {
            value = [value modelToJSONString];
        }
        [save_dic setObject:value forKey:key];
    }
    
    // 写入文件
    if (![save_dic writeToFile:[self getDownloadChapterRecordPlistFilePathWithProduction_id:production_id productionType:productionType] atomically:NO]) {
        return NO;
    }
    return YES;
}

// 删除作品文件夹
- (void)removeDownloadProductionFolderWithProduction_id:(NSInteger)production_id productionType:(WXYZ_ProductionType)productionType
{
    // 删除plist文件记录
    [self removeRecordDownloadProductionWithProduction_id:production_id productionType:productionType];
    
    // 删除对应作品整体文件夹
    [[NSFileManager defaultManager] removeItemAtPath:[self getDownloadProductionFolderPathWithProduction_id:production_id productionType:productionType] error:nil];
}

// 删除章节文件夹
- (BOOL)removeDownloadChapterFolderWithProduction_id:(NSInteger)production_id chapter_ids:(NSArray <NSString *>*)chapter_ids productionType:(WXYZ_ProductionType)productionType
{
    for (NSString *chapter_id in chapter_ids) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self getDownloadChapterFolderPathWithProduction_id:production_id chapter_id:[chapter_id integerValue] productionType:productionType]]) {
            [[NSFileManager defaultManager] removeItemAtPath:[self getDownloadChapterFolderPathWithProduction_id:production_id chapter_id:[chapter_id integerValue] productionType:productionType] error:nil];            
        }
    }
    
    // 删除章节plist文件记录
    return [self removeRecordDownloadChapterWithProduction_id:production_id chapter_ids:chapter_ids productionType:productionType];
}

// 作品章节是否下载
- (BOOL)isChapterDownloadedWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id productionType:(WXYZ_ProductionType)productionType
{
    if ([[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self getDownloadChapterFolderPathWithProduction_id:production_id chapter_id:chapter_id productionType:productionType] error:nil].count > 0) {
        return YES;
    }
    return NO;
}

// 获取下载章节数
- (NSInteger)getDownloadChapterCountWithProduction_id:(NSInteger)production_id productionType:(WXYZ_ProductionType)productionType
{
    // 存在已下载章节内容文件夹数量
    CGFloat chapterDownloadNumber = 0;
    
    // 获取作品下全部章节文件夹名称
    NSArray <NSString *>*chapterFolderNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self getDownloadProductionFolderPathWithProduction_id:production_id productionType:productionType] error:nil];
    
    for (NSString *folderName in chapterFolderNames) {
        NSString *chapterFloderPath = [[self getDownloadProductionFolderPathWithProduction_id:production_id productionType:productionType] stringByAppendingPathComponent:folderName];
        
        BOOL isDirectory = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:chapterFloderPath isDirectory:&isDirectory];
        if (isDirectory && [[NSFileManager defaultManager] contentsOfDirectoryAtPath:chapterFloderPath error:nil].count > 0) {
            chapterDownloadNumber ++;
        }
    }
    
    return chapterDownloadNumber;
}

// 获取类别下的所有下载作品
- (NSArray <WXYZ_ProductionModel *> *)getDownloadProductionArrayWithProductionType:(WXYZ_ProductionType)productionType
{
    return [self productionRecordDownloadArrayWithProductionType:productionType];
}

- (WXYZ_ProductionModel *)getDownloadProductionModelWithProduction_id:(NSInteger)production_id productionType:(WXYZ_ProductionType)productionType
{
    for (WXYZ_ProductionModel *t_model in [self productionRecordDownloadArrayWithProductionType:productionType]) {
        if (t_model.production_id == production_id) {
            return t_model;
        }
    }
    return nil;
}

// 主文件夹路径
- (NSString *)getDownloadRootFolderPathWithProductionType:(WXYZ_ProductionType)productionType
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectOrNilAtIndex:0];
    
    // 主目录文件夹
    NSString *rootFolderPath = [documentPath stringByAppendingPathComponent:[WXYZ_UtilsHelper stringToMD5:@"WXYZ_DownloadFileFolder"]];
    
    // 创建章节文件夹
    if (![[NSFileManager defaultManager] fileExistsAtPath:rootFolderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:rootFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // 作品类别文件夹
    NSString *typeFolderPath = @"";
    switch (productionType) {
        case WXYZ_ProductionTypeBook: // 存储全部下载书籍
            typeFolderPath = [rootFolderPath stringByAppendingPathComponent:[WXYZ_UtilsHelper stringToMD5:@"BookDownloadFileFolder"]];
            break;
        case WXYZ_ProductionTypeComic: // 存储全部下载漫画
            typeFolderPath = [rootFolderPath stringByAppendingPathComponent:[WXYZ_UtilsHelper stringToMD5:@"ComicDownloadFileFolder"]];
            break;
        case WXYZ_ProductionTypeAudio:  // 存储全部下载听书
            typeFolderPath = [rootFolderPath stringByAppendingPathComponent:[WXYZ_UtilsHelper stringToMD5:@"AudioDownloadFileFolder"]];
            break;
            
        default:
            break;
    }
    
    // 创建章节文件夹
    if (![[NSFileManager defaultManager] fileExistsAtPath:typeFolderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:typeFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return typeFolderPath;
}

// 下载作品文件夹
- (NSString *)getDownloadProductionFolderPathWithProduction_id:(NSInteger)production_id productionType:(WXYZ_ProductionType)productionType
{
    NSString *productionFolderPath = [[self getDownloadRootFolderPathWithProductionType:productionType] stringByAppendingPathComponent:[WXYZ_UtilsHelper stringToMD5:[NSString stringWithFormat:@"%@%@", [WXYZ_UtilsHelper formatStringWithInteger:productionType], [WXYZ_UtilsHelper formatStringWithInteger:production_id]]]];
    // 创建章节文件夹
    if (![[NSFileManager defaultManager] fileExistsAtPath:productionFolderPath] && production_id != 0) {
        [[NSFileManager defaultManager] createDirectoryAtPath:productionFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return productionFolderPath;
}

// 下载章节文件夹
- (NSString *)getDownloadChapterFolderPathWithProduction_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id productionType:(WXYZ_ProductionType)productionType
{
    NSString *chapterFolderPath = [[self getDownloadProductionFolderPathWithProduction_id:production_id productionType:productionType] stringByAppendingPathComponent:[WXYZ_UtilsHelper stringToMD5:[NSString stringWithFormat:@"%@%@%@", [WXYZ_UtilsHelper formatStringWithInteger:productionType], [WXYZ_UtilsHelper formatStringWithInteger:production_id], [WXYZ_UtilsHelper formatStringWithInteger:chapter_id]]]];
    
    // 创建章节文件夹
    if (![[NSFileManager defaultManager] fileExistsAtPath:chapterFolderPath] && production_id != 0) {
        [[NSFileManager defaultManager] createDirectoryAtPath:chapterFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return chapterFolderPath;
}

// 下载作品记录文件路径
- (NSString *)getDownloadProductionRecordPlistFilePathWithProductionType:(WXYZ_ProductionType)productionType
{
    NSString *productionRecordFilePath = [[self getDownloadRootFolderPathWithProductionType:productionType] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", [WXYZ_UtilsHelper stringToMD5:@"WXYZ_DownloadProductionRecordFile"]]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:productionRecordFilePath]) {
        [@[] writeToFile:productionRecordFilePath atomically:NO];
    }
    
    return productionRecordFilePath;
}

// 下载章节记录文件路径
- (NSString *)getDownloadChapterRecordPlistFilePathWithProduction_id:(NSInteger)production_id productionType:(WXYZ_ProductionType)productionType
{
    // 记录下载状态plist文件地址
    NSString *chapterRecordFilePath = [[self getDownloadProductionFolderPathWithProduction_id:production_id productionType:productionType] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", [WXYZ_UtilsHelper stringToMD5:@"WXYZ_DownloadChapterRecordFile"]]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:chapterRecordFilePath]) {
        [@{} writeToFile:chapterRecordFilePath atomically:NO];
    }
    
    return chapterRecordFilePath;
}

// 作品记录缓存变量
static NSMutableDictionary *_productionsRecordDictionary;
- (NSMutableArray *)productionRecordDownloadArrayWithProductionType:(WXYZ_ProductionType)productionType;
{
    if (!_productionsRecordDictionary) {
        // 此全局临时变量的作用是记录不同作品的下载记录,减少了文件的读写,增加访问效率
        _productionsRecordDictionary = [NSMutableDictionary dictionary];
    }
    
    NSMutableArray *t_arr = [_productionsRecordDictionary objectForKey:[NSString stringWithFormat:@"%@", [WXYZ_UtilsHelper formatStringWithInteger:productionType]]];
    if (!t_arr) {
        
        NSMutableArray *localArr = [NSMutableArray arrayWithContentsOfFile:[self getDownloadProductionRecordPlistFilePathWithProductionType:productionType]];
        
        t_arr = [NSMutableArray array];
        
        for (NSString *json in localArr) {
            [t_arr addObject:[WXYZ_ProductionModel modelWithJSON:json]];
        }
        
        [_productionsRecordDictionary setObject:t_arr forKey:[NSString stringWithFormat:@"%@", [WXYZ_UtilsHelper formatStringWithInteger:productionType]]];
    }
    
    return t_arr;
}

// 写入作品记录文件
- (BOOL)writeToPlistFileWithProductionType:(WXYZ_ProductionType)productionType;
{
    NSMutableArray *t_downloadArr = [self productionRecordDownloadArrayWithProductionType:productionType];
    
    NSMutableArray *saveArr = [NSMutableArray array];
    
    for (WXYZ_ProductionModel *t_model in t_downloadArr) {
        [saveArr addObject:[t_model modelToJSONString]];
    }
    
    // 写入文件
    if (![saveArr writeToFile:[self getDownloadProductionRecordPlistFilePathWithProductionType:productionType] atomically:NO]) {
        return NO;
    }
    return YES;
}

// 章节记录缓存变量
static NSMutableDictionary *_chaptersRecordDictionary;
- (NSMutableDictionary *)chaptersRecordDownloadDictionaryWithProduction_id:(NSInteger)production_id productionType:(WXYZ_ProductionType)productionType modelClass:(Class)modelClass
{
    if (!_chaptersRecordDictionary) {
        // 此全局临时变量的作用是记录不同作品的下载记录,减少了文件的读写,增加访问效率
        _chaptersRecordDictionary = [NSMutableDictionary dictionary];
    }
    
    NSMutableDictionary *t_dic = [_chaptersRecordDictionary objectForKey:[NSString stringWithFormat:@"%@", [WXYZ_UtilsHelper formatStringWithInteger:production_id]]];
    if (!t_dic || t_dic.count == 0) {
        
        NSMutableDictionary *localDic = [NSMutableDictionary dictionaryWithContentsOfFile:[self getDownloadChapterRecordPlistFilePathWithProduction_id:production_id productionType:productionType]];
        
        t_dic = [NSMutableDictionary dictionary];
        for (NSString *key in localDic.allKeys) {
            id value = [localDic objectForKey:key];
            if ([value isKindOfClass:[NSDictionary class]]) {
                [t_dic setObject:value forKey:key];
            } else if ([value isEqualToString:identify_fail]) {
                [t_dic setObject:value forKey:key];
            } else if (![value isEqual:identify_downloading] && value) {
                [t_dic setObject:[modelClass modelWithJSON:value] forKey:key];
            }
        }
        
        [_chaptersRecordDictionary setObject:t_dic forKey:[NSString stringWithFormat:@"%@", [WXYZ_UtilsHelper formatStringWithInteger:production_id]]];
    }
    
    return t_dic;
}

// 写入章节记录文件
- (BOOL)writeToChapterPlistFileWithProduction_id:(NSInteger)production_id productionType:(WXYZ_ProductionType)productionType modelClass:(Class)modelClass
{
    NSMutableDictionary *t_downloadDic = [self chaptersRecordDownloadDictionaryWithProduction_id:production_id productionType:productionType modelClass:modelClass];
    if (t_downloadDic.count == 0) {
        return NO;
    }
    
    NSMutableDictionary *save_dic = [NSMutableDictionary dictionary];
    for (NSString *key in t_downloadDic.allKeys) {
        
        id value = [t_downloadDic objectForKey:key];
        
        if ([value isKindOfClass:[modelClass class]]) {
            value = [value modelToJSONString];
        }
        [save_dic setObject:value forKey:key];
    }
    
    // 写入文件
    if (![save_dic writeToFile:[self getDownloadChapterRecordPlistFilePathWithProduction_id:production_id productionType:productionType] atomically:NO]) {
        return NO;
    }
    return YES;
}

@end

//
//  WXYZ_ProductionCollectionManager.m
//  WXReader
//
//  Created by Andrew on 2020/3/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ProductionCollectionManager.h"

@interface WXYZ_ProductionCollectionManager ()

@end

@implementation WXYZ_ProductionCollectionManager

static WXYZ_ProductionType _productionTypeCollection;
static WXYZ_ProductionCollectionManager *_instance_collection;
+ (instancetype)shareManagerWithProductionType:(WXYZ_ProductionType)productionType
{
    static dispatch_once_t once_token_collection;
    dispatch_once(&once_token_collection, ^{
        _instance_collection = [[self alloc] init];
    });
    _productionTypeCollection = productionType;
    return _instance_collection;
}

#pragma add

// 添加收藏作品
- (BOOL)addCollectionWithProductionModel:(WXYZ_ProductionModel *)productionModel
{
    return [self addCollectionWithProductionModel:productionModel atIndex:0];
}

- (BOOL)addCollectionWithProductionModel:(WXYZ_ProductionModel *)productionModel atIndex:(NSInteger)index
{
    if (!productionModel) {
        return NO;
    }
    
    // 已存储
    if ([self isCollectedWithProductionModel:productionModel]) {
        return NO;
    }
    
    if (self.collectionArray.count == 0) {
        [self.collectionArray addObject:productionModel];
    } else {
        
        if (index < 0) {
            index = 0;
        } else if (index > self.collectionArray.count - 1) {
            index = self.collectionArray.count - 1;
        }
        [self.collectionArray insertObject:productionModel atIndex:index];
    }
    
    // 写入文件
    return [self writeToPlistFile];
}

#pragma delete

// 删除收藏作品
- (BOOL)removeCollectionWithProductionModel:(WXYZ_ProductionModel *)productionModel
{
    WXYZ_ProductionModel *t_model = [self isCollectedWithProductionModel:productionModel];
    return [self removeCollectionWithProduction_id:t_model.production_id];
}

// 删除收藏作品
- (BOOL)removeCollectionWithProduction_id:(NSInteger)production_id
{
    if (![self isCollectedWithProduction_id:production_id]) {
        // 本地无记录无法删除
        return NO;
    }
    
    for (WXYZ_ProductionModel *t_model in self.collectionArray) {
        if (t_model.production_id == production_id) {
            [self.collectionArray removeObject:t_model];
            break;
        }
    }
    // 写入文件
    return [self writeToPlistFile];
}

// 删除全部收藏作品
- (BOOL)removeAllCollection
{
    [self.collectionArray removeAllObjects];
    
    [[NSFileManager defaultManager] removeItemAtPath:[self cacheFilePath] error:nil];
    
    // 写入文件
    return [self writeToPlistFile];
}

#pragma change

// 修改本地作品记录
- (BOOL)modificationCollectionWithProductionModel:(WXYZ_ProductionModel *)productionModel
{
    // 本地记录不存在,无法删除
    if (![self isCollectedWithProductionModel:productionModel]) {
        return NO;
    }
    
    for (int i = 0; i < self.collectionArray.count; i ++) {
        WXYZ_ProductionModel *t_model = [self.collectionArray objectAtIndex:i];
        if (t_model.production_id == productionModel.production_id) {
            [self.collectionArray replaceObjectAtIndex:i withObject:productionModel];
            break;
        }
    }
    
    // 写入文件
    return [self writeToPlistFile];
}

// 移动当前作品记录到首位
- (void)moveCollectionToTopWithProductionModel:(WXYZ_ProductionModel *)productionModel
{
    WXYZ_ProductionModel *t_model = [self isCollectedWithProductionModel:productionModel];
    if (!t_model) {
        return;
    }
    
    if (self.collectionArray.count == 1) {
        return;
    }
    
    for (WXYZ_ProductionModel *tt_model in self.collectionArray) {
        if (tt_model.production_id == productionModel.production_id) {
            [self.collectionArray removeObject:tt_model];
            [self.collectionArray insertObject:tt_model atIndex:0];
            break;
        }
    }
    
    [self writeToPlistFile];
}

#pragma check

// 本地全部作品记录
- (NSArray <WXYZ_ProductionModel *> *)getAllCollection
{
    return [self.collectionArray mutableCopy];
}

// 此作品是否已收藏
- (WXYZ_ProductionModel * _Nullable)isCollectedWithProductionModel:(WXYZ_ProductionModel *)productionModel
{
    if (self.collectionArray.count <= 0) {
        return nil;
    }
    
    if (!productionModel) {
        return nil;
    }
    
    for (WXYZ_ProductionModel *t_model in self.collectionArray) {
        if (t_model.production_id == productionModel.production_id) {
            return t_model;
        }
    }
    
    return nil;
}

- (WXYZ_ProductionModel *)getCollectedProductionModelWithProduction_id:(NSInteger)production_id
{
    if (self.collectionArray.count <= 0) {
        return nil;
    }
    
    if (production_id == 0) {
        return nil;
    }
    
    for (WXYZ_ProductionModel *t_model in self.collectionArray) {
        if (t_model.production_id == production_id) {
            return t_model;
        }
    }
    
    return nil;
}

// 此作品是否已收藏
- (BOOL)isCollectedWithProduction_id:(NSInteger)production_id
{
    if (self.collectionArray.count <= 0) {
        return NO;
    }
    
    for (WXYZ_ProductionModel *t_model in self.collectionArray) {
        if (t_model.production_id == production_id) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - private
static NSMutableDictionary *collectionDictionary;
- (NSMutableArray *)collectionArray
{
    if (!collectionDictionary) {
        collectionDictionary = [NSMutableDictionary dictionary];
    }
    
    NSMutableArray *t_arr = [collectionDictionary objectForKey:[WXYZ_UtilsHelper formatStringWithInteger:_productionTypeCollection]];
    if (!t_arr) {
        
        NSMutableArray *localDataArray = [NSMutableArray arrayWithContentsOfFile:[self cacheFilePath]];
        
        t_arr = [NSMutableArray array];
        for (NSString *modelJsong in localDataArray) {
            [t_arr addObject:[WXYZ_ProductionModel modelWithJSON:modelJsong]];
        }
        
        [collectionDictionary setObject:t_arr forKey:[NSString stringWithFormat:@"%@", [WXYZ_UtilsHelper formatStringWithInteger:_productionTypeCollection]]];
        
    }
    
    return t_arr;
}

- (NSString *)cacheFilePath
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectOrNilAtIndex:0];
    NSString *rootFloderPath = [documentPath stringByAppendingPathComponent:[@"WXYZ_ProductionCollectionFileFloder" md5String]];
    // 创建章节文件夹
    if (![[NSFileManager defaultManager] fileExistsAtPath:rootFloderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:rootFloderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *cacheFilePath = @"";
    switch (_productionTypeCollection) {
        case WXYZ_ProductionTypeBook:
            cacheFilePath = [rootFloderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", [@"BookCollectionFile" md5String]]];
            break;
        case WXYZ_ProductionTypeComic:
            cacheFilePath = [rootFloderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", [@"ComicCollectionFile" md5String]]];
            break;
        case WXYZ_ProductionTypeAudio:
            cacheFilePath = [rootFloderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", [@"AudioCollectionFile" md5String]]];
            break;
        case WXYZ_ProductionTypeAi:
            cacheFilePath = [rootFloderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", [@"AiCollectionFile" md5String]]];
            break;
            
        default:
            break;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        [@[] writeToFile:cacheFilePath atomically:NO];
    }
    
    return cacheFilePath;
}

// 写入文件
- (BOOL)writeToPlistFile
{
    NSMutableArray *t_arr = [NSMutableArray array];
    
    for (WXYZ_ProductionModel *t_model in self.collectionArray) {
        [t_arr addObject:[t_model modelToJSONString]];
    }
    
    // 写入文件
    if (![t_arr writeToFile:[self cacheFilePath] atomically:NO]) {
        return NO;
    }
    return YES;
}

@end

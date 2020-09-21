//
//  WXYZ_ProductionCollectionManager.h
//  WXReader
//
//  Created by Andrew on 2020/3/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ProductionCollectionManager : NSObject

+ (instancetype)shareManagerWithProductionType:(WXYZ_ProductionType)productionType;

#pragma add

// 添加收藏作品
- (BOOL)addCollectionWithProductionModel:(WXYZ_ProductionModel *)productionModel;

- (BOOL)addCollectionWithProductionModel:(WXYZ_ProductionModel *)productionModel atIndex:(NSInteger)index;

#pragma delete

// 删除收藏作品
- (BOOL)removeCollectionWithProductionModel:(WXYZ_ProductionModel *)productionModel;

- (BOOL)removeCollectionWithProduction_id:(NSInteger)production_id;

// 删除全部收藏作品
- (BOOL)removeAllCollection;

#pragma change
// 修改本地作品记录
- (BOOL)modificationCollectionWithProductionModel:(WXYZ_ProductionModel *)productionModel;

// 移动当前作品记录到首位
- (void)moveCollectionToTopWithProductionModel:(WXYZ_ProductionModel *)productionModel;

#pragma check

// 本地全部作品记录
- (NSArray <WXYZ_ProductionModel *> *)getAllCollection;

// 此作品是否已收藏
- (WXYZ_ProductionModel * _Nullable)isCollectedWithProductionModel:(WXYZ_ProductionModel *)productionModel;

// 获取作品收藏记录
- (WXYZ_ProductionModel *)getCollectedProductionModelWithProduction_id:(NSInteger)production_id;

// 此作品是否已收藏
- (BOOL)isCollectedWithProduction_id:(NSInteger)production_id;

@end

NS_ASSUME_NONNULL_END

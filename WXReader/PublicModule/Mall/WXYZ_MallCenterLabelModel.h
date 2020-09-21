//
//  WXYZ_MallCenterLabelModel.h
//  WXReader
//
//  Created by Andrew on 2019/6/14.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXYZ_ADModel.h"

NS_ASSUME_NONNULL_BEGIN

@class WXYZ_ProductionModel;

@interface WXYZ_MallCenterLabelModel : WXYZ_ADModel

@property (nonatomic, assign) NSInteger recommend_id; // 推荐位id

@property (nonatomic, assign) NSInteger style; // 展示风格

@property (nonatomic, copy) NSString *label; // 名称

@property (nonatomic, copy) NSString *total; // 漫画数

@property (nonatomic, assign) BOOL can_more; // 是否有更多 true有，false没有

@property (nonatomic, assign) BOOL can_refresh; // 是否有更多 true有，false没有

@property (nonatomic, assign) NSInteger expire_time;

@property (nonatomic, strong) NSArray <WXYZ_ProductionModel *>*list; // 作品列表

@end

NS_ASSUME_NONNULL_END

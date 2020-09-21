//
//  WXYZ_ComicMallDetailModel.m
//  WXReader
//
//  Created by Andrew on 2019/5/28.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicMallDetailModel.h"
#import "WXYZ_MallCenterLabelModel.h"

@implementation WXYZ_ComicMallDetailModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"comment" : [WXYZ_CommentsDetailModel class],
             @"label" : [WXYZ_MallCenterLabelModel class],
             @"advert" : [WXYZ_ADModel class],
             @"productionModel":[WXYZ_ProductionModel class]
             };
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"productionModel"  :@"comic"
             };
}

@end

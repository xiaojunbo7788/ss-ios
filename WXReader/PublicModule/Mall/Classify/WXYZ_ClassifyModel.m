//
//  WXYZ_ClassifyModel.m
//  WXReader
//
//  Created by Andrew on 2019/6/17.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ClassifyModel.h"

@implementation WXYZ_ClassifyModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass
{
    return @{@"search_box" : [WXYZ_SearchBoxModel class]
             };
}

+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{@"classList":@"list"};
}

@end

@implementation WXYZ_SearchBoxModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"searchList" : [WXYZ_SearchOptionListModel class]};
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"searchList"    :@"list"
             };
}

@end

@implementation WXYZ_SearchOptionListModel

@end

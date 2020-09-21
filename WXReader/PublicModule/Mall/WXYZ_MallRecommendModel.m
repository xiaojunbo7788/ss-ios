//
//  WXYZ_MallRecommendModel.m
//  WXReader
//
//  Created by Andrew on 2019/6/20.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_MallRecommendModel.h"

@implementation WXYZ_MallRecommendModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"recommendTitle":@"recommend.title",
             @"recommendList": @[@"list", @"book"]
             };
}

@end

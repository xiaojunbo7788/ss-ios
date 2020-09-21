//
//  WXYZ_SearchModel.m
//  WXReader
//
//  Created by Andrew on 2018/7/5.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_SearchModel.h"

@implementation WXYZ_SearchModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"list" : [WXYZ_ProductionModel class]};
}


@end

//
//  WXYZ_InsterestBookModel.m
//  WXReader
//
//  Created by Andrew on 2018/11/21.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "WXYZ_InsterestBookModel.h"

@implementation WXYZ_InsterestBookModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass
{
    return @{@"book" : [WXYZ_ProductionModel class], @"comic" : [WXYZ_ProductionModel class], @"audio": [WXYZ_ProductionModel class]};
 }

@end

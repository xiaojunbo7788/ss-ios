//
//  WXYZ_SignModel.m
//  WXReader
//
//  Created by Andrew on 2019/7/1.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_SignModel.h"

@implementation WXYZ_SignModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"book" : [WXYZ_ProductionModel class],
             @"comic" : [WXYZ_ProductionModel class],
             @"audio" : [WXYZ_ProductionModel class]
             };
}

@end

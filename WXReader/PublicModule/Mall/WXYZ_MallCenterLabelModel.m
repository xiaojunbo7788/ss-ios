//
//  WXYZ_MallCenterLabelModel.m
//  WXReader
//
//  Created by Andrew on 2019/6/14.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_MallCenterLabelModel.h"

@implementation WXYZ_MallCenterLabelModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"list" : [WXYZ_ProductionModel class]};
}

@end

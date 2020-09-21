//
//  WXYZ_ProductionListModel.m
//  WXReader
//
//  Created by Andrew on 2019/6/17.
//  Copyright © 2019 Andrew. All rights reserved.
//


@implementation WXYZ_ProductionListModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"list" : [WXYZ_ProductionModel class]};
}

@end

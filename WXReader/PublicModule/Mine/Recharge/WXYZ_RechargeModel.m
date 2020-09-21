//
//  WXYZ_RechargeModel.m
//  WXReader
//
//  Created by Andrew on 2018/7/4.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_RechargeModel.h"



@implementation WXYZ_RechargeModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"list" : [WXYZ_GoodsModel class],
             @"user"  : [WXYZ_UserInfoManager class]
             };
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"list"  :@"items",
             @"goldUnit"  :@"unit_tag.currencyUnit",
             @"silverUnit"  :@"unit_tag.subUnit"
             };
}

@end

@implementation WXYZ_GoodsModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{
             @"tag" : [WXYZ_TagModel class],
             @"pal_channel":[WXYZ_PayModel class]
             };
}

@end

@implementation WXYZ_PayModel

@end

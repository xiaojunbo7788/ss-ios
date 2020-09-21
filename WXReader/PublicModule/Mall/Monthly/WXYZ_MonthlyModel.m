//
//  WXYZ_MonthlyModel.m
//  WXReader
//
//  Created by Andrew on 2018/6/15.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_MonthlyModel.h"

@implementation WXYZ_MonthlyModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"privilege" : [WXYZ_PrivilegeModel class],
             @"banner"  : [WXYZ_BannerModel class],
             @"label"   : [WXYZ_MallCenterLabelModel class]
    };
}

@end

@implementation WXYZ_MonthlyInfoModel


@end

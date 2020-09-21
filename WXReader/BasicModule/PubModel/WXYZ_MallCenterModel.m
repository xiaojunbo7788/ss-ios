//
//  WXYZ_MallCenterModel.m
//  WXReader
//
//  Created by Andrew on 2019/5/25.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_MallCenterLabelModel.h"

#import "WXYZ_UserCenterModel.h"

@implementation WXYZ_MallCenterModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"banner" : [WXYZ_BannerModel class],
             @"label" : [WXYZ_MallCenterLabelModel class],
             @"menus_tabs": [WXYZ_MallCenterMenusModel class]
    };
}

@end


@implementation WXYZ_MallCenterMenusModel

@end

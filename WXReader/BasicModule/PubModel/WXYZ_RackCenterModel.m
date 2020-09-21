//
//  WXYZ_RackCenterModel.m
//  WXReader
//
//  Created by Andrew on 2019/6/13.
//  Copyright © 2019 Andrew. All rights reserved.
//


@implementation WXYZ_RackCenterModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"rackDescription" :@"description",
             @"announcement":@[@"announce", @"announcement"],
             @"recommendList":@[@"recommend_list", @"recommend"],
             @"productionList":@[@"list"]
             };
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"announcement" : [WXYZ_AnnouncementModel class], @"recommendList" : [WXYZ_ProductionModel class], @"productionList":[WXYZ_ProductionModel class]};
}

@end

@implementation WXYZ_BaseInfoModel

@end

@implementation WXYZ_AnnouncementModel

@end

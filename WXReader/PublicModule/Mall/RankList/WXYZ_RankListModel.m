//
//  WXYZ_RankListModel.m
//  WXReader
//
//  Created by Andrew on 2018/6/14.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_RankListModel.h"

@implementation WXYZ_RankListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"rankDescription"    :@[@"description", @"desc"],
             @"list_name"          :@[@"list_name", @"title"]
             };
}

@end

//
//  WXYZ_MemeberModel.m
//  WXReader
//
//  Created by Andrew on 2018/7/19.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_MemeberModel.h"
#import "WXYZ_RechargeModel.h"

@implementation WXYZ_MemeberModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"list" : [WXYZ_GoodsModel class], @"privilege" : [WXYZ_PrivilegeModel class]};
}

- (BOOL)thirdOn {
    return true;
}

@end

@implementation WXYZ_PrivilegeModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"production_descirption"  :@"description",
             @"visited"             :@"view",
             @"record_title"        :@"chapter_title",
             @"production_id"       :@[@"book_id", @"comic_id", @"audio_id"],
             @"name"                :@[@"name", @"title", @"book_name", @"comic_name", @"audio_name"],
             @"total_chapters"      :@[@"total_chapters", @"total_chapter"]
             };
}

@end

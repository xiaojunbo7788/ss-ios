//
//  WXYZ_GiftMonthlyPassModel.m
//  WXReader
//
//  Created by LL on 2020/5/28.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_GiftMonthlyPassModel.h"

@implementation WXYZ_GiftMonthlyPassModel

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"info" : @"ticket_info",
        @"list" : @"ticket_option"
    };
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{
        @"info" : WXYZ_GiftMonthlyPassInfoModel.class,
        @"list" : WXYZ_GiftMonthlyPassListModel.class
    };
}

@end


@implementation WXYZ_GiftMonthlyPassInfoModel

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"stickerNumber" : @"current_month_get",
        @"ranking" : @"rank_tips",
        @"ticket_remain" : @"user_remain",
    };
}

@end


@implementation WXYZ_GiftMonthlyPassListModel

@end

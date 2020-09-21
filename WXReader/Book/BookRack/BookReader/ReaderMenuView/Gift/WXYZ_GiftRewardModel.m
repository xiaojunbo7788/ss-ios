//
//  WXYZ_GiftRewardList.m
//  WXReader
//
//  Created by LL on 2020/5/28.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_GiftRewardModel.h"

@implementation WXYZ_GiftRewardModel

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"list" : @"gift_option",
        @"announce_list" : @"broadcast_list"
    };
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{
        @"list" : WXYZ_GiftRewardListModel.class
    };
}

@end


@implementation WXYZ_GiftRewardListModel

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"awardTitle" : @"award_money"
    };
}

@end


@implementation WXYZ_GiftUserModel

@end

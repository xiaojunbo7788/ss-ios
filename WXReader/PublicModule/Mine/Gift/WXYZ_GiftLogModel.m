//
//  WXYZ_GiftLogModel.m
//  WXReader
//
//  Created by LL on 2020/6/2.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_GiftLogModel.h"

@implementation WXYZ_GiftLogModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{
        @"list" : WXYZ_GiftLogListModel.class
    };
}

@end


@implementation WXYZ_GiftLogListModel

@end

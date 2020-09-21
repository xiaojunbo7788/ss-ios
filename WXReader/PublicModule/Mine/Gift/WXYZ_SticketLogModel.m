//
//  WXYZ_SticketLogModel.m
//  WXReader
//
//  Created by LL on 2020/6/1.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_SticketLogModel.h"

@implementation WXYZ_SticketLogModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{
        @"list" : WXYZ_SticketLogListModel.class
    };
}

@end


@implementation WXYZ_SticketLogListModel

@end

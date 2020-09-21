//
//  WXYZ_TickectAlertModel.m
//  WXReader
//
//  Created by LL on 2020/6/1.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_TickectAlertModel.h"

@implementation WXYZ_TickectAlertModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{
        @"items" : WXYZ_TickectAlertItemsModel.class
    };
}

@end


@implementation WXYZ_TickectAlertItemsModel

@end

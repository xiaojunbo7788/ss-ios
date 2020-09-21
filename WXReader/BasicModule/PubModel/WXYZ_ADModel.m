//
//  WXYZ_ADModel.m
//  WXReader
//
//  Created by Andrew on 2019/6/27.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ADModel.h"

@implementation WXYZ_ADModel

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"timestamp" : @"time"
    };
}

@end

//
//  WXYZ_AboutModel.m
//  WXReader
//
//  Created by Andrew on 2018/10/15.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "WXYZ_AboutModel.h"

@implementation WXYZ_AboutModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{
             @"about" : [WXYZ_ContactInfoModel class]
             };
}

@end

@implementation WXYZ_ContactInfoModel



@end

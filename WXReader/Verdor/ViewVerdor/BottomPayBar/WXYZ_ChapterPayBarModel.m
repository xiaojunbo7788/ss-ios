//
//  WXYZ_ChapterPayBarModel.m
//  WXReader
//
//  Created by Andrew on 2018/7/15.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_ChapterPayBarModel.h"

@implementation WXYZ_ChapterPayBarModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"pay_options" : [WXYZ_ChapterPayBarOptionModel class]};
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"pay_options"  :@"buy_option"
             };
}

@end

@implementation WXYZ_ChapterPayBarInfoModel

@end


@implementation WXYZ_ChapterPayBarOptionModel

@end


@implementation Actual_Cost

@end


@implementation Original_Cost

@end

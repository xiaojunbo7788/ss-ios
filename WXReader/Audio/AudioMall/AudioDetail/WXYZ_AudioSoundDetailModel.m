//
//  WXYZ_AudioSoundDetailModel.m
//  WXReader
//
//  Created by Andrew on 2020/3/12.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AudioSoundDetailModel.h"

@implementation WXYZ_AudioSoundDetailModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{
             @"audio" : [WXYZ_ProductionModel class]
             };
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"color"  :@"audio.color",
             @"is_vip" :@"user.is_vip"
             };
}


@end

//
//  WXYZ_AudioSoundRecommendedModel.m
//  WXReader
//
//  Created by Andrew on 2020/3/17.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AudioSoundRecommendedModel.h"

@implementation WXYZ_AudioSoundRecommendedModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"list" : [WXYZ_AudioSoundPlayPageModel class]};
}

@end

@implementation WXYZ_AudioSoundPlayPageModel

@end

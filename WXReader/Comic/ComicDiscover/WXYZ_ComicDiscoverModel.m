//
//  WXYZ_ComicDiscoverModel.m
//  WXReader
//
//  Created by Andrew on 2019/6/12.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicDiscoverModel.h"

@implementation WXYZ_ComicDiscoverModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"banner" : [WXYZ_BannerModel class]};
}

@end



//
//  WXYZ_ComicBarrageModel.m
//  WXReader
//
//  Created by LL on 2020/5/11.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ComicBarrageModel.h"

@implementation WXYZ_ComicBarrageModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{
        @"list" : WXYZ_ComicBarrageList.class
    };
}

@end


@implementation WXYZ_ComicBarrageList

@end

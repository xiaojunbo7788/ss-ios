//
//  WXYZ_CommentsModel.m
//  WXReader
//
//  Created by Andrew on 2018/6/26.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_CommentsModel.h"

@implementation WXYZ_CommentsModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"list" : [WXYZ_CommentsDetailModel class]};
}

@end

@implementation WXYZ_CommentsDetailModel

@end

//
//  WXYZ_BookDetailModel.m
//  WXReader
//
//  Created by Andrew on 2018/5/23.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BookDetailModel.h"
#import "WXYZ_MallCenterLabelModel.h"

@implementation WXYZ_BookDetailModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"label" : [WXYZ_MallCenterLabelModel class], @"comment" : [WXYZ_CommentsDetailModel class], @"advert":[WXYZ_ADModel class]};
}

@end

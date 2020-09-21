//
//  WXYZ_BookBackSideModel.m
//  WXReader
//
//  Created by Andrew on 2020/5/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BookBackSideModel.h"
#import "WXYZ_MallCenterLabelModel.h"

@implementation WXYZ_BookBackSideModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"guess_like" : [WXYZ_MallCenterLabelModel class]};
}

@end

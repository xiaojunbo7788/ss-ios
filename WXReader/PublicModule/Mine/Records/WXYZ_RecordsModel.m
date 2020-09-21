//
//  WXYZ_RecordsModel.m
//  WXReader
//
//  Created by Andrew on 2018/7/12.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_RecordsModel.h"

@implementation WXYZ_RecordsModel
+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"list" : [WXBookRecordsListModel class]};
}
@end

@implementation WXBookRecordsListModel

@end

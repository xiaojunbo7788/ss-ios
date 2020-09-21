//
//  WXYZ_TaskModel.m
//  WXReader
//
//  Created by Andrew on 2018/11/15.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "WXYZ_TaskModel.h"

@implementation WXYZ_TaskModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"task_menu" : [WXYZ_TaskMenuModel class]};
}


@end

@implementation WXYZ_SignInfoModel


@end

@implementation WXYZ_TaskMenuModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"task_list" : [WXYZ_TaskListModel class]};
}


@end


@implementation WXYZ_TaskListModel


@end

//
//  WXYZ_UserDataModel.m
//  WXReader
//
//  Created by LL on 2020/6/5.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_UserDataModel.h"

@implementation WXYZ_UserDataModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    NSMutableArray<NSArray <WXYZ_UserDataListModel *> *> *t_list = [NSMutableArray array];
    NSArray *t_arr = dictionary[@"panel_list"];
    for (NSArray *obj in t_arr) {
        NSArray<WXYZ_UserDataListModel *> *arr = [NSArray modelArrayWithClass:WXYZ_UserDataListModel.class json:obj];
        [t_list addObject:arr];
    }
    WXYZ_UserDataModel *t_model = [[self alloc] init];
    t_model.panel_list = [t_list copy];
    return t_model;
}

@end


@implementation WXYZ_UserDataListModel

@end

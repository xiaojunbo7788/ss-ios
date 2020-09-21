//
//  WXYZ_MemeberModel.h
//  WXReader
//
//  Created by Andrew on 2018/7/19.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXYZ_MemeberModel.h"

@class WXYZ_MonthlyInfoModel, WXYZ_GoodsModel, WXYZ_PrivilegeModel;

@interface WXYZ_MemeberModel : NSObject

@property (nonatomic, strong) NSArray<WXYZ_PrivilegeModel *> *privilege;

@property (nonatomic, strong) WXYZ_MonthlyInfoModel *user;

@property (nonatomic, strong) NSArray<WXYZ_GoodsModel *> *list;

@property (nonatomic, strong) NSArray<NSString *> *about; // 提示

@property (nonatomic, assign) BOOL thirdOn;

@end

@interface WXYZ_PrivilegeModel : NSObject

@property (nonatomic, copy) NSString *label;

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *action;

@end

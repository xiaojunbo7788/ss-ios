//
//  WXYZ_TaskModel.h
//  WXReader
//
//  Created by Andrew on 2018/11/15.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WXYZ_TaskMenuModel, WXYZ_TaskListModel, WXYZ_SignInfoModel;

@interface WXYZ_TaskModel : NSObject

@property (nonatomic, strong) WXYZ_SignInfoModel *sign_info;

@property (nonatomic, strong) NSArray <WXYZ_TaskMenuModel *>*task_menu;

@end

@interface WXYZ_SignInfoModel : NSObject

@property (nonatomic, assign) NSInteger sign_status;

@property (nonatomic, strong) NSArray *sign_rules;

@property (nonatomic, copy) NSString *unit;

@property (nonatomic, assign) NSInteger max_award;

@property (nonatomic, assign) NSInteger sign_days;

@end

@interface WXYZ_TaskMenuModel : NSObject

@property (nonatomic, copy) NSString *task_title;

@property (nonatomic, strong) NSArray <WXYZ_TaskListModel *>*task_list;

@end

@interface WXYZ_TaskListModel : NSObject

@property (nonatomic, copy) NSString *task_award;

@property (nonatomic, copy) NSString *task_label;

@property (nonatomic, copy) NSString *task_desc;

@property (nonatomic, assign) NSInteger task_state;

@property (nonatomic, assign) NSInteger task_id;

@property (nonatomic, copy) NSString *task_action;

@end



NS_ASSUME_NONNULL_END

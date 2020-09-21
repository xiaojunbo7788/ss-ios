//
//  WXYZ_UserCenterModel.h
//  WXReader
//
//  Created by LL on 2020/6/5.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXYZ_UserCenterListModel;

NS_ASSUME_NONNULL_BEGIN

/// 个人中心首页Model
@interface WXYZ_UserCenterModel : NSObject <NSMutableCopying>

@property (nonatomic, copy) NSString *nickname;

@property (nonatomic, copy) NSString *avatar;

@property (nonatomic, copy) NSString *user_token;

/// 主货币单位
@property (nonatomic, copy) NSString *masterUnit;

/// 主货币数量
@property (nonatomic, assign) NSInteger masterRemain;

/// 子货币单位
@property (nonatomic, copy) NSString *subUnit;

/// 子货币数量
@property (nonatomic, assign) NSInteger subRemain;

/// 月票余额
@property (nonatomic, assign) NSInteger ticketRemain;

@property (nonatomic, assign, getter=isVip) BOOL vip;

@property (nonatomic, copy) NSString *mobile;

@property (nonatomic, assign) NSInteger uid;

@property (nonatomic, assign) NSInteger gender;

/// 列表信息
@property (nonatomic, copy) NSArray<NSArray <WXYZ_UserCenterListModel *> *> *panel_list;

@property (nonatomic, copy) NSMutableArray<NSArray <WXYZ_UserCenterListModel *> *> *panelNewList;

@end


/// 个人中心列表信息
@interface WXYZ_UserCenterListModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *desc;

/// 16进制颜色
@property (nonatomic, copy) NSString *title_color;

/// 16进制颜色
@property (nonatomic, copy) NSString *desc_color;

@property (nonatomic, copy) NSString *icon;

/// 动作类型
@property (nonatomic, copy) NSString *action;

@property (nonatomic, copy) NSString *content;

/// 点击状态
@property (nonatomic, assign, getter=isEnable) BOOL enable;

@property (nonatomic, assign) NSInteger group_id;

@end

NS_ASSUME_NONNULL_END

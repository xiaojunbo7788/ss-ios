//
//  WXYZ_UserInfoManager.h
//  WXReader
//
//  Created by LL on 2020/6/5.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_UserInfoManager : NSObject<NSCopying, NSMutableCopying>

@property (nonatomic, copy) NSString *token;

@property (nonatomic, assign) NSInteger uid;

@property (nonatomic, copy) NSString *nickname;

@property (nonatomic, copy) NSString *mobile;

@property (nonatomic, copy) NSString *avatar;

/// 0：未知，1：女，2：男
@property (nonatomic, assign) NSInteger gender;

@property (nonatomic, assign, getter=isVip) BOOL vip;

/// 主货币余额
@property (nonatomic, assign) NSInteger masterRemain;

/// 子货币余额
@property (nonatomic, assign) NSInteger subRemain;

/// 月票余额
@property (nonatomic, assign) NSInteger ticketRemain;

/// 总余额
@property (nonatomic, assign) NSInteger totalRemain;

/// 自动订阅开启状态
@property (nonatomic, assign) BOOL auto_sub;

/// 登录状态
@property (nonatomic, assign, class, readonly, getter=isLogin) BOOL login;

//清晰度 0 标清 1超清
@property (nonatomic, assign) NSInteger clearData;
//线路  0 普通线路 1 VIP线路
@property (nonatomic, assign) NSInteger lineData;

/// 更新Model数据，会自动同步本地数据。
/// @param dict dict
+ (instancetype)updateWithDict:(NSDictionary *)dict;

+ (instancetype)shareInstance;

+ (instancetype)logout;

+ (instancetype)allocWithZone:(struct _NSZone *)zone UNAVAILABLE_ATTRIBUTE;

+ (instancetype)alloc UNAVAILABLE_ATTRIBUTE;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END

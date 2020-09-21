//
//  WXYZ_WechatManager.h
//  WXReader
//
//  Created by Andrew on 2019/3/30.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXYZ_MineUserModel;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WXYZ_WechatState) {
    WXYZ_WechatStateLogin,
    WXYZ_WechatStateBinding
};

@protocol WXYZ_WeChatManagerDelegate <NSObject>

@optional

// 登录成功
- (void)wechatResponseSuccess:(WXYZ_UserInfoManager *)userData;

// 登录失败
- (void)wechatResponseFail:(NSString *)error;

@end

@interface WXYZ_WechatManager : NSObject

@property (nonatomic, weak) id <WXYZ_WeChatManagerDelegate> delegate;

interface_singleton

- (void)tunedUpWechatWithState:(WXYZ_WechatState)wechatState;

+ (BOOL)isInstallWechat;

@end

NS_ASSUME_NONNULL_END

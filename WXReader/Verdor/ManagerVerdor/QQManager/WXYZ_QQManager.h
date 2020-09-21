//
//  WXYZ_QQManager.h
//  WXReader
//
//  Created by Chair on 2019/11/22.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WXYZ_QQState) {
    WXYZ_QQStateLogin,
    WXYZ_QQStateBinding
};

@protocol WXYZ_QQManagerDelegate <NSObject>

@optional

// 登录成功
- (void)qqResponseSuccess:(WXYZ_UserInfoManager *)userData;

// 登录失败
- (void)qqResponseFail:(NSString *)error;

@end

@interface WXYZ_QQManager : NSObject

@property (nonatomic, weak) id <WXYZ_QQManagerDelegate> delegate;

interface_singleton

- (void)tunedUpQQWithState:(WXYZ_QQState)qqState;

+ (BOOL)isInstallQQ;

@end

NS_ASSUME_NONNULL_END

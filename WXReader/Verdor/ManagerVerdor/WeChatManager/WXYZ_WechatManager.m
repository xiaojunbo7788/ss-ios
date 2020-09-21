
//
//  WXYZ_WechatManager.m
//  WXReader
//
//  Created by Andrew on 2019/3/30.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_WechatManager.h"
#if __has_include(<UMShare/UMShare.h>)
#import <UMShare/UMShare.h>
#endif

#import "AppDelegate.h"
#import "WXYZ_URLProtocol.h"

@implementation WXYZ_WechatManager
{
    WXYZ_WechatState _wechatState;
}

implementation_singleton(WXYZ_WechatManager)

- (void)tunedUpWechatWithState:(WXYZ_WechatState)wechatState {
#if __has_include(<UMShare/UMShare.h>)
    // 注册网络请求监听。
    [WXYZ_URLProtocol startMonitor];
    _wechatState = wechatState;
    
    WS(weakSelf)
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_WechatSession currentViewController:nil completion:^(id result, NSError *error) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSString *code = delegate.wechatCode ?: @"";
        
        if (code.length > 0) {
            if (wechatState == WXYZ_WechatStateLogin) {
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeLoading alertTitle:@"微信登录中"];
            }
            
            if (wechatState == WXYZ_WechatStateBinding) {
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeLoading alertTitle:@"正在获取微信信息"];
            }
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"微信登录失败"];
            return;
        }
        
        if (code && code.length > 0) {
            NSDictionary *params = @{
                @"code" : code
            };
            if (wechatState == WXYZ_WechatStateLogin) {
                [WXYZ_NetworkRequestManger POST:WeChat_Login parameters:params model:WXYZ_UserInfoManager.class success:^(BOOL isSuccess, WXYZ_UserInfoManager *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
                    [WXYZ_URLProtocol stopMonitor];
                    if (isSuccess) {
                        [weakSelf wechatRequestSuccess:t_model];
                        return;
                    }
                    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [WXYZ_URLProtocol stopMonitor];
                    [weakSelf wechatRequestFail:@"微信登录失败"];
                }];
                return ;
            }
            
            if (wechatState == WXYZ_WechatStateBinding) {
                [WXYZ_NetworkRequestManger POST:WeChat_Binding parameters:params model:WXYZ_UserInfoManager.class success:^(BOOL isSuccess, WXYZ_UserInfoManager *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
                    [WXYZ_URLProtocol stopMonitor];
                    if (isSuccess) {
                        [weakSelf wechatRequestSuccess:t_model];
                    } else {
                        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [WXYZ_URLProtocol stopMonitor];
                    [weakSelf wechatRequestFail:@"微信绑定失败"];
                }];
                return ;
            }
        } else {
            if (wechatState == WXYZ_WechatStateLogin) {
                [weakSelf wechatRequestFail:@"微信登录失败"];
            }
            if (wechatState == WXYZ_WechatStateBinding) {
                [weakSelf wechatRequestFail:@"微信绑定失败"];
            }
        }
    }];
#endif
}

+ (BOOL)isInstallWechat {
#if __has_include(<UMShare/UMShare.h>)
    return [[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_WechatSession];
#else
    return NO;
#endif
}

- (void)wechatRequestSuccess:(WXYZ_UserInfoManager *)userData
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(wechatResponseSuccess:)]) {
        [self.delegate wechatResponseSuccess:userData];
    }
}

- (void)wechatRequestFail:(NSString *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(wechatResponseFail:)]) {
        [self.delegate wechatResponseFail:error?:@""];
    }
}

@end

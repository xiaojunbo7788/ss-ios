//
//  WXYZ_QQManager.m
//  WXReader
//
//  Created by Chair on 2019/11/22.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_QQManager.h"

#if __has_include(<UMShare/UMShare.h>)
#import <UMShare/UMShare.h>
#endif


@implementation WXYZ_QQManager {
    WXYZ_QQState _qqState;
}

implementation_singleton(WXYZ_QQManager)

- (void)tunedUpQQWithState:(WXYZ_QQState)qqState {
#if __has_include(<UMShare/UMShare.h>)
    _qqState = qqState;
        
    WS(weakSelf)
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_QQ currentViewController:nil completion:^(id result, NSError *error) {
        if (qqState == WXYZ_QQStateLogin) {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeLoading alertTitle:@"QQ登录中"];
        }
        
        if (qqState == WXYZ_QQStateBinding) {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeLoading alertTitle:@"正在获取QQ信息"];
        }
        
        UMSocialUserInfoResponse *resp = result;
        if (resp) {
            NSDictionary *params = @{
                @"access_token" : resp.accessToken
            };
            if (qqState == WXYZ_QQStateLogin) {
                [WXYZ_NetworkRequestManger POST:QQ_Login parameters:params model:WXYZ_UserInfoManager.class success:^(BOOL isSuccess, WXYZ_UserInfoManager *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
                    if (isSuccess) {
                        [weakSelf qqRequestSuccess:t_model];
                        return ;
                    }
                    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [weakSelf qqRequestFail:@"QQ登录失败"];
                }];
                return ;
            }
            
            if (qqState == WXYZ_QQStateBinding) {
                [WXYZ_NetworkRequestManger POST:QQ_Binding parameters:params model:WXYZ_UserInfoManager.class success:^(BOOL isSuccess, WXYZ_UserInfoManager *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
                    if (isSuccess) {
                        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"QQ绑定成功"];
                        [weakSelf qqRequestSuccess:t_model];
                        return ;
                    }
                    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [weakSelf qqRequestFail:@"QQ绑定失败"];
                }];
                return ;
            }
        } else {
            if (qqState == WXYZ_QQStateLogin) {
                [weakSelf qqRequestFail:@"QQ登录失败"];
            }
            
            if (qqState == WXYZ_QQStateBinding) {
                [weakSelf qqRequestFail:@"QQ绑定失败"];
            }
        }
    }];
#endif
}

+ (BOOL)isInstallQQ {
#if __has_include(<UMShare/UMShare.h>)
    BOOL status = [[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_QQ];
    if (status) return status;
    return [[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_Tim];
#else
    return NO;
#endif
}

- (void)qqRequestSuccess:(WXYZ_UserInfoManager *)userData {
    if (self.delegate && [self.delegate respondsToSelector:@selector(qqResponseSuccess:)]) {
        [self.delegate qqResponseSuccess:userData];
    }
}

- (void)qqRequestFail:(NSString *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(qqResponseFail:)]) {
        [self.delegate qqResponseFail:error ?: @""];
    }
}

@end

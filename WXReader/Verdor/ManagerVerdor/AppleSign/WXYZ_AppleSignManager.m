//
//  AppleSignManager.m
//  WXReader
//
//  Created by Chair on 2020/1/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AppleSignManager.h"

#import <AuthenticationServices/AuthenticationServices.h>
#import "AppDelegate.h"



@interface WXYZ_AppleSignManager ()<ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding>

@end

@implementation WXYZ_AppleSignManager

implementation_singleton(WXYZ_AppleSignManager)

- (void)tunedUpAppleSignWithState:(WXYZ_appleSignState)state {    
    ASAuthorizationAppleIDProvider *provider = [[ASAuthorizationAppleIDProvider alloc] init];
    ASAuthorizationAppleIDRequest *request = [provider createRequest];
    request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];

    ASAuthorizationController *vc = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
    vc.delegate = self;
    vc.presentationContextProvider = self;
    [vc performRequests];
}

#pragma mark - ASAuthorizationControllerPresentationContextProviding
- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller  API_AVAILABLE(ios(13.0)) {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return app.window;
}

#pragma mark - ASAuthorizationControllerDelegate
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)) {
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]])       {
        /*
         ASAuthorizationAppleIDCredential *credential = authorization.credential;
        NSString *state = credential.state;
        NSString *userID = credential.user;
        NSPersonNameComponents *fullName = credential.fullName;
        NSString *email = credential.email;
        NSString *authorizationCode = [[NSString alloc] initWithData:credential.authorizationCode encoding:NSUTF8StringEncoding]; // refresh token
        NSString *identityToken = [[NSString alloc] initWithData:credential.identityToken encoding:NSUTF8StringEncoding]; // access token
        ASUserDetectionStatus realUserStatus = credential.realUserStatus;
         */
        
        // 请求游客登录
        [self requestTouristsLogin];
    }
}

/// 请求游客登录
- (void)requestTouristsLogin {
    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeLoading alertTitle:@"游客登录中"];

    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Tourists_Login parameters:@{@"udid":[WXYZ_UtilsHelper getUDID]} model:WXYZ_UserInfoManager.class success:^(BOOL isSuccess, WXYZ_UserInfoManager * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        [WXYZ_TopAlertManager hiddenAlert];
        if (isSuccess) {            
            [weakSelf appleSignResponseSuccess:t_model];
        } else {
            [weakSelf appleSignResponseFail:requestModel.msg];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager hiddenAlert];
        [weakSelf appleSignResponseFail:error.localizedFailureReason ?: @"登录失败"];
    }];
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)) {
    NSString *errorMsg = nil;
    switch (error.code) {
        case ASAuthorizationErrorCanceled:
            errorMsg = @"您已取消授权";
            break;
        case ASAuthorizationErrorFailed:
            errorMsg = @"授权请求失败";
            break;
        case ASAuthorizationErrorInvalidResponse:
            errorMsg = @"授权请求响应无效";
            break;
        case ASAuthorizationErrorNotHandled:
            errorMsg = @"未能处理授权请求";
            break;
        case ASAuthorizationErrorUnknown:
            errorMsg = @"授权请求失败原因未知";
            break;
    }
    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:errorMsg];
}

- (void)appleSignResponseSuccess:(WXYZ_UserInfoManager *)userData {
    if (self.delegate && [self.delegate respondsToSelector:@selector(appleSignResponseSuccess:)]) {
        [self.delegate appleSignResponseSuccess:userData];
    }
}

- (void)appleSignResponseFail:(NSString *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(appleSignResponseFail:)]) {
        [self.delegate appleSignResponseFail:error ?: @""];
    }
}

@end

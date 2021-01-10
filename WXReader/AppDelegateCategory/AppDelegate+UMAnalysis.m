//
//  AppDelegate+UMAnalysis.m
//  WXReader
//
//  Created by Andrew on 2018/7/31.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "AppDelegate+UMAnalysis.h"
#import <UMCommon/UMCommon.h>

#if __has_include(<UMShare/UMShare.h>)
#import <UMShare/UMShare.h>
#endif

@implementation AppDelegate (UMAnalysis)

- (void)initUMAnalysis {
    [UMConfigure setEncryptEnabled:YES];//打开加密传输
    [UMConfigure setLogEnabled:YES];//设置打开日志
    [UMConfigure initWithAppkey:UM_App_Key channel:@"App Store"];
//    [MobClick setScenarioType:E_UM_NORMAL];
#if __has_include(<UMShare/UMShare.h>)
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:Tencent_APPID  appSecret:nil redirectURL:@"http://mobile.umeng.com/social"];
    /* 设置微信的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:WX_WeChat_APPID appSecret:WX_Wechat_Screct redirectURL:@"http://mobile.umeng.com/social"];
#endif
}

@end

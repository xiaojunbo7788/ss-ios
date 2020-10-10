//
//  SettingConfig.h
//  WXReader
//
//  Created by Andrew on 2018/5/15.
//  Copyright © 2018年 Andrew. All rights reserved.
//

// 软件版本 v4.2.0

#ifndef SettingConfig_h
#define SettingConfig_h

// 主货币名称
#define Main_Unit_Name @"书币"

// 子货币名称
#define Sub_Unit_Name @"书券"

// apple ID
#define Apple_ID @""

// api服务器地址 fix-g
////TODO:线上
// api域名
#define APIURL @"https://app.sscomic.life"
// api秘钥
#define app_key @"TiLFn7mGINnlGm4f"
// api签名
#define secret_key @"aWazSjvX6BLtI39elV4CpwCMeQzJud0q"


////TODO:测试
// api域名
//#define APIURL @"http://api.songshucangku.com"
//// api秘钥
//#define app_key @"dc1fbf20163dc54a"
//// api签名
//#define secret_key @"60c76bfc252cd9403b4a0a7bbd8ad827"



// 提交审核时间
#define Submission_Date @"2020-06-10 21:26:34"

/**
 微信
 */
#define WX_WeChat_APPID @""

#define WX_Wechat_Screct @""

/**
 QQ
 */
#define Tencent_APPID @""

/**
 友盟
 */
#define UM_App_Key @"5f2950cfd30932215474e6bb"

/**
 阿里推送
 */
#define Ali_App_Key @"30957467"

#define Ali_App_Secret @"f630283cf7324724fd1b8690f7182840"

// 穿山甲
#define BUA_App_Key @""

// 启动页默认Key
#define BUA_Splash_Key @""

// 激励视频默认Key
#define BUA_Incentive_Video_Key @""

// 讯飞语音
#define IFLY_App_ID @""

// 进入后台后返回App前台重新展示广告间隔时间(分钟)
#define WX_Launch_Interval 2.0f

// 好评页跳转地址
#define WX_EvaluationAddress [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%@?mt=8", Apple_ID]


#endif /* SettingConfig_h */

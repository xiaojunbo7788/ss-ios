//
//  AppDelegate.m
//  WXReader
//
//  Created by Andrew on 2018/5/14.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "AppDelegate.h"

#import "AppDelegate+CheckSetting.h"
#import "AppDelegate+Service.h"
#import "AppDelegate+AliPush.h"
#import "AppDelegate+UMAnalysis.h"
#import "AppDelegate+UMShare.h"
#import "AppDelegate+ShortcutTouch.h"
#import "AppDelegate+Score.h"
#import "AppDelegate+AppSign.h"
#import "AppDelegate+LaunchAD.h"
#import "AppDelegate+StartTimes.h"
#import "AppDelegate+Insterest.h"
#import "AppDelegate+Bugly.h"
#import "AppDelegate+DeviceID.h"
#if WX_Enable_Ai
    #import "AppDelegate+IflySpeech.h"
#endif
#import "CYLTabBarController.h"

#import "IAPManager.h"
#if __has_include(<UMShare/UMShare.h>)
#import <UMShare/UMShare.h>
#endif
#import "WXYZ_BookMarkModel.h"
#import "WXYZ_ProductionReadRecordManager.h"
#import "WXYZ_AgreementAlertView.h"

@interface AppDelegate ()

@property (nonatomic, copy) NSString *enterBackgroundTime; // 进入后台时间戳

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [WXYZ_ViewHelper setStateBarLightStyle];
    if (!WXYZ_SystemInfoManager.agreementAllow) {
        WXYZ_AgreementAlertView *alert = [[WXYZ_AgreementAlertView alloc] initInController];
        alert.confirmButtonClickBlock = ^{
            [self firstApplication:application didFinishLaunchingWithOptions:launchOptions];
        };
        [alert showAlertView];
    } else {
        [self firstApplication:application didFinishLaunchingWithOptions:launchOptions];
    }

    // 注册设备信息
    [self initDeviceInfo];

    // 检查系统设置
    [self initCheckSetting];

    // 友盟
    [self initUMAnalysis];

    // 分享
    [self initUMShare];

    // 3D Touch
    [self initShortcutTouch];

    // 应用内好评
    [self initAppStoreScore];

    [self initBugly];

#if WX_Enable_Ai
    [self initIFlySpeech];
#endif
#if WX_Super_Member_Mode || WX_Recharge_Mode
    // 启动IAP
    [[IAPManager sharedManager] startManager];
#endif

    // 签到
    [self initUserSign];

    // 显示沙盒地址
    [self showHome];
    
    return YES;
}

- (void)firstApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.tabBarControllerConfig = [[WXYZ_MainTabbarViewController alloc] init];
    CYLTabBarController *tabBarController = self.tabBarControllerConfig.tabBarController;
    [self.window setRootViewController:tabBarController];
    
    // 开启阿里推送
    [self initAliPushWithApplication:application launchOptions:launchOptions];
            
    // 开启广告
    [self initADManager];
    if (!isMagicState) {
        // 启动页
        [self initLaunchADView];
        [self initInsterestView];
        [self updateInsterestData];
    }
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initStartTimes];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
#if __has_include(<UMShare/UMShare.h>)
    return [[UMSocialManager defaultManager] handleOpenURL:url];
#else
    return YES;
#endif
}

- (void)applicationWillResignActive:(UIApplication *)application {
    self.enterBackgroundTime = [WXYZ_UtilsHelper currentDateString];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    #if WX_Super_Member_Mode || WX_Recharge_Mode
        // 检查未完成的内购
        [[IAPManager sharedManager] checkIAPFiles];
    #endif
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    application.applicationIconBadgeNumber = 0;
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:WX_START_PAGE];
    
    StartPage *start_page = [StartPage modelWithJSON:data];
    
    NSInteger enterInterval = [WXYZ_UtilsHelper getCurrentMinutesIntervalWithTimeStamp:self.enterBackgroundTime];
    
    if (start_page.skip_type == 5 && enterInterval >= WX_Launch_Interval) { // 穿山甲开屏广告
        [self initLaunchADView];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    /**结束IAP工具类*/
    [[IAPManager sharedManager] stopManager];
    
    [application endReceivingRemoteControlEvents];
}

@end

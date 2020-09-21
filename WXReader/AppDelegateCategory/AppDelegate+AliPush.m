//
//  AppDelegate+AliPush.m
//  WXDating
//
//  Created by Andrew on 2017/12/21.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "AppDelegate+AliPush.h"
#import "WXYZ_WebViewViewController.h"
#import "AppDelegate+DeviceID.h"
#import <CloudPushSDK/CloudPushSDK.h>
#import <UserNotifications/UserNotifications.h>

@implementation AppDelegate (AliPush)

- (void)initAliPushWithApplication:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions
{
#if WX_Enable_Push
    
    // APNs注册，获取deviceToken并上报
    [self registerAPNS:application];
    
    // 初始化阿里云推送SDK
    [self initCloudPush];
    
    // 监听推送通道打开动作
    [self listenerOnChannelOpened];
    
    // 监听推送消息到达
    [self registerMessageReceive];
    
    // 打开回执上报
    [CloudPushSDK sendNotificationAck:launchOptions];
#endif
}

#pragma mark 初始化阿里云推送SDK
- (void)initCloudPush
{
    WS(weakSelf)
    // 初始化SDK
    [CloudPushSDK asyncInit:Ali_App_Key appSecret:Ali_App_Secret callback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            [weakSelf uploadDeviceID];
        } else {
        }
    }];
}

#pragma mark APNs Register

// 向APNs注册，获取deviceToken用于推送
- (void)registerAPNS:(UIApplication *)application
{
    self.notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    // 创建category，并注册到通知中心
    [self createCustomNotificationCategory];
    self.notificationCenter.delegate = self;
    // 请求推送权限
    [self.notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            // 向APNs注册，获取deviceToken
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
        } else {
            // not granted
            NSLog(@"用户不允许通知");
        }
    }];
}

// 主动获取设备通知是否授权
- (void)getNotificationSettingStatus {
    [self.notificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            NSLog(@"用户允许通知");
        } else {
            NSLog(@"用户不允许通知");
        }
    }];
}

// APNs注册成功回调，将返回的deviceToken上传到CloudPush服务器
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [CloudPushSDK registerDevice:deviceToken withCallback:^(CloudPushCallbackResult *res) {}];
}

// APNs注册失败回调
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {}

// 创建并注册通知category
- (void)createCustomNotificationCategory
{
    // 自定义`action1`和`action2`
    UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"action1" title:@"test1" options: UNNotificationActionOptionNone];
    UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"action2" title:@"test2" options: UNNotificationActionOptionNone];
    // 创建id为`test_category`的category，并注册两个action到category
    // UNNotificationCategoryOptionCustomDismissAction表明可以触发通知的dismiss回调
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"test_category" actions:@[action1, action2] intentIdentifiers:@[] options:
                                        UNNotificationCategoryOptionCustomDismissAction];
    // 注册category到通知中心
    [self.notificationCenter setNotificationCategories:[NSSet setWithObjects:category, nil]];
}

// 处理iOS 10通知
- (void)handleiOS10Notification:(UNNotification *)notification
{
    UNNotificationRequest *request = notification.request;
    UNNotificationContent *content = request.content;
    NSDictionary *userInfo = content.userInfo;
    
    // 通知角标数清0
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // 同步角标数到服务端
    [self syncBadgeNum:0];
    // 通知打开回执上报
    [CloudPushSDK sendNotificationAck:userInfo];
}

// App处于前台时收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    // 处理iOS 10通知，并上报通知打开回执
    [self handleiOS10Notification:notification];
    
    // 通知弹出，且带有声音、内容和角标
    completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge);
}

/**
 *  触发通知动作时回调，比如点击、删除通知和点击自定义action
 */

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    
    StartPage *model = [StartPage modelWithDictionary:userInfo];
    
    [self.tabBarControllerConfig.tabBarController setSelectedIndex:1];
    
    if (model.content.length > 0) {
        switch (model.skip_type) {
#if WX_Enable_Book
            case 1: // 小说
            {
                dispatch_after(0.5, dispatch_get_main_queue(), ^{
                    WXYZ_BookMallDetailViewController *vc = [[WXYZ_BookMallDetailViewController alloc] init];
                    vc.book_id = [model.content integerValue];
                    [[WXYZ_ViewHelper getCurrentViewController].navigationController pushViewController:vc animated:YES];
                });
            }
                break;
#endif
                
            case 2:
                break;
#if WX_Enable_Comic
            case 3: // 漫画
            {
                dispatch_after(0.5, dispatch_get_main_queue(), ^{
                    WXYZ_ComicMallDetailViewController *vc = [[WXYZ_ComicMallDetailViewController alloc] init];
                    vc.comic_id = [model.content integerValue];
                    [[WXYZ_ViewHelper getCurrentViewController].navigationController pushViewController:vc animated:YES];
                });
            }
                break;
#endif
                
            case 4: // web
            {
                dispatch_after(0.5, dispatch_get_main_queue(), ^{
                    WXYZ_WebViewViewController *vc = [[WXYZ_WebViewViewController alloc] init];
                    vc.navTitle = model.title?:@"";
                    vc.URLString = model.content?:@"";
                    [[WXYZ_ViewHelper getCurrentViewController].navigationController pushViewController:vc animated:YES];
                });
            }
                break;
#if WX_Enable_Audio
            case 8: // 有声
            {
                dispatch_after(0.5, dispatch_get_main_queue(), ^{
                    WXYZ_AudioMallDetailViewController *vc = [[WXYZ_AudioMallDetailViewController alloc] init];
                    vc.audio_id = [model.content integerValue];
                    [[WXYZ_ViewHelper getCurrentViewController].navigationController pushViewController:vc animated:YES];
                });
            }
                break;
#endif
                
            default:
                break;
        }
    }
    
    completionHandler();
}

#pragma mark Channel Opened

// 注册推送通道打开监听
- (void)listenerOnChannelOpened
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChannelOpened:) name:@"CCPDidChannelConnectedSuccess" object:nil];
}

// 推送通道打开回调
- (void)onChannelOpened:(NSNotification *)notification
{
    NSLog(@"消息通道建立成功");
}

#pragma mark Receive Message

// 注册推送消息到来监听
- (void)registerMessageReceive
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageReceived:) name:@"CCPDidReceiveMessageNotification" object:nil];
}

// 处理到来推送消息
- (void)onMessageReceived:(NSNotification *)notification
{
    NSLog(@"Receive one message!");
   
    CCPSysMessage *message = [notification object];
    NSString *title = [[NSString alloc] initWithData:message.title encoding:NSUTF8StringEncoding];
    NSString *body = [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding];
    NSLog(@"Receive message title: %@, content: %@.", title, body);
}

/* 同步通知角标数到服务端 */
- (void)syncBadgeNum:(NSUInteger)badgeNum {
    [CloudPushSDK syncBadgeNum:badgeNum withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Sync badge num: [%lu] success.", (unsigned long)badgeNum);
        } else {
            NSLog(@"Sync badge num: [%lu] failed, error: %@", (unsigned long)badgeNum, res.error);
        }
    }];
}

@end

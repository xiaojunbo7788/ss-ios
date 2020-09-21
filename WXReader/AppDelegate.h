//
//  AppDelegate.h
//  WXReader
//
//  Created by Andrew on 2018/5/14.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "WXYZ_MainTabbarViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>

@property (nonatomic, strong) WXYZ_CheckSettingModel *checkSettingModel;

@property (nonatomic, strong) UNUserNotificationCenter *notificationCenter;

@property (nonatomic, strong) WXYZ_MainTabbarViewController *tabBarControllerConfig;

@property (strong, nonatomic) UIWindow *window;

/** 微信登录Code */
@property (nonatomic, copy) NSString *wechatCode;

@end


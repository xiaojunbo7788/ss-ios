//
//  AppDelegate+Insterest.m
//  WXReader
//
//  Created by Andrew on 2018/11/19.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "AppDelegate+Insterest.h"
#import "AppDelegate+StartTimes.h"
#import "WXYZ_InsterestViewController.h"

@implementation AppDelegate (Insterest)

- (void)initInsterestView
{
#if WX_Insterest_View
    if ([WXYZ_NetworkReachabilityManager networkingStatus]) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:WX_Insterest_Switch] == nil) {
            [self.window.rootViewController presentViewController:[[WXYZ_InsterestViewController alloc] init] animated:NO completion:^{
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:WX_Insterest_Switch];
            }];
        }
    }
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInsterestData) name:Notification_Login_Success object:nil];
}

- (void)updateInsterestData
{
#if WX_Insterest_View
    // 上传感兴趣的内容
    if (WXYZ_UserInfoManager.isLogin) {
        [WXYZ_NetworkRequestManger POST:Save_Recommed parameters:@{@"gender":@([WXYZ_UserInfoManager shareInstance].gender)} model:nil success:nil failure:nil];
    }
#endif
}

@end

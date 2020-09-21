//
//  AppDelegate+DeviceID.m
//  WXDating
//
//  Created by Andrew on 2018/1/9.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "AppDelegate+DeviceID.h"
#import <CloudPushSDK/CloudPushSDK.h>

@implementation AppDelegate (DeviceID)

- (void)initDeviceInfo
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadDeviceID) name:Notification_Login_Success object:nil];
}

- (void)uploadDeviceID
{
    NSString *device_id = [CloudPushSDK getDeviceId];
    
    if (!device_id || device_id.length == 0) return;

    [WXYZ_NetworkRequestManger POST:Upload_Device_Info parameters:@{@"device_id":device_id?:@""} model:nil success:nil failure:nil];
}

@end

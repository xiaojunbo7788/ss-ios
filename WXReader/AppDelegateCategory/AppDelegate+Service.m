//
//  AppDelegate+Service.m
//  WXDating
//
//  Created by Andrew on 2017/8/13.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "AppDelegate+Service.h"
#import "YYFPSLabel.h"

@implementation AppDelegate (Service)

- (void)showHome
{
    NSLog(@"沙盒地址：%@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]);
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        YYFPSLabel *fpsLabel = [YYFPSLabel new];
//        fpsLabel.frame = CGRectMake(0, PUB_NAVBAR_OFFSET + 20, 50, 30);
//        [fpsLabel sizeToFit];
//        [kMainWindow addSubview:fpsLabel];
//    });
}

@end

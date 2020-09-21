//
//  AppDelegate+UMShare.m
//  WXReader
//
//  Created by Andrew on 2018/9/26.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "AppDelegate+UMShare.h"
#if __has_include(<UMShare/UMShare.h>)
#import <UMShare/UMShare.h>
#endif

@implementation AppDelegate (UMShare)

- (void)initUMShare
{
    [self configUSharePlatforms];
    [self confitUShareSettings];
}

- (void)confitUShareSettings {
#if __has_include(<UMShare/UMShare.h>)
    // 打开图片水印
    [UMSocialGlobal shareInstance].isUsingWaterMark = NO;
#endif
}

- (void)configUSharePlatforms {
#if __has_include(<UMShare/UMShare.h>)
    // 移除相应平台的分享，如微信收藏
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformTypes:@[@(UMSocialPlatformType_WechatFavorite)]];
#endif
}

@end

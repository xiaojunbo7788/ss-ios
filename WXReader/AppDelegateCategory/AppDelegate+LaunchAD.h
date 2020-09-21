//
//  AppDelegate+LaunchAD.h
//  WXReader
//
//  Created by Andrew on 2018/11/15.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "AppDelegate.h"
#if WX_Enable_Third_Party_Ad
    #import <BUAdSDK/BUAdSDK.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (LaunchAD)
#if WX_Enable_Third_Party_Ad
<BUSplashAdDelegate>
#endif

- (void)initLaunchADView;

- (void)initADManager;

@end

NS_ASSUME_NONNULL_END

//
//  AppDelegate+IflySpeech.m
//  WXReader
//
//  Created by Andrew on 2020/3/8.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "AppDelegate+IflySpeech.h"
#if WX_Enable_Ai
    #import "iflyMSC/IFlyMSC.h"
#endif

@implementation AppDelegate (IflySpeech)

- (void)initIFlySpeech
{
#if WX_Enable_Ai
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@", IFLY_App_ID];
        [IFlySpeechUtility createUtility:initString];
		[IFlySetting showLogcat:NO];
    });
#endif
}

@end

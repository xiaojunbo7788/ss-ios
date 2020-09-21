//
//  AppDelegate+Bugly.m
//  WXReader
//
//  Created by Andrew on 2019/6/28.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "AppDelegate+Bugly.h"
#import <Bugly/Bugly.h>

@implementation AppDelegate (Bugly)

- (void)initBugly
{
    [Bugly startWithAppId:@"8565dcf23a"];
}

@end

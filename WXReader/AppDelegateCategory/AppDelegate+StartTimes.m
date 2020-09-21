//
//  AppDelegate+StartTimes.m
//  WXReader
//
//  Created by Andrew on 2018/11/16.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "AppDelegate+StartTimes.h"

@implementation AppDelegate (StartTimes)

- (void)initStartTimes
{
    int startNum = [[[NSUserDefaults standardUserDefaults] objectForKey:@"wx_start_num"] intValue];
    
    if (startNum != 0) {
        startNum ++;
    } else {
        startNum = 1;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:startNum] forKey:@"wx_start_num"];
}

- (int)startTimes
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"wx_start_num"] intValue];
}

@end

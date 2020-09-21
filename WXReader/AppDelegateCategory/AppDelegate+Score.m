//
//  AppDelegate+Score.m
//  WXReader
//
//  Created by Andrew on 2018/11/7.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "AppDelegate+Score.h"
#import "AppDelegate+StartTimes.h"
#import<StoreKit/StoreKit.h>
#import "WXYZ_EvaluationAlertView.h"

@implementation AppDelegate (Score)

- (void)initAppStoreScore
{
#if WX_AppStore_Score
    if ([self startTimes] % 20 != 0 || [self startTimes] <= 20) {
        return;
    }

    if (isMagicState) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        WXYZ_EvaluationAlertView *alert = [[WXYZ_EvaluationAlertView alloc] init];
        alert.confirmButtonClickBlock = ^{
            if (@available(iOS 10.3, *)) {
                if([SKStoreReviewController respondsToSelector:@selector(requestReview)]){
                        [[UIApplication sharedApplication].keyWindow endEditing:YES];
                        [SKStoreReviewController requestReview];
                }
            } else {
                // Fallback on earlier versions
            }
        };
        alert.cancelButtonClickBlock = ^{
            NSURL *appReviewUrl = [NSURL URLWithString:WX_EvaluationAddress];
            [[UIApplication sharedApplication] openURL:appReviewUrl options:@{} completionHandler:nil];
        };
        [alert showAlertView];        
    });
#endif
}

@end


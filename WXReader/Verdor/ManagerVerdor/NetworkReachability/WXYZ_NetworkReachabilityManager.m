//
//  WXYZ_NetworkReachabilityManager.m
//  WXReader
//
//  Created by Andrew on 2019/12/4.
//  Copyright © 2019 Andrew. All rights reserved.
//


@implementation WXYZ_NetworkReachabilityManager


+ (void)cellularDataRestrictionDidUpdateNotifier:(void(^)(CTCellularDataRestrictedState status))complete {
    CTCellularData *cellularData = [[CTCellularData alloc] init];
    cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState status) {
        if (complete) {
            complete(status);
        }
    };
}

+ (CTCellularDataRestrictedState)currentNetworkStatus {
    if (TARGET_IPHONE_SIMULATOR) return kCTCellularDataNotRestricted;
    
    /* CTCellularData实例创建时restrictedState总是kCTCellularDataRestrictedStateUnknown,之后在cellularDataRestrictionDidUpdateNotifier会有一次回调，此时才能获取到正确的网络状态。
     */
    CTCellularDataRestrictedState __block state;
    CTCellularData *cellularData = [[CTCellularData alloc] init];
    dispatch_semaphore_t signal = dispatch_semaphore_create(0);
    cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState status) {
        state = status;
        dispatch_semaphore_signal(signal);
    };
    dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);
    cellularData.cellularDataRestrictionDidUpdateNotifier = nil;
    
    return state;
}


+ (ReachabilityType)currentNetworkType {
    if (@available(iOS 13.0, *)) {
        UIStatusBarManager *statusBarManager = kRCodeSync([UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager);
        id statusBar = nil;
        // 获取当前的状态栏
        
        if (![statusBarManager respondsToSelector:NSSelectorFromString(@"createLocalStatusBar")]) return ReachabilityTypeUnknown;
        
        SEL selector = NSSelectorFromString(@"createLocalStatusBar");
        IMP imp = [statusBarManager methodForSelector:selector];
        UIView * (*func) (id, SEL) = (void *)imp;
        UIView *localStatusBar = kRCodeSync(func(statusBarManager, selector));
        
        if ([localStatusBar respondsToSelector:NSSelectorFromString(@"statusBar")]) {
            SEL selector = NSSelectorFromString(@"statusBar");
            IMP imp = [localStatusBar methodForSelector:selector];
            id (*func) (id, SEL) = (void *)imp;
            statusBar = func(localStatusBar, selector);
        }
        
        if (!statusBar) return ReachabilityTypeUnknown;

        id currentData = [[statusBar valueForKeyPath:@"_statusBar"] valueForKeyPath:@"currentData"];
        id wifiEntry = [currentData valueForKeyPath:@"wifiEntry"];
        id cellularEntry = [currentData valueForKeyPath:@"cellularEntry"];
        if (wifiEntry && [[wifiEntry valueForKeyPath:@"isEnabled"] boolValue]) {
            return ReachabilityTypeWiFi;
        }
        
        if (cellularEntry && [[cellularEntry valueForKeyPath:@"isEnabled"] boolValue]) {
            NSNumber *type = [cellularEntry valueForKeyPath:@"type"];
            if (![type boolValue]) return ReachabilityTypeUnknown;
            
            switch (type.integerValue) {
                case 0:
                    return ReachabilityTypeNone;
                case 1:
                    return ReachabilityType2G;
                case 4:
                    return ReachabilityType3G;
                case 5:
                    return ReachabilityType4G;
                    
                default:
                    return ReachabilityTypeDefault;
            }
        }
    }
    
    
    // iOS13.0以下的处理方法
    YYReachability* reach = [YYReachability reachabilityWithHostname:@"www.baidu.com"];
    
    if (reach.status == YYReachabilityStatusNone) {
        return ReachabilityTypeNone;
    } else if (reach.status == YYReachabilityStatusWWAN) {
        return ReachabilityType4G;
    } else {
        return ReachabilityTypeWiFi;
    }
    
    
//    NSArray *children;
//    id statusBar = [[UIApplication sharedApplication] valueForKeyPath:@"_statusBar"];
//    if ([statusBar isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
//        children = [[[statusBar valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
//    } else {
//        children = [[statusBar valueForKeyPath:@"foregroundView"] subviews];
//    }
//
//    int type = 0;
//    for (id child in children) {
//        if ([child isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
//            type = [[child valueForKeyPath:@"dataNetworkType"] intValue];
//        }
//    }
//
//    switch (type) {
//        case 0:
//            return ReachabilityTypeNone;
//        case 1:
//            return ReachabilityType2G;
//        case 2:
//            return ReachabilityType3G;
//        case 3:
//            return ReachabilityType4G;
//        case 4:
//            return ReachabilityTypeLTE;
//        case 5:
//            return ReachabilityTypeWiFi;
//
//        default:
//            return ReachabilityTypeUnknown;
//    }
}

+ (BOOL)networkingStatus {
    BOOL originStatus = [AFNetworkReachabilityManager sharedManager].reachable;
    if (originStatus == NO) {
        ReachabilityType currentStatus = [self currentNetworkType];
        if (currentStatus == ReachabilityTypeNone || currentStatus == ReachabilityTypeUnknown) {
            return NO;
        } else {
            return YES;
        }
    }
    
    return YES;
}

+ (void)networkingStatus:(void(^)(BOOL status))complete {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            if (complete) {
                complete(YES);
            }
        } else {
            if (complete) {
                complete(NO);
            }
        }
    }];
    [manager startMonitoring];
}

@end

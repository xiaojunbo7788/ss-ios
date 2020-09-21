//
//  NetWorkReachability.h
//  SECC01
//
//  Created by Harvey on 16/6/29.
//  Copyright © 2016年 Haley. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WXYZ_NetworkStatus) {
    WXYZ_NetWorkStatusNotReachable = 0,
    WXYZ_NetWorkStatusUnknown = 1,
    WXYZ_NetWorkStatusWWAN2G = 2,
    WXYZ_NetWorkStatusWWAN3G = 3,
    WXYZ_NetWorkStatusWWAN4G = 4,
    
    WXYZ_NetWorkStatusWiFi = 9,
};

extern NSString *kNetWorkReachabilityChangedNotification;

@interface WXYZ_NetworkObserver : NSObject

/*!
 * Use to check the reachability of a given host name.
 */
+ (instancetype)reachabilityWithHostName:(NSString *)hostName;

/*!
 * Use to check the reachability of a given IP address.
 */
+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;

/*!
 * Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 */
+ (instancetype)reachabilityForInternetConnection;

- (BOOL)startNotifier;

- (void)stopNotifier;

- (WXYZ_NetworkStatus)currentReachabilityStatus;

@end

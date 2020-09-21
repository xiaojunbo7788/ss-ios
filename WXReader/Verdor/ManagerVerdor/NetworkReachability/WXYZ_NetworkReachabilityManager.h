//
//  WXYZ_NetworkReachabilityManager.h
//  WXReader
//
//  Created by Andrew on 2019/12/4.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <CoreTelephony/CTCellularData.h>

typedef NS_ENUM(NSUInteger, ReachabilityType) {/**<详细的网络类型 */
    /** 默认类型WWAN */
    ReachabilityTypeDefault = 0,
    /** 无网络 */
    ReachabilityTypeNone    = 1,
    /** 未知网络 */
    ReachabilityTypeUnknown = 2,
    /** LTE */
    ReachabilityTypeLTE     = 3,
    /** WiFi */
    ReachabilityTypeWiFi    = 4,
    /** 2G */
    ReachabilityType2G      = 5,
    /** 3G */
    ReachabilityType3G      = 6,
    /** 4G */
    ReachabilityType4G      = 7,
    
};

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_NetworkReachabilityManager : NSObject

/// 实时获取APP网络访问状态
/// @param complete 一个回调，返回APP的网络访问状态
+ (void)cellularDataRestrictionDidUpdateNotifier:(void(^)(CTCellularDataRestrictedState status))complete;

/// 获取APP网络访问状态，不是网络类型状态(例如wift、4G)
+ (CTCellularDataRestrictedState)currentNetworkStatus;

/// 获取网络的具体类型(4G、wifi等)
+ (ReachabilityType)currentNetworkType;

/// 获取APP的联网状态，YES：有网络，NO：无网络
+ (BOOL)networkingStatus;

/// 实时获取APP的联网状态
/// @param complete 一个回调，返回APP的联网状态，YES：有网络，NO：无网络
+ (void)networkingStatus:(void(^)(BOOL status))complete;

@end

NS_ASSUME_NONNULL_END

//
//  WXYZ_URLProtocol.h
//  WXReader
//
//  Created by Chair on 2020/3/21.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 拦截网络请求
@interface WXYZ_URLProtocol : NSURLProtocol

@property (nonatomic, assign, readonly) BOOL isSwizzle;

+ (instancetype)sharedInstance;

/// 开始监听
+ (void)startMonitor;

/// 停止监听
+ (void)stopMonitor;

@end


@interface WXYZ_SessionConfig : NSObject

+ (void)swizzleSelector;

@end

NS_ASSUME_NONNULL_END

//
//  AppleSignManager.h
//  WXReader
//
//  Created by Chair on 2020/1/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXYZ_UserInfoManager;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WXYZ_appleSignState) {
    WXYZ_AppleSignStateLogin,
    WXYZ_AppleSignStateBinding
};

@protocol WXYZ_AppleSignManagerDelegate <NSObject>

@optional
- (void)appleSignResponseSuccess:(WXYZ_UserInfoManager *)userData;

- (void)appleSignResponseFail:(NSString *)error;

@end

@interface WXYZ_AppleSignManager : NSObject

@property (nonatomic, weak) id <WXYZ_AppleSignManagerDelegate> delegate;

interface_singleton

- (void)tunedUpAppleSignWithState:(WXYZ_appleSignState)state API_AVAILABLE(ios(13.0));

@end

NS_ASSUME_NONNULL_END

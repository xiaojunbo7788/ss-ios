//
//  WXYZ_ShareManager.h
//  WXReader
//
//  Created by Andrew on 2019/1/17.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXYZ_ShareView.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ShareManager : NSObject

interface_singleton

// 分享应用
- (void)shareApplicationInController:(UIViewController *)viewController shareState:(WXYZ_ShareState)shareState;

- (void)shareApplicationInController:(UIViewController *)viewController shareTitle:(NSString *)shareTitle shareDescribe:(NSString *)shareDescribe shareImageURL:(NSString *)imageURL shareUrl:(NSString *)shareUrl shareState:(WXYZ_ShareState)shareState;

// 分享作品
- (void)shareProductionInController:(UIViewController *)viewController shareTitle:(NSString *)shareTitle shareDescribe:(NSString *)shareDescribe shareImageURL:(NSString *)imageURL productionType:(WXYZ_ShareProductionState)productionType production_id:(NSUInteger)production_id shareState:(WXYZ_ShareState)shareState;

- (void)shareProductionInController:(UIViewController *)viewController shareTitle:(NSString *)shareTitle shareDescribe:(NSString *)shareDescribe shareImageURL:(NSString *)imageURL shareUrl:(NSString *)shareUrl productionType:(WXYZ_ShareProductionState)productionType production_id:(NSUInteger)production_id shareState:(WXYZ_ShareState)shareState;

- (void)shareProductionWithChapter_id:(NSInteger)chapter_id controller:(UIViewController *)viewController type:(WXYZ_ShareProductionState)type shareState:(WXYZ_ShareState)shareState production_id:(NSInteger)production_id complete:(void(^)(void))complete;

@end

NS_ASSUME_NONNULL_END

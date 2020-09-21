//
//  TopAlert.h
//  TopAlert
//
//  Created by roycms on 2016/10/19.
//  Copyright © 2016年 roycms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXYZ_TopAlertView.h"

NS_ASSUME_NONNULL_BEGIN
@interface WXYZ_TopAlertManager : NSObject

+ (void)showAlertWithType:(WXYZ_TopAlertType)type alertTitle:(NSString *)alertTitle;

+ (void)showLimitAlertWithType:(WXYZ_TopAlertType)type alertTitle:(NSString *)alertTitle;

+ (void)showAlertWithType:(WXYZ_TopAlertType)type alertTitle:(NSString *)alertTitle duration:(CGFloat)duration;

+ (void)showAlertWithType:(WXYZ_TopAlertType)type alertTitle:(NSString *)alertTitle completionHandler:(WXYZ_TopAlertDissmissBlock)completionHandler;

+ (void)showAlertWithType:(WXYZ_TopAlertType)type alertTitle:(NSString *)alertTitle duration:(CGFloat)duration completionHandler:(WXYZ_TopAlertDissmissBlock)completionHandler;

+ (void)showAlertWithError:(NSError *)error defaultText:(NSString * _Nullable)text;

+ (void)showAlertWithLoading:(WXYZ_TopAlertMaskType)type style:(WXYZ_TopAlertStyle)style;

+ (void)stopAnimating;

+ (void)hiddenAlert;

/// 展示小说阅读器Loading(仅限小说阅读器使用)
+ (UIView *)showLoading:(UIView * _Nullable)rootView;

/// 隐藏小说阅读器Loading(仅限小说阅读器使用)
+ (void)hideLoading;

@end
NS_ASSUME_NONNULL_END

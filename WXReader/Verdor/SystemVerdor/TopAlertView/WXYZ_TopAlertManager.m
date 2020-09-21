//
//  TopAlert.m
//  TopAlert
//
//  Created by roycms on 2016/10/19.
//  Copyright © 2016年 roycms. All rights reserved.
//

#import "WXYZ_TopAlertManager.h"

#import "WXYZ_ReaderSettingHelper.h"
#import "UIImage+Color.h"

#define Alert_Duration 1.0f

static WXYZ_TopAlertView *_alertView = nil;

@implementation WXYZ_TopAlertManager

static NSDictionary *_errInfo;
+ (void)showAlertWithError:(NSError *)error defaultText:(NSString * _Nullable)text {
    _errInfo = _errInfo ?: [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ErrorCode" ofType:@"plist"]];
    NSString *_text = _errInfo[[NSString stringWithFormat:@"%zd", error.code]];
    _text = _text ?: (error.localizedDescription ?: (text ?: @"请求失败"));
    [self showAlertWithType:WXYZ_TopAlertTypeError alertTitle:_text];
}

+ (void)showAlertWithType:(WXYZ_TopAlertType)type alertTitle:(NSString *)alertTitle
{
    [self showAlertWithType:type alertTitle:alertTitle duration:Alert_Duration];
}

+ (void)showLimitAlertWithType:(WXYZ_TopAlertType)type alertTitle:(NSString *)alertTitle
{
    [self showAlertWithType:type alertTitle:alertTitle duration:Alert_Duration];
}

+ (void)showAlertWithType:(WXYZ_TopAlertType)type alertTitle:(NSString *)alertTitle duration:(CGFloat)duration
{
    [self showAlertWithType:type alertTitle:alertTitle duration:duration completionHandler:nil];
}

+ (void)showAlertWithType:(WXYZ_TopAlertType)type alertTitle:(NSString *)alertTitle completionHandler:(WXYZ_TopAlertDissmissBlock)completionHandler
{
    [self showAlertWithType:type alertTitle:alertTitle duration:Alert_Duration completionHandler:completionHandler];
}

+ (void)showAlertWithType:(WXYZ_TopAlertType)type alertTitle:(NSString *)alertTitle duration:(CGFloat)duration completionHandler:(WXYZ_TopAlertDissmissBlock)completionHandler
{
    if (!alertTitle || alertTitle.length == 0) {
        return;
    }
    if ([_alertView.alertTitle isEqualToString:alertTitle]) {
        return;
    }
    
    if (_alertView) {
        [_alertView hiddenAlertView];
    }
    
    if (type == WXYZ_TopAlertTypeLoading) {
        duration = 30;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        WS(weakSelf)
        _alertView = [[WXYZ_TopAlertView alloc] init];
        _alertView.alertTitle = alertTitle;
        _alertView.alertType = type;
        _alertView.alertDuration = duration;
        _alertView.alertDissmissBlock = ^{
            [weakSelf hiddenAlert];
            if (completionHandler) {
                completionHandler();
            }
        };
        [_alertView showAlertView];
    });
}
    
static UIActivityIndicatorView *activityIndicator;
UIView *maskView;
+ (void)showAlertWithLoading:(WXYZ_TopAlertMaskType)type style:(WXYZ_TopAlertStyle)style {
    if (@available(iOS 13.0, *)) {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    } else {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    activityIndicator.center = [self currentWindow].center;
    
    // 设置动画颜色
    switch (style) {
        case WXYZ_TopAlertStyleLight:
        {
            activityIndicator.color = [UIColor whiteColor];
        }
            break;
        case WXYZ_TopAlertStyleDark:
        {
            activityIndicator.color = [UIColor darkGrayColor];
        }
            break;
    }
    
    // 设置动画的蒙层
    switch (type) {
        case WXYZ_TopAlertMaskTypeNone:
        {
            [[self currentWindow] addSubview:activityIndicator];
        }
            break;
        case WXYZ_TopAlertMaskTypeBlack:

        case WXYZ_TopAlertMaskTypeClear:
        {
            maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            maskView.backgroundColor = type == WXYZ_TopAlertMaskTypeBlack ? [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5] : [UIColor clearColor];
            [[self currentWindow] addSubview:maskView];
            [[self currentWindow] addSubview:activityIndicator];
        }
            break;
    }
    
    [activityIndicator startAnimating];
}

+ (void)stopAnimating {
    [activityIndicator stopAnimating];
    if (maskView.superview) {
        [maskView removeFromSuperview];
        maskView = nil;
    }
}

+ (void)hiddenAlert
{
    if (_alertView.isShowing) {
        [_alertView hiddenAlertView];
        _alertView = nil;
    }
}

+ (UIWindow *)currentWindow {
    if (__IPHONE_13_0) {
        return [UIApplication sharedApplication].windows.firstObject;
    } else {
        return [UIApplication sharedApplication].keyWindow;
    }
}

static UIView *_loadingView;
+ (UIView *)showLoading:(UIView *)rootView {
    UIView *mainView = [[UIView alloc] init];
    _loadingView = mainView;
    mainView.backgroundColor = kColorRGBA(0, 0, 0, 0);
    if (rootView) {
        [rootView addSubview:mainView];
    } else {
        [kMainWindow addSubview:mainView];
    }
    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(mainView.superview);
    }];
    
    NSMutableArray<YYImage *> *arr = [NSMutableArray array];
    for (int i = 0; i < 47; i++) {
        YYImage *image = [YYImage imageNamed:[NSString stringWithFormat:@"%@%d", @"loading", i]];
        image = [image imageWithColor:[[[WXYZ_ReaderSettingHelper sharedManager] getReaderTextColor] colorWithAlphaComponent:0.75]];
        [arr addObject:image];
    }
    
    YYAnimatedImageView *loadingView = [[YYAnimatedImageView alloc] init];
    loadingView.backgroundColor = [UIColor clearColor];
    loadingView.animationImages = arr;
    loadingView.animationDuration = 2.0;
    [loadingView startAnimating];
    [mainView addSubview:loadingView];
    [loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(mainView);
        make.width.mas_equalTo(90);
        make.height.equalTo(loadingView.mas_width).multipliedBy(150.0 / 240.0);
    }];
    __weak typeof(loadingView) weakView = loadingView;
    [NSTimer scheduledTimerWithTimeInterval:loadingView.animationDuration block:^(NSTimer * _Nonnull timer) {
           if (!weakView.superview) {
               [timer invalidate];
               timer = nil;
           }
           NSArray *t_arr = [[loadingView.animationImages reverseObjectEnumerator] allObjects];
           weakView.animationImages = t_arr;
       } repeats:YES];
    return mainView;
}

+ (void)hideLoading {
    [_loadingView removeFromSuperview];
}

@end

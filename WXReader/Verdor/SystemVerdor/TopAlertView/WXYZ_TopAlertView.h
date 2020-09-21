//
//  WXYZ_TopAlertView.h
//  WXReader
//
//  Created by Andrew on 2019/6/7.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WXYZ_TopAlertType) {
    WXYZ_TopAlertTypeSuccess,
    WXYZ_TopAlertTypeError,
    WXYZ_TopAlertTypeLoading
};

typedef NS_ENUM(NSUInteger, WXYZ_TopAlertMaskType) {
    WXYZ_TopAlertMaskTypeNone  = 0,  // 默认类型，Alert显示时可以响应用户交互事件。
    WXYZ_TopAlertMaskTypeClear = 1,  // 不响应用户交互事件，背景透明。
    WXYZ_TopAlertMaskTypeBlack = 2,  // 不响应用户交互事件，背景调暗。
};

typedef NS_ENUM(NSUInteger, WXYZ_TopAlertStyle) {
    WXYZ_TopAlertStyleLight = 0,     // 默认样式，白色的转圈动画。
    WXYZ_TopAlertStyleDark  = 1,     // 灰色的转圈动画。
};

typedef void(^ _Nullable WXYZ_TopAlertDissmissBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_TopAlertView : UIView

@property (nonatomic, copy) NSString *alertTitle;

@property (nonatomic, assign) WXYZ_TopAlertType alertType;

@property (nonatomic, assign) CGFloat alertDuration;

@property (nonatomic, assign) BOOL showMask;

@property (nonatomic, assign) BOOL isShowing;

@property (nonatomic, copy) WXYZ_TopAlertDissmissBlock alertDissmissBlock;

- (void)showAlertView;

- (void)hiddenAlertView;

- (void)removeAlertView;

@end

NS_ASSUME_NONNULL_END

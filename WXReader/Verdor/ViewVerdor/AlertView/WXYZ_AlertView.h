//
//  DPBasicAlertView.h
//  WXReader
//
//  Created by Andrew on 2018/11/8.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WXYZ_AlertView;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WXYZ_AlertButtonType) {
    WXYZ_AlertButtonTypeNone,           // 底部无按钮
    WXYZ_AlertButtonTypeSingleCancel,   // 底部单一取消按钮
    WXYZ_AlertButtonTypeSingleConfirm,  // 底部单一确认按钮
    WXYZ_AlertButtonTypeDouble          // 底部双按钮
};

typedef NS_ENUM(NSUInteger, WXYZ_AlertViewDisappearType) { // 弹框消失状态
    WXYZ_AlertViewDisappearTypeNormal,  // 点击按钮或弹框以外位置消失
    WXYZ_AlertViewDisappearTypeConfirm, // 只能点击按钮消失
    WXYZ_AlertViewDisappearTypeNever    // 不可消失
};


typedef void(^ClickButtonBlock)(WXYZ_AlertView *view);

@interface WXYZ_AlertView : UIView

@property (nonatomic, copy) void(^confirmButtonClickBlock)(void);

@property (nonatomic, copy) void(^cancelButtonClickBlock)(void);

// 按钮样式
@property (nonatomic, assign) WXYZ_AlertButtonType alertButtonType;

// 弹框消失状态
@property (nonatomic, assign) WXYZ_AlertViewDisappearType alertViewDisappearType;

// 是否显示按钮分割线
@property (nonatomic, assign) BOOL showDivider;

@property (nonatomic, copy) NSString *alertViewTitle;

@property (nonatomic, copy) NSString *alertViewDetailContent;

@property (nonatomic, strong) NSMutableAttributedString *alertViewDetailAttributeContent;

@property (nonatomic, copy) NSString *alertViewCancelTitle;

@property (nonatomic, copy) NSString *alertViewConfirmTitle;

- (void)showAlertView;

- (void)closeAlertView;

- (instancetype)initInController;

- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;

/*
 子类使用变量
 */

@property (nonatomic, assign, readonly) CGFloat alertViewWidth;

@property (nonatomic, assign, readonly) CGFloat alertViewButtonHeight;

@property (nonatomic, strong) UIView *alertBackView;

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UILabel *alertViewTitleLabel;

@property (nonatomic, strong) YYLabel *alertViewContentLabel;

@property (nonatomic, strong) UIScrollView *alertViewContentScrollView;

- (void)createSubviews;

@end

NS_ASSUME_NONNULL_END

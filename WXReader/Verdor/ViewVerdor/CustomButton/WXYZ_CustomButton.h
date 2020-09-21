//
//  WXYZ_CustomButton.h
//  WXReader
//
//  Created by Andrew on 2019/5/31.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WXYZ_CustomButtonIndicator) {
    WXYZ_CustomButtonIndicatorTitleLeft,            // 文字左 图片右
    WXYZ_CustomButtonIndicatorTitleRight,           // 文字右 图片左
    WXYZ_CustomButtonIndicatorTitleTop,             // 文字上 图片下
    WXYZ_CustomButtonIndicatorTitleBottom,          // 文字下 图片上
    WXYZ_CustomButtonIndicatorImageLeftBothLeft,    // 图片左 文字右 (同时靠左)
    WXYZ_CustomButtonIndicatorImageLeftBothRight,   // 图片左 文字右 (同时靠右)
    WXYZ_CustomButtonIndicatorImageRightBothLeft,   // 文字左 图片右 (同时靠左)
    WXYZ_CustomButtonIndicatorImageRightBothRight   // 文字左 图片右 (同时靠右)
};

@interface WXYZ_CustomButton : UIButton

/*
 text
 */

// 主标题
@property (nonatomic, copy) NSString *buttonTitle;

// 子标题
@property (nonatomic, copy) NSString *buttonSubTitle;

// 主标题字号
@property (nonatomic, strong) UIFont *buttonTitleFont;

// 子标题字号
@property (nonatomic, strong) UIFont *buttonSubTitleFont;

/*
 color
 */

// 主标题颜色
@property (nonatomic, strong) UIColor *buttonTitleColor;

// 子标题颜色
@property (nonatomic, strong) UIColor *buttonSubTitleColor;

// 整体颜色 (与buttonTitleColor && buttonSubTitleColor 互斥)
@property (nonatomic, strong) UIColor *buttonTintColor;

/*
 image
 */

// 按钮图片名称
@property (nonatomic, copy) NSString *buttonImageName;

/*
 frame
 */

// 图片宽度
@property (nonatomic, assign) NSInteger buttonImageViewWidth;

// 图片高度
@property (nonatomic, assign) NSInteger buttonImageViewHeight;

// 图片缩放 默认0.7 最大为1.0
@property (nonatomic, assign) CGFloat buttonImageScale;

// 图文间距 默认 10
@property (nonatomic, assign) NSInteger graphicDistance;

// 整体偏移量 正数为整体向右偏移  负数为整体向左偏移
@property (nonatomic, assign) CGFloat horizontalMigration;

// 边距 默认0
@property (nonatomic, assign) CGFloat buttonMargin;

/*
 cornerMark
 */

// 角标背景颜色
@property (nonatomic, strong) UIColor *cornerBackColor;

// 角标文字颜色
@property (nonatomic, strong) UIColor *cornerTextColor;

// 角标字号
@property (nonatomic, strong) UIFont *cornerTextFont;

// 角标文字
@property (nonatomic, copy) NSString *cornerTitle;

/*
 other
 */
// 是否翻转图片
@property (nonatomic, assign) BOOL transformImageView;

// 主标题显示行数 默认一行
@property (nonatomic, assign) NSInteger buttonTitleNumberOfLines;

// 按钮标识
@property (nonatomic, copy) NSString *buttonTag;


- (instancetype)initWithButtonTitle:(NSString *)buttonTitle buttonImageName:(NSString *)buttonImageName buttonIndicator:(WXYZ_CustomButtonIndicator)buttonIndicatior;

- (instancetype)initWithFrame:(CGRect)frame buttonTitle:(NSString *)buttonTitle buttonImageName:(NSString *)buttonImageName buttonIndicator:(WXYZ_CustomButtonIndicator)buttonIndicatior;

- (instancetype)initWithFrame:(CGRect)frame buttonTitle:(NSString *)buttonTitle buttonImageName:(NSString *)buttonImageName buttonIndicator:(WXYZ_CustomButtonIndicator)buttonIndicatior showMaskView:(BOOL)showMaskView;

- (instancetype)initWithFrame:(CGRect)frame buttonTitle:(NSString *)buttonTitle buttonSubTitle:(NSString *)buttonSubTitle buttonImageName:(NSString *)buttonImageName buttonIndicator:(WXYZ_CustomButtonIndicator)buttonIndicatior showMaskView:(BOOL)showMaskView;

// 撤销遮盖层
- (void)undoMaskView;

// 图片 开始旋转
- (void)startSpin;

// 图片 停止旋转
- (void)stopSpin;

@end

NS_ASSUME_NONNULL_END

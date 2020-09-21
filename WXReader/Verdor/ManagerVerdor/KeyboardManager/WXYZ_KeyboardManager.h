//
//  WXYZ_KeyboardManager.h
//  WXReader
//
//  Created by Andrew on 2020/7/4.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_KeyboardManager : NSObject

// 键盘高度改变
@property (nonatomic, copy) void (^keyboardHeightChanged)(CGFloat keyboardHeight, CGFloat shouldMoveDistance, CGRect shouldMoveFrame);

// 输入框与键盘间距 default 10
@property (nonatomic, assign) CGFloat spacingFromKeyboard;

// 是否添加键盘工具条 default YES
@property (nonatomic, assign) BOOL showToolBar;

// 主移动视图
@property (nonatomic, strong) UIView *adaptiveMovementView;

- (instancetype)initObserverWithAdaptiveMovementView:(UIView *)adaptiveMovementView;

- (void)startKeyboardObserver;

- (void)stopKeyboardObserver;

+ (void)hideKeyboard;

@end

NS_ASSUME_NONNULL_END

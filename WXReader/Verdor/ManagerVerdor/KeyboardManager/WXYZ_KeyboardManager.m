//
//  WXYZ_KeyboardManager.m
//  WXReader
//
//  Created by Andrew on 2020/7/4.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_KeyboardManager.h"

@interface WXYZ_KeyboardManager ()

@property (nonatomic, strong) UIToolbar *toolBar;

@end

@implementation WXYZ_KeyboardManager
{
    UIView *_observerSuperView;
    
    // 被遮挡时,控件需移动距离
    CGFloat shouldMoveDistance;
    
    // 原父控件frame
    NSValue *tempSuperViewFrame;
    
    // 键盘是否显示
    BOOL _keyboardShowing;
    
    // 监听是否已添加
    BOOL _observerSeted;
    
}

- (instancetype)initObserverWithAdaptiveMovementView:(UIView *)adaptiveMovementView
{
    if (self = [super init]) {
        _observerSuperView = adaptiveMovementView;
        _spacingFromKeyboard = 10;
        _showToolBar = YES;
        _keyboardShowing = NO;
        _observerSeted = NO;
        [self toolBar];
        [self startKeyboardObserver];
    }
    return self;
}

- (void)startKeyboardObserver
{
    if (_observerSeted) {
        return;
    }
    _observerSeted = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstResponderDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstResponderDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowWithNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideWithNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)stopKeyboardObserver
{
    if (!_observerSeted) {
        return;
    }
    _observerSeted = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)firstResponderDidBeginEditing:(NSNotification *)notification
{
    [self setKeyboardToolBarForView:notification.object];
}

- (void)keyboardWillShowWithNotification:(NSNotification *)notification
{
    CGRect startFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
     if (startFrame.size.height > 0 && !_keyboardShowing) {
         
         _keyboardShowing = YES;
         
         UITextView *firstResponder = (UITextView *)[self findFirstResponderFromView:_observerSuperView];
         
         // 屏蔽网页
         if ([firstResponder isKindOfClass:NSClassFromString(@"WKContentView")] || !_observerSuperView || !firstResponder) {
             return ;
         }
         
         [self setKeyboardToolBarForView:firstResponder];
         
         CGFloat keyboardHeight = [self getKeyboardSizeWithKeyboardInfo:[notification userInfo]].height;
         
         CGRect firstResponderFrame = [_observerSuperView convertRect:firstResponder.frame toView:kMainWindow];
         
         shouldMoveDistance = CGRectGetMaxY(firstResponderFrame) - (kMainWindow.height - keyboardHeight) + _spacingFromKeyboard;
         
         // 没有遮挡输入框
         if (shouldMoveDistance < 0) {
             shouldMoveDistance = 0;
             return;
         }
         
         tempSuperViewFrame = [NSValue valueWithCGRect:_observerSuperView.frame];
         
         // 移动后的frame
         CGRect newSuperViewFrame = CGRectMake(_observerSuperView.origin.x, CGRectGetMaxY(_observerSuperView.frame) - shouldMoveDistance - _observerSuperView.size.height, _observerSuperView.size.width, _observerSuperView.size.height);
         
         if (self.keyboardHeightChanged) {
             NSLog(@"%lf", shouldMoveDistance);
             self.keyboardHeightChanged(keyboardHeight, - shouldMoveDistance, newSuperViewFrame);
         }
     }
}

- (void)keyboardWillHideWithNotification:(NSNotification *)notification
{
    if (shouldMoveDistance > 0 && _keyboardShowing) {
        if (self.keyboardHeightChanged) {
            self.keyboardHeightChanged(0, shouldMoveDistance, tempSuperViewFrame.CGRectValue);
        }
    }
    
    _keyboardShowing = NO;
    shouldMoveDistance = 0;
    tempSuperViewFrame = nil;
}

#pragma mark - tool

- (UIView *)findFirstResponderFromView:(UIView *)view
{
    if (view.isFirstResponder) {
        return view;
    }
    for (UIView *subView in view.subviews) {
        UIView * firstResponder = [self findFirstResponderFromView:subView];
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
    return nil;
}

- (CGSize)getKeyboardSizeWithKeyboardInfo:(NSDictionary *)keyboardInfo
{
    NSValue *value = [keyboardInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    return [value CGRectValue].size;
}

- (void)setKeyboardToolBarForView:(UITextView *)view
{
    if (self.showToolBar) {
        if (!view.inputAccessoryView || view.inputAccessoryView == nil) {
            view.inputAccessoryView = self.toolBar;
        }
    } else {
        view.inputAccessoryView = nil;
    }
}

- (void)setAdaptiveMovementView:(UIView *)adaptiveMovementView
{
    _adaptiveMovementView = adaptiveMovementView;
    _observerSuperView = adaptiveMovementView;
}

- (UIToolbar *)toolBar
{
    if (!_toolBar) {
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        _toolBar.barStyle = UIBarStyleDefault;
        
        UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(hideKeyboard)];
        
        [_toolBar setItems:@[flexibleSpaceItem, doneItem]];
    }
    return _toolBar;
}

- (void)hideKeyboard
{
    [WXYZ_KeyboardManager hideKeyboard];
}

+ (void)hideKeyboard
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)dealloc
{
    [self stopKeyboardObserver];
}

@end

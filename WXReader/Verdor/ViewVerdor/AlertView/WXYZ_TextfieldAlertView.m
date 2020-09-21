//
//  DPTextfieldAlertView.m
//  WXDating
//
//  Created by Andrew on 2017/12/13.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "WXYZ_TextfieldAlertView.h"
#import "WXYZ_KeyboardManager.h"

@implementation WXYZ_TextfieldAlertView
{
    UITextField *alertTF;
    WXYZ_KeyboardManager *keyboardManager;
}

- (void)createSubviews
{
    [super createSubviews];
    
    alertTF = [[UITextField alloc] init];
    alertTF.backgroundColor = [UIColor clearColor];
    alertTF.font = kMainFont;
    alertTF.textColor = [UIColor blackColor];
    alertTF.textAlignment = NSTextAlignmentLeft;
    alertTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    alertTF.layer.borderColor = kColorRGBA(235, 235, 241, 1).CGColor;
    alertTF.layer.borderWidth = 1;
    alertTF.layer.cornerRadius = 8;
    alertTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    alertTF.leftViewMode = UITextFieldViewModeAlways;
    [self.alertBackView addSubview:alertTF];
    
    [self.confirmButton addTarget:self action:@selector(confirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    WS(weakSelf)
    keyboardManager = [[WXYZ_KeyboardManager alloc] initObserverWithAdaptiveMovementView:self.alertBackView];
    keyboardManager.spacingFromKeyboard = 80;
    keyboardManager.keyboardHeightChanged = ^(CGFloat keyboardHeight, CGFloat shouldMoveDistance, CGRect shouldMoveFrame) {
        weakSelf.alertBackView.frame = shouldMoveFrame;
    };
}

- (void)showAlertView
{
    [super showAlertView];
    
    [alertTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.alertViewTitleLabel.mas_left);
        make.right.mas_equalTo(self.alertViewTitleLabel.mas_right);
        make.top.mas_equalTo(self.alertViewContentScrollView.mas_bottom).with.offset(kHalfMargin);
        make.height.mas_equalTo(self.alertViewButtonHeight);
    }];
    
    [self.cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.alertBackView.mas_left).with.offset(0);
        make.top.mas_equalTo(alertTF.mas_bottom).with.offset(kMargin);
        make.height.mas_equalTo(self.alertViewButtonHeight);
        make.width.mas_equalTo(self.alertViewWidth / 2);
    }];
    
    [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.alertBackView.mas_right).with.offset(0);
        make.top.mas_equalTo(alertTF.mas_bottom).with.offset(kMargin);
        make.height.mas_equalTo(self.alertViewButtonHeight);
        make.width.mas_equalTo(self.alertViewWidth / 2);
    }];
    
}

- (void)setPlaceHoldTitle:(NSString *)placeHoldTitle
{
    _placeHoldTitle = placeHoldTitle;
    alertTF.text = placeHoldTitle;
}

- (void)confirmButtonClick
{
    alertTF.text = [alertTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (alertTF.text.length == 0) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"昵称不能为空"];
        return;
    }
    
    if ([self.placeHoldTitle isEqualToString:alertTF.text]) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"昵称没有变化哦"];
        return;
    }
    
    if (self.endEditedBlock) {
        self.endEditedBlock(alertTF.text);
    }
    [self closeAlertView];
}

- (void)dealloc
{
    [keyboardManager stopKeyboardObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

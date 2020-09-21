//
//  WXYZ_BindPhoneViewController.m
//  WXReader
//
//  Created by Andrew on 2018/7/27.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BindPhoneViewController.h"
#import "WXYZ_SendCodeButton.h"

@interface WXYZ_BindPhoneViewController ()
{
    UITextField *usernameTF;
    UITextField *passwordTF;
    UIButton *loginButton;
    WXYZ_SendCodeButton *sendCodeButton;
}
@end

@implementation WXYZ_BindPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarDefaultStyle];
}

- (void)initialize
{
    [self setNavigationBarTitle:@"绑定手机号"];
}

- (void)createSubviews
{
    usernameTF = [[UITextField alloc] init];
    usernameTF.backgroundColor = [UIColor clearColor];
    usernameTF.keyboardType = UIKeyboardTypePhonePad;
    usernameTF.font = kFont15;
    usernameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    usernameTF.textColor = kBlackColor;
    NSMutableAttributedString *usernameTFAttributedString = [[NSMutableAttributedString alloc] initWithString:@"手机号"];
    [usernameTFAttributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kFontSize15], NSForegroundColorAttributeName:kColorRGBA(199, 199, 205, 1)} range:NSMakeRange(0, 3)];
    usernameTF.attributedPlaceholder = usernameTFAttributedString;
    [usernameTF addTarget:self action:@selector(textFieldChange) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:usernameTF];
    
    [usernameTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT + 30);
        make.width.mas_equalTo(SCREEN_WIDTH - 2 * kMargin);
        make.height.mas_equalTo(55);
    }];
    
    passwordTF = [[UITextField alloc] init];
    passwordTF.backgroundColor = [UIColor clearColor];
    passwordTF.keyboardType = UIKeyboardTypePhonePad;
    passwordTF.font = kFont15;
    passwordTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordTF.textColor = kBlackColor;
    NSMutableAttributedString *passwordTFAttributedString = [[NSMutableAttributedString alloc] initWithString:@"验证码"];
    [passwordTFAttributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kFontSize15], NSForegroundColorAttributeName:kColorRGBA(199, 199, 205, 1)} range:NSMakeRange(0, 3)];
    passwordTF.attributedPlaceholder = passwordTFAttributedString;
    [passwordTF addTarget:self action:@selector(textFieldChange) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:passwordTF];
    
    [passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(usernameTF.mas_bottom).offset(5);
        make.left.right.height.equalTo(usernameTF);
    }];
    
    sendCodeButton = [[WXYZ_SendCodeButton alloc] initWithFrame:CGRectMake(0, 0, 90, 20) identify:@"login_timer"];
    sendCodeButton.userInteractionEnabled = NO;
    sendCodeButton.backgroundColor = [UIColor clearColor];
    [sendCodeButton.titleLabel setFont:kMainFont];
    [sendCodeButton setTitleColor:kColorRGBA(199, 199, 205, 1) forState:UIControlStateNormal];
    [sendCodeButton addTarget:self action:@selector(sendCodeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendCodeButton];
    [sendCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.centerY.equalTo(passwordTF);
        if (sendCodeButton.countdownState) {
            make.width.mas_equalTo(160);
        } else {
            make.width.mas_equalTo(sendCodeButton.intrinsicContentSize.width + kMargin);
        }
        make.height.mas_equalTo(sendCodeButton.titleLabel.intrinsicContentSize.height);
    }];
    
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.userInteractionEnabled = NO;
    loginButton.backgroundColor = kColorRGBA(229, 230, 231, 1);
    loginButton.layer.cornerRadius = 20;
    loginButton.clipsToBounds = YES;
    [loginButton setTitle:@"确定" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [loginButton.titleLabel setFont:kFont15];
    [loginButton addTarget:self action:@selector(bindPhoneRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.top.mas_equalTo(passwordTF.mas_bottom).with.offset(60);
        make.width.mas_equalTo(passwordTF.mas_width);
        make.height.mas_equalTo(40);
    }];
}

- (void)textFieldChange
{
    if (usernameTF.text.length == 11) {
        sendCodeButton.userInteractionEnabled = YES;
        [sendCodeButton setTitleColor:kRedColor forState:UIControlStateNormal];
    } else {
        sendCodeButton.userInteractionEnabled = NO;
        [sendCodeButton setTitleColor:kColorRGBA(199, 199, 205, 1) forState:UIControlStateNormal];
    }
    
    if (usernameTF.text.length == 11 && passwordTF.text.length > 0) {
        loginButton.userInteractionEnabled = YES;
        loginButton.backgroundColor = kRedColor;
        [loginButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    } else {
        loginButton.userInteractionEnabled = NO;
        loginButton.backgroundColor = kColorRGBA(229, 230, 231, 1);
        [loginButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [usernameTF addBorderLineWithBorderWidth:0.5 borderColor:kGrayLineColor cornerRadius:0 borderType:UIBorderSideTypeBottom];
    [passwordTF addBorderLineWithBorderWidth:0.5 borderColor:kGrayLineColor cornerRadius:0 borderType:UIBorderSideTypeBottom];
    [sendCodeButton addBorderLineWithBorderWidth:0.5 borderColor:kGrayLineColor cornerRadius:0 borderType:UIBorderSideTypeLeft];
}
- (void)sendCodeButtonClick
{
    sendCodeButton.userInteractionEnabled = NO;
    
    [WXYZ_NetworkRequestManger POST:Send_Verification_Code parameters:@{@"mobile":usernameTF.text} model:nil success:^(BOOL isSuccess, id  _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            [self->sendCodeButton startTiming];
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"验证码已发送"];
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        }
        self->sendCodeButton.userInteractionEnabled = YES;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
        self->sendCodeButton.userInteractionEnabled = YES;
    }];
}

- (void)bindPhoneRequest
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Phone_Binding parameters:@{@"mobile":usernameTF.text, @"code":passwordTF.text} model:nil success:^(BOOL isSuccess, id  _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            [weakSelf performSelector:@selector(bindSuccess) withObject:nil afterDelay:0.5];
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
            self->loginButton.userInteractionEnabled = YES;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
        self->loginButton.userInteractionEnabled = YES;
    }];
}

- (void)bindSuccess
{
    WS(weakSelf)
    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"绑定成功" completionHandler:^{
        [weakSelf popViewController];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [usernameTF resignFirstResponder];
    [passwordTF resignFirstResponder];
}

@end

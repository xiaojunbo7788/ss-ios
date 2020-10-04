//
//  WXYZ_LoginViewController.m
//  WXReader
//
//  Created by Andrew on 2018/7/6.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_LoginViewController.h"

#import "WXYZ_WebViewViewController.h"
#import "WXYZ_SendCodeButton.h"
#import "AppDelegate.h"

#import "NSObject+Observer.h"
#import "UIView+layoutCallback.h"

#import "WXYZ_KeyboardManager.h"
#import <CloudPushSDK/CloudPushSDK.h>
#if WX_WeChat_Login_Mode
    #import "WXYZ_WechatManager.h"
#endif
#if WX_QQ_Login_Mode
    #import "WXYZ_QQManager.h"
#endif
#if WX_WeChat_Login_Mode || WX_QQ_Login_Mode
    #import "WXYZ_AppleSignManager.h"
#endif



@interface WXYZ_LoginViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate
#if WX_WeChat_Login_Mode
, WXYZ_WeChatManagerDelegate
#endif
#if WX_QQ_Login_Mode
, WXYZ_QQManagerDelegate
#endif
#if WX_QQ_Login_Mode || WX_WeChat_Login_Mode
, WXYZ_AppleSignManagerDelegate
#endif
>
{
    WXYZ_KeyboardManager *keyboardManager;
}

@property (nonatomic, copy) void(^completeBlock)(WXYZ_UserInfoManager *userDataModel);

/** 第三方登录图标、文本数组  */
@property (nonatomic, copy) NSArray<NSDictionary <NSString *, UIImage *>*> *thirdPartyArray;

/** 电话号码输入框 */
@property (nonatomic, weak) UITextField *phoneTextField;

/** 验证码输入框 */
@property (nonatomic, weak) UITextField *codeTextField;

/** 发送验证码按钮 */
@property (nonatomic, weak) WXYZ_SendCodeButton *sendCodeButton;

/** 登录按钮 */
@property (nonatomic, weak) UIButton *loginButton;

@property (nonatomic, strong) NSPredicate *predicate;

@end

@implementation WXYZ_LoginViewController

#pragma mark - Public
+ (void)presentLoginView {
    WXYZ_NavigationController *nav = [[WXYZ_NavigationController alloc] initWithRootViewController:[[self alloc] init]];
    [[WXYZ_ViewHelper getWindowRootController] presentViewController:nav animated:YES completion:nil];
}

+ (void)presentLoginView:(void(^)(WXYZ_UserInfoManager *userDataModel))complete {
    WXYZ_LoginViewController *vc = [[self alloc] init];
    vc.completeBlock = complete;
    WXYZ_NavigationController *nav = [[WXYZ_NavigationController alloc] initWithRootViewController:vc];
    [[WXYZ_ViewHelper getWindowRootController] presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Private
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
}


- (void)initialize {
    [self hiddenNavigationBarLeftButton];
    [self setNavigationBarTitle:@"手机号快捷登录"];
    [self hiddenSeparator];
    UIButton *_rightButton;
    [self setNavigationBarRightButton:({
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _rightButton = rightButton;
        [rightButton setImage:[[UIImage imageNamed:@"public_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        rightButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        WS(weakSelf);
        [rightButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            [weakSelf closeView:nil];
        }]];
        rightButton;
    })];
    [_rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navigationBar.navTitleLabel.mas_centerY);
        make.right.equalTo(self.view.mas_right).offset(-kMargin);
        make.width.height.mas_equalTo(40.0);
    }];
    
    self.predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[0-9]*"];
    
#if WX_WeChat_Login_Mode
    [WXYZ_WechatManager sharedManager].delegate = self;
#endif
#if WX_QQ_Login_Mode
    [WXYZ_QQManager sharedManager].delegate = self;
#endif
#if WX_WeChat_Login_Mode || WX_QQ_Login_Mode
    [WXYZ_AppleSignManager sharedManager].delegate = self;
#endif
}

- (void)createSubviews {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, PUB_TABBAR_OFFSET, 0);
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(PUB_NAVBAR_HEIGHT);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = scrollView.backgroundColor;
    [scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.width.equalTo(scrollView);
    }];
    
    UITextField *phoneTextField = ({
        UITextField *phoneTextField = [[UITextField alloc] init];
        phoneTextField.backgroundColor = [UIColor whiteColor];
        phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        phoneTextField.font = kFont15;
        phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        phoneTextField.textColor = kBlackColor;
        phoneTextField.placeholder = @"手机号";
        phoneTextField.delegate = self;
        phoneTextField.frameBlock = ^(UIView * _Nonnull view) {
            [view addBorderLineWithBorderWidth:kCellLineHeight borderColor:kGrayLineColor cornerRadius:0 borderType:UIBorderSideTypeBottom];
        };
        phoneTextField;
    });
    self.phoneTextField = phoneTextField;
    [contentView addSubview:phoneTextField];
    [phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(2 * kMargin);
        make.top.equalTo(contentView.mas_top).offset(kLineY(56.0));
        make.right.equalTo(self.view.mas_right).offset(-2 * kMargin);
        make.height.equalTo(phoneTextField.mas_width).multipliedBy(61.0 / 334.0);
    }];
    
    UITextField *codeTextField = ({
        UITextField *codeTextField = [[UITextField alloc] init];
        codeTextField.backgroundColor = phoneTextField.backgroundColor;
        codeTextField.keyboardType = phoneTextField.keyboardType;
        codeTextField.font = phoneTextField.font;
        codeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        codeTextField.textColor = phoneTextField.textColor;
        codeTextField.placeholder = @"验证码";
        codeTextField.delegate = self;
        codeTextField.frameBlock = ^(UIView * _Nonnull view) {
            [view addBorderLineWithBorderWidth:kCellLineHeight borderColor:kGrayLineColor cornerRadius:0 borderType:UIBorderSideTypeBottom];
        };
        codeTextField;
    });
    self.codeTextField = codeTextField;
    [contentView addSubview:codeTextField];
    [codeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(phoneTextField);
        make.top.equalTo(phoneTextField.mas_bottom).offset(kMargin);
    }];
    
    WXYZ_SendCodeButton *sendCodeButton = ({
        WXYZ_SendCodeButton *sendCodeButton = [[WXYZ_SendCodeButton alloc] initWithFrame:CGRectZero identify:@"login_timer"];
        sendCodeButton.backgroundColor = [UIColor whiteColor];
        sendCodeButton.enabled = NO;
        sendCodeButton.titleLabel.font = kMainFont;
        [sendCodeButton setTitleColor:kRedColor forState:UIControlStateNormal];
        [sendCodeButton setTitleColor:kColorRGB(199, 199, 205) forState:UIControlStateDisabled];
        sendCodeButton.frameBlock = ^(UIButton * _Nonnull button) {
            [button addBorderLineWithBorderWidth:kCellLineHeight borderColor:kGrayLineColor cornerRadius:0 borderType:UIBorderSideTypeLeft];
        };
        [sendCodeButton addTarget:self action:@selector(sendCodeEvent:) forControlEvents:UIControlEventTouchUpInside];
        sendCodeButton;
    });
    self.sendCodeButton = sendCodeButton;
    [contentView addSubview:sendCodeButton];
    [sendCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.centerY.equalTo(codeTextField);
        if (sendCodeButton.countdownState) {
            make.width.mas_equalTo(160);
        } else {
            make.width.mas_equalTo(sendCodeButton.intrinsicContentSize.width + kMargin);
        }
        make.height.mas_equalTo(sendCodeButton.titleLabel.intrinsicContentSize.height);
    }];
    
    UIButton *loginButton = ({
        loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        loginButton.clipsToBounds = YES;
        [loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [loginButton.titleLabel setFont:kFont15];
        [loginButton addObserver:KEY_PATH(loginButton, enabled) complete:^(UIButton * _Nonnull obj, id  _Nullable oldVal, id  _Nullable newVal) {
            obj.backgroundColor = [newVal boolValue] ? kRedColor : kColorRGBA(229, 230, 231, 1);
        }];
        loginButton.enabled = NO;
        loginButton.frameBlock = ^(UIButton * _Nonnull button) {
            button.layer.cornerRadius = (CGRectGetWidth(button.bounds) + CGRectGetHeight(button.bounds)) * 0.058;
        };
        [loginButton addTarget:self action:@selector(loginEvent:) forControlEvents:UIControlEventTouchUpInside];
        loginButton;
    });
    self.loginButton = loginButton;
    [contentView addSubview:loginButton];
    [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(phoneTextField);
        make.top.equalTo(codeTextField.mas_bottom).offset(is_iPhone4 || is_iPhone5 ? 40 : 60);
        make.height.equalTo(loginButton.mas_width).multipliedBy(44.0 / 334.0);
    }];
    
    // 观察电话号码输入框文字变化
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:phoneTextField queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if (phoneTextField.text.length > 11) {
            phoneTextField.text = [phoneTextField.text substringToIndex:11];
            return ;
        }
        if (sendCodeButton.countdownState == NO) {
            sendCodeButton.enabled = phoneTextField.text.length == 11;
        }
        loginButton.enabled = phoneTextField.text.length == 11 && codeTextField.text.length > 0;
    }];
        
    // 观察验证码输入框文字变化
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:codeTextField queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if (codeTextField.text.length > 4) {
            codeTextField.text = [codeTextField.text substringToIndex:4];
            return ;
        }
        loginButton.enabled = phoneTextField.text.length == 11 && codeTextField.text.length > 0;
    }];
    
    UILabel *thirdPartyLabel = ({
        UILabel *thirdPartyLabel = [[UILabel alloc] init];
        thirdPartyLabel.text = @"第三方帐号登录";
        thirdPartyLabel.textAlignment = NSTextAlignmentCenter;
        thirdPartyLabel.textColor = kGrayTextColor;
        thirdPartyLabel.backgroundColor = [UIColor whiteColor];
        thirdPartyLabel.font = kFont10;
        thirdPartyLabel.frameBlock = ^(UIView * _Nonnull view) {
            // 设置文字分割线
            CALayer *splitLine = [CALayer layer];
            splitLine.backgroundColor = kGrayLineColor.CGColor;
            splitLine.anchorPoint = CGPointMake(0, 0);
            splitLine.frame = CGRectMake(2 * kMargin, view.frame.origin.y + view.frame.size.height / 2.0, SCREEN_WIDTH - 2 * kMargin * 2, kCellLineHeight);
            [contentView.layer addSublayer:splitLine];
            splitLine.hidden = view.hidden;
            [contentView bringSubviewToFront:view];
        };
        thirdPartyLabel;
    });
    [contentView addSubview:thirdPartyLabel];
    [thirdPartyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(loginButton.mas_bottom).offset(is_iPhone4 || is_iPhone5 ? 40 : 60);
        make.width.mas_equalTo(thirdPartyLabel.intrinsicContentSize.width + 20.0f);
    }];
    
    if (self.thirdPartyArray.count == 0) {
        thirdPartyLabel.hidden = YES;
    }
    
    UICollectionViewFlowLayout *flowLayout = ({
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.estimatedItemSize = CGSizeMake(50 + 10, 20);// 50 + 10(前者表示文字宽度，后者表示左右间距)
        flowLayout.minimumInteritemSpacing = is_iPhone4 || is_iPhone5 ? 10.0f : 20.0f;
        flowLayout;
    });

    UICollectionView *thirdPartyView = ({
        UICollectionView *thirdPartyView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [thirdPartyView registerClass:WXYZ_LoginViewCell.class forCellWithReuseIdentifier:kLoginViewCellIdentifier];
        thirdPartyView.backgroundColor = [UIColor clearColor];
        thirdPartyView.dataSource = self;
        thirdPartyView.delegate = self;
        thirdPartyView.showsHorizontalScrollIndicator = NO;
        [thirdPartyView addObserver:KEY_PATH(thirdPartyView, contentSize) complete:^(UICollectionView * _Nonnull obj, id  _Nullable oldVal, id  _Nullable newVal) {
            CGSize size = [newVal CGSizeValue];
            [obj mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(size.height);
            }];
        }];
        thirdPartyView;
    });
    [contentView addSubview:thirdPartyView];
    [thirdPartyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        CGFloat width = flowLayout.estimatedItemSize.width * self.thirdPartyArray.count + (self.thirdPartyArray.count - 1) * flowLayout.minimumInteritemSpacing;
        if (width > SCREEN_WIDTH) width = SCREEN_WIDTH;
        make.size.mas_equalTo(CGSizeMake(width, 65));
        make.top.equalTo(thirdPartyLabel.mas_bottom).offset(kMargin);
    }];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"点击登录即表示已同意「%@」《用户协议》", App_Name]];
    text.lineSpacing = 5;
    text.font = kFont10;
    text.color = kGrayTextColor;
    WS(weakSelf)
    [text setTextHighlightRange:NSMakeRange(12 + App_Name.length, 6) color:kMainColor backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        WXYZ_WebViewViewController *vc = [[WXYZ_WebViewViewController alloc] init];
        vc.isPresentState = NO;
        vc.navTitle = @"用户协议";
        AppDelegate *delegate = (AppDelegate *)kRCodeSync([UIApplication sharedApplication].delegate);
        vc.URLString = delegate.checkSettingModel.protocol_list.user ?: [NSString stringWithFormat:@"%@%@", APIURL, Notify_Note];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];

    YYLabel *tipsLabel = ({
        YYLabel *tipsLabel = [[YYLabel alloc] init];
        tipsLabel.numberOfLines = 0;
        tipsLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 2 * kMargin;
        tipsLabel.attributedText = text;
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.userInteractionEnabled = YES;
        tipsLabel;
    });
    [contentView addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(- PUB_TABBAR_OFFSET - kMargin);
    }];
    
    // 页面高度确定线
    UIView *splitLine = [[UIView alloc] init];
    splitLine.backgroundColor = [UIColor redColor];
    [contentView addSubview:splitLine];
    [splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(contentView);
        make.height.mas_equalTo(0.1);
        make.top.equalTo(tipsLabel.mas_bottom).priorityLow();
    }];
    
    keyboardManager = [[WXYZ_KeyboardManager alloc] initObserverWithAdaptiveMovementView:scrollView];
    keyboardManager.keyboardHeightChanged = ^(CGFloat keyboardHeight, CGFloat shouldMoveDistance, CGRect shouldMoveFrame) {
        scrollView.frame = shouldMoveFrame;
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setStatusBarDefaultStyle];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [WXYZ_KeyboardManager hideKeyboard];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [WXYZ_KeyboardManager hideKeyboard];
}

// 电话号码输入框的“下一步”按钮响应事件
- (void)phoneDone {
    [self.codeTextField becomeFirstResponder];
    if (self.sendCodeButton.enabled) {
        [self.sendCodeButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

// 切换输入框的选择状态
- (void)textFieldSwitch {
    if (self.phoneTextField.isFirstResponder) {
        [self.codeTextField becomeFirstResponder];
    } else if (self.codeTextField.isFirstResponder) {
        [self.phoneTextField becomeFirstResponder];
    }
}

// 验证码输入框的“登录”按钮响应事件
- (void)signup {
    if (self.loginButton.enabled) {
        [self.codeTextField resignFirstResponder];
        [self.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)closeView:(void(^)(void))compltetion {
    [self syncUserGender];
    [self dismissViewControllerAnimated:YES completion:^{
        !compltetion ?: compltetion();
    }];
}

// 同步首次选择的用户性别
- (void)syncUserGender {
    if (WXYZ_UserInfoManager.isLogin && WXYZ_SystemInfoManager.firstGenderSelecte) {
        [WXYZ_NetworkRequestManger POST:Set_Gender parameters:@{@"gender" : WXYZ_SystemInfoManager.firstGenderSelecte, @"is_force" : @"0"} model:nil success:^(BOOL isSuccess, id  _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
            if (isSuccess) {
                WXYZ_SystemInfoManager.firstGenderSelecte = nil;
            }
        } failure:nil];
    }
}

- (NSArray<NSDictionary <NSString *, UIImage *>*> *)thirdPartyArray {
    if (_thirdPartyArray == nil) {
        NSMutableArray<NSDictionary <NSString *, UIImage *>*> *array = [NSMutableArray array];
        if (WX_Tourists_Login_Mode) {
            [array addObject:@{@"游客登录" : [YYImage imageNamed:@"login_visitor"]}];
        }
        BOOL status = NO;
#if WX_WeChat_Login_Mode
        if ([WXYZ_WechatManager isInstallWechat]) {
            [array addObject:@{@"微信登录" : [YYImage imageNamed:@"login_wechat"]}];
            status = YES;
        }
#endif
#if WX_QQ_Login_Mode
        if ([WXYZ_QQManager isInstallQQ]) {
            [array addObject:@{@"QQ登录" : [YYImage imageNamed:@"login_qq"]}];
            status = YES;
        }
#endif
        if (@available(iOS 13.0, *)) {
            if (status == YES) {
                [array addObject:@{@"Apple登录" : [YYImage imageNamed:@"login_apple"]}];
            }
        }
        _thirdPartyArray = array;
    }
    return _thirdPartyArray;
}

// 登录按钮点击事件
- (void)loginEvent:(UIButton *)button {
    self.view.userInteractionEnabled = NO;
    NSDictionary *params = @{
        @"mobile"    : self.phoneTextField.text,
        @"code"      : self.codeTextField.text,
        @"udid"      : [WXYZ_UtilsHelper getUDID] ?: @"",
        @"sysVer"    : [WXYZ_UtilsHelper getSystemVersion] ?: @"",
        @"device_id" : [CloudPushSDK getDeviceId] ?: @""
    };
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Mobile_Login parameters:params model:WXYZ_UserInfoManager.class success:^(BOOL isSuccess, WXYZ_UserInfoManager *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            !weakSelf.completeBlock ?: weakSelf.completeBlock(t_model);
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Login_Success object:t_model];
            [weakSelf closeView:^{
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"登录成功"];
            }];
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
            weakSelf.view.userInteractionEnabled = YES;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
        weakSelf.view.userInteractionEnabled = YES;
    }];
}

// 发送验证码
- (void)sendCodeEvent:(WXYZ_SendCodeButton *)button {
    [WXYZ_NetworkRequestManger POST:Send_Verification_Code parameters:@{@"mobile":self.phoneTextField.text} model:nil success:^(BOOL isSuccess, id _Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            [button startTiming];
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"验证码已发送"];
            [self.codeTextField becomeFirstResponder];
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
    }];
}

#if WX_WeChat_Login_Mode
- (void)weChatLoginClick {
    [[WXYZ_WechatManager sharedManager] tunedUpWechatWithState:WXYZ_WechatStateLogin];
}

#pragma mark - WXYZ_WeChatManagerDelegate
- (void)wechatResponseSuccess:(WXYZ_UserInfoManager *)userData {
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Login_Success object:nil];
    if (self.completeBlock) {
        self.completeBlock(userData);
    }
    [self closeView:^{
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"登录成功"];
    }];
}

- (void)wechatResponseFail:(NSString *)error {
    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:error];
}
#endif

#if WX_QQ_Login_Mode
- (void)qqLoginClick {
    [[WXYZ_QQManager sharedManager] tunedUpQQWithState:WXYZ_QQStateLogin];
}

#pragma mark - WXYZ_QQManagerDelegate
- (void)qqResponseSuccess:(WXYZ_UserInfoManager *)userData {
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Login_Success object:nil];
    if (self.completeBlock) {
        self.completeBlock(userData);
    }
    [self closeView:^{
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"登录成功"];
    }];
}

- (void)qqResponseFail:(NSString *)error {
    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:error];
}
#endif

#if WX_QQ_Login_Mode || WX_WeChat_Login_Mode
- (void)appleSignLoginClick {
    if (@available(iOS 13.0, *)) {
        [[WXYZ_AppleSignManager sharedManager] tunedUpAppleSignWithState:WXYZ_AppleSignStateLogin];
    }
}

#pragma mark - WXYZ_AppleSignManagerDelegate
- (void)appleSignResponseSuccess:(WXYZ_UserInfoManager *)userData {
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Login_Success object:nil];
    if (self.completeBlock) {
        self.completeBlock(userData);
    }
    [self closeView:^{
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"登录成功"];
    }];
}

- (void)appleSignResponseFail:(NSString *)error {
    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:error];
}
#endif

#if WX_Tourists_Login_Mode
- (void)touristsLogin {
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Tourists_Login parameters:@{@"udid":[WXYZ_UtilsHelper getUDID]} model:WXYZ_UserInfoManager.class success:^(BOOL isSuccess, WXYZ_UserInfoManager *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Login_Success object:t_model];
            !weakSelf.completeBlock ?: weakSelf.completeBlock(t_model);
            [weakSelf closeView:^{
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"登录成功"];
            }];
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
    }];
}
#endif

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [self.predicate evaluateWithObject:string];
}




#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.thirdPartyArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WXYZ_LoginViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kLoginViewCellIdentifier forIndexPath:indexPath];
    [cell dataInput:self.thirdPartyArray[indexPath.row]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.thirdPartyArray[indexPath.row];
    NSString *name = dict.allKeys.firstObject;
    
    if ([name isEqualToString:@"游客登录"]) {
#if WX_Tourists_Login_Mode
        [self touristsLogin];
#endif
        return ;
    }
    
    if ([name isEqualToString:@"微信登录"]) {
#if WX_WeChat_Login_Mode
        [self weChatLoginClick];
#endif
        return ;
    }
    
    if ([name isEqualToString:@"QQ登录"]) {
#if WX_QQ_Login_Mode
        [self qqLoginClick];
#endif
        return ;
    }
    
    if ([name isEqualToString:@"Apple登录"]) {
#if WX_WeChat_Login_Mode || WX_QQ_Login_Mode
        [self appleSignLoginClick];
#endif
        return ;
    }
}

- (void)dealloc
{
    [keyboardManager stopKeyboardObserver];
}

@end



@implementation WXYZ_LoginViewCell {
    UIImageView *_iconImageView;
    UILabel *_descLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews {
    UIImageView *iconImageView = [[UIImageView alloc] init];
    _iconImageView = iconImageView;
    [self.contentView addSubview:iconImageView];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.width.height.mas_equalTo(kGeometricWidth(SCREEN_WIDTH, 45.0, 375.0));
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.textAlignment = NSTextAlignmentCenter;
    descLabel.textColor = kGrayTextColor;
    descLabel.font = kFont11;
    _descLabel = descLabel;
    [self.contentView addSubview:descLabel];
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(iconImageView.mas_bottom).offset(6.0f).priorityLow();
    }];
}

- (void)dataInput:(NSDictionary<NSString *, UIImage *> *)dict {
    _iconImageView.image = dict.allValues.firstObject;
    _descLabel.text = dict.allKeys.firstObject;
}

- (void)dealloc {
    NSLog(@"释放");
}

@end

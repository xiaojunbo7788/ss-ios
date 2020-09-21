//
//  WXYZ_AgreementAlertView.m
//  WXReader
//
//  Created by Andrew on 2020/1/7.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AgreementAlertView.h"
#import "WXYZ_WebViewViewController.h"
#import "AppDelegate.h"

@implementation WXYZ_AgreementAlertView

- (void)createSubviews
{
    [super createSubviews];
    
    UIView *backgroundView = ({/**< 穿山甲的背景视图，解决穿山甲加载广告期间的空白页面*/
        NSString *lauchStoryboardName = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchStoryboardName"];
        UIViewController *launchScreen = [[UIStoryboard storyboardWithName:lauchStoryboardName bundle:nil] instantiateInitialViewController];
        UIView *backgroundView = launchScreen.view;
        backgroundView.backgroundColor = [UIColor whiteColor];
        backgroundView.frame = self.window.bounds;
        backgroundView;
    });
    [self addSubview:backgroundView];
    [self sendSubviewToBack:backgroundView];
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UIView *shadowView = [[UIView alloc] init];
    shadowView.backgroundColor = kColorRGBA(0, 0, 0, 0.3);
    [backgroundView addSubview:shadowView];
    [shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(backgroundView);
    }];
    
    self.alertViewDisappearType = WXYZ_AlertViewDisappearTypeConfirm;

    self.closeButton.hidden = YES;
    
    self.alertViewTitle = @"用户隐私保护提示";
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@为了更好的保护您的隐私和信息安全，根据国家相关法律规定和国家标准制定并执行《%@隐私政策》及《软件许可及服务协议》，请您在使用前务必仔细阅读并透彻理解，如果您继续使用本产品即代表您同意本平台的协议条款，我们会全力保护您的个人信息安全。", App_Name, App_Name]];
    [str setColor:kColorRGB(102, 102, 102)];
    [str setFont:kMainFont];
    [str setLineSpacing:4];
    [str setTextHighlightRange:[str.string localizedStandardRangeOfString:[NSString stringWithFormat:@"《%@隐私政策》", App_Name]] color:kMainColor backgroundColor:[UIColor whiteColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        if (![WXYZ_ViewHelper getWindowRootController].presentedViewController) {
            WXYZ_WebViewViewController *vc = [[WXYZ_WebViewViewController alloc] init];
            vc.navTitle = @"隐私政策";
            AppDelegate *delegate = (AppDelegate *)kRCodeSync([UIApplication sharedApplication].delegate);
            vc.URLString = delegate.checkSettingModel.protocol_list.privacy ?: [NSString stringWithFormat:@"%@%@", APIURL, Privacy_Policy];
            vc.isPresentState = YES;
            [[WXYZ_ViewHelper getWindowRootController] presentViewController:vc animated:YES completion:nil];
        }
    }];

    [str setTextHighlightRange:[str.string localizedStandardRangeOfString:@"《软件许可及服务协议》"] color:kMainColor backgroundColor:[UIColor whiteColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        if (![WXYZ_ViewHelper getWindowRootController].presentedViewController) {
            WXYZ_WebViewViewController *vc = [[WXYZ_WebViewViewController alloc] init];
            vc.navTitle = @"软件许可及服务协议";
            vc.URLString = [NSString stringWithFormat:@"%@%@", APIURL, Notify_Note];
            vc.isPresentState = YES;
            [[WXYZ_ViewHelper getWindowRootController] presentViewController:vc animated:YES completion:nil];
        }
    }];
    self.alertViewDetailAttributeContent = str;
    
    self.alertViewCancelTitle = @"拒绝并退出";
    self.alertViewConfirmTitle = @"我已经阅读并同意";
    
    [self.cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmButton addTarget:self action:@selector(confirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showAlertView
{
    [super showAlertView];
}

- (void)willMoveToWindow:(nullable UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (!newWindow) {// 跳转到协议时newWindow会为空
        [UIApplication sharedApplication].statusBarHidden = NO;
    } else {
        [UIApplication sharedApplication].statusBarHidden = YES;
    }
}

- (void)cancelButtonClick {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [UIView animateWithDuration:kAnimatedDuration animations:^{
        window.alpha = 0;
        window.frame = CGRectMake(0, window.bounds.size.height / 2, window.bounds.size.width, 0.5);
    } completion:^(BOOL finished) {
        exit(0);
    }];
}

- (void)confirmButtonClick {
    [self closeAlertView];
    WXYZ_SystemInfoManager.agreementAllow = YES;
    !self.confirmButtonClickBlock ?: self.confirmButtonClickBlock();
}

@end

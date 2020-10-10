//
//  WebViewViewController.m
//  WXDating
//
//  Created by Andrew on 2017/12/13.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "WXYZ_WebViewViewController.h"
#import "WXYZ_WeakScriptMessageHandlerDelegate.h"
#import "WXYZ_ShareManager.h"
#import <WebKit/WKWebView.h>
#import <WebKit/WebKit.h>
#import "NSObject+Observer.h"

static void *WkwebBrowserContext = &WkwebBrowserContext;

@interface WXYZ_WebViewViewController () <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *WKWebView;

@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) NSMutableArray *snapShotsArray;
//返回按钮
@property (nonatomic, strong) UIButton *customBackButton;
//关闭按钮
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation WXYZ_WebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.isNoHiddenTab) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Hidden_Tabbar object:@"1"];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.WKWebView setNavigationDelegate:nil];
    [self.WKWebView setUIDelegate:nil];
    
    NSArray *t_arr = self.navigationController.viewControllers;
    if (t_arr.count == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Show_Tabbar object:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setStatusBarDefaultStyle];
     if (self.form != nil && self.form.length > 0) {
          [self.WKWebView loadHTMLString:_form baseURL:nil];
     }
    
}

- (void)initialize
{
    [self setNavigationBarTitle:self.navTitle];
    [self hiddenNavigationBarLeftButton];
    [self.navigationBar addSubview:self.customBackButton];
    [self.navigationBar addSubview:self.closeButton];
    
    [self.view addSubview:self.WKWebView];
    [self.view addSubview:self.progressView];
}

- (void)createSubviews
{
    if (self.form != nil && self.form.length > 0) {
        
    } else {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.URLString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    //加载网页
    [self.WKWebView loadRequest:request];
}
    
}

- (void)setForm:(NSString *)form {
    _form = form;
}

- (void)customBackItemClicked
{
    if (self.WKWebView.goBack) {
        [self.WKWebView goBack];
    } else {
        if (self.isPresentState) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)closeItemClicked
{
    if (self.isPresentState) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:@"share"]) {
        NSDictionary *dic = [WXYZ_UtilsHelper dictionaryWithJsonString:message.body];
        
        
        NSString *title = [WXYZ_UtilsHelper formatStringWithObject:[dic objectForKey:@"title"]];
        NSString *desc = [WXYZ_UtilsHelper formatStringWithObject:[dic objectForKey:@"desc"]];
        NSString *imageUrl = [WXYZ_UtilsHelper formatStringWithObject:[dic objectForKey:@"image"]];
        NSString *url = [WXYZ_UtilsHelper formatStringWithObject:[dic objectForKey:@"url"]];
        
        [[WXYZ_ShareManager sharedManager] shareApplicationInController:self shareTitle:title shareDescribe:desc shareImageURL:imageUrl shareUrl:url shareState:WXYZ_ShareStateAll];
    }
}

#pragma mark - WKUIDelegate

//这个是网页加载完成，导航的变化
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateNavigationItems];
}

//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    //开始加载的时候，让加载进度条显示
    self.progressView.hidden = NO;
}

//内容返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{}

//服务器请求跳转的时候调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    switch (navigationAction.navigationType) {
        case WKNavigationTypeLinkActivated: {
            [self pushCurrentSnapshotViewWithRequest:navigationAction.request];
            break;
        }
        case WKNavigationTypeFormSubmitted: {
            [self pushCurrentSnapshotViewWithRequest:navigationAction.request];
            break;
        }
        case WKNavigationTypeBackForward: {
            break;
        }
        case WKNavigationTypeReload: {
            break;
        }
        case WKNavigationTypeFormResubmitted: {
            break;
        }
        case WKNavigationTypeOther: {
            [self pushCurrentSnapshotViewWithRequest:navigationAction.request];
            break;
        }
        default: {
            break;
        }
    }
    [self updateNavigationItems];
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 内容加载失败时候调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
}

//跳转失败的时候调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{}

//进度条
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{}

- (void)updateNavigationItems
{
    if (self.WKWebView.canGoBack) {
        self.closeButton.hidden = NO;
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.closeButton.hidden = YES;
    }
}

//请求链接处理
- (void)pushCurrentSnapshotViewWithRequest:(NSURLRequest *)request
{
    NSURLRequest *lastRequest = (NSURLRequest *)[[self.snapShotsArray lastObject] objectForKey:@"request"];
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        return;
    }
    if ([lastRequest.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
        return;
    }
    
    UIView *currentSnapShotView = [self.WKWebView snapshotViewAfterScreenUpdates:YES];
    [self.snapShotsArray addObject:@{@"request":request,@"snapShotView":currentSnapShotView}];
}

#pragma mark - 懒加载
- (UIButton *)customBackButton
{
    if (!_customBackButton) {
        UIButton *backButton = [[UIButton alloc] init];
        backButton.frame = CGRectMake(kHalfMargin, PUB_NAVBAR_OFFSET + 20, 44, 44);
        [backButton.titleLabel setFont:kMainFont];
        [backButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [backButton setImage:[UIImage imageNamed:@"public_back"] forState:UIControlStateNormal];
        [backButton setImageEdgeInsets:UIEdgeInsetsMake(12, 6, 12, 18)];
        
        [backButton addTarget:self action:@selector(customBackItemClicked) forControlEvents:UIControlEventTouchUpInside];
        _customBackButton = backButton;
    }
    return _customBackButton;
}

- (UIButton *)closeButton
{
    if (!_closeButton) {
        UIButton *backButton = [[UIButton alloc] init];
        backButton.frame = CGRectMake(kHalfMargin + 44, PUB_NAVBAR_OFFSET + 20, 44, 44);
        backButton.hidden = YES;
        backButton.adjustsImageWhenHighlighted = NO;
        backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [backButton setTitle:@"关闭" forState:UIControlStateNormal];
        [backButton.titleLabel setFont:kMainFont];
        [backButton setTitleColor:kBlackColor forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(closeItemClicked) forControlEvents:UIControlEventTouchUpInside];
        _closeButton = backButton;
    }
    return _closeButton;
}

- (WKWebView *)WKWebView
{
    if (!_WKWebView) {
        //设置网页的配置文件
        WKWebViewConfiguration *Configuration = [[WKWebViewConfiguration alloc] init];
        //允许视频播放
        if (@available(iOS 9.0, *)) {
            Configuration.allowsAirPlayForMediaPlayback = YES;
        } else {
            // Fallback on earlier versions
        }
        // 允许在线播放
        Configuration.allowsInlineMediaPlayback = YES;
        // 允许可以与网页交互，选择视图
        Configuration.selectionGranularity = YES;
        // web内容处理池
        Configuration.processPool = [[WKProcessPool alloc] init];
        //自定义配置,一般用于 js调用oc方法(OC拦截URL中的数据做自定义操作)
        
        Configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        
        // 是否支持记忆读取
        Configuration.suppressesIncrementalRendering = YES;
        
        //实例化对象
        Configuration.userContentController = [WKUserContentController new];
        
        //调用JS方法
//        [Configuration.userContentController addScriptMessageHandler:self name:@"share"];
        [Configuration.userContentController addScriptMessageHandler:[[WXYZ_WeakScriptMessageHandlerDelegate alloc] initWithDelegate:self] name:@"handleGoMall"];
        
        _WKWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT) configuration:Configuration];
        _WKWebView.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
        // 设置代理
        _WKWebView.navigationDelegate = self;
        _WKWebView.UIDelegate = self;
        _WKWebView.configuration.allowsInlineMediaPlayback = YES;
        WS(weakSelf)
        //kvo 添加进度监控
        [_WKWebView addObserver:NSStringFromSelector(@selector(estimatedProgress)) complete:^(WKWebView * _Nonnull obj, id  _Nullable oldVal, id  _Nullable newVal) {
            [weakSelf.progressView setAlpha:1.0f];
            BOOL animated = obj.estimatedProgress > weakSelf.progressView.progress;
            [weakSelf.progressView setProgress:obj.estimatedProgress animated:animated];
            
            // Once complete, fade out UIProgressView
            if(obj.estimatedProgress >= 1.0f) {
                [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [weakSelf.progressView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [weakSelf.progressView setProgress:0.0f animated:NO];
                }];
            }
        }];
        //开启手势触摸
        _WKWebView.allowsBackForwardNavigationGestures = YES;
        // 设置 可以前进 和 后退
        //适应你设定的尺寸
        //        [_WKWebView evaluateJavaScript:@"share()" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        //            NSLog(@"");
        //        }];
        //        [_WKWebView sizeToFit];
    }
    return _WKWebView;
}

- (UIProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectMake(0, PUB_NAVBAR_HEIGHT, self.view.bounds.size.width, 3);
        _progressView.progressTintColor = kMainColor;
        [_progressView setTrackTintColor:[UIColor clearColor]];
    }
    return _progressView;
}

- (void)setOnTheFrontPage:(BOOL)OnTheFrontPage
{
    _OnTheFrontPage = OnTheFrontPage;
    if (OnTheFrontPage) {
        self.progressView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 3);
        self.WKWebView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT - PUB_TABBAR_HEIGHT);
    }
}

- (NSMutableArray *)snapShotsArray
{
    if (!_snapShotsArray) {
        _snapShotsArray = [NSMutableArray array];
    }
    return _snapShotsArray;
}

// 加载 HTTPS 的链接，需要权限认证时调用  \  如果 HTTPS 是用的证书在信任列表中这不要此代理方法
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *_Nullable))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (challenge.previousFailureCount == 0) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    }
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}


- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;

}


- (void)dealloc {
    [_WKWebView.configuration.userContentController removeScriptMessageHandlerForName:@"handleGoMall"];
}

@end

//
//  AppDelegate+LaunchAD.m
//  WXReader
//
//  Created by Andrew on 2018/11/15.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "AppDelegate+LaunchAD.h"
#import "AppDelegate+StartTimes.h"
#import "XHLaunchAd.h"
#import "WXYZ_WebViewViewController.h"
#import "WXYZ_AudioMallDetailViewController.h"

@implementation AppDelegate (LaunchAD)

- (void)initADManager
{
#if WX_Enable_Third_Party_Ad
    [BUAdSDKManager setAppID:BUA_App_Key];
    [BUAdSDKManager setIsPaidApp:NO];
    [BUAdSDKManager setLoglevel:BUAdSDKLogLevelError];
#endif
}

- (void)initLaunchADView
{
#if WX_Launch_Advertising
    // 如果启动引导页将不加载广告启动图
    if ([self startTimes] == 1) {
        return;
    }
#endif
    
    if (isMagicState) {
        return;
    }
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:WX_START_PAGE];
    
    StartPage *start_page = [StartPage modelWithJSON:data];

    if (start_page.skip_type == 5) { // 穿山甲开屏广告
#if WX_Enable_Third_Party_Ad
        UIView *backgroundView = ({/**< 穿山甲的背景视图，解决穿山甲加载广告期间的空白页面*/
            NSString *lauchStoryboardName = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchStoryboardName"];
            UIViewController *launchScreen = [[UIStoryboard storyboardWithName:lauchStoryboardName bundle:nil] instantiateInitialViewController];
            UIView *backgroundView = launchScreen.view;
            backgroundView.backgroundColor = [UIColor whiteColor];
            backgroundView.frame = self.window.bounds;
            backgroundView;
        });
        [self.window.rootViewController.view addSubview:backgroundView];
        
        BUSplashAdView *splashView = [[BUSplashAdView alloc] initWithSlotID:start_page.ad_key?:BUA_Splash_Key frame:backgroundView.frame];
        splashView.backgroundColor = [UIColor clearColor];
        splashView.tolerateTimeout = 5;
        splashView.delegate = self;
        [splashView loadAdData];
        [backgroundView addSubview:splashView];
        splashView.rootViewController = self.window.rootViewController;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{// 有些时候穿山甲加载失败不会走代理，这里强行3秒后显示状态栏
            [UIApplication sharedApplication].statusBarHidden = NO;
        });
#endif
    } else { // 自带开屏广告
        [self createXLLaunchAdView:start_page];
    }
}

- (void)createXLLaunchAdView:(StartPage *)start_page {
    if (!start_page.image || start_page.image.length <= 0) {
        return;
    }
    
    [XHLaunchAd setLaunchSourceType:SourceTypeLaunchScreen];
    XHLaunchImageAdConfiguration *imageAdconfiguration = [XHLaunchImageAdConfiguration defaultConfiguration];
    imageAdconfiguration.duration = 5;
    imageAdconfiguration.openModel = start_page;
    imageAdconfiguration.imageNameOrURLString = start_page.image;
    imageAdconfiguration.showEnterForeground = YES;
    imageAdconfiguration.imageOption = XHLaunchAdImageRefreshCached;
    imageAdconfiguration.contentMode = UIViewContentModeScaleAspectFill;
    [XHLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:self];
}


#pragma mark - XHLaunchAdDelegate
- (void)xhLaunchAd:(XHLaunchAd *)launchAd clickAndOpenModel:(id)openModel clickPoint:(CGPoint)clickPoint {
    if(openModel == nil) return;
    
    if (![openModel isKindOfClass:[StartPage class]]) {
        return;
    }
    
    StartPage *model = openModel;
    
    //点击跳转类型 1-小说书籍，2-内部链接跳转，3-漫画 4-外部链接
    switch (model.skip_type) {
        case 1:
        {
            WXYZ_BookMallDetailViewController *vc = [[WXYZ_BookMallDetailViewController alloc] init];
            vc.book_id = [model.content integerValue];
            CYLTabBarController *rootVC = (CYLTabBarController *)[[UIApplication sharedApplication].delegate window].rootViewController;
            [rootVC.childViewControllers[rootVC.selectedIndex] pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            WXYZ_WebViewViewController *vc = [[WXYZ_WebViewViewController alloc] init];
            vc.URLString = model.content;
            CYLTabBarController *rootVC = (CYLTabBarController *)[[UIApplication sharedApplication].delegate window].rootViewController;
            [rootVC.childViewControllers[rootVC.selectedIndex] pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {
            WXYZ_ComicMallDetailViewController *vc = [[WXYZ_ComicMallDetailViewController alloc] init];
            vc.comic_id = [model.content integerValue];
            CYLTabBarController *rootVC = (CYLTabBarController *)[[UIApplication sharedApplication].delegate window].rootViewController;
            [rootVC.childViewControllers[rootVC.selectedIndex] pushViewController:vc animated:YES];
        }
            break;
        case 4:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.content] options:@{} completionHandler:nil];
            break;
        case 8:
        {
            WXYZ_AudioMallDetailViewController *vc = [[WXYZ_AudioMallDetailViewController alloc] init];
            vc.audio_id = [model.content integerValue];
            CYLTabBarController *rootVC = (CYLTabBarController *)[[UIApplication sharedApplication].delegate window].rootViewController;
            [rootVC.childViewControllers[rootVC.selectedIndex] pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
}

-(void)xhLaunchAdShowFinish:(XHLaunchAd *)launchAd {
    [UIApplication sharedApplication].statusBarHidden = NO;
}

#pragma mark - BUSplashAdDelegate
#if WX_Enable_Third_Party_Ad
- (void)splashAdDidClose:(BUSplashAdView *)splashAd {
    [splashAd.superview removeFromSuperview];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)splashAd:(BUSplashAdView *)splashAd didFailWithError:(NSError * _Nullable)error {
    [splashAd.superview removeFromSuperview];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)splashAdDidClick:(BUSplashAdView *)splashAd {
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
}
#endif

@end

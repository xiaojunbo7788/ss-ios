//
//  AppDelegate+ShortcutTouch.m
//  WXReader
//
//  Created by Andrew on 2018/10/16.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "AppDelegate+ShortcutTouch.h"
#import "WXYZ_SearchViewController.h"

@implementation AppDelegate (ShortcutTouch)

- (void)initShortcutTouch
{
    
#if WX_ShortcutTouch
    if (@available(iOS 9.0, *)) {
        
        UIApplicationShortcutIcon *searchIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"public_search@3x.png"];
        UIApplicationShortcutIcon *bookRackIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"public_quick_rack.png"];
        UIApplicationShortcutIcon *discoverIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"public_quick_discover.png"];
        
        UIMutableApplicationShortcutItem *searchItem = [[UIMutableApplicationShortcutItem alloc] initWithType:@"search" localizedTitle:@"搜索" localizedSubtitle:nil icon:searchIcon userInfo:nil];
        UIMutableApplicationShortcutItem *bookRackItem = [[UIMutableApplicationShortcutItem alloc] initWithType:@"bookRack" localizedTitle:@"书架" localizedSubtitle:nil icon:bookRackIcon userInfo:nil];
        UIMutableApplicationShortcutItem *discoverItem = [[UIMutableApplicationShortcutItem alloc] initWithType:@"discover" localizedTitle:@"发现" localizedSubtitle:nil icon:discoverIcon userInfo:nil];
        
        [[UIApplication sharedApplication] setShortcutItems:@[searchItem,bookRackItem,discoverItem]];
    }
#endif
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler API_AVAILABLE(ios(9.0))
{
    if (shortcutItem) {
        [self actionWithShortcutItem:shortcutItem];
    }
    
    if (completionHandler) {
        completionHandler(YES);
    }
}

- (void)actionWithShortcutItem:(UIApplicationShortcutItem *)item API_AVAILABLE(ios(9.0))
{
    if ([item.type isEqualToString:@"search"]) {
        
        [self.tabBarControllerConfig.tabBarController setSelectedIndex:1];
        
        WXYZ_SearchViewController *vc = [[WXYZ_SearchViewController alloc] init];
        WXYZ_NavigationController *bookRackNavigationController = [[WXYZ_NavigationController alloc] initWithRootViewController:vc];
        [[WXYZ_ViewHelper getCurrentViewController] presentViewController:bookRackNavigationController animated:YES completion:nil];
        
    } else if ([item.type isEqualToString:@"bookRack"]) {
        [self.tabBarControllerConfig.tabBarController setSelectedIndex:0];
    } else if ([item.type isEqualToString:@"discover"]) {
        [self.tabBarControllerConfig.tabBarController setSelectedIndex:2];
    }
}

@end

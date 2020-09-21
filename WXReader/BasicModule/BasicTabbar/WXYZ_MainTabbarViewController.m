//
//  WXYZ_MainTabbarViewController.m
//  WXDating
//
//  Created by Andrew on 2018/1/4.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_MainTabbarViewController.h"

#import "WXYZ_RackCenterViewController.h"
#import "WXYZ_MallCenterViewController.h"
#import "WXYZ_DiscoverViewController.h"
#import "WXYZ_MineViewController.h"
#import "WXYZ_FansViewController.h"

#import "WXYZ_MagicBookRackViewController.h"
#import "WXYZ_MagicBookMallViewController.h"
#import "WXYZ_MagicMineViewController.h"

@interface WXYZ_MainTabbarViewController () <UITabBarControllerDelegate>

@property (nonatomic, readwrite, strong) CYLTabBarController *tabBarController;

@end

@implementation WXYZ_MainTabbarViewController

- (instancetype)init
{
    if (self = [super init]) {
        // 隐藏tabbar
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenTabbar:) name:Notification_Hidden_Tabbar object:nil];
        
        // 显示tabbar
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTabbar:) name:Notification_Show_Tabbar object:nil];
        
        // 改变审核状态
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMagicState:) name:Notification_Review_State object:nil];
        
        // 改变tabbar选项卡
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changTabbarIndex:) name:Notification_Change_Tabbar_Index object:nil];
    }
    return self;
}

#pragma mark - Tabbar

- (CYLTabBarController *)tabBarController
{
    if (!_tabBarController) {
        CYLTabBarController *tabBarController = nil;
        if (@available(iOS 13.0, *)) {
            tabBarController = [CYLTabBarController tabBarControllerWithViewControllers:self.viewControllers tabBarItemsAttributes:self.tabBarItemsAttributesForController imageInsets:UIEdgeInsetsMake(1, 0, 1, 0) titlePositionAdjustment:UIOffsetMake(0, - 3)];
            [[UITabBar appearance] setUnselectedItemTintColor:kColorRGBA(217, 217, 217, 1)];
            [[UITabBar appearance] setTintColor:kMainColor];
        } else {
            tabBarController = [CYLTabBarController tabBarControllerWithViewControllers:self.viewControllers tabBarItemsAttributes:self.tabBarItemsAttributesForController imageInsets:UIEdgeInsetsMake(0, 0, 0, 0) titlePositionAdjustment:UIOffsetMake(0, - 3)];
            [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:kMainColor} forState:UIControlStateSelected];
            [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:kColorRGBA(217, 217, 217, 1)} forState:UIControlStateNormal];
        }
        
        tabBarController.tabBarHeight = PUB_TABBAR_HEIGHT;
        tabBarController.tabBar.translucent = YES;
        tabBarController.delegate = self;
        tabBarController.tabBar.clipsToBounds = YES;
        [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
        [[UITabBar appearance] setBackgroundImage:[WXYZ_ViewHelper scaleImage:[UIImage imageNamed:@"tabbar_background"] toScale:1]];
        
        if (![[NSUserDefaults standardUserDefaults] objectForKey:WX_TABBAR_SELECT_MEMORY]) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:1] forKey:WX_TABBAR_SELECT_MEMORY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        NSNumber *selectIndex = [[NSUserDefaults standardUserDefaults] objectForKey:WX_TABBAR_SELECT_MEMORY];
        tabBarController.selectedIndex = [selectIndex integerValue];
        
        _tabBarController = tabBarController;
    }
    
    return _tabBarController;
}

- (NSArray *)tabBarItemsAttributesForController
{
    NSMutableArray *tabbarItems = [NSMutableArray array];
    for (int i = 0; i < self.titleArr.count; i ++) {
        [tabbarItems addObject:@{
                                 CYLTabBarItemTitle : self.titleArr[i],
                                 CYLTabBarItemImage : self.itemImageArr[i],
                                 CYLTabBarItemSelectedImage : self.itemImageSelectedArr[i],
                                 }];
    }
    NSArray *tabBarItemsAttributes = [tabbarItems copy];
    return tabBarItemsAttributes;
}

- (NSArray *)titleArr
{
    if (isMagicState) {
        return @[@"书架", @"书城", @"我的"];
    }
    return @[@"书架", @"书城", @"娱乐", @"发现", @"我的"];
}

- (NSArray *)itemImageArr
{
    if (isMagicState) {
        return @[@"bookRack", @"bookMall", @"mine"];
    }
    return @[@"bookRack", @"bookMall", @"bookFans", @"discover", @"mine"];
}

- (NSArray *)itemImageSelectedArr
{
    if (isMagicState) {
        return @[@"bookRack_select", @"bookMall_select", @"mine_select"];
    }
    return @[@"bookRack_select", @"bookMall_select", @"bookFans_select", @"discover_select", @"mine_select"];
}

- (NSArray *)viewControllers
{
    NSArray *t_viewControllers;
    
    // 状态不存在或是审核中
    if (isMagicState) {
        WXYZ_MagicBookRackViewController *bookRackViewController = [[WXYZ_MagicBookRackViewController alloc] init];
        WXYZ_MagicBookMallViewController *bookMallViewController = [[WXYZ_MagicBookMallViewController alloc] init];
        WXYZ_MagicMineViewController *mineViewController = [[WXYZ_MagicMineViewController alloc] init];

        t_viewControllers = @[bookRackViewController, bookMallViewController, mineViewController];
    } else {
        WXYZ_RackCenterViewController *bookRackViewController = [[WXYZ_RackCenterViewController alloc] init];
        WXYZ_MallCenterViewController *bookMallViewController = [[WXYZ_MallCenterViewController alloc] init];
        WXYZ_FansViewController *fansViewController = [[WXYZ_FansViewController alloc] init];
        WXYZ_DiscoverViewController *discoverViewController = [[WXYZ_DiscoverViewController alloc] init];
        WXYZ_MineViewController *mineViewController = [[WXYZ_MineViewController alloc] init];
        
        t_viewControllers = @[bookRackViewController, bookMallViewController, fansViewController, discoverViewController, mineViewController];
    }

    NSMutableArray *t_navigationControllers = [NSMutableArray array];
    for (UIViewController *t_viewController in t_viewControllers) {
        UINavigationController *t_navigationController;
        if (isMagicState) {
            t_navigationController = [[UINavigationController alloc] initWithRootViewController:t_viewController];
        } else {
            t_navigationController = [[WXYZ_NavigationController alloc] initWithRootViewController:t_viewController];
        }
        [t_navigationControllers addObject:t_navigationController];
    }
    
    return [t_navigationControllers copy];
    
}

#pragma mark - Tabbar Delegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectControl:(UIControl *)control
{
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self saveTabbarSelectedIndex:tabBarController.selectedIndex];
}

- (void)saveTabbarSelectedIndex:(NSUInteger)selectedIndex
{
    if (selectedIndex == 0 || selectedIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:selectedIndex] forKey:WX_TABBAR_SELECT_MEMORY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Notification
// 隐藏tabbar
- (void)hiddenTabbar:(NSNotification *)noti
{
    self.tabBarController.tabBar.hidden = YES;
    NSString *animationState = [NSString stringWithFormat:@"%@", noti.object];
    if ([animationState isEqualToString:@"1"]) {
        self.tabBarController.tabBar.frame = CGRectMake(0, SCREEN_HEIGHT, self.tabBarController.tabBar.frame.size.width, self.tabBarController.tabBar.frame.size.height);
    } else {
        [UIView animateWithDuration:kAnimatedDuration animations:^{
            self.tabBarController.tabBar.frame = CGRectMake(0, SCREEN_HEIGHT, self.tabBarController.tabBar.frame.size.width, self.tabBarController.tabBar.frame.size.height);
        }];
    }
}

// 显示tabbar
- (void)showTabbar:(NSNotification *)noti
{
    NSString *animationState = [NSString stringWithFormat:@"%@", noti.object];
    self.tabBarController.tabBar.hidden = NO;
    if ([animationState isEqualToString:@"animation"]) {
        [UIView animateWithDuration:kAnimatedDuration animations:^{
            self.tabBarController.tabBar.frame = CGRectMake(0, SCREEN_HEIGHT - self.tabBarController.tabBar.frame.size.height, self.tabBarController.tabBar.frame.size.width, self.tabBarController.tabBar.frame.size.height);
        }];
    } else {
        self.tabBarController.tabBar.frame = CGRectMake(0, SCREEN_HEIGHT - self.tabBarController.tabBar.frame.size.height, self.tabBarController.tabBar.frame.size.width, self.tabBarController.tabBar.frame.size.height);
    }
}

// 改变tabbar选项卡位置
- (void)changTabbarIndex:(NSNotification *)noti
{
    [self.tabBarController setSelectedIndex:[noti.object integerValue]];
    
    NSUInteger selectIndex = [noti.object integerValue];
    [self saveTabbarSelectedIndex:selectIndex];
}

// 改变tabbar结构
- (void)changeMagicState:(NSNotification *)noti
{
    // 如果本地状态与通知状态相同，就不更改界面
    
    if ([WXYZ_SystemInfoManager.magicStatus isEqualToString:noti.object]) {
        return;
    }
    
    WXYZ_SystemInfoManager.magicStatus = noti.object;
    
    self.tabBarController = nil;
    [kMainWindow setRootViewController:self.tabBarController];
}

@end

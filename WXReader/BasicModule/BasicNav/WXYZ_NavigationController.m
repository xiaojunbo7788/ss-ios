//
//  WXYZ_NavigationController.m
//  fuck
//
//  Created by Andrew on 2017/8/11.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "UINavigationController+DZM.h"

@interface WXYZ_NavigationController () <UINavigationControllerDelegate>

@property (assign, nonatomic) BOOL isSwitching;

@end

@implementation WXYZ_NavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.delegate = self;
    // 使导航条有效
    [self setNavigationBarHidden:NO];
    
    // 隐藏导航条，但由于导航条有效，系统的返回按钮页有效，所以可以使用系统的右滑返回手势。
    [self.navigationBar setHidden:YES];
}

- (void)setEnableSlidingBack:(BOOL)enableSlidingBack
{
    _enableSlidingBack = enableSlidingBack;
    self.interactivePopGestureRecognizer.enabled = enableSlidingBack;
}

#pragma mark - private
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0 && !self.isTransition) {
        viewController.hidesBottomBarWhenPushed = YES;
    }

    if (animated) {
        if (self.isSwitching) {
            return; // 1. 如果是动画，并且正在切换，直接忽略
        }
        self.isSwitching = YES; // 2. 否则修改状态
    }
    
    [super pushViewController:viewController animated:animated];
    self.isSwitching = NO;
    self.isTransition = NO;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    BOOL isRootVC = viewController == navigationController.viewControllers.firstObject;
    if (self.enableSlidingBack) {
        self.enableSlidingBack = !isRootVC;
    }
    
    self.isSwitching = NO; // 3. 还原状态
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    self.isSwitching = NO;
    return [super popViewControllerAnimated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

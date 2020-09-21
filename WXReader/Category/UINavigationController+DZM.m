//
//  UINavigationController+DZM.m
//  DZMAnimatedTransitioning
//
//  Created by 邓泽淼 on 2017/12/21.
//  Copyright © 2017年 邓泽淼. All rights reserved.
//

#import "UINavigationController+DZM.h"
#import <objc/runtime.h>

static const char *transitionKey = "transitionKey";

@implementation UINavigationController (DZM)

- (void)setIsTransition:(BOOL)isTransition
{
    objc_setAssociatedObject(self, transitionKey, @(isTransition), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isTransition
{
    NSNumber *number = objc_getAssociatedObject(self, transitionKey);
    return [number boolValue];
}

- (void)pushATViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    [viewController setValue:[NSNumber numberWithBool:YES] forKey:@"isAT"];
    
    self.delegate = (id<UINavigationControllerDelegate>)viewController;
    
    self.isTransition = YES;
    [self pushViewController:viewController animated:animated];
}

@end

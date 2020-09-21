//
//  NSObject+WXYZ_Observer.m
//  BW_Video
//
//  Created by Chair on 2019/11/29.
//  Copyright © 2019 WXYZ. All rights reserved.
//

#import "NSObject+Observer.h"

#import <objc/runtime.h>

static NSString *helper;

@implementation NSObject (Observer)

- (void)addObserver:(NSString *)keyPath complete:(void (^)(id _Nonnull, id _Nullable, id _Nullable))complte {
    if (keyPath.length == 0 || complte == nil) return ;

    [self addObserverBlockForKeyPath:keyPath block:complte];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 11.0 && ENABLE_SWIZZ_IN_SIMPLEKVO) {
        NSString *objHash = [NSString stringWithFormat:@"%zd", [self modelHash]];
        NSString *pathHash = [NSString stringWithFormat:@"%zd", [keyPath modelHash]];
        helper = [objHash stringByAppendingString:pathHash];
        if (!objc_getAssociatedObject(self, &helper)) {
            objc_setAssociatedObject(self, &helper, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

+ (void)load {
    // 判断版本是否小于11.0并且开关打开，然后替换系统的dealloc方法
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 11.0 && ENABLE_SWIZZ_IN_SIMPLEKVO) {
        NSString *dealloc = @"dealloc";
        Method originalDealloc = class_getInstanceMethod(self, NSSelectorFromString(dealloc));
        Method kvoDealloc = class_getInstanceMethod(self, @selector(customDealloc));
        method_exchangeImplementations(originalDealloc, kvoDealloc);
    }
}

- (void)customDealloc {
    // 判断是否需要移除KVO
    if (objc_getAssociatedObject(self, &helper) != nil) {
        [self removeObserverBlocks];
        objc_setAssociatedObject(self, &helper, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [self customDealloc];
}

@end

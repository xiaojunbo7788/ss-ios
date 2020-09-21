//
//  UIView+LayoutSubviewsCallback.m
//  iOS_TEST
//
//  Created by Chair on 2019/11/24.
//  Copyright © 2019 Chair. All rights reserved.
//

#import "UIView+LayoutCallback.h"

#import <objc/runtime.h>

static const char * identifier = "identifier";

@implementation UIView (LayoutCallback)

#if ENABLE_SWIZZ_IN_SIMPLEFrame

+ (void)load {
    Method method1 = class_getInstanceMethod(self, @selector(layoutSubviews));
    Method method2 = class_getInstanceMethod(self, @selector(xl_layoutSubviews));
    method_exchangeImplementations(method1, method2);
}

- (void)xl_layoutSubviews {
    [self xl_layoutSubviews];
    
    !self.frameBlock ?: self.frameBlock(self);
    
    // 移除指定的对象
    !self.frameBlock ?: objc_setAssociatedObject(self, identifier, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setFrameBlock:(void (^)(UIView * _Nonnull))frameBlock {
    if (frameBlock == nil) return ;
    objc_setAssociatedObject(self, identifier, frameBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(UIView * _Nonnull))frameBlock {
    return objc_getAssociatedObject(self, identifier);
}

#endif

@end

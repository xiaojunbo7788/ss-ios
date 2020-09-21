//
//  NSObject+LSDefaults.m
//  WXReader
//
//  Created by Andrew on 2019/10/9.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "NSObject+LSDefaults.h"

@implementation NSObject (LSDefaults)

+ (void)load{
    
    SEL originalSelector = @selector(doesNotRecognizeSelector:);
    SEL swizzledSelector = @selector(sw_doesNotRecognizeSelector:);
    
    Method originalMethod = class_getClassMethod(self, originalSelector);
    Method swizzledMethod = class_getClassMethod(self, swizzledSelector);
    
    if(class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))){
        class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)sw_doesNotRecognizeSelector:(SEL)aSelector{
    //处理 _LSDefaults 崩溃问题
    if([[self description] isEqualToString:@"_LSDefaults"] && (aSelector == NSSelectorFromString(@"sharedInstance"))){
        return;
    }
    [self sw_doesNotRecognizeSelector:aSelector];
}


@end

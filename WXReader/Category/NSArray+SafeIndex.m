//
//  NSArray+SafeIndex.m
//  WXReader
//
//  Created by songshu on 2020/9/18.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "NSArray+SafeIndex.h"

@implementation NSArray (SafeIndex)

+(void)load{
    
    Class cls = NSClassFromString(@"__NSArrayI");
    Method method1 = class_getInstanceMethod(cls, @selector(objectAtIndexedSubscript:));
    Method method2 = class_getInstanceMethod(self, @selector(pf_objectAtIndexedSubscript:));
    method_exchangeImplementations(method1, method2);

    Method method3 = class_getInstanceMethod(cls, @selector(objectAtIndex:));
    Method method4 = class_getInstanceMethod(self, @selector(pf_objectAtIndex:));
    method_exchangeImplementations(method3, method4);
}

-(id)pf_objectAtIndexedSubscript:(NSUInteger)idx{
    if (idx > self.count - 1) {
        NSLog(@"数组越界了");
//        NSAssert(NO, @"数组越界了");
        return nil;
    }else{
        return [self pf_objectAtIndexedSubscript:idx];
    }
}

-(id)pf_objectAtIndex:(NSUInteger)index{
    if (index > self.count - 1) {
        NSLog(@"数组越界了");
//        NSAssert(NO, @"数组越界了");
        return nil;
    }else{
        return [self pf_objectAtIndex:index];
    }
}

@end

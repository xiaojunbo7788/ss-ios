#import "NSMutableArray+Extension.h"
#import <objc/runtime.h>

@implementation NSMutableArray (Extension)

+(void)load{
    
    Class cls = NSClassFromString(@"__NSArrayM");
    // mArray[4] 会调用方法objectAtIndexedSubscript 取值
    Method method1 = class_getInstanceMethod(cls, @selector(objectAtIndexedSubscript:));
    Method method2 = class_getInstanceMethod(self, @selector(pf_objectAtIndexedSubscript:));
    method_exchangeImplementations(method1, method2);
    
    // mArray[4] 会调用setObject:atIndexedSubscript: 赋值
    Method method3 = class_getInstanceMethod(cls, @selector(setObject:atIndexedSubscript:));
    Method method4 = class_getInstanceMethod(self, @selector(pf_setObject:atIndexedSubscript:));
    method_exchangeImplementations(method3, method4);
    
//    [marray addobject] 会调用insertObject atIndex
    Method method5 = class_getInstanceMethod(cls, @selector(insertObject:atIndex:));
    Method method6 = class_getInstanceMethod(self, @selector(pf_insertObject:atIndex:));
    method_exchangeImplementations(method5, method6);
    
    Method method7 = class_getInstanceMethod(cls, @selector(removeObjectAtIndex:));
    Method method8 = class_getInstanceMethod(self, @selector(pf_removeObjectAtIndex:));
    method_exchangeImplementations(method7, method8);
    
}

// 防止数组越界导致崩溃
-(id)pf_objectAtIndexedSubscript:(NSUInteger)idx{
    if (idx > self.count - 1) {
//        NSAssert(NO, @"index %zd 越界",idx);
        return nil;
    }
    return [self pf_objectAtIndexedSubscript:idx];
}

-(void)pf_setObject:(id)obj atIndexedSubscript:(NSUInteger)idx{
    // 不能越界
    if (idx > self.count - 1) {
//        NSAssert(NO, @"index %zd 越界",idx);
        return;
    }
    // 不能插入空值
    if (obj == nil) {
//        NSAssert(NO, @"不能插入nil值");
        return;
    }
    
    [self pf_setObject:obj atIndexedSubscript:idx];
}


-(void)pf_insertObject:(id)anObject atIndex:(NSUInteger)index{
    if (!anObject) {
//        NSAssert(NO, @"不能插入nil值");
        return;
    }
    [self pf_insertObject:anObject atIndex:index];
    
}

-(void)pf_removeObjectAtIndex:(NSUInteger)index{
    if (index > self.count - 1) {
        return;
    }
    [self pf_removeObjectAtIndex:index];
}
@end


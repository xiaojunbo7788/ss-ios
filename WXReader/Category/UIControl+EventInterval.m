//
//  UIControl+EventInterval.m
//  WXReader
//
//  Created by Andrew on 2020/7/23.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "UIControl+EventInterval.h"
#import <objc/runtime.h>

static char * const touchEventIntervalKey = "touchEventIntervalKey";
static char * const eventUnavailableKey = "eventUnavailableKey";

@interface UIControl ()

@property (nonatomic, assign) BOOL eventUnavailable;

@end

@implementation UIControl (EventInterval)

+ (void)load
{
    Method method = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    Method qi_method = class_getInstanceMethod(self, @selector(qi_sendAction:to:forEvent:));
    method_exchangeImplementations(method, qi_method);
}


#pragma mark - Action functions

- (void)qi_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    if ([self isMemberOfClass:[UIButton class]]) {
        if (self.eventUnavailable == NO) {
            self.eventUnavailable = YES;
            [self qi_sendAction:action to:target forEvent:event];
            [self performSelector:@selector(setEventUnavailable:) withObject:0 afterDelay:self.touchEventInterval];
        }
    } else {
        [self qi_sendAction:action to:target forEvent:event];
    }
}


#pragma mark - Setter & Getter functions

- (NSTimeInterval)touchEventInterval
{
    return [objc_getAssociatedObject(self, touchEventIntervalKey) doubleValue];
}

- (void)setTouchEventInterval:(NSTimeInterval)touchEventInterval
{
    objc_setAssociatedObject(self, touchEventIntervalKey, @(touchEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)eventUnavailable
{
    return [objc_getAssociatedObject(self, eventUnavailableKey) boolValue];
}

- (void)setEventUnavailable:(BOOL)eventUnavailable
{
    objc_setAssociatedObject(self, eventUnavailableKey, @(eventUnavailable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

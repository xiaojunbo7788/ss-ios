//
//  NSObject+Utils.m
//  WXReader
//
//  Created by LL on 2020/6/5.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "NSObject+Utils.h"

#import "NSString+WXYZ_NSString.h"

@implementation NSObject (Utils)

/// 获取指定类中所有的属性信息(属性名-属性类型)
+ (NSDictionary<NSString *, NSString *> *)propertyDict {
    // 属性数量
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(self, &count);
    NSMutableDictionary<NSString *, NSString *> *dic = [NSMutableDictionary dictionary];
    for (int i = 0; i < count; i++) {
        // 获取属性名称
        objc_property_t property = properties[i];
        const char *cName = property_getName(property);
        const char *cType = property_getAttributes(property);
        // 属性名称
        NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        
        // 属性类型
        NSString *type = [NSString stringWithCString:cType encoding:NSUTF8StringEncoding];
        NSError *error;
        // 利用正则表达式获取正确类型
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=@\").*?(?=\")" options:NSRegularExpressionCaseInsensitive error:&error];
        if (error) {
            NSAssert(NO, error.localizedDescription ?: @"动态获取属性类型错误");
            return @{};
        }
        
        NSTextCheckingResult *match = [regex firstMatchInString:type options:kNilOptions range:NSMakeRange(0, type.length)];
        if (match) {
            type = [type substringWithRange:match.range];
        } else {
            type = [self switchType:type];
        }
        
        [dic setObject:type forKey:name];
    }
    return dic;
}

/// 获取指定类中属性名数组
+ (NSArray<NSString *> *)propertyArr {
    return [[self propertyDict] allKeys];
}

+ (NSString *)switchType:(NSString *)type {
    NSString *sub = [type substringWithRange:NSMakeRange(1, 1)];
    if ([sub isEqualToString:@"i"] ||
        [sub isEqualToString:@"s"] ||
        [sub isEqualToString:@"I"] ||
        [sub isEqualToString:@"S"]) {
        return @"int";
    }
    
    if ([sub isEqualToString:@"l"]) {
        return @"long";
    }
    
    if ([sub isEqualToString:@"q"]) {
        return @"NSInteger";
    }
    
    if ([sub isEqualToString:@"Q"]) {
        return @"NSUInteger";
    }
    
    if ([sub isEqualToString:@"L"]) {
        return @"long";// unsigned long
    }
    
    if ([sub isEqualToString:@"f"]) {
        return @"float";
    }
    
    if ([sub isEqualToString:@"d"]) {
        return @"CGFloat";
    }
    
    if ([sub isEqualToString:@"B"]) {
        return @"BOOL";
    }
    
    return @"int";
}

/// 检查Model是否为空
- (BOOL)modelisEmpty {
    for (NSString *name in [self.class propertyArr]) {
        SEL sel = NSSelectorFromString(name);
        if ([self respondsToSelector:sel]) {
            id obj = [self performSelectorWithArgs:sel];
            if (!kObjectIsEmpty(obj)) {
                return NO;
            }
        } else {
            SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@%@", @"is", [name firstCapitalized]]);
            if ([self respondsToSelector:sel]) {
                id obj = [self performSelectorWithArgs:sel];
                if (!kObjectIsEmpty(obj)) {
                    return NO;
                }
            } else {
                return YES;
            }
        }
    }
    return YES;
}

@end

//
//  NSURL+ImageURL.m
//  WXReader
//
//  Created by Andrew on 2020/7/2.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "NSURL+ImageURL.h"
#import <objc/runtime.h>

@implementation NSURL (ImageURL)

+ (void)load
{
    Method URLWithStringMethod = class_getClassMethod(self, @selector(URLWithString:));
    Method sc_URLWithStringMethod = class_getClassMethod(self, @selector(wxyz_URLWithString:));
    method_exchangeImplementations(URLWithStringMethod, sc_URLWithStringMethod);
}

// 处理网络图片地址带中文的问题
+ (NSURL *)wxyz_URLWithString:(NSString *)URLString
{
    for (int i = 0; i < [URLString length]; i++) {
        int character = [URLString characterAtIndex:i];
        if (character > 0x4e00 && character < 0x9fff) { // 如果包含中文
            
            // 转义中文内容
            NSString *t_string = [[URLString substringWithRange:NSMakeRange(i, 1)] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            URLString = [URLString stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:t_string];
        }
    }
    
    return [NSURL wxyz_URLWithString:URLString];
}

@end

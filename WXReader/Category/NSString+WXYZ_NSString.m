//
//  NSString+WXYZ_NSString.m
//  WXReader
//
//  Created by Andrew on 2019/4/5.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "NSString+WXYZ_NSString.h"

@implementation NSString (WXYZ_NSString)

- (NSString *)fileSize
{
    // 总大小
    unsigned long long size = 0;
    NSString *sizeText = @"";
    // 文件管理者
    NSFileManager *mgr = [NSFileManager defaultManager];
    
    // 文件属性
    NSDictionary *attrs = [mgr attributesOfItemAtPath:self error:nil];
    // 如果这个文件或者文件夹不存在,或者路径不正确直接返回0;
    if (attrs == nil) return @"";
    if ([attrs.fileType isEqualToString:NSFileTypeDirectory]) { // 如果是文件夹
        // 获得文件夹的大小  == 获得文件夹中所有文件的总大小
        NSDirectoryEnumerator *enumerator = [mgr enumeratorAtPath:self];
        for (NSString *subpath in enumerator) {
            // 全路径
            NSString *fullSubpath = [self stringByAppendingPathComponent:subpath];
            // 累加文件大小
            size += [mgr attributesOfItemAtPath:fullSubpath error:nil].fileSize;
            
            if (size >= pow(10, 9)) { // size >= 1GB
                sizeText = [NSString stringWithFormat:@"%.2fGB", size / pow(10, 9)];
            } else if (size >= pow(10, 6)) { // 1GB > size >= 1MB
                sizeText = [NSString stringWithFormat:@"%.2fMB", size / pow(10, 6)];
            } else if (size >= pow(10, 3)) { // 1MB > size >= 1KB
                sizeText = [NSString stringWithFormat:@"%.2fKB", size / pow(10, 3)];
            } else { // 1KB > size
                sizeText = [NSString stringWithFormat:@"%zdB", (long)size];
            }
            
        }
        return sizeText;
    } else { // 如果是文件
        size = attrs.fileSize;
        if (size >= pow(10, 9)) { // size >= 1GB
            sizeText = [NSString stringWithFormat:@"%.2fGB", size / pow(10, 9)];
        } else if (size >= pow(10, 6)) { // 1GB > size >= 1MB
            sizeText = [NSString stringWithFormat:@"%.2fMB", size / pow(10, 6)];
        } else if (size >= pow(10, 3)) { // 1MB > size >= 1KB
            sizeText = [NSString stringWithFormat:@"%.2fKB", size / pow(10, 3)];
        } else { // 1KB > size
            sizeText = [NSString stringWithFormat:@"%zdB", (long)size];
        }
        
    }
    return sizeText;
}

- (NSString *)safe_substringWithRange:(NSRange)range
{
    if (range.location > self.length) {
        return @"";
    }
    
    if (range.length > self.length) {
        return @"";
    }
    
    if ((range.location + range.length) > self.length) {
        return @"";
    }
    return [self substringWithRange:range];
}

- (BOOL)isChinese {
    int strlength = 0;

    char *p = (char*)[self cStringUsingEncoding:NSUnicodeStringEncoding];

    for (int i = 0; i < [self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if (*p) {
            p++;
            strlength++;
        } else {
            p++;
        }
    }
    
    return ((strlength / 2) == 1);
}

- (BOOL)containChinese {
    for (int i = 0; i < [self length]; i++) {
        unichar t_char = [self characterAtIndex:i];
        if (t_char < 0x4e00 && t_char < 0x9fff) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)firstCapitalized {
    NSString *firstStirng = [self substringToIndex:1];
    NSString *lastString = [self substringFromIndex:1];
    return [firstStirng.capitalizedString stringByAppendingString:lastString];
}

@end

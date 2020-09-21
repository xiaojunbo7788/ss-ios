//
//  NSString+WXYZ_NSString.h
//  WXReader
//
//  Created by Andrew on 2019/4/5.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (WXYZ_NSString)

- (NSString *)fileSize;

- (NSString *)safe_substringWithRange:(NSRange)range;

- (BOOL)isChinese;

- (BOOL)containChinese;

- (NSString *)firstCapitalized;

@end

NS_ASSUME_NONNULL_END

//
//  NSObject+Utils.h
//  WXReader
//
//  Created by LL on 2020/6/5.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Utils)

- (BOOL)modelisEmpty;

+ (NSDictionary<NSString *, NSString *> *)propertyDict;

+ (NSArray<NSString *> *)propertyArr;

@end

NS_ASSUME_NONNULL_END

//
//  NSObject+WXYZ_Observer.h
//  BW_Video
//
//  Created by Chair on 2019/11/29.
//  Copyright © 2019 WXYZ. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 启用KVO自动清除功能 */
#define ENABLE_SWIZZ_IN_SIMPLEKVO 1

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Observer)

/** 添加一个会自动释放的KVO */
- (void)addObserver:(NSString *)keyPath complete:(void(^)(id obj, id _Nullable oldVal, id _Nullable newVal))complte;

@end

NS_ASSUME_NONNULL_END

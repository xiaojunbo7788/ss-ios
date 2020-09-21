//
//  UIButton+LayoutCallback.h
//  iOS_TEST
//
//  Created by Chair on 2020/1/22.
//  Copyright © 2020 Chair. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 是否启用该功能 */
#define ENABLE_SWIZZ_IN_SIMPLEFrame 1

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (LayoutCallback)

#if ENABLE_SWIZZ_IN_SIMPLEFrame

/** 子视图布局完成后返回自身 */
@property (nonatomic, copy) void(^frameBlock)(UIButton *button);

#endif

@end

NS_ASSUME_NONNULL_END

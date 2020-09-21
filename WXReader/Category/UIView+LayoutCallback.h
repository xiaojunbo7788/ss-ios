//
//  UIView+LayoutSubviewsCallback.h
//  iOS_TEST
//
//  Created by Chair on 2019/11/24.
//  Copyright © 2019 Chair. All rights reserved.
//

//#import <AppKit/AppKit.h>


#import <UIKit/UIKit.h>

#import "UIButton+LayoutCallback.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (LayoutCallback)

#if ENABLE_SWIZZ_IN_SIMPLEFrame

/** 子视图布局完成后返回自身 */
@property (nonatomic, copy) void(^frameBlock)(UIView *view);

#endif

@end

NS_ASSUME_NONNULL_END

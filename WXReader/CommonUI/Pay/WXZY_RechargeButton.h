//
//  WXZY_RechargeButton.h
//  WXReader
//
//  Created by geng on 2020/10/3.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXZY_RechargeButton : UIView

@property (nonatomic, copy) void(^onClick)();

@end

NS_ASSUME_NONNULL_END

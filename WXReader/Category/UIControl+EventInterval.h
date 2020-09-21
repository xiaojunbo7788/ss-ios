//
//  UIControl+EventInterval.h
//  WXReader
//
//  Created by Andrew on 2020/7/23.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (EventInterval)

@property (nonatomic, assign) NSTimeInterval touchEventInterval;

@end

NS_ASSUME_NONNULL_END

//
//  WXYZ_ADPangolinView.h
//  WXReader
//
//  Created by Andrew on 2019/7/25.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ADBasicView.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ADPangolinView : WXYZ_ADBasicView

/// 广告关闭时的回调
@property (nonatomic, copy) void(^closeBlock)(void);

@end

NS_ASSUME_NONNULL_END

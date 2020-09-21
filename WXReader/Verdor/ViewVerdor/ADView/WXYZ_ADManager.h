//
//  WXYZ_ADManager.h
//  WXReader
//
//  Created by Andrew on 2019/6/27.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ADBasicView.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ADManager : WXYZ_ADBasicView

/// 广告关闭时的回调
@property (nonatomic, copy) void(^closeBlock)(void);

/// 广告当前时间戳
@property (nonatomic, assign, class) NSInteger adTimestamp;

// 是否需要展示指定广告
+ (BOOL)canLoadAd:(WXYZ_ADViewType)adType adPosition:(WXYZ_ADViewPosition)adPosition;

@end

NS_ASSUME_NONNULL_END

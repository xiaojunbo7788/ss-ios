//
//  WXYZ_ADPangoinVideo.h
//  WXReader
//
//  Created by LL on 2020/7/29.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ADBasicView.h"

#if WX_Enable_Third_Party_Ad
#import <BUAdSDK/BUAdSDK.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ADPangolinVideo : WXYZ_ADBasicView
#if WX_Enable_Third_Party_Ad
<BUNativeExpressRewardedVideoAdDelegate>
#endif

- (void)show;

@end

NS_ASSUME_NONNULL_END

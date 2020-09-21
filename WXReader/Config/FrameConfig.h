//
//  FrameConfig.h
//  WXReader
//
//  Created by Andrew on 2018/5/15.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#ifndef FrameConfig_h
#define FrameConfig_h

//屏幕宽高
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000

#define SCREEN_WIDTH ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?[UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale:[UIScreen mainScreen].bounds.size.width)

#define SCREEN_HEIGHT ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?[UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale:[UIScreen mainScreen].bounds.size.height)

#else

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#endif

//iPhone X适配 Nav 和 Tabber 高度和偏移数
#define PUB_NAVBAR_HEIGHT (is_iPhoneX?88.0f:64.0f)

#define PUB_NAVBAR_OFFSET (is_iPhoneX?24.0f:0.0f)

#define PUB_TABBAR_HEIGHT (50.0f + PUB_TABBAR_OFFSET)

#define PUB_TABBAR_OFFSET ({\
CGFloat temp = 0.0;\
if (@available(iOS 11.0, *)) {\
temp = [kRCodeSync(@([[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom)) floatValue];\
} else {\
temp = 0.0;\
}\
temp;\
})

//  状态栏高度
#define kStatusBarHeight (([[UIApplication sharedApplication] isStatusBarHidden]) ? (is_iPhoneX ? 44.0 : 20.0) : [[UIApplication sharedApplication] statusBarFrame].size.height)

// 固定单位
#define kMargin 20.0f

#define kMoreHalfMargin 15.0f

#define kHalfMargin 10.0f

#define kQuarterMargin 5.0f

#define kCellLineHeight (is_iPhone6?0.5f:0.4f)

#define kLabelHeight 30.0f

#define KCellHeight 40.0f

#define kiPhone6W 375.0
#define kiPhone6H 667.0
#define kScaleX SCREEN_WIDTH / kiPhone6W
#define kScaleY SCREEN_HEIGHT / kiPhone6H

//  比例高度
#define kGeometricHeight(viewWidth, width, height) (((viewWidth) * (height)) / (width))

//  比例宽度
#define kGeometricWidth(viewHeight, width, height) (((viewHeight) * (width)) / (height))

//  比例X坐标
#define kLineX(x) x*kScaleX

//  比例Y坐标
#define kLineY(y) y*kScaleY

// 小尺寸书籍宽度
#define BOOK_WIDTH_SMALL (BOOK_WIDTH - 20)

// 小尺寸书籍高度
#define BOOK_HEIGHT_SMALL (kGeometricHeight(BOOK_WIDTH_SMALL, 3, 4))

// 书籍宽度
#define BOOK_WIDTH ((SCREEN_WIDTH - 4 * kHalfMargin) / 3)

// 书籍高度
#define BOOK_HEIGHT kGeometricHeight(BOOK_WIDTH, 3, 4)

// 标题高度
#define BOOK_CELL_TITLE_HEIGHT 40

/*
 Font
 */

//  字体适配
#define kFont(value) [UIFont systemFontOfSize:value * kScaleX]

//  粗字体适配
#define kBoldFont(value) [UIFont boldSystemFontOfSize:value * kScaleX]

#define kMainFont [UIFont systemFontOfSize:kFontSize14]

#define kBoldMainFont kBoldFont14

// 字号偏移量

#define kFontOffset (is_iPhoneX_Max?2.0f:1.0f)

#define kFont5  [UIFont systemFontOfSize:kFontSize5]
#define kFont6  [UIFont systemFontOfSize:kFontSize6]
#define kFont7  [UIFont systemFontOfSize:kFontSize7]
#define kFont8  [UIFont systemFontOfSize:kFontSize8]
#define kFont9  [UIFont systemFontOfSize:kFontSize9]
#define kFont10 [UIFont systemFontOfSize:kFontSize10]
#define kFont11 [UIFont systemFontOfSize:kFontSize11]
#define kFont12 [UIFont systemFontOfSize:kFontSize12]
#define kFont13 [UIFont systemFontOfSize:kFontSize13]
#define kFont14 [UIFont systemFontOfSize:kFontSize14]
#define kFont15 [UIFont systemFontOfSize:kFontSize15]
#define kFont16 [UIFont systemFontOfSize:kFontSize16]
#define kFont17 [UIFont systemFontOfSize:kFontSize17]
#define kFont18 [UIFont systemFontOfSize:kFontSize18]
#define kFont19 [UIFont systemFontOfSize:kFontSize19]
#define kFont20 [UIFont systemFontOfSize:kFontSize20]
#define kFont21 [UIFont systemFontOfSize:kFontSize21]
#define kFont22 [UIFont systemFontOfSize:kFontSize22]
#define kFont23 [UIFont systemFontOfSize:kFontSize23]
#define kFont24 [UIFont systemFontOfSize:kFontSize24]
#define kFont25 [UIFont systemFontOfSize:kFontSize25]
#define kFont26 [UIFont systemFontOfSize:kFontSize26]
#define kFont27 [UIFont systemFontOfSize:kFontSize27]
#define kFont28 [UIFont systemFontOfSize:kFontSize28]
#define kFont29 [UIFont systemFontOfSize:kFontSize29]
#define kFont30 [UIFont systemFontOfSize:kFontSize30]

#define kBoldFont5  [UIFont boldSystemFontOfSize:kFontSize5]
#define kBoldFont6  [UIFont boldSystemFontOfSize:kFontSize6]
#define kBoldFont7  [UIFont boldSystemFontOfSize:kFontSize7]
#define kBoldFont8  [UIFont boldSystemFontOfSize:kFontSize8]
#define kBoldFont9  [UIFont boldSystemFontOfSize:kFontSize9]
#define kBoldFont10 [UIFont boldSystemFontOfSize:kFontSize10]
#define kBoldFont11 [UIFont boldSystemFontOfSize:kFontSize11]
#define kBoldFont12 [UIFont boldSystemFontOfSize:kFontSize12]
#define kBoldFont13 [UIFont boldSystemFontOfSize:kFontSize13]
#define kBoldFont14 [UIFont boldSystemFontOfSize:kFontSize14]
#define kBoldFont15 [UIFont boldSystemFontOfSize:kFontSize15]
#define kBoldFont16 [UIFont boldSystemFontOfSize:kFontSize16]
#define kBoldFont17 [UIFont boldSystemFontOfSize:kFontSize17]
#define kBoldFont18 [UIFont boldSystemFontOfSize:kFontSize18]
#define kBoldFont19 [UIFont boldSystemFontOfSize:kFontSize19]
#define kBoldFont20 [UIFont boldSystemFontOfSize:kFontSize20]
#define kBoldFont21 [UIFont boldSystemFontOfSize:kFontSize21]
#define kBoldFont22 [UIFont boldSystemFontOfSize:kFontSize22]
#define kBoldFont23 [UIFont boldSystemFontOfSize:kFontSize23]
#define kBoldFont24 [UIFont boldSystemFontOfSize:kFontSize24]
#define kBoldFont25 [UIFont boldSystemFontOfSize:kFontSize25]
#define kBoldFont26 [UIFont boldSystemFontOfSize:kFontSize26]
#define kBoldFont27 [UIFont boldSystemFontOfSize:kFontSize27]
#define kBoldFont28 [UIFont boldSystemFontOfSize:kFontSize28]
#define kBoldFont29 [UIFont boldSystemFontOfSize:kFontSize29]
#define kBoldFont30 [UIFont boldSystemFontOfSize:kFontSize30]

#define kFontSize5   5.0f + kFontOffset
#define kFontSize6   6.0f + kFontOffset
#define kFontSize7   7.0f + kFontOffset
#define kFontSize8   8.0f + kFontOffset
#define kFontSize9   9.0f + kFontOffset
#define kFontSize10 10.0f + kFontOffset
#define kFontSize11 11.0f + kFontOffset
#define kFontSize12 12.0f + kFontOffset
#define kFontSize13 13.0f + kFontOffset
#define kFontSize14 14.0f + kFontOffset
#define kFontSize15 15.0f + kFontOffset
#define kFontSize16 16.0f + kFontOffset
#define kFontSize17 17.0f + kFontOffset
#define kFontSize18 18.0f + kFontOffset
#define kFontSize19 19.0f + kFontOffset
#define kFontSize20 20.0f + kFontOffset
#define kFontSize21 21.0f + kFontOffset
#define kFontSize22 22.0f + kFontOffset
#define kFontSize23 23.0f + kFontOffset
#define kFontSize24 24.0f + kFontOffset
#define kFontSize25 25.0f + kFontOffset
#define kFontSize26 26.0f + kFontOffset
#define kFontSize27 27.0f + kFontOffset
#define kFontSize28 28.0f + kFontOffset
#define kFontSize29 29.0f + kFontOffset
#define kFontSize30 30.0f + kFontOffset


// ANIMATION_DURATION

#define kAnimatedDuration 0.4f

#define kAnimatedDurationFast 0.2f

#endif /* FrameConfig_h */

//
//  ColorConfig.h
//  WXReader
//
//  Created by Andrew on 2018/5/15.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#ifndef ColorConfig_h
#define ColorConfig_h

/*
 颜色获取方法
 */
#define kColorRGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define kColorRGB(r,g,b) kColorRGBA(r,g,b,1)

//  随机色
#define kRandomColor kColorRGBA(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), 1)

#define kColorXRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1]  //十六进制颜色(不带透明度)

/*
 色调值 命名方式 k+颜色+Color
 */

// 主色调
#define kMainColorMagicAlpha(x) kColorRGBA(255, 153, 102, x)

#define kMainColor kMainColorAlpha(1)

#define kMainColorAlpha(x) ([WXYZ_UtilsHelper isInSafetyPeriod]?kMainColorMagicAlpha(x):kColorRGBA(255, 153, 102, x))

// 颜色管理
#define kBlackColor kColorRGBA(57, 56, 60, 1)

#define kWhiteColor kColorRGBA(255, 255, 255, 1)

#define kRedColor kColorRGBA(231, 85, 79, 1)

#define kGrayLineColor kColorRGBA(240, 238, 245, 1)

#define kGrayViewColor kColorRGBA(249, 249, 249, 1)

#define kGrayDeepViewColor kColorRGBA(241, 242, 241, 1)

#define kGrayTextColor kColorRGBA(176, 176, 176, 1)

#define kGrayTextLightColor kColorRGBA(153, 153, 153, 1)

#define KGrayTextMiddleColor kColorRGBA(102, 102, 102, 1)

#define kGrayTextDeepColor kColorRGBA(77, 77, 75, 1)

#define kBlackTransparentColor kColorRGBA(0, 0, 0, 0.5)

#define kBlackTransparentAlphaColor(x) kColorRGBA(0, 0, 0, x)

#define HoldImage [UIImage imageNamed:@"public_hold_image"]
#define HoldUserAvatar [UIImage imageNamed:@"hold_user_avatar_boy"]

#endif /* ColorConfig_h */

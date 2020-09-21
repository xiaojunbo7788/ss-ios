//
//  WXYZ_ADBasicView.h
//  WXReader
//
//  Created by LL on 2020/7/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WXYZ_ADViewType) {/**< 广告类型*/
    WXYZ_ADViewTypeNone  = 0,/**< 列表广告*/
    WXYZ_ADViewTypeBook  = 1,/**< 小说广告*/
    WXYZ_ADViewTypeComic = 2,/**< 漫画广告*/
};

typedef NS_ENUM(NSUInteger, WXYZ_ADViewPosition) {/**< 广告位置*/
    WXYZ_ADViewPositionNone   = 0,/**< 列表广告*/
    WXYZ_ADViewPositionEnd    = 8,/**< 阅读器章节末尾广告*/
    WXYZ_ADViewPositionBottom = 12,/**< 阅读器底部广告*/
    WXYZ_ADViewPositionVideo  = 13,/**< 激励视频广告*/
};

// 所有的广告视图基类
@interface WXYZ_ADBasicView : UIView

@property (nonatomic, strong) WXYZ_ADModel *adModel;

@property (nonatomic, assign) WXYZ_ADViewPosition adPosition;

@property (nonatomic, assign) WXYZ_ADViewType adType;

- (instancetype)initWithFrame:(CGRect)frame adType:(WXYZ_ADViewType)type adPosition:(WXYZ_ADViewPosition)position;

+ (instancetype)allocWithZone:(struct _NSZone *)zone UNAVAILABLE_ATTRIBUTE;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;

- (void)createSubviews;

/// 广告点击
- (void)clickAd;

/// 请求指定广告信息
- (void)requestADWithType:(WXYZ_ADViewType)type postion:(WXYZ_ADViewPosition)position complete:(void(^)(WXYZ_ADModel * _Nullable adModel, NSString *msg))complete;

@end

NS_ASSUME_NONNULL_END

//
//  WXYZ_ADPangolinView.m
//  WXReader
//
//  Created by Andrew on 2019/7/25.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ADPangolinView.h"
#import "WXYZ_ADPangolinVideo.h"
#import "WXYZ_ReaderSettingHelper.h"
#import "AppDelegate.h"
#import "UIView+LayoutCallback.h"

@interface WXYZ_ADPangolinView ()
#if WX_Enable_Third_Party_Ad
<BUNativeExpressAdViewDelegate, BUNativeExpressBannerViewDelegate>
#endif

#if WX_Enable_Third_Party_Ad
@property (strong, nonatomic) BUNativeExpressAdManager *nativeExpressAdManager;

@property(nonatomic, strong) BUNativeExpressBannerView *bannerView;
#endif

@property (nonatomic, weak) UILabel *titleLabel;

@property (nonatomic, weak) UILabel *subtitle;

/// 高度比例
@property (nonatomic, assign) CGFloat heightScale;

@end

@implementation WXYZ_ADPangolinView

- (instancetype)initWithFrame:(CGRect)frame adType:(WXYZ_ADViewType)type adPosition:(WXYZ_ADViewPosition)position {
    if (self = [super initWithFrame:frame adType:type adPosition:position]) {
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews {
    self.backgroundColor = [UIColor clearColor];
    
    if (self.adPosition == WXYZ_ADViewPositionEnd && self.adType == WXYZ_ADViewTypeBook) {
        UILabel *subtitle = [[UILabel alloc] init];
        self.subtitle = subtitle;
        subtitle.backgroundColor = [UIColor clearColor];
        UIColor *textColor = [WXYZ_ReaderSettingHelper sharedManager].getReaderTextColor;
        subtitle.textColor = textColor;
        subtitle.font = kFont14;
        AppDelegate *delegate = (AppDelegate *)kRCodeSync([UIApplication sharedApplication].delegate);
        subtitle.text = [NSString stringWithFormat:@"%@%@", delegate.checkSettingModel.ad_status_setting.video_ad_text ?: @"", @">"];
        [self addSubview:subtitle];
        subtitle.frameBlock = ^(UIView * _Nonnull view) {
            [view addBorderLineWithBorderWidth:1.0 borderColor:textColor cornerRadius:0.0 borderType:UIBorderSideTypeBottom];
        };
        subtitle.userInteractionEnabled = YES;
        [subtitle addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(watchVideo)]];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        self.titleLabel = titleLabel;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = @"点击/滑动可继续阅读";
        textColor = [textColor colorWithAlphaComponent:0.4];
        titleLabel.textColor = textColor;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = kFont17;
        [self addSubview:titleLabel];
    }
}

- (void)setAdModel:(WXYZ_ProductionModel *)adModel {
    [super setAdModel:adModel];
    
    self.heightScale = 1.0 / 1.2;
    if (adModel.ad_width > 0 && adModel.ad_height > 0) {
        self.heightScale = (CGFloat)adModel.ad_height / adModel.ad_width;
    }
    if (self.adPosition == WXYZ_ADViewPositionEnd) {
        self.heightScale = 1.0 / 1.2;
    }
        
#if WX_Enable_Third_Party_Ad
    if (self.adPosition == WXYZ_ADViewPositionBottom) {// 阅读器底部广告
        if (self.bannerView == nil) {
            self.bannerView = [[BUNativeExpressBannerView alloc] initWithSlotID:adModel.ad_key rootViewController:[WXYZ_ViewHelper getCurrentViewController] adSize:self.bounds.size IsSupportDeepLink:YES];
            self.bannerView.frame = self.bounds;
            self.bannerView.delegate = self;
            [self addSubview:self.bannerView];
        }
        [self.bannerView loadAdData];
    } else {
        if (!self.nativeExpressAdManager) {
            BUAdSlot *slot = [[BUAdSlot alloc] init];
            slot.ID = adModel.ad_key;
            slot.AdType = BUAdSlotAdTypeFeed;
            BUSize *imgSize = [[BUSize alloc] init];
            slot.imgSize = imgSize;
            slot.position = BUAdSlotPositionFeed;
            slot.isSupportDeepLink = YES;
            CGFloat scale = 0.8 / 1.0;
            if (adModel.ad_width > 0 && adModel.ad_height > 0) {
                scale = adModel.ad_height / adModel.ad_width;
            }
            self.nativeExpressAdManager = [[BUNativeExpressAdManager alloc] initWithSlot:slot adSize:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetWidth(self.bounds) * self.heightScale)];
            self.nativeExpressAdManager.delegate = self;
        }
        
        [self.nativeExpressAdManager loadAd:1];
    }
    
    if (self.adPosition == WXYZ_ADViewPositionEnd && self.adType == WXYZ_ADViewTypeBook) {// 章节末尾广告
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset((CGRectGetHeight(self.bounds) / 2.0) + ((CGRectGetWidth(self.bounds) * self.heightScale) / 2.0));
            make.bottom.equalTo(self.subtitle.mas_top);
            make.left.right.equalTo(self);
        }];
        [self.subtitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-kHalfMargin);
            make.centerX.equalTo(self);
            make.height.mas_equalTo(20);
        }];
        AppDelegate *delegate = (AppDelegate *)kRCodeSync([UIApplication sharedApplication].delegate);
        self.subtitle.hidden = !delegate.checkSettingModel.ad_status_setting.video_ad_switch;
    }
#endif
}
/// 观看激励视频
- (void)watchVideo {
    WXYZ_ADPangolinVideo *video = [[WXYZ_ADPangolinVideo alloc] initWithFrame:CGRectZero adType:self.adType adPosition:self.adPosition];
    [video show];
}

#if WX_Enable_Third_Party_Ad
#pragma mark - 信息流广告
- (void)nativeExpressAdSuccessToLoad:(BUNativeExpressAdManager *)nativeExpressAd views:(NSArray<__kindof BUNativeExpressAdView *> *)views {
    if (views.count > 0) {
        BUNativeExpressAdView *expressView = [views firstObject];
        expressView.backgroundColor = [UIColor whiteColor];
        expressView.frame = self.bounds;
        if (self.adPosition == WXYZ_ADViewPositionEnd) {
            expressView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetWidth(self.bounds) * self.heightScale);
            expressView.center = self.center;
        }
        expressView.rootViewController = [WXYZ_ViewHelper getCurrentViewController];
        expressView.layer.cornerRadius = 8;
        expressView.clipsToBounds = YES;
        [expressView render];
        
        [self addSubview:expressView];
    }
}

- (void)nativeExpressAdViewDidClick:(BUNativeExpressAdView *)nativeExpressAdView {
    [super clickAd];
}

- (void)nativeExpressAdView:(BUNativeExpressAdView *)nativeExpressAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords {
    !self.closeBlock ?: self.closeBlock();
    [nativeExpressAdView removeAllSubviews];
    [nativeExpressAdView removeFromSuperview];
}

#pragma mark - banner广告
- (void)nativeExpressBannerAdViewDidClick:(BUNativeExpressBannerView *)bannerAdView {
    [super clickAd];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *_Nullable)filterwords {
    [bannerAdView loadAdData];
}

#endif

@end

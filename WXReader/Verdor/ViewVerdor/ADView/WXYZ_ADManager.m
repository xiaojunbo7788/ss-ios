//
//  WXYZ_ADManager.m
//  WXReader
//
//  Created by Andrew on 2019/6/27.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ADManager.h"

#import "WXYZ_ADWebView.h"
#import "AppDelegate.h"

#if WX_Enable_Third_Party_Ad
#import <BUAdSDK/BUBannerAdView.h>
#import "WXYZ_ADPangolinView.h"
#endif

@interface WXYZ_ADManager ()

@property (nonatomic, weak) WXYZ_ADWebView *adWebView;

#if WX_Enable_Third_Party_Ad
@property (nonatomic, weak) WXYZ_ADPangolinView *adPangolinView;
#endif

@end

@implementation WXYZ_ADManager

+ (BOOL)canLoadAd:(WXYZ_ADViewType)adType adPosition:(WXYZ_ADViewPosition)adPosition {
    AppDelegate *appDelegate = (AppDelegate *)kRCodeSync([[UIApplication sharedApplication] delegate]);
    
    switch (adPosition) {
        case WXYZ_ADViewPositionEnd:
        {
            if (adType == WXYZ_ADViewTypeBook) {
                return appDelegate.checkSettingModel.ad_status_setting.chapter_read_end;
            } else if (adType == WXYZ_ADViewTypeComic) {
                return appDelegate.checkSettingModel.ad_status_setting.comic_read_end;
            } else {
                return NO;
            }
        }
            break;
        case WXYZ_ADViewPositionBottom:
        {
            if (adType == WXYZ_ADViewTypeBook) {
                return appDelegate.checkSettingModel.ad_status_setting.chapter_read_bottom;
            } else {
                return NO;
            }
        }
            break;
            
        default:
            return YES;
    }
}

#pragma mark - Public
#if WX_Enable_Third_Party_Ad
- (instancetype)initWithFrame:(CGRect)frame adType:(WXYZ_ADViewType)type adPosition:(WXYZ_ADViewPosition)position {
    if (![self.class canLoadAd:type adPosition:position]) return nil;
    
    if (self = [super initWithFrame:frame adType:type adPosition:position]) {
        [self initialize];
        [self netRequest];
    }
    return self;
}

- (void)setAdModel:(WXYZ_ADModel *)adModel {
    [super setAdModel:adModel];

    if (adModel.ad_type == 1) {// 内部广告
        self.adWebView.adModel = adModel;
        self.adWebView.hidden = NO;
        self.adPangolinView.hidden = YES;
        return;
    }
    
    if (adModel.ad_type == 2) {// 穿山甲广告
        self.adPangolinView.adModel = adModel;
        self.adPangolinView.hidden = NO;
        self.adWebView.hidden = YES;
        return;
    }
}

- (void)setCloseBlock:(void (^)(void))closeBlock {
    _closeBlock = closeBlock;
    self.adPangolinView.closeBlock = closeBlock;
}

#pragma mark - Private
- (void)initialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveTimestamp) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)createSubviews {
    WXYZ_ADWebView *adWebView = [[WXYZ_ADWebView alloc] initWithFrame:self.bounds adType:self.adType adPosition:self.adPosition];
    adWebView.hidden = YES;
    self.adWebView = adWebView;
    [self addSubview:adWebView];
    [adWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    WXYZ_ADPangolinView *adPangolinView = [[WXYZ_ADPangolinView alloc] initWithFrame:self.bounds adType:self.adType adPosition:self.adPosition];
    adPangolinView.hidden = YES;
    self.adPangolinView = adPangolinView;
    [self addSubview:adPangolinView];
    [adPangolinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)netRequest {
    if (self.adPosition == 0 || self.adType == 0) return;
    
    WS(weakSelf)
    [super requestADWithType:self.adType postion:self.adPosition complete:^(WXYZ_ADModel * _Nullable adModel, NSString * _Nonnull msg) {
        if (adModel) {
            _adTimestamp = [adModel.timestamp integerValue];
            weakSelf.adModel = adModel;
        } else {
            weakSelf.frame = CGRectZero;
        }
    }];
}

- (void)dealloc {
    [self saveTimestamp];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#endif

static NSInteger _adTimestamp;
+ (NSInteger)adTimestamp {
    if (!_adTimestamp) {
        _adTimestamp = [[NSUserDefaults standardUserDefaults] integerForKey:WX_Reader_Ad_Timestamp];
    }
    return _adTimestamp;
}

+ (void)setAdTimestamp:(NSInteger)adTimestamp {
    _adTimestamp = adTimestamp;
}

- (void)saveTimestamp {
    [[NSUserDefaults standardUserDefaults] setInteger:_adTimestamp forKey:WX_Reader_Ad_Timestamp];
}

@end

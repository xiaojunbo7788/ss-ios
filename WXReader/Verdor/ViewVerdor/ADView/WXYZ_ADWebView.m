//
//  WXYZ_ADWebView.m
//  WXReader
//
//  Created by Andrew on 2019/12/10.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ADWebView.h"
#import "WXYZ_WebViewViewController.h"
#import "WXYZ_ReaderSettingHelper.h"
#import "AppDelegate.h"
#import "UIView+LayoutCallback.h"
#import "WXYZ_ADPangolinVideo.h"

@interface WXYZ_ADWebView ()
#if WX_Enable_Third_Party_Ad
<BUNativeExpressRewardedVideoAdDelegate>
#endif

@property (nonatomic, weak) YYAnimatedImageView *webImageView;

@property (nonatomic, weak) UILabel *titleLabel;

@property (nonatomic, weak) UILabel *subtitle;

#if WX_Enable_Third_Party_Ad
@property (nonatomic, strong) BUNativeExpressRewardedVideoAd *expressView;
#endif

@end

@implementation WXYZ_ADWebView

- (instancetype)initWithFrame:(CGRect)frame adType:(WXYZ_ADViewType)type adPosition:(WXYZ_ADViewPosition)position {
    if (self = [super initWithFrame:frame adType:type adPosition:position]) {
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews {
    self.backgroundColor = [UIColor clearColor];
    YYAnimatedImageView *webImageView = [[YYAnimatedImageView alloc] init];
    self.webImageView = webImageView;
    webImageView.contentMode = UIViewContentModeScaleAspectFill;
    webImageView.layer.masksToBounds = YES;
    webImageView.userInteractionEnabled = YES;
    [webImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAd)]];
    [self addSubview:webImageView];
    
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
    
    [self.webImageView setImageWithURL:[NSURL URLWithString:adModel.ad_image ?: @""] placeholder:HoldImage options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
    
    switch (self.adPosition) {
        case WXYZ_ADViewPositionNone:
        {
            // 使用zy_cornerRadiusAdvance会导致Gif图无法播放，暂不清楚为什么
//            [self.webImageView zy_cornerRadiusAdvance:8 rectCornerType:UIRectCornerAllCorners];
            self.webImageView.layer.cornerRadius = 9.5;
            [self.webImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
            break;
        case WXYZ_ADViewPositionEnd:
        {
            if (self.adType == WXYZ_ADViewTypeBook) {
                self.titleLabel.hidden = NO;
                AppDelegate *delegate = (AppDelegate *)kRCodeSync([UIApplication sharedApplication].delegate);
                self.subtitle.hidden = !delegate.checkSettingModel.ad_status_setting.video_ad_switch;
            }
            self.webImageView.layer.cornerRadius = 12.5;
            CGFloat scale = 1.0 / 1.2;
//            if (adModel.ad_width > 0 && adModel.ad_height > 0) {
//                scale = (CGFloat)adModel.ad_height / adModel.ad_width;
//                if (scale < 9.0 / 16.0) {
//                    scale = 9.0 / 16.0;
//                }
//            }
            [self.webImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.width.equalTo(self);
                make.height.equalTo(self.mas_width).multipliedBy(scale);
            }];
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.webImageView.mas_bottom);
                make.bottom.equalTo(self.subtitle.mas_top);
                make.left.right.equalTo(self);
            }];
            [self.subtitle mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self).offset(-kHalfMargin);
                make.centerX.equalTo(self);
                make.height.mas_equalTo(20);
            }];
        }
            break;
        default:
        {
            [self.webImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
            break;
    }
}

- (void)clickAd {
    [super clickAd];
    if (kObjectIsEmpty(self.adModel.ad_skip_url)) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"链接错误，请联系客服"];
        return;
    }
    
    if (self.adModel.ad_url_type == 1) {
        WXYZ_WebViewViewController *vc = [[WXYZ_WebViewViewController alloc] init];
        vc.navTitle = self.adModel.ad_title;
        vc.URLString = self.adModel.ad_skip_url;
        vc.isPresentState = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Reader_Push object:nil];
        [[WXYZ_ViewHelper getCurrentNavigationController] pushViewController:vc animated:YES];
        return;
    }
    
    if (self.adModel.ad_url_type == 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.adModel.ad_skip_url] options:@{} completionHandler:nil];
    }
}

// 观看激励视频
- (void)watchVideo {
    WXYZ_ADPangolinVideo *video = [[WXYZ_ADPangolinVideo alloc] initWithFrame:CGRectZero adType:self.adType adPosition:self.adPosition];
    [video show];
}

@end

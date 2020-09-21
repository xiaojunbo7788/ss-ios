//
//  WXYZ_ADPangoinVideo.m
//  WXReader
//
//  Created by LL on 2020/7/29.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ADPangolinVideo.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface WXYZ_ADPangolinVideo ()

#if WX_Enable_Third_Party_Ad
@property (nonatomic, strong) BUNativeExpressRewardedVideoAd *expressView;
#endif

/// 观看视频前的音量大小
@property (nonatomic, assign) CGFloat initialVolume;

@property (nonatomic, weak) MPVolumeView *volumeView;

@end

@implementation WXYZ_ADPangolinVideo

- (void)createSubviews {
    [super createSubviews];
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)show {
    #if WX_Enable_Third_Party_Ad
    UIView *rootView = [WXYZ_ViewHelper getCurrentViewController].view;
    [rootView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(rootView);
    }];
    [WXYZ_TopAlertManager showLoading:self];
    
    WS(weakSelf)
    [super requestADWithType:WXYZ_ADViewTypeBook postion:WXYZ_ADViewPositionVideo complete:^(WXYZ_ADModel * _Nullable adModel, NSString * _Nonnull msg) {
        if (adModel) {
            BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
            model.userId = BUA_App_Key;
            weakSelf.expressView = [[BUNativeExpressRewardedVideoAd alloc] initWithSlotID:adModel.ad_key ?: BUA_Incentive_Video_Key rewardedVideoModel:model];
            weakSelf.expressView.delegate = weakSelf;
            [weakSelf.expressView loadAdData];
        } else {
            [weakSelf hide];
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:msg];
        }
    }];
    #endif
}

- (void)hide {
    [WXYZ_TopAlertManager hideLoading];
    [self removeFromSuperview];
    // 穿山甲广告视频播放结束后会设置成AVAudioSessionCategorySoloAmbient模式导致有声或听书被停止播放
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [self restoreVolume];
    });
}

// 恢复音量
- (void)restoreVolume {
    UISlider *volumeSlider = nil;
    for (UIView *obj in self.volumeView.subviews) {
        if ([obj.class.description isEqualToString:@"MPVolumeSlider"]) {
            volumeSlider = (UISlider *)obj;
            break;
        }
    }
    self.volumeView.showsVolumeSlider = YES;
    [volumeSlider setValue:self.initialVolume animated:NO];
    [volumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self.volumeView sizeToFit];
}

- (MPVolumeView *)volumeView {
    if (!_volumeView) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-100, -100, 40, 40)];
        _volumeView = volumeView;
        [self.window addSubview:volumeView];
    }
    return _volumeView;
}

#if WX_Enable_Third_Party_Ad
#pragma mark - BUNativeExpressRewardedVideoAdDelegate
// 视频广告素材加载失败后调用
- (void)nativeExpressRewardedVideoAd:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:error.localizedFailureReason ?: @"广告加载失败"];
    [self hide];
}

// 渲染nativeExpressAdView成功时调用
- (void)nativeExpressRewardedVideoAdViewRenderSuccess:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [rewardedVideoAd showAdFromRootViewController:self.viewController.navigationController];
    [WXYZ_TopAlertManager hideLoading];
    self.initialVolume = [[AVAudioSession sharedInstance] outputVolume];
}

// 渲染nativeExpressAdView失败时调用
- (void)nativeExpressRewardedVideoAdViewRenderFail:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd error:(NSError *_Nullable)error {
    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:error.localizedFailureReason ?: @"广告加载失败"];
    [self hide];
}

// 视频广告位即将关闭时调用
- (void)nativeExpressRewardedVideoAdWillClose:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [self hide];
}

// 视频广告播放完成或发生错误时调用
- (void)nativeExpressRewardedVideoAdDidPlayFinish:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    // 穿山甲广告视频播放结束后会设置成AVAudioSessionCategorySoloAmbient模式导致有声或听书被停止播放
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [self restoreVolume];
    });
    if (error) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:error.localizedFailureReason ?: @"广告播放发生错误"];
        return;
    }

    [WXYZ_NetworkRequestManger POST:AdVert_Click parameters:@{@"advert_id":[WXYZ_UtilsHelper formatStringWithInteger:self.adModel.advert_id]}  model:nil success:^(BOOL isSuccess, id  _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            NSString *timestamp = [NSString stringWithFormat:@"%@", t_model[@"data"][@"time"]];
            [[NSUserDefaults standardUserDefaults] setObject:timestamp forKey:WX_Reader_Ad_Start_Timestamp];
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Reader_Ad_Hidden object:nil];
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg ?: @"免广告失败"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
    }];
}

#endif

@end

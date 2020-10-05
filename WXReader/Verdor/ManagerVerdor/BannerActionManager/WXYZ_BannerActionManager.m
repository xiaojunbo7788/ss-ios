//
//  WXYZ_BannerActionManager.m
//  WXReader
//
//  Created by Andrew on 2019/6/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_BannerActionManager.h"

#import "WXYZ_MonthlyViewController.h"
#import "WXYZ_TaskViewController.h"
#import "WXYZ_TaskViewController.h"
#import "WXYZ_RechargeViewController.h"
#import "WXYZ_FeedbackSubViewController.h"
#import "WXYZ_SettingViewController.h"

#import "WXYZ_NewInviteViewController.h"
#import "WXYZ_WebViewViewController.h"

@implementation WXYZ_BannerActionManager

+ (WXYZ_BasicViewController * _Nullable)getBannerActionWithBannerModel:(WXYZ_BannerModel *)bannerModel productionType:(WXYZ_ProductionType)productionType
{
    switch (bannerModel.action) {
        case 1:
            switch (productionType) {
#if WX_Enable_Book
                case WXYZ_ProductionTypeBook:
                {
                    WXYZ_BookMallDetailViewController *vc = [[WXYZ_BookMallDetailViewController alloc] init];
                    vc.book_id = [bannerModel.content integerValue];
                    return vc;
                }
                    break;
#endif
                    
#if WX_Enable_Comic
                case WXYZ_ProductionTypeComic:
                {
                    WXYZ_ComicMallDetailViewController *vc = [[WXYZ_ComicMallDetailViewController alloc] init];
                    vc.comic_id = [bannerModel.content integerValue];
                    return vc;
                }
                    break;
#endif
                    
#if WX_Enable_Audio
                case WXYZ_ProductionTypeAudio:
                {
                    WXYZ_AudioMallDetailViewController *vc = [[WXYZ_AudioMallDetailViewController alloc] init];
                    vc.audio_id = [bannerModel.content integerValue];
                    return vc;
                }
                    break;
#endif
                    
                default:
                    break;
            }
            break;
        case 2:
        {
            if ([bannerModel.content isEqualToString:@"vip"]) { // 会员中心
                return [[WXYZ_MonthlyViewController alloc] init];
            } else if ([bannerModel.content isEqualToString:@"task"]) { // 任务
                return [[WXYZ_TaskViewController alloc] init];
            } else if ([bannerModel.content isEqualToString:@"sign"]) { // 签到
                return [[WXYZ_TaskViewController alloc] init];
            } else if ([bannerModel.content isEqualToString:@"recharge"]) {  // 金币充值
                return [[WXYZ_RechargeViewController alloc] init];
            } else if ([bannerModel.content isEqualToString:@"feedback"]) { // 意见反馈
                return [[WXYZ_FeedbackSubViewController alloc] init];
            } else if ([bannerModel.content isEqualToString:@"setting"]) { // 设置
                return [[WXYZ_SettingViewController alloc] init];
            } else if ([bannerModel.content isEqualToString:@"invite"]) { // 邀请好友
                return [[WXYZ_NewInviteViewController alloc] init];
            }
        }
            break;
        case 3:
        {
            WXYZ_WebViewViewController *vc = [[WXYZ_WebViewViewController alloc] init];
            vc.URLString = bannerModel.content;
            return vc;
        }
            break;
        case 4:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:bannerModel.content] options:@{} completionHandler:nil];
            break;
            
        default:
            break;
    }
    return nil;
}

@end

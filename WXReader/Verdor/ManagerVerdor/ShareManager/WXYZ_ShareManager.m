//
//  WXYZ_ShareManager.m
//  WXReader
//
//  Created by Andrew on 2019/1/17.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ShareManager.h"
#import "WXYZ_ShareView.h"
#import "WXYZ_ShareModel.h"
#if __has_include(<UMShare/UMShare.h>)
#import <UMShare/UMShare.h>
#endif

@implementation WXYZ_ShareManager

implementation_singleton(WXYZ_ShareManager)

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

// 系统分享
- (void)systemShareWithTitle:(NSString *)title shareUrl:(NSURL *)shareUrl {
    NSString *shareText = title ?: @"";
    UIImage *shareImage = [UIImage imageNamed:[[[[NSBundle mainBundle] infoDictionary] valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject]];
    NSArray *activityItems = @[shareText, shareImage, shareUrl ?: [NSURL URLWithString:@""]];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.modalInPopover = YES;
    activityVC.excludedActivityTypes = @[
    UIActivityTypePostToFacebook,
    UIActivityTypePostToTwitter,
    UIActivityTypePostToWeibo,
    UIActivityTypeMessage,
    UIActivityTypeMail,
    UIActivityTypePrint,
    UIActivityTypeCopyToPasteboard,
    UIActivityTypeAssignToContact,
    UIActivityTypeSaveToCameraRoll,
    UIActivityTypeAddToReadingList,
    UIActivityTypePostToFlickr,
    UIActivityTypePostToVimeo,
    UIActivityTypePostToTencentWeibo,
    UIActivityTypeAirDrop,
    UIActivityTypeOpenInIBooks
    ];
    UIActivityViewControllerCompletionWithItemsHandler itemsBlock = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError) {
    };
    activityVC.completionWithItemsHandler = itemsBlock;
    [[WXYZ_ViewHelper getCurrentViewController] presentViewController:activityVC animated:YES completion:nil];
}

// 分享应用
- (void)shareApplicationInController:(UIViewController *)viewController shareState:(WXYZ_ShareState)shareState
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:App_Share parameters:nil model:WXYZ_ShareModel.class success:^(BOOL isSuccess, WXYZ_ShareModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            NSString *shareUrl = @"";
            if (WXYZ_UserInfoManager.isLogin) {
                shareUrl = [NSString stringWithFormat:@"【%@】小伙伴快来，日更动漫资源，永久免费 %@?uid=%zd&osType=1&product=1", App_Name, t_model.link?:[NSString stringWithFormat:@"%@%@", APIURL, Site_Share], [WXYZ_UserInfoManager shareInstance].uid];
            } else {
                shareUrl = [NSString stringWithFormat:@"【%@】小伙伴快来，日更动漫资源，永久免费 %@?osType=1&product=1", App_Name, t_model.link?:[NSString stringWithFormat:@"%@%@", APIURL, Site_Share]];
            }
            [weakSelf systemShareWithTitle:t_model.title shareUrl:[NSURL URLWithString:shareUrl]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"分享出错"];
    }];
}

- (void)shareProductionWithChapter_id:(NSInteger)chapter_id controller:(UIViewController *)viewController type:(WXYZ_ShareProductionState)type shareState:(WXYZ_ShareState)shareState production_id:(NSInteger)production_id complete:(void(^)(void))complete {
    NSDictionary *params = @{
        @"type" : @(type),
        @"novel_id" : @(production_id),
        @"chapter_id" : @(chapter_id)
    };
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:App_Chapter_Share parameters:params model:WXYZ_ShareModel.class success:^(BOOL isSuccess, WXYZ_ShareModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        !complete ?: complete();
        if (isSuccess) {
            NSString *shareUrl = @"";
            if (WXYZ_UserInfoManager.isLogin) {
                shareUrl = [NSString stringWithFormat:@"【%@】小伙伴快来，日更动漫资源，永久免费 %@?uid=%zd&osType=1&product=1", App_Name, t_model.link?:[NSString stringWithFormat:@"%@%@", APIURL, Site_Share], [WXYZ_UserInfoManager shareInstance].uid];
            } else {
                shareUrl = [NSString stringWithFormat:@"【%@】小伙伴快来，日更动漫资源，永久免费 %@?osType=1&product=1", App_Name, t_model.link?:[NSString stringWithFormat:@"%@%@", APIURL, Site_Share]];
            }
            
//            [weakSelf shareInController:viewController shareTitle:t_model.title shareDescribe:t_model.desc shareImageURL:t_model.imgUrl shareUrl:shareUrl shareState:shareState needShareBackRequest:YES];
            [weakSelf systemShareWithTitle:t_model.title ?: @"" shareUrl:[NSURL URLWithString:shareUrl]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !complete ?: complete();
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"分享出错"];
    }];
}

- (void)shareApplicationInController:(UIViewController *)viewController shareTitle:(NSString *)shareTitle shareDescribe:(NSString *)shareDescribe shareImageURL:(NSString *)imageURL shareUrl:(NSString *)shareUrl shareState:(WXYZ_ShareState)shareState
{
    [self shareInController:viewController shareTitle:shareTitle shareDescribe:shareDescribe shareImageURL:imageURL shareUrl:shareUrl shareState:shareState needShareBackRequest:YES];
}

// 分享作品
- (void)shareProductionInController:(UIViewController *)viewController shareTitle:(NSString *)shareTitle shareDescribe:(NSString *)shareDescribe shareImageURL:(NSString *)imageURL productionType:(WXYZ_ShareProductionState)productionType production_id:(NSUInteger)production_id shareState:(WXYZ_ShareState)shareState
{
    NSDictionary *params = @{
        @"type" : @(productionType),
        @"novel_id" : @(production_id),
    };
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:App_Chapter_Share parameters:params model:WXYZ_ShareModel.class success:^(BOOL isSuccess, WXYZ_ShareModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            NSString *shareUrl = @"";
            if (WXYZ_UserInfoManager.isLogin) {
                shareUrl = [NSString stringWithFormat:@"【%@】小伙伴快来，日更动漫资源，永久免费 %@?uid=%zd&osType=1&product=1", App_Name, t_model.link?:[NSString stringWithFormat:@"%@%@", APIURL, Site_Share], [WXYZ_UserInfoManager shareInstance].uid];
            } else {
                shareUrl = [NSString stringWithFormat:@"【%@】小伙伴快来，日更动漫资源，永久免费 %@?osType=1&product=1", App_Name, t_model.link?:[NSString stringWithFormat:@"%@%@", APIURL, Site_Share]];
            }
            
//            [weakSelf shareInController:viewController shareTitle:t_model.title shareDescribe:t_model.desc shareImageURL:t_model.imgUrl shareUrl:shareUrl shareState:shareState needShareBackRequest:YES];
            [weakSelf systemShareWithTitle:t_model.title ?: @"" shareUrl:[NSURL URLWithString:shareUrl]];
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg ?: @"分享错误"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"分享错误"];
    }];
}

- (void)shareProductionInController:(UIViewController *)viewController shareTitle:(NSString *)shareTitle shareDescribe:(NSString *)shareDescribe shareImageURL:(NSString *)imageURL shareUrl:(NSString *)shareUrl productionType:(WXYZ_ShareProductionState)productionType production_id:(NSUInteger)production_id shareState:(WXYZ_ShareState)shareState
{
    [self shareInController:viewController shareTitle:shareTitle shareDescribe:shareDescribe shareImageURL:imageURL shareUrl:shareUrl shareState:shareState needShareBackRequest:NO];
}

// 分享汇总
- (void)shareInController:(UIViewController *)viewController shareTitle:(NSString *)shareTitle shareDescribe:(NSString *)shareDescribe shareImageURL:(NSString *)imageURL shareUrl:(NSString *)shareUrl shareState:(WXYZ_ShareState)shareState needShareBackRequest:(BOOL)needShareBackRequest {
#if __has_include(<UMShare/UMShare.h>)
    if ((shareUrl.length == 0 || !shareUrl) && (shareTitle.length == 0 || !shareTitle) && (shareDescribe.length == 0 || !shareDescribe) && (imageURL.length == 0 || !imageURL)) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"分享地址出错，请稍后重试"];
        return;
    }
    
    if (!shareTitle || shareTitle.length == 0) {
        shareTitle = App_Name;
    }
    
    if (!shareDescribe || shareDescribe.length == 0) {
        shareDescribe = [NSString stringWithFormat:@"%@ - 分享得%@", App_Name, WXYZ_SystemInfoManager.masterUnit];
    }
    
    UIImage * __block shareImage = nil;
    if (!imageURL || imageURL.length == 0) {
        shareImage = [UIImage imageNamed:[[[[NSBundle mainBundle] infoDictionary] valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject]];
    } else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            shareImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
        });
    }
    
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //设置网页地址
    if (shareUrl && shareUrl.length > 0) {
        UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:shareTitle descr:shareDescribe thumImage:shareImage];
        shareObject.webpageUrl = shareUrl;
        messageObject.shareObject = shareObject;
    } else if (shareImage) {
        UMShareImageObject *shareObject = [UMShareImageObject shareObjectWithTitle:@"" descr:@"" thumImage:shareImage];
        shareObject.shareImage = shareImage;
        messageObject.shareObject = shareObject;
    }
    
    switch (shareState) {
        case WXYZ_ShareStateAll:
        {
            WS(weakSelf)
            WXYZ_ShareView *shareView = [[WXYZ_ShareView alloc] init];
            shareView.clickHandler = ^(WXYZ_ShareState shareState) {
                [weakSelf shareMessageWithMessageObject:messageObject shareType:shareState currentViewController:viewController needShareBackRequest:needShareBackRequest];
            };
            [shareView show];
        }
            break;
        case WXYZ_ShareStateQQ:
        {
            [self shareMessageWithMessageObject:messageObject shareType:WXYZ_ShareStateQQ currentViewController:viewController needShareBackRequest:needShareBackRequest];
        }
            break;
        case WXYZ_ShareStateQQZone:
        {
            [self shareMessageWithMessageObject:messageObject shareType:WXYZ_ShareStateQQZone currentViewController:viewController needShareBackRequest:needShareBackRequest];
        }
            break;
        case WXYZ_ShareStateWeChat:
        {
            [self shareMessageWithMessageObject:messageObject shareType:WXYZ_ShareStateWeChat currentViewController:viewController needShareBackRequest:needShareBackRequest];
        }
            break;
            
        case WXYZ_ShareStateWeChatTimeLine:
        {
            [self shareMessageWithMessageObject:messageObject shareType:WXYZ_ShareStateWeChatTimeLine currentViewController:viewController needShareBackRequest:needShareBackRequest];
        }
            break;
        default:
            break;
    }
#endif
}

#if __has_include(<UMShare/UMShare.h>)
- (void)shareMessageWithMessageObject:(UMSocialMessageObject *)messageObject shareType:(WXYZ_ShareState)shareType currentViewController:(UIViewController *)controller needShareBackRequest:(BOOL)needShareBackRequest {
    WS(weakSelf)
    switch (shareType) {
        case WXYZ_ShareStateWeChat: {
            [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_WechatSession messageObject:messageObject currentViewController:controller completion:^(id data, NSError *error) {
                if (needShareBackRequest) {
                    [weakSelf shareBackRequest];
                }
            }];
        }
            break;
        case WXYZ_ShareStateWeChatTimeLine: {
            [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_WechatTimeLine messageObject:messageObject currentViewController:controller completion:^(id data, NSError *error) {
                if (needShareBackRequest) {
                    [weakSelf shareBackRequest];
                }
            }];
        }
            break;
        case WXYZ_ShareStateQQ: {
            [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_QQ messageObject:messageObject currentViewController:controller completion:^(id data, NSError *error) {
                if (error) {
                    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"分享失败"];
                } else {
                    if (needShareBackRequest) {
                        [weakSelf shareBackRequest];
                    }
                }
            }];
        }
            break;
        case WXYZ_ShareStateQQZone: {
            [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_Qzone messageObject:messageObject currentViewController:controller completion:^(id data, NSError *error) {
                if (error) {
                    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"分享失败"];
                } else {
                    if (needShareBackRequest) {
                        [weakSelf shareBackRequest];
                    }
                }
            }];
        }
            break;
            
        default:
            break;
    }
}
#endif

- (void)shareBackRequest {
    [WXYZ_NetworkRequestManger POST:Share_Back parameters:nil model:nil success:^(BOOL isSuccess, NSDictionary *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Share_Success object:nil];
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"分享成功"];
        }
    } failure:nil];
}

@end

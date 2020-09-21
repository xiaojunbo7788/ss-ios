//
//  WXYZ_CheckSettingModel.h
//  WXReader
//
//  Created by Andrew on 2019/12/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AdStatusSetting, SystemSetting, VersionUpdate, StartPage, WXYZ_ProtocolListModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_CheckSettingModel : NSObject

@property (nonatomic, strong) AdStatusSetting *ad_status_setting;

@property (nonatomic, strong) SystemSetting *system_setting;

@property (nonatomic, strong) VersionUpdate *version_update;

@property (nonatomic, strong) StartPage *start_page;

@property (nonatomic, copy) NSString *web_view_url;

/** 微信获取access_token的方法前缀 */
@property (nonatomic, copy) NSString *wechatTokenURL;

@property (nonatomic, strong) WXYZ_ProtocolListModel *protocol_list;

@end

@interface AdStatusSetting : NSObject

@property (nonatomic, assign) BOOL chapter_read_end;    // 章节阅读末尾是否开启

@property (nonatomic, assign) BOOL chapter_read_bottom; // 章节阅读器底部是否开启

@property (nonatomic, assign) BOOL comic_read_end;      // 漫画章节末尾

/// 激励视频广告开关
@property (nonatomic, assign) BOOL video_ad_switch;

/// 激励视频展示文字
@property (nonatomic, copy) NSString *video_ad_text;

/// 免广告总时长
@property (nonatomic, assign) NSInteger ad_free_time;

@end

@interface SystemSetting : NSObject

@property (nonatomic, assign) NSInteger check_status;   // 过审状态开关 1-开启 0-关闭

@property (nonatomic, strong) NSArray <NSString *>*site_type; // 新版UI状态,1：小说，2：漫画，3：有声

@property (nonatomic, copy) NSString *currencyUnit;     // 主货币

@property (nonatomic, copy) NSString *subUnit;          // 子货币

@property (nonatomic, copy) NSString *vip_send_switch;  // 是否开启注册送会员弹框 1 开 2 关

@property (nonatomic, copy) NSString *project_type;     // 项目状态 是否展示漫画小说

@property (nonatomic, assign) NSInteger ai_switch;           // ai读书开关 1 开 2 关

@property (nonatomic, assign) NSInteger novel_reward_switch; // 阅读器打赏显示开关 1开

@property (nonatomic, assign) NSInteger monthly_ticket_switch; // 阅读器月票显示开关 1开

@end

@interface VersionUpdate : NSObject

@property (nonatomic, assign) NSInteger status;         // 更新状态 1 弱更新 2 强更新

@property (nonatomic, copy) NSString *msg;              // 更新文案

@property (nonatomic, copy) NSString *url;              // 更新跳转链接

@end

@interface StartPage : NSObject

@property (nonatomic, copy) NSString *title;            // 广告标题

@property (nonatomic, copy) NSString *content;          // 广告内容

@property (nonatomic, copy) NSString *image;            // 自带广告展示图片地址

@property (nonatomic, assign) NSInteger skip_type;      // 点击跳转类型 1 - 跳转小说 2 - 应用内打开链接 3 - 跳转漫画 4 - 浏览器打开链接 5 - 穿山甲广告 6 - 谷歌广告 7 - 广点通广告 8 - 跳转有声

@property (nonatomic, copy) NSString *ad_key;           // 开屏广告key

@end


@interface WXYZ_ProtocolListModel : NSObject

/// 用户服务协议
@property (nonatomic, copy) NSString *notify;

/// 隐私政策
@property (nonatomic, copy) NSString *privacy;

/// 注销协议
@property (nonatomic, copy) NSString *logoff;

/// 用户协议
@property (nonatomic, copy) NSString *user;

@end

NS_ASSUME_NONNULL_END

//
//  WXYZ_CheckSettingModel.m
//  WXReader
//
//  Created by Andrew on 2019/12/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_CheckSettingModel.h"


@implementation WXYZ_CheckSettingModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{
            @"ad_status_setting" : [AdStatusSetting class],
            @"system_setting" : [SystemSetting class],
            @"version_update" : [VersionUpdate class],
            @"start_page" : [StartPage class],
            @"protocol_list" : WXYZ_ProtocolListModel.class
             };
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
         @"wechatTokenURL" : @"wechat_api_url"
    };
}

@end

@implementation AdStatusSetting

- (BOOL)chapter_read_bottom {
    if ([WXYZ_NetworkReachabilityManager networkingStatus]) {
        return _chapter_read_bottom;
    } else {
        return NO;
    }
}

- (BOOL)chapter_read_end {
    if ([WXYZ_NetworkReachabilityManager networkingStatus]) {
        return _chapter_read_end;
    } else {
        return NO;
    }
}

@end

@implementation SystemSetting

@end

@implementation VersionUpdate

@end

@implementation StartPage

@end

@implementation WXYZ_ProtocolListModel
@end


//
//  AppDelegate+CheckSetting.m
//  WXReader
//
//  Created by Andrew on 2019/12/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "AppDelegate+CheckSetting.h"
#import "AppDelegate+Insterest.h"
#import "AppDelegate+StartTimes.h"
#import "WXYZ_UpdateAlertView.h"


@implementation AppDelegate (CheckSetting)

- (void)initCheckSetting
{
    if ([WXYZ_NetworkReachabilityManager networkingStatus] == NO || [WXYZ_NetworkReachabilityManager currentNetworkStatus] == kCTCellularDataRestrictedStateUnknown) {
        [WXYZ_NetworkReachabilityManager networkingStatus:^(BOOL status) {
            if (status == YES) {
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Restore_Network object:nil];
                    [self initCheckSetting];
                });
            }
        }];
        return ;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkSettingRequestWithState:) name:Notification_Login_Success object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkSettingRequestWithState:) name:Notification_Recharge_Success object:nil];
    
    [self checkSettingRequestWithState:1];
}

// state == 1 是更新全部数据
- (void)checkSettingRequestWithState:(NSInteger)state
{
    WS(weakSelf)
    self.checkSettingModel = [[WXYZ_CheckSettingModel alloc] init];
    [WXYZ_NetworkRequestManger POST:Check_Setting parameters:nil model:WXYZ_CheckSettingModel.class success:^(BOOL isSuccess, WXYZ_CheckSettingModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            weakSelf.checkSettingModel = t_model;
            if (state == 1) {
                // 更新提醒
                switch (weakSelf.checkSettingModel.version_update.status) {
                    case 0:
                        
                        break;
                    case 1: // 弱更新
                    {
                        WXYZ_UpdateAlertView *alert = [[WXYZ_UpdateAlertView alloc] init];
                        alert.updateMessage = weakSelf.checkSettingModel.version_update.msg;
                        alert.confirmButtonClickBlock = ^{
                            if (weakSelf.checkSettingModel.version_update.url.length > 0) {
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:weakSelf.checkSettingModel.version_update.url] options:@{} completionHandler:nil];
                            } else {
                                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"更新地址错误"];
                            }
                        };
                        [alert showAlertView];
                    }
                        break;
                    case 2: // 强更新
                    {
                        WXYZ_UpdateAlertView *alert = [[WXYZ_UpdateAlertView alloc] init];
                        alert.updateMessage = weakSelf.checkSettingModel.version_update.msg?:@"";
                        alert.alertViewDisappearType = WXYZ_AlertViewDisappearTypeNever;
                        alert.alertButtonType = WXYZ_AlertButtonTypeSingleConfirm;
                        alert.confirmButtonClickBlock = ^{
                            if (weakSelf.checkSettingModel.version_update.url.length > 0) {
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:weakSelf.checkSettingModel.version_update.url] options:@{} completionHandler:nil];
                            } else {
                                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"更新地址错误"];
                            }
                        };
                        [alert showAlertView];
                    }
                        break;
                        
                    default:
                        break;
                }
                
                // 过审开关
#if WX_Enable_Magic
                if (weakSelf.checkSettingModel.system_setting.check_status == 1) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Review_State object:@"1"];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Review_State object:@"0"];
                }
                
#endif
                
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Check_Setting_Update object:nil];
            }
            
            // 系统设置参数保存
            WXYZ_SystemInfoManager.masterUnit = weakSelf.checkSettingModel.system_setting.currencyUnit;
            WXYZ_SystemInfoManager.subUnit = weakSelf.checkSettingModel.system_setting.subUnit;
            
            // 启动页相关
            [[NSUserDefaults standardUserDefaults] setObject:[weakSelf.checkSettingModel.start_page modelToJSONData] forKey:WX_START_PAGE];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // 功能状态选择
            if (weakSelf.checkSettingModel.system_setting.project_type.length > 0) {
                [[NSUserDefaults standardUserDefaults] setObject:weakSelf.checkSettingModel.system_setting.project_type forKey:WX_SITE_STATE];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            // 新版站点状态选择
            if (weakSelf.checkSettingModel.system_setting.site_type.count > 0) {
                [[NSUserDefaults standardUserDefaults] setObject:weakSelf.checkSettingModel.system_setting.site_type forKey:WX_SITE_STATE];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            // ai开关状态
            if (weakSelf.checkSettingModel.system_setting.ai_switch == 1) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:WX_Ai_Switch];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:WX_Ai_Switch];
            }
            
            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } failure:nil];
}

@end

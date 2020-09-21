//
//  IAPManager.h
//  IAPDemo
//
//  Created by Charles.Yao on 2016/10/31.
//  Copyright © 2016年 com.pico. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <StoreKit/StoreKit.h>

typedef NS_ENUM(NSInteger, IAPFiledCode) {
    IAP_FILEDCOED_APPLECODE             = 0, // 苹果返回错误信息
    IAP_FILEDCOED_NORIGHT               = 1, // 用户禁止应用内付费购买
    IAP_FILEDCOED_EMPTYGOODS            = 2, // 商品为空
    IAP_FILEDCOED_CANNOTGETINFORMATION  = 3, // 无法获取产品信息，请重试
    IAP_FILEDCOED_BUYFILED              = 4, // 购买失败，请重试
    IAP_FILEDCOED_USERCANCEL            = 5, // 用户取消交易
    IAP_FILEDCOED_BUYING                = 6, // 商品正在请求
    IAP_FILEDCOED_NOTLOGGEDIN           = 7  // 
};


@protocol IApRequestResultsDelegate <NSObject>

// 请求成功
- (void)requestSuccess;

// 请求失败
- (void)filedWithErrorCode:(NSInteger)errorCode andError:(NSString *)error;

@end

@interface IAPManager : NSObject

interface_singleton

// 作品id - 用于充值来源统计
@property (nonatomic, assign) NSInteger production_id;

// 作品类型 - 用于充值来源统计
@property (nonatomic, assign) WXYZ_ProductionType productionType;

@property (nonatomic, weak) id<IApRequestResultsDelegate>delegate;

/**
 启动工具
 */
- (void)startManager;

/**
 结束工具
 */
- (void)stopManager;

/**
 请求商品列表
 */
- (void)requestProductWithId:(NSString *)productId;

- (void)checkIAPFiles;


@end

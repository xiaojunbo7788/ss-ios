//
//  WXYZ_RechargeModel.h
//  WXReader
//
//  Created by Andrew on 2018/7/4.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WXYZ_GoodsModel, WXYZ_TagModel, WXYZ_PayModel;

@interface WXYZ_RechargeModel : NSObject

@property (nonatomic, strong) NSArray<WXYZ_GoodsModel *> *list;

@property (nonatomic, strong) NSArray<NSString *> *about;

@property (nonatomic, copy) NSString *tips;

@property (nonatomic, assign) NSInteger goldRemain;

@property (nonatomic, assign) NSInteger silverRemain;

@property (nonatomic, copy) NSString *goldUnit;

@property (nonatomic, copy) NSString *silverUnit;

@property (nonatomic, assign) BOOL thirdOn;

@end

@interface WXYZ_GoodsModel : NSObject

@property (nonatomic, copy) NSString *note;

@property (nonatomic, copy) NSString *price;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *sub_title;

@property (nonatomic, copy) NSString *flag;

@property (nonatomic, copy) NSString *apple_id;

@property (nonatomic, copy) NSString *fat_price; //金额，带单位

@property (nonatomic, strong) NSArray <WXYZ_PayModel *>*pal_channel;

@property (nonatomic, assign) NSInteger goods_id;

@property (nonatomic, strong) NSArray <WXYZ_TagModel *> *tag;

@end

@interface WXYZ_PayModel : NSObject

@property (nonatomic, copy) NSString *icon;     //icon

@property (nonatomic, copy) NSString *title;    //名称

@property (nonatomic, assign) NSInteger channel_id; //渠道id

@property (nonatomic, assign) NSInteger pay_type;   //渠道类型 1原生支付（如支付宝app支付和微信app支付） 2三方wap支付 3三方sdk支付

@property (nonatomic, copy) NSString *gateway;      //跳转网关

@property (nonatomic, copy) NSString *channel_code; //渠道码，原生和三方SDK支付时需要关注 alipay-支付宝 wechat-微信支付

@end

//
//  WXYZ_ADModel.h
//  WXReader
//
//  Created by Andrew on 2019/6/27.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ADModel : NSObject

/*
 广告相关
 **/

@property (nonatomic, assign) NSUInteger advert_id;         // 广告id

@property (nonatomic, assign) NSUInteger ad_url_type;   // 跳转类型 1 内部 2 外部

@property (nonatomic, copy) NSString *ad_title;             // 广告标题

@property (nonatomic, copy) NSString *ad_image;             // 广告图片

@property (nonatomic, copy) NSString *ad_skip_url;          // 广告跳转地址

@property (nonatomic, copy) NSString *ad_key;               //

@property (nonatomic, assign) NSUInteger ad_type;           // 广告类型 0 不显示  1 内部广告 2 穿山甲广告

@property (nonatomic, assign) NSInteger ad_width;

@property (nonatomic, assign) NSInteger ad_height;

/// 当前时间戳
@property (nonatomic, copy) NSString *timestamp;

@end

NS_ASSUME_NONNULL_END

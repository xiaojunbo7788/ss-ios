//
//  WXYZ_SystemInfoModel.h
//  WXReader
//
//  Created by LL on 2020/6/5.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// APP相关信息
@interface WXYZ_SystemInfoManager : NSObject

/// 主货币单位
@property (nonatomic, copy, class) NSString *masterUnit;

/// 子货币单位
@property (nonatomic, copy, class) NSString *subUnit;

/// 首页性别频道：1：男，2：女
@property (nonatomic, assign, class) NSInteger sexChannel;

/// 审核状态
@property (nonatomic, copy, class) NSString *magicStatus;

/// 隐私协议同意状态
@property (nonatomic, assign, class) BOOL agreementAllow;

/// 阅读任务记录作品id
@property (nonatomic, copy, class) NSString *taskReadProductionId;

/// 首次性别选择，可能为nil
@property (nonatomic, copy, class, nullable) NSString *firstGenderSelecte;

+ (instancetype)allocWithZone:(struct _NSZone *)zone UNAVAILABLE_ATTRIBUTE;

+ (instancetype)alloc UNAVAILABLE_ATTRIBUTE;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END

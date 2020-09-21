//
//  WXYZ_GiftMonthlyPassModel.h
//  WXReader
//
//  Created by LL on 2020/5/28.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXYZ_GiftMonthlyPassInfoModel, WXYZ_GiftMonthlyPassListModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_GiftMonthlyPassModel : NSObject

/// 月票信息
@property (nonatomic, strong) WXYZ_GiftMonthlyPassInfoModel *info;

/// 月票列表
@property (nonatomic, strong) NSArray<WXYZ_GiftMonthlyPassListModel *> *list;

@end


@interface WXYZ_GiftMonthlyPassInfoModel : NSObject

@property (nonatomic, assign) NSInteger book_id;

/// 作品名称
@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *cover;

/// 本月获得月票数量
@property (nonatomic, copy) NSString *stickerNumber;

/// 排名
@property (nonatomic, copy) NSString *ranking;

/// 和上一名排行的距离
@property (nonatomic, copy) NSString *last_distance;

/// 剩余的月票
@property (nonatomic, copy) NSString *ticket_remain;

/// 月票规则
@property (nonatomic, copy) NSString *ticket_rule;

/// 是否可投
@property (nonatomic, assign) NSInteger can_vote;

/// 投票说明
@property (nonatomic, copy) NSString *monthly_tips;

@end


@interface WXYZ_GiftMonthlyPassListModel : NSObject

@property (nonatomic, copy) NSString *title;

/// 月票展示数量
@property (nonatomic, assign) NSInteger num;

/// 是否可选中
@property (nonatomic, assign, getter=isEnabled) NSInteger enabled;

@end

NS_ASSUME_NONNULL_END

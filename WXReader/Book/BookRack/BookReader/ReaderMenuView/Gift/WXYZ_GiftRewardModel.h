//
//  WXYZ_GiftRewardList.h
//  WXReader
//
//  Created by LL on 2020/5/28.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXYZ_GiftRewardListModel, WXYZ_GiftUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_GiftRewardModel : NSObject

@property (nonatomic, copy) NSArray<WXYZ_GiftRewardListModel *> *list;

@property (nonatomic, copy) NSArray<NSString *> *announce_list;

@property (nonatomic, strong) WXYZ_GiftUserModel *user;

@end


@interface WXYZ_GiftRewardListModel : NSObject

@property (nonatomic, assign) NSInteger gift_id;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *icon;

/// 奖励文案
@property (nonatomic, copy) NSString *gift_price;

/// 角标
@property (nonatomic, copy) NSString *flag;

@end


@interface WXYZ_GiftUserModel : NSObject

@property (nonatomic, assign) NSInteger goldRemain;

@end

NS_ASSUME_NONNULL_END

//
//  WXYZ_TickectAlertModel.h
//  WXReader
//
//  Created by LL on 2020/6/1.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXYZ_TickectAlertItemsModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_TickectAlertModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSArray<NSString *> *desc;

@property (nonatomic, copy) NSArray<WXYZ_TickectAlertItemsModel *> *items;

@end


@interface WXYZ_TickectAlertItemsModel : NSObject

@property (nonatomic, copy) NSString *title;

/// 动作 recharge去充值 exchange金币抵扣
@property (nonatomic, copy) NSString *action;

@end

NS_ASSUME_NONNULL_END

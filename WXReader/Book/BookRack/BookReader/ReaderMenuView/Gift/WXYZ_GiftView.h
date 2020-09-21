//
//  WXYZ_GiftView.h
//  WXReader
//
//  Created by LL on 2020/5/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WXYZ_ProductionModel;

NS_ASSUME_NONNULL_BEGIN

/// 阅读器礼物视图
@interface WXYZ_GiftView : UIView

/// 月票余额返回
@property (nonatomic, copy) void(^ticketNumBlock)(NSInteger ticketNumber);

/// 打赏余额返回
@property (nonatomic, copy) void(^giftNumBlock)(NSInteger giftNumber);

/// 是否选中月票页面
@property (nonatomic, assign) BOOL isTicket;

- (instancetype)initWithFrame:(CGRect)frame bookModel:(WXYZ_ProductionModel *)bookModel;

- (void)hide;

- (void)show;

@end

NS_ASSUME_NONNULL_END

//
//  WXYZ_GiftMonthlyPassView.h
//  WXReader
//
//  Created by LL on 2020/5/28.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WXYZ_GiftView;

@class WXYZ_ProductionModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_GiftMonthlyPassView : UIView

- (instancetype)initWithFrame:(CGRect)frame bookModel:(WXYZ_ProductionModel *)bookModel;

/// 月票余额返回
@property (nonatomic, copy) void(^ticketNumBlock)(NSInteger ticketNumber);

@property (nonatomic, weak) WXYZ_GiftView *giftView;

@end

NS_ASSUME_NONNULL_END

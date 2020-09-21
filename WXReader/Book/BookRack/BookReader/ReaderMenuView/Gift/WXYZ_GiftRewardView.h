//
//  WXYZ_GiftRewardView.h
//  WXReader
//
//  Created by LL on 2020/5/28.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WXYZ_GiftView;

@class WXYZ_GiftRewardListModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_GiftRewardView : UIView

@property (nonatomic, weak) WXYZ_GiftView *giftView;

@property (nonatomic, strong) WXYZ_ProductionModel *bookModel;

/// 打赏余额返回
@property (nonatomic, copy) void(^giftNumBlock)(NSInteger giftNumber);

- (instancetype)initWithBookModel:(WXYZ_ProductionModel *)bookModel;

@end


@interface WXYZ_GiftRewardCell : UICollectionViewCell

@property (nonatomic, strong) WXYZ_GiftRewardListModel *giftRewardModel;

- (void)setSelected:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END

//
//  WXYZ_GiftAlertView.h
//  WXReader
//
//  Created by LL on 2020/7/24.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AlertView.h"

@class WXYZ_TickectAlertModel, WXYZ_GiftMonthlyPassListModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_GiftAlertView : WXYZ_AlertView

- (void)setAlertModel:(WXYZ_TickectAlertModel *)alertModel giftModel:(WXYZ_GiftMonthlyPassListModel *)giftModel production_id:(NSInteger)production_id ticketBlock:(void(^)(NSInteger number))ticketBlock;

@end

NS_ASSUME_NONNULL_END

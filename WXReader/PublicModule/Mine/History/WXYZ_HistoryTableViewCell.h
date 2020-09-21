//
//  WXYZ_HistoryTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/1/8.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ContinueReadBlock)(NSInteger book_id);

@interface WXYZ_HistoryTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, strong) WXYZ_ProductionModel *productionModel;

@property (nonatomic, copy) ContinueReadBlock continueReadBlock;

@end

NS_ASSUME_NONNULL_END

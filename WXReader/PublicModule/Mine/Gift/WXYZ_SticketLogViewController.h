//
//  WXYZ_SticketViewController.h
//  WXReader
//
//  Created by LL on 2020/6/1.
//  Copyright © 2020 Andrew. All rights reserved.
//


@class WXYZ_SticketLogListModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_SticketLogViewController : WXYZ_BasicViewController

@end


@interface WXYZ_SticketViewCell : UITableViewCell

@property (nonatomic, strong) WXYZ_SticketLogListModel *logModel;

- (void)setSplitLineHidden:(BOOL)hidden;

@end

NS_ASSUME_NONNULL_END

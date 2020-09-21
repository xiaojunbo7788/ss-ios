//
//  WXYZ_GiftLogViewController.h
//  WXReader
//
//  Created by LL on 2020/6/1.
//  Copyright © 2020 Andrew. All rights reserved.
//


@class WXYZ_GiftLogListModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_GiftLogViewController : WXYZ_BasicViewController

@end


@interface WXYZ_GiftLogViewCell : UITableViewCell

@property (nonatomic, strong) WXYZ_GiftLogListModel *logModel;

- (void)setSplitLineHidden:(BOOL)hidden;

@end

NS_ASSUME_NONNULL_END

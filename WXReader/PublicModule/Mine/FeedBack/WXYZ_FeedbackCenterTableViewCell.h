//
//  WXYZ_FeedbackCenterTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/12/25.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_FeedbackCenterModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_FeedbackCenterTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, strong) WXYZ_QuestionListModel *questionModel;

@property (nonatomic, assign) BOOL detailCellShowing;

- (void)showDetail;

- (void)hiddenDetail;

@end

NS_ASSUME_NONNULL_END

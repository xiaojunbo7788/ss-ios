//
//  WXYZ_FeedbackTextViewTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/12/27.
//  Copyright © 2019 Andrew. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_FeedbackTextViewTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, copy) void(^textViewDidChange)(NSString *contentString);

@end

NS_ASSUME_NONNULL_END

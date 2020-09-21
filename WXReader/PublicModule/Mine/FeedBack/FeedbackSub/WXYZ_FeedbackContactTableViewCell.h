//
//  WXYZ_FeedbackContactTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/12/27.
//  Copyright © 2019 Andrew. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_FeedbackContactTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, copy) void(^contactDidChange)(NSString *contactString);

@property (nonatomic, copy) void(^willBeginEditing)(void);

@end

NS_ASSUME_NONNULL_END

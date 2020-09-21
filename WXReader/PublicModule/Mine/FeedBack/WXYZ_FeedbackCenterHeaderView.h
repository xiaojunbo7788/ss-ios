//
//  WXYZ_FeedbackCenterHeaderView.h
//  WXReader
//
//  Created by Andrew on 2019/12/25.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_FeedbackCenterHeaderView : UIView

@property (nonatomic, copy) void(^leftButtonClick)(void);

@property (nonatomic, copy) void(^rightButtonClick)(void);

@end

NS_ASSUME_NONNULL_END

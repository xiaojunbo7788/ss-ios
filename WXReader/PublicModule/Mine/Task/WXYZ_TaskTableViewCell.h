//
//  WXYZ_TaskTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2018/11/15.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@class WXYZ_TaskListModel;

typedef void(^TaskClickBlock)(NSString *taskAction);

@interface WXYZ_TaskTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, strong) WXYZ_TaskListModel *taskModel;

@property (nonatomic, copy) TaskClickBlock taskClickBlock;

@end

NS_ASSUME_NONNULL_END

//
//  WXYZ_FeedbackCenterModel.h
//  WXReader
//
//  Created by Andrew on 2019/12/25.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WXYZ_HelpListModel, WXYZ_QuestionListModel;

@interface WXYZ_FeedbackCenterModel : NSObject

@property (nonatomic, strong) NSArray <WXYZ_HelpListModel *>*help_list;

@end

@interface WXYZ_HelpListModel : NSObject

@property (nonatomic, copy) NSString *name; // 标题

@property (nonatomic, strong) NSArray <WXYZ_QuestionListModel *>*list; // 问题列表

@end

@interface WXYZ_QuestionListModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *answer;

@end

NS_ASSUME_NONNULL_END

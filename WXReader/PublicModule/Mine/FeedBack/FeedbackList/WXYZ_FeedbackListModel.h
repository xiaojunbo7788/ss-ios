//
//  WXYZ_FeedbackListModel.h
//  WXReader
//
//  Created by Andrew on 2019/12/28.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WXYZ_FeedbackContentModel, WXYZ_PagingModel;

@interface WXYZ_FeedbackListModel : WXYZ_PagingModel

@property (nonatomic, strong) NSArray <WXYZ_FeedbackContentModel *>*list;

@end

@interface WXYZ_FeedbackContentModel : NSObject

@property (nonatomic, copy) NSString *content;  // 用户反馈内容

@property (nonatomic, strong) NSArray <NSString *>* images; // 图片组

@property (nonatomic, copy) NSString *reply;    // 管理员回复内容

@property (nonatomic, copy) NSString *created_at;   // 反馈时间

@end

NS_ASSUME_NONNULL_END

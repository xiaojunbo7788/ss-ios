//
//  WXYZ_BookMarkModel.h
//  WXReader
//
//  Created by LL on 2020/5/23.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_BookMarkModel : NSObject

/// 书籍ID
@property (nonatomic, copy) NSString *bookID;

/// 书签页内容
@property (nonatomic, copy) NSString *pageContent;

/// 章节标题
@property (nonatomic, copy) NSString *chapterTitle;

/// 章节id
@property (nonatomic, copy) NSString *chapterID;

/// 章节排序
@property (nonatomic, assign) NSInteger chapterSort;

/// 章节内容索引
@property (nonatomic, assign) NSInteger specificIndex;

/// 书签加入时间戳
@property (nonatomic, copy) NSString *timestamp;

@end

NS_ASSUME_NONNULL_END

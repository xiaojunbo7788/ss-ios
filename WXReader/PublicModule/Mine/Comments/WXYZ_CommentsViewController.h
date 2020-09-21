//
//  WXYZ_CommentsViewController.h
//  WXReader
//
//  Created by Andrew on 2018/6/26.
//  Copyright © 2018年 Andrew. All rights reserved.
//


@class WXYZ_CommentsDetailModel;

typedef void(^CommentsSuccessBlock)(WXYZ_CommentsDetailModel *commentModel);

@interface WXYZ_CommentsViewController : WXYZ_BasicViewController

// 作品id
@property (nonatomic, assign) NSInteger production_id;

@property (nonatomic, assign) NSInteger chapter_id;

@property (nonatomic, assign) NSInteger comment_id;

@property (nonatomic, assign) BOOL pushFromReader;

@property (nonatomic, copy) CommentsSuccessBlock commentsSuccessBlock;

@end

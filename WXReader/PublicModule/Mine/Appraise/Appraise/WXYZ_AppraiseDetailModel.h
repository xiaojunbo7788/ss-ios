//
//  WXYZ_AppraiseDetailModel.h
//  WXReader
//
//  Created by Andrew on 2020/4/13.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_AppraiseDetailModel : WXYZ_CommentsModel

@property (nonatomic, assign) NSInteger production_id;      // 作品id

@property (nonatomic, assign) NSInteger chapter_id;

@property (nonatomic, copy) NSString *name;         // 作品名

@property (nonatomic, assign) NSInteger comment_id;

@property (nonatomic, assign) NSInteger uid;

@property (nonatomic, copy) NSString *nickname;

@property (nonatomic, copy) NSString *avatar;

@property (nonatomic, copy) NSString *time;

@property (nonatomic, assign) NSInteger like_num;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, assign) BOOL is_vip;

@property (nonatomic, copy) NSString *cover;

@property (nonatomic, copy) NSString *author;

@property (nonatomic, copy) NSString *reply_info;

@end

NS_ASSUME_NONNULL_END

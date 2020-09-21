//
//  WXYZ_CommentsModel.h
//  WXReader
//
//  Created by Andrew on 2018/6/26.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WXYZ_CommentsDetailModel, WXYZ_PagingModel;

@interface WXYZ_CommentsModel : WXYZ_PagingModel

@property (nonatomic, strong) NSArray<WXYZ_CommentsDetailModel *> *list;

@end

@interface WXYZ_CommentsDetailModel : NSObject

@property (nonatomic, copy) NSString *avatar;       //评论用户头像

@property (nonatomic, assign) NSInteger comment_id; //评论id

@property (nonatomic, assign) NSInteger uid;        //评论用户uid

@property (nonatomic, copy) NSString *time;         //评论时间

@property (nonatomic, copy) NSString *nickname;     //评论人昵称

@property (nonatomic, copy) NSString *content;      //评论内容

@property (nonatomic, assign) NSInteger like_num;   //点赞数

@property (nonatomic, copy) NSString *reply_info;   //回复的评论内容

@property (nonatomic, assign) NSInteger is_vip;     //是否为VIP ，0否 1是

@property (nonatomic, assign) NSInteger comment_num; //评论数

@property (nonatomic, copy) NSString *name_title; // 评论的书籍

@property (nonatomic, assign) NSInteger reply_num; // 评论回复数

@end

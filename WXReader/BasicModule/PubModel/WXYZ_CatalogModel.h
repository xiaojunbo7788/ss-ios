//
//  WXYZ_CatalogModel.h
//  WXReader
//
//  Created by LL on 2020/5/8.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXYZ_CatalogListModel, WXYZ_CatalogAuthorModel;

NS_ASSUME_NONNULL_BEGIN

/// 章节Model
@interface WXYZ_CatalogModel : NSObject

@property (nonatomic, assign) NSInteger total_chapter;

@property (nonatomic, strong) WXYZ_CatalogAuthorModel *author;

@property (nonatomic, copy) NSArray<WXYZ_CatalogListModel *> *list;

@end


@interface WXYZ_CatalogAuthorModel : NSObject

@property (nonatomic, copy) NSString *author_name;

@property (nonatomic, copy) NSString *author_note;

@property (nonatomic, assign) NSInteger author_id;

@property (nonatomic, copy) NSString *author_avatar;

@end


@interface WXYZ_CatalogListModel : NSObject

/// 章节id
@property (nonatomic, copy) NSString *chapter_id;

/// 下一章章节id
@property (nonatomic, copy) NSString *next_chapter;

/// 上一章章节id
@property (nonatomic, copy) NSString *previou_chapter;

@property (nonatomic, copy) NSString *book_id;

/// 章节标题
@property (nonatomic, copy) NSString *title;

/// 字数
@property (nonatomic, copy) NSString *words;

@property (nonatomic, assign, getter=isVip) BOOL vip;

/// 章节更新时间：时间戳
@property (nonatomic, copy) NSString *update_time;

@property (nonatomic, copy) NSString *tab;

/// tab颜色，默认是16进制色值
@property (nonatomic, copy) NSString *color;

/// 当前章节在整个章节中的顺序
@property (nonatomic, assign) NSInteger display_order;

@property (nonatomic, assign) BOOL can_read;

@property (nonatomic, assign, getter=isPreview) BOOL preview;

@property (nonatomic, copy) NSString *author_note;

@property (nonatomic, assign) NSInteger comment_num;

@property (nonatomic, assign) NSInteger ticket_num;

@property (nonatomic, assign) NSInteger reward_num;

@end

NS_ASSUME_NONNULL_END

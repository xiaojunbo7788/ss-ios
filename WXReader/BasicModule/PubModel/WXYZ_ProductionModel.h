//
//  WXBookModel.h
//  WXReader
//
//  Created by Andrew on 2018/5/27.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXYZ_ADModel.h"

#import "WXYZ_CatalogModel.h"

@class WXYZ_TagModel, WXYZ_ProductionChapterModel,WXYZ_AuthorModel,WXYZ_AuthorSiniciModel,WXYZ_OriginalModel;

@interface WXYZ_ProductionModel : WXYZ_ADModel <NSCopying>

@property (nonatomic, assign) NSInteger production_id;          // 作品id

@property (nonatomic, assign) NSUInteger log_id;                // 阅读记录id

@property (nonatomic, copy) NSString *name;                     // 作品名

@property (nonatomic, copy) NSString *flag;                     // 作品角标

@property (nonatomic, copy) NSString *cover;                    // 封面

@property (nonatomic, copy) NSString *horizontal_cover;         // 横封面

@property (nonatomic, copy) NSString *vertical_cover;           // 竖封面

@property (nonatomic, copy) NSString *author;                   // 作者

@property (nonatomic, copy) NSArray <WXYZ_AuthorModel *>*author2;                   // 作者

@property (nonatomic, copy) NSString *author_name;              // 作品封面作家名称

@property (nonatomic, copy) NSString *author_note;              // 作品封面作家的话

@property (nonatomic, assign) NSInteger author_id;              // 作品封面作家id

@property (nonatomic, copy) NSString *author_avatar;            // 作品封面作家头像

@property (nonatomic, copy) NSString *finished;                 // 连载状态

@property (nonatomic, copy) NSString *visited;                  // 访问数

@property (nonatomic, copy) NSString *total_favors;             // 全部收藏数

@property (nonatomic, assign) NSInteger free_chapters;          // 免费章节数

@property (nonatomic, assign) NSInteger total_comment;          // 作品评论人数

@property (nonatomic, copy) NSString *issue_time;               // 发布时间

@property (nonatomic, copy) NSString *hot_num;                  // 热度值

@property (nonatomic, copy) NSString *production_descirption;   // 作品简介

@property (nonatomic, copy) NSString *last_chapter_time;        // 最新更新时间

@property (nonatomic, copy) NSString *last_chapter;             //最新章节名

@property (nonatomic, copy) NSString *record_title;             // 阅读记录章节名称

@property (nonatomic, assign) NSInteger total_chapters;         // 全部章节数


@property (nonatomic, assign) BOOL is_readed;                   // 是否已读

@property (nonatomic, assign) BOOL is_baoyue;                   // 是否是vip作品

@property (nonatomic, assign) BOOL is_recommend;                // 是否是推荐作品

@property (nonatomic, assign) NSString *display_no;              // 榜单列表用于排序使用(只有榜单列表会使用)


@property (nonatomic, assign) WXYZ_ProductionType productionType;        // 作品类别

@property (nonatomic, strong) NSArray <WXYZ_ProductionChapterModel *> *chapter_list;        // 章节目录

@property (nonatomic, copy) NSArray<WXYZ_CatalogListModel *> *list;     // 新章节目录

@property (nonatomic, strong) NSArray <WXYZ_TagModel *> *tag;           // 作品标签 没有标签时为空数组

@property (nonatomic, strong) NSArray *tags; // 分类

@property (nonatomic, copy) NSString *created_at;

@property (nonatomic, copy) NSString *sinici; // 汉化组
@property (nonatomic, copy) NSArray <WXYZ_AuthorSiniciModel *>*sinici2; // 汉化组

@property (nonatomic, copy) NSString *original; // 原著
@property (nonatomic, copy) NSArray <WXYZ_OriginalModel *>*original2; // 原著



@end

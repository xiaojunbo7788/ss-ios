//
//  WXYZ_ProductionChapterModel.h
//  WXReader
//
//  Created by Andrew on 2020/3/21.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WXYZ_ImageListModel;

@interface WXYZ_ProductionChapterModel : NSObject

/*
 公共使用区域
 **/

@property (nonatomic, assign) NSInteger production_id;              // 作品id

@property (nonatomic, assign) NSInteger chapter_id;                 // 章节id

@property (nonatomic, strong) NSArray <NSString *>* chapter_ids;    // 章节合集

@property (nonatomic, assign) NSInteger relation_production_id;     // 关联作品id

@property (nonatomic, copy) NSString *name;                         // 作品名称

@property (nonatomic, copy) NSString *chapter_title;                // 章节标题

@property (nonatomic, copy) NSString *recharge_content;

@property (nonatomic, copy) NSString *subtitle;                     // 章节子标题

@property (nonatomic, assign) NSInteger total_words;                // 全部字数

@property (nonatomic, copy) NSString *cover;                        // 封面

@property (nonatomic, assign) NSInteger is_preview;                 // 是否预览内容 1-是 0-不是

@property (nonatomic, copy) NSString *display_order;                // 章节序号

@property (nonatomic, assign) NSInteger last_chapter;               // 上一章节id 没有上一章时返回0

@property (nonatomic, assign) NSInteger next_chapter;               // 下一章id 没有下一章时返回0

@property (nonatomic, copy) NSString *play_num;                     // 观看次数

@property (nonatomic, assign) NSInteger hot_num;                    // 热度值

@property (nonatomic, assign) BOOL is_vip;                          // 是否是vip可观看

@property (nonatomic, assign) BOOL can_read;                        // 是否可读

@property (nonatomic, copy) NSString *update_time;                  // 章节更新时间

@property (nonatomic, strong) WXYZ_TagModel *tag;                   // 标签

@property (nonatomic, strong) WXYZ_ADModel *advert;                 // 广告

/// 总章节数
@property (nonatomic, assign) NSInteger total_chapters;

/*
 小说专属
 **/

@property (nonatomic, copy) NSString *content;                      // 章节内容

@property (nonatomic, copy) NSString *author_note;                  // 章节作者寄语

@property (nonatomic, copy) NSString *comment_num;                  // 评论数，为Null时不展示

@property (nonatomic, copy) NSString *ticket_num;                   // 月票数，为Null时不展示

@property (nonatomic, copy) NSString *reward_num;                   // 打赏数，为Null时不展示

/*
 漫画专属
 **/

@property (nonatomic, assign) NSInteger vip_images;                 // 会员章节数

@property (nonatomic, assign) NSInteger free_image_num;             // 免费阅读图片数

@property (nonatomic, assign) NSInteger total_images;               // 全部图片数

@property (nonatomic, assign) NSInteger total_comment;              // 总评论数

@property (nonatomic, copy) NSString *display_label;                // 序号标题

@property (nonatomic, strong) NSArray <WXYZ_ImageListModel *>*image_list;       // 图片合集

/*
 有声专属
 **/
@property (nonatomic, copy) NSString *duration_time;                // 音频时长

@property (nonatomic, assign) NSInteger duration_second;            // 音频时长 秒

@property (nonatomic, assign) CGFloat size;                         // 音频文件大小 单位：KB

@end

@interface WXYZ_ImageListModel : NSObject

@property (nonatomic, assign) NSInteger image_id;

@property (nonatomic, copy) NSString *image;

@property (nonatomic, assign) NSInteger width;

@property (nonatomic, assign) NSInteger height;

@property (nonatomic, assign) NSInteger image_update_time;

@end

NS_ASSUME_NONNULL_END

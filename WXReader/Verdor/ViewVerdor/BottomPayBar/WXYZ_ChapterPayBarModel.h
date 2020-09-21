//
//  WXYZ_ChapterPayBarModel.h
//  WXReader
//
//  Created by Andrew on 2018/7/15.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXYZ_ChapterPayBarInfoModel, WXYZ_ChapterPayBarOptionModel, Actual_Cost, Original_Cost;
@interface WXYZ_ChapterPayBarModel : NSObject

@property (nonatomic, strong) WXYZ_ChapterPayBarInfoModel *base_info;

@property (nonatomic, strong) NSArray <WXYZ_ChapterPayBarOptionModel *> *pay_options;

@end

@interface WXYZ_ChapterPayBarInfoModel : NSObject

@property (nonatomic, assign) NSInteger remain;

@property (nonatomic, assign) NSInteger gold_remain;

@property (nonatomic, assign) NSInteger silver_remain;

@property (nonatomic, copy) NSString *unit;

@property (nonatomic, copy) NSString *subUnit;

@property (nonatomic, assign) NSInteger chapter_id;

@property (nonatomic, assign) NSInteger auto_sub;

@end

@interface WXYZ_ChapterPayBarOptionModel : NSObject

@property (nonatomic, strong) Original_Cost *original_cost; // 原价

@property (nonatomic, assign) NSInteger buy_num;

@property (nonatomic, assign) NSInteger original_price;

@property (nonatomic, strong) Actual_Cost *actual_cost; // 实际需要消费的金额

@property (nonatomic, copy) NSString *discount;

@property (nonatomic, copy) NSString *label;

@property (nonatomic, assign) NSInteger total_price;

@end

@interface Actual_Cost : NSObject

@property (nonatomic, assign) NSInteger gold_cost;

@property (nonatomic, assign) NSInteger silver_cost;

@end

@interface Original_Cost : NSObject

@property (nonatomic, assign) NSInteger gold_cost;

@property (nonatomic, assign) NSInteger silver_cost;

@end


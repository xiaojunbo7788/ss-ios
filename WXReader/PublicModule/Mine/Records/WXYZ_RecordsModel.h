//
//  WXYZ_RecordsModel.h
//  WXReader
//
//  Created by Andrew on 2018/7/12.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXBookRecordsListModel, WXYZ_PagingModel;

@interface WXYZ_RecordsModel : WXYZ_PagingModel

@property (nonatomic, strong) NSArray<WXBookRecordsListModel *> *list;  //明细列表

@end


@interface WXBookRecordsListModel : NSObject

@property (nonatomic, copy) NSString *article;  //string 明细说明

@property (nonatomic, copy) NSString *detail;   //string 明细

@property (nonatomic, assign) NSInteger detail_type;    //int 明细类型 1-充值 2-消费

@property (nonatomic, copy) NSString *date;     //string 日期

@end

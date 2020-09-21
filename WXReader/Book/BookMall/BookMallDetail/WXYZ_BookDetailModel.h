//
//  WXYZ_BookDetailModel.h
//  WXReader
//
//  Created by Andrew on 2018/5/23.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXYZ_CommentsDetailModel, WXYZ_TagModel, WXYZ_ProductionModel, WXYZ_ProductionModel, WXYZ_MallCenterLabelModel;
@interface WXYZ_BookDetailModel : NSObject

@property (nonatomic, strong) NSArray<WXYZ_CommentsDetailModel *> *comment;       //作品评论列表

@property (nonatomic, strong) WXYZ_ProductionModel *book;             //作品基本信息

@property (nonatomic, strong) NSArray<WXYZ_MallCenterLabelModel *> *label;                  //推荐作品label

@property (nonatomic, strong) WXYZ_ADModel *advert;

@end


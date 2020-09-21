//
//  WXYZ_ComicMallDetailModel.h
//  WXReader
//
//  Created by Andrew on 2019/5/28.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXYZ_ProductionModel, WXYZ_MallCenterLabelModel, WXYZ_CommentsDetailModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ComicMallDetailModel : NSObject

@property (nonatomic, strong) WXYZ_ProductionModel *productionModel;

@property (nonatomic, strong) NSArray <WXYZ_CommentsDetailModel *>*comment;

@property (nonatomic, strong) NSArray <WXYZ_MallCenterLabelModel *>*label;

@property (nonatomic, strong) WXYZ_ADModel *advert;

@end

NS_ASSUME_NONNULL_END

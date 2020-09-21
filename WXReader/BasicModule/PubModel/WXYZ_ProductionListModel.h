//
//  WXYZ_ProductionListModel.h
//  WXReader
//
//  Created by Andrew on 2019/6/17.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXYZ_PagingModel.h"

NS_ASSUME_NONNULL_BEGIN

@class WXYZ_ProductionModel;

@interface WXYZ_ProductionListModel : WXYZ_PagingModel

@property (nonatomic, strong) NSArray <WXYZ_ProductionModel *>*list;

@end

NS_ASSUME_NONNULL_END

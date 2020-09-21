//
//  WXYZ_MallRecommendModel.h
//  WXReader
//
//  Created by Andrew on 2019/6/20.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WXYZ_ProductionListModel;

@interface WXYZ_MallRecommendModel : NSObject

@property (nonatomic, copy) NSString *recommendTitle;

@property (nonatomic, strong) WXYZ_ProductionListModel *recommendList;

@end

NS_ASSUME_NONNULL_END

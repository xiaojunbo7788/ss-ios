//
//  WXYZ_ComicDiscoverModel.h
//  WXReader
//
//  Created by Andrew on 2019/6/12.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXYZ_ProductionModel, WXYZ_TagModel, WXYZ_BannerModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ComicDiscoverModel : NSObject

@property (nonatomic, strong) NSArray <WXYZ_BannerModel *>*banner;

@property (nonatomic, strong) WXYZ_ProductionListModel *item_list;

@end

NS_ASSUME_NONNULL_END

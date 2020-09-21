//
//  WXYZ_ComicMallModel.h
//  WXReader
//
//  Created by Andrew on 2019/5/25.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXYZ_BannerModel, WXYZ_MallCenterLabelModel, WXYZ_MallCenterMenusModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_MallCenterModel : NSObject

@property (nonatomic, strong) NSArray <WXYZ_BannerModel *>*banner; // banner列表

@property (nonatomic, strong) NSArray <WXYZ_MallCenterLabelModel *>*label;

@property (nonatomic, strong) NSArray <WXYZ_MallCenterMenusModel *> *menus_tabs;

@property (nonatomic, strong) NSArray <NSString *>*hot_word;

@end


@interface WXYZ_MallCenterMenusModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, copy) NSString *action;

@end

NS_ASSUME_NONNULL_END

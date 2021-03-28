//
//  WXYZ_ComicMallModel.h
//  WXReader
//
//  Created by Andrew on 2019/5/25.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXYZ_BannerModel, WXYZ_MallCenterLabelModel, WXYZ_MallCenterMenusModel,WXYZ_NoticeModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_MallCenterModel : NSObject

@property (nonatomic, strong) NSArray <WXYZ_BannerModel *>*banner; // banner列表

@property (nonatomic, strong) NSArray <WXYZ_MallCenterLabelModel *>*label;

@property (nonatomic, strong) NSArray <WXYZ_MallCenterMenusModel *> *menus_tabs;

@property (nonatomic, strong) NSArray <WXYZ_NoticeModel *> *announcement;


@property (nonatomic, strong) NSArray <NSString *>*hot_word;

@end


@interface WXYZ_MallCenterMenusModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, copy) NSString *action;

@end

@interface WXYZ_NoticeModel : NSObject

@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *open_type;
@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *product;

@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *deleted_at;
@property (nonatomic, copy) NSString *link_url;

@end


NS_ASSUME_NONNULL_END

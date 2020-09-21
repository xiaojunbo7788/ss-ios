//
//  WXYZ_UserDataModel.h
//  WXReader
//
//  Created by LL on 2020/6/5.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXYZ_UserDataListModel;

NS_ASSUME_NONNULL_BEGIN

// 用户资料首页数据
@interface WXYZ_UserDataModel : NSObject

@property (nonatomic, copy) NSArray<NSArray <WXYZ_UserDataListModel *> *> *panel_list;

@end


@interface WXYZ_UserDataListModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *title_color;

@property (nonatomic, copy) NSString *desc_color;

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, copy) NSString *action;

@property (nonatomic, assign) BOOL is_click;

@end

NS_ASSUME_NONNULL_END

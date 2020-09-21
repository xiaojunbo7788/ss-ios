//
//  WXYZ_ClassifyModel.h
//  WXReader
//
//  Created by Andrew on 2019/6/17.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WXYZ_SearchOptionListModel, WXYZ_SearchBoxModel, WXYZ_ProductionListModel;

@interface WXYZ_ClassifyModel : NSObject

@property (nonatomic, strong) NSArray <WXYZ_SearchBoxModel *>*search_box;

@property (nonatomic, strong) WXYZ_ProductionListModel *classList;

@end

@interface WXYZ_SearchBoxModel : NSObject

@property (nonatomic, copy) NSString *label;    //tab名

@property (nonatomic, copy) NSString *field;    //字段名 请求分类作品接口时作为参数使用

@property (nonatomic, strong) NSArray<WXYZ_SearchOptionListModel *> *searchList;    //可选筛选条件list

@end

@interface WXYZ_SearchOptionListModel : NSObject

@property (nonatomic, copy) NSString *display;  //筛选条件名

@property (nonatomic, copy) NSString *value;    //参数值

@property (nonatomic, assign) BOOL checked;     // 是否选中

@end

NS_ASSUME_NONNULL_END

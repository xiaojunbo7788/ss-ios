//
//  WXYZ_RackCenterModel.h
//  WXReader
//
//  Created by Andrew on 2019/6/13.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WXYZ_BaseInfoModel, WXYZ_AnnouncementModel, WXYZ_ProductionModel, WXYZ_TaskModel;

@interface WXYZ_RackCenterModel : NSObject

@property (nonatomic, strong) WXYZ_BaseInfoModel *base_info;

@property (nonatomic, strong) NSArray <WXYZ_AnnouncementModel *>* announcement;     // 公告

@property (nonatomic, strong) NSArray <WXYZ_ProductionModel *>* recommendList;      // 推荐

@property (nonatomic, strong) NSArray <WXYZ_ProductionModel *>* productionList;     // 作品列表

@end

@interface WXYZ_BaseInfoModel : NSObject

@property (nonatomic, assign) NSInteger sign_status;

@end

@interface WXYZ_AnnouncementModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *content;

@end

NS_ASSUME_NONNULL_END

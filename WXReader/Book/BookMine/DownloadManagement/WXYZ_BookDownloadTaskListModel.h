//
//  WXYZ_BookDownloadTaskListModel.h
//  WXReader
//
//  Created by Andrew on 2019/4/3.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXYZ_DownloadManagerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class WXYZ_DownloadTaskModel, WXYZ_ProductionModel;

@interface WXYZ_BookDownloadTaskListModel : NSObject

@property (nonatomic, strong) WXYZ_ProductionModel *productionModel;

@property (nonatomic, strong) NSMutableArray <WXYZ_DownloadTaskModel *> *task_list;


@end

@interface WXYZ_DownloadTaskModel : NSObject

@property (nonatomic, copy) NSString *label;

@property (nonatomic, copy) NSString *start_chapter_id;

@property (nonatomic, copy) NSString *tag;

@property (nonatomic, assign) NSInteger down_num;

@property (nonatomic, copy) NSString *file_name;

@property (nonatomic, assign) NSInteger start_order;

@property (nonatomic, assign) NSInteger end_order;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *download_title;

@property (nonatomic, copy) NSString *dateString;

@property (nonatomic, copy) NSString *file_size_title;

@property (nonatomic, assign) CGFloat file_size;

@end

NS_ASSUME_NONNULL_END

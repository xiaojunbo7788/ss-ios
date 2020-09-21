//
//  WXYZ_SticketLogModel.h
//  WXReader
//
//  Created by LL on 2020/6/1.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXYZ_SticketLogListModel, WXYZ_PagingModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_SticketLogModel : WXYZ_PagingModel

@property (nonatomic, copy) NSArray<WXYZ_SticketLogListModel *> *list;

@property (nonatomic, copy) NSString *ticket_rule;

@end


@interface WXYZ_SticketLogListModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *time;

@property (nonatomic, assign) NSInteger log_id;

@end

NS_ASSUME_NONNULL_END

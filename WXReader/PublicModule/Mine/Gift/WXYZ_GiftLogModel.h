//
//  WXYZ_GiftLogModel.h
//  WXReader
//
//  Created by LL on 2020/6/2.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXYZ_GiftLogListModel, WXYZ_PagingModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_GiftLogModel : WXYZ_PagingModel

@property (nonatomic, copy) NSArray<WXYZ_GiftLogListModel *> *list;

@end


@interface WXYZ_GiftLogListModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *time;

@property (nonatomic, assign) NSInteger log_id;

@end

NS_ASSUME_NONNULL_END

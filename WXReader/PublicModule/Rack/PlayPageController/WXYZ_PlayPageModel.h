//
//  WXYZ_PlayPageModel.h
//  WXReader
//
//  Created by Andrew on 2020/3/10.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WXYZ_CommentsDetailModel, WXYZ_ADModel, WXYZ_RelationModel;

@interface WXYZ_PlayPageModel : NSObject

@property (nonatomic, assign) NSInteger comment_total_count;
 
@property (nonatomic, strong) WXYZ_CommentsModel *comment;

@property (nonatomic, strong) NSArray <WXYZ_ProductionModel *> *list;

@property (nonatomic, strong) WXYZ_RelationModel *relation;

@property (nonatomic, strong) WXYZ_ADModel *advert;

@end

@interface WXYZ_RelationModel : NSObject

@property (nonatomic, assign) NSInteger production_id;

@property (nonatomic, assign) NSInteger chapter_id;

@property (nonatomic, copy) NSString *chapter_title;

@end

NS_ASSUME_NONNULL_END

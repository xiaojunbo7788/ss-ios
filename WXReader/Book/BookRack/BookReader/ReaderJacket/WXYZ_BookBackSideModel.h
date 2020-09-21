//
//  WXYZ_BookBackSideModel.h
//  WXReader
//
//  Created by Andrew on 2020/5/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WXYZ_MallCenterLabelModel;

@interface WXYZ_BookBackSideModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, assign) NSInteger comment_num;

@property (nonatomic, strong) WXYZ_MallCenterLabelModel *guess_like;

@end

NS_ASSUME_NONNULL_END

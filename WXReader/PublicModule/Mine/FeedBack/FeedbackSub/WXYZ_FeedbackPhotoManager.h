//
//  WXYZ_FeedbackPhotoManager.h
//  WXReader
//
//  Created by Andrew on 2019/12/28.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXYZ_FeedbackPhotoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_FeedbackPhotoManager : NSObject

@property (nonatomic, assign, readonly) BOOL isUploading;

@property (nonatomic, copy) void(^deletePhotoBlock)(WXYZ_FeedbackPhotoModel *photoModel);

interface_singleton

- (void)addPhotoImage:(UIImage *)image complete:(void(^)(WXYZ_FeedbackPhotoModel *photoModel))completeBlock;

- (void)deletePhotoWithPhotoModel:(WXYZ_FeedbackPhotoModel *)photoModel;

- (void)removeAllPhotoImageWithPhotoArray:(NSArray *)dataSources;

@end

NS_ASSUME_NONNULL_END

//
//  WXYZ_FeedbackCollectionViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/12/27.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_FeedbackPhotoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_FeedbackCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) WXYZ_FeedbackPhotoModel *photoModel;

@property (nonatomic, strong) UIImage *uploadImage;

@property (nonatomic, strong) UIImageView *feedbackImage;

@property (nonatomic, assign) NSInteger cellIndex;

@property (nonatomic, copy) void(^deleteImageBlock)(NSInteger index);

@property (nonatomic, copy) void(^finishedUploadBlock)(NSString *img);

@end

NS_ASSUME_NONNULL_END

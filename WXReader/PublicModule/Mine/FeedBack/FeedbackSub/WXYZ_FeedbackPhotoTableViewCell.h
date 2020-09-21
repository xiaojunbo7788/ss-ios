//
//  WXYZ_FeedbackPhotoTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/12/27.
//  Copyright © 2019 Andrew. All rights reserved.
//
#import "WXYZ_ImagePicker.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_FeedbackPhotoTableViewCell : WXYZ_BasicTableViewCell <DPImagePickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, copy) void(^operationPhotosBlock)(NSMutableArray *photosSource);

@end

NS_ASSUME_NONNULL_END

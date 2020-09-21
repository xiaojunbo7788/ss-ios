//
//  WXYZ_FeedbackPhotoModel.h
//  WXReader
//
//  Created by Andrew on 2019/12/28.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_FeedbackPhotoModel : NSObject

@property (nonatomic, copy) NSString *img;  // 图片相对地址，这个值传递保存

@property (nonatomic, copy) NSString *show_img; // 图片显示地址

@end

NS_ASSUME_NONNULL_END

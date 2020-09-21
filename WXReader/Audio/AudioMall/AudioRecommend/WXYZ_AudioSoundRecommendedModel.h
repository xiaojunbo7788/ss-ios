//
//  WXYZ_AudioSoundRecommendedModel.h
//  WXReader
//
//  Created by Andrew on 2020/3/17.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WXYZ_AudioSoundPlayPageModel, WXYZ_PagingModel;

@interface WXYZ_AudioSoundRecommendedModel : WXYZ_PagingModel

@property (nonatomic, strong) NSArray <WXYZ_AudioSoundPlayPageModel *>*list;

@end

@interface WXYZ_AudioSoundPlayPageModel : WXYZ_ProductionModel

@property (nonatomic, assign) BOOL is_vip;          // 是否是vip章节

@property (nonatomic, assign) BOOL is_finish;       // 是否已完结

@property (nonatomic, assign) NSInteger views; // 观看数

@property (nonatomic, assign) NSInteger total_views;

@end

NS_ASSUME_NONNULL_END

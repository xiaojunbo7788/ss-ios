//
//  WXYZ_AudioSoundDetailModel.h
//  WXReader
//
//  Created by Andrew on 2020/3/12.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_AudioSoundDetailModel : NSObject

@property (nonatomic, strong) WXYZ_ProductionModel *audio;

@property (nonatomic, strong) NSArray <NSString *> *color;

@property (nonatomic, assign) NSInteger is_vip;

@end

NS_ASSUME_NONNULL_END

//
//  WXYZ_AudioSoundDetailFooterView.h
//  WXReader
//
//  Created by Andrew on 2020/3/12.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^PushToComicDetailBlock)(NSInteger production_id);

@interface WXYZ_AudioSoundDetailFooterView : WXYZ_BasicViewController

@property (nonatomic, assign) BOOL canScroll;

@property (nonatomic, assign) CGFloat contentOffSetY;

@property (nonatomic, assign) NSInteger audio_id;

@property (nonatomic, strong) WXYZ_ProductionModel *directoryModel;

@end

NS_ASSUME_NONNULL_END

//
//  WXYZ_AudioSoundDetailHeaderView.h
//  WXReader
//
//  Created by Andrew on 2020/3/12.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_AudioSoundDetailHeaderView : UIView

@property (nonatomic, strong) WXYZ_ProductionModel *audioModel;

@property (nonatomic, copy) void (^changeIntroductionBlock)(CGFloat headerViewHeight, BOOL viewEnable);

@property (nonatomic, assign) CGFloat contentOffSetY;

- (void)reloadCollectionButtonState;

@end

NS_ASSUME_NONNULL_END

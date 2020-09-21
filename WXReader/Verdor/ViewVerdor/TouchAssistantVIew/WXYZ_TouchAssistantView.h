//
//  WXYZ_TouchAssistantView.h
//  WXReader
//
//  Created by Andrew on 2020/3/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_TouchAssistantView : UIWindow

@property (nonatomic, assign, readonly) WXYZ_ProductionType productionType;

interface_singleton

- (void)setPlayerProductionType:(WXYZ_ProductionType)productionType;

/*
*  显示小助手
*/
- (void)showAssistiveTouchView;

/*
 *  显示小助手
 */
- (void)showAssistiveTouchViewWithImageCover:(NSString *)imageCover productionType:(WXYZ_ProductionType)productionType;

/*
 *  隐藏小助手
 */
- (void)hiddenAssistiveTouchView;

/*
 *  开启播放状态
 */
- (void)playPlayerState;

/*
 *  暂停播放状态
 */
- (void)pausePlayerState;

/*
 *  停止播放状态
 */
- (void)stopPlayerState;

/*
 *  改变播放进度
 */
- (void)changePlayProgress:(CGFloat)progress;

@end

NS_ASSUME_NONNULL_END

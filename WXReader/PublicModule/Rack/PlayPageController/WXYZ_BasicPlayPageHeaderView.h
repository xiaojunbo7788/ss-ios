//
//  WXYZ_BasicPlayPageHeaderView.h
//  WXReader
//
//  Created by Andrew on 2020/4/18.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_PlayPageModel.h"
#import "CKAudioProgressView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WXYZ_PlayPagePlayerState) {
    WXYZ_PlayPagePlayerStateLoading,
    WXYZ_PlayPagePlayerStatePlaying,
    WXYZ_PlayPagePlayerStatePause,
    WXYZ_PlayPagePlayerStateStoped,
    WXYZ_PlayPagePlayerStateFail
};

@interface WXYZ_BasicPlayPageHeaderView : UIView

@property (nonatomic, assign) WXYZ_ProductionType productionType;

@property (nonatomic, strong) WXYZ_RelationModel *relationModel;

@property (nonatomic, strong) NSArray <WXYZ_ProductionChapterModel *> *chapter_list;

@property (nonatomic, strong) WXYZ_ProductionChapterModel *productionChapterModel;

@property (nonatomic, strong) WXYZ_ProductionChapterModel *temp_chapterModel; // 临时章节信息记录

@property (nonatomic, strong) WXYZ_CustomButton *timingButton;    // 定时按钮

@property (nonatomic, strong) WXYZ_CustomButton *speedButton;     // 语速按钮

@property (nonatomic, strong) WXYZ_CustomButton *voiceButton;     // 声音按钮

@property (nonatomic, assign) WXYZ_PlayPagePlayerState playerState;

@property (nonatomic, strong) CKAudioProgressView *timelineProgress; // 播放进度

@property (nonatomic, copy) void (^checkOriginalBlock)(WXYZ_ProductionChapterModel *chapterModel);

@property (nonatomic, copy) void (^checkRelationProductionBlock)(WXYZ_RelationModel *relationModel);

@property (nonatomic, copy) void (^resetPlayerBlock)(BOOL immediateReset);

- (instancetype)initWithProductionType:(WXYZ_ProductionType)productionType;

- (void)createSubviews;

// 上一首
- (void)skipToLastChapter;

// 下一首
- (void)skipToNextChapter;

// 显示充值页
- (void)showPayView;

// 设置关联作品标题
- (void)setRelationViewTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END

//
//  WXYZ_BasicPlayPageHeaderView.m
//  WXReader
//
//  Created by Andrew on 2020/4/18.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BookAiPlayPageViewController.h"
#import "WXYZ_BasicPlayPageHeaderView.h"
#import "WXYZ_TouchAssistantView.h"
#import "WXYZ_AudioPlayPageMenuView.h"
#import "WXYZ_ChapterBottomPayBar.h"
#import "WXYZ_ProductionReadRecordManager.h"

#import "WXYZ_Player.h"
#if __has_include(<iflyMSC/IFlyMSC.h>)
#import "iflyMSC/IFlyMSC.h"
#endif

#import "WXYZ_AudioSettingHelper.h"
#import "WXYZ_ReaderBookManager.h"
#import "WXYZ_ReaderSettingHelper.h"
#import "WXYZ_AudioDownloadManager.h"

#import "UIControl+EventInterval.h"

@interface WXYZ_BasicPlayPageHeaderView () <CKAudioProgressViewDelegate>

@end

@implementation WXYZ_BasicPlayPageHeaderView
{
    WXYZ_ProductionCoverView *bookImageView; // 作品图片
    UILabel *chapterNameLabel;
    UILabel *bookNameLabel;
    
    UIButton *fastForwardButton; // 快进
    UIButton *fastBackButton;   // 快退
    
    UIButton *playButton;       // 播放按钮
    UIActivityIndicatorView *playButtonIndicator;   // 播放loading
    UIButton *previousButton;   // 上一首
    UIButton *nextButton;       // 下一首
    
    
    WXYZ_CustomButton *chapterButton;   // 目录
    WXYZ_CustomButton *originalButton;  // 原文
    
    UIButton *relationView;
    UILabel *relationChapterTitle;
}

- (instancetype)initWithProductionType:(WXYZ_ProductionType)productionType
{
    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetPlayerInfo) name:Notification_Reset_Player_Inof object:nil];
        self.productionType = productionType;
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    // 作品图片
    bookImageView = [[WXYZ_ProductionCoverView alloc] initWithProductionType:WXYZ_ProductionTypeBook productionCoverDirection:WXYZ_ProductionCoverDirectionVertical];
    bookImageView.userInteractionEnabled = YES;
    [self addSubview:bookImageView];
    
    [bookImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.mas_top).with.offset(kMargin);
        make.width.mas_equalTo(BOOK_WIDTH);
        make.height.mas_equalTo(BOOK_HEIGHT);
    }];
    
    // 章节名
    chapterNameLabel = [[UILabel alloc] init];
    chapterNameLabel.textAlignment = NSTextAlignmentCenter;
    chapterNameLabel.textColor = kBlackColor;
    chapterNameLabel.backgroundColor = kWhiteColor;
    chapterNameLabel.font = kBoldFont17;
    [self addSubview:chapterNameLabel];
    
    [chapterNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(bookImageView.mas_centerX);
        make.top.mas_equalTo(bookImageView.mas_bottom).with.offset(kHalfMargin);
        make.width.mas_equalTo(SCREEN_WIDTH - 2 * kMargin);
        make.height.mas_equalTo(kLabelHeight);
    }];
    
    // 作者
    bookNameLabel = [[UILabel alloc] init];
    bookNameLabel.backgroundColor = kWhiteColor;
    bookNameLabel.textColor = kGrayTextColor;
    bookNameLabel.textAlignment = NSTextAlignmentCenter;
    bookNameLabel.font = kFont11;
    [self addSubview:bookNameLabel];
    
    [bookNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(chapterNameLabel.mas_bottom);
        make.centerX.mas_equalTo(chapterNameLabel.mas_centerX);
        make.width.mas_equalTo(chapterNameLabel.mas_width);
        make.height.mas_equalTo(chapterNameLabel.mas_height);
    }];
    
    if (self.productionType == WXYZ_ProductionTypeAudio) {
        
        fastBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        fastBackButton.tag = 1;
        fastBackButton.enabled = NO;
        fastBackButton.touchEventInterval = 0.5;
        [fastBackButton setImageEdgeInsets:UIEdgeInsetsMake(6, 12, 6, 0)];
        [fastBackButton setImage:[UIImage imageNamed:@"audio_fast_back"] forState:UIControlStateNormal];
        [fastBackButton addTarget:self action:@selector(adjustProgress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:fastBackButton];
        
        [fastBackButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).with.offset(kMoreHalfMargin);
            make.top.mas_equalTo(bookNameLabel.mas_bottom).with.offset(kMargin);
            make.width.height.mas_equalTo(30);
        }];
        
        fastForwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        fastForwardButton.tag = 0;
        fastForwardButton.enabled = NO;
        fastForwardButton.touchEventInterval = 0.5;
        [fastForwardButton setImageEdgeInsets:UIEdgeInsetsMake(6, 0, 6, 12)];
        [fastForwardButton setImage:[UIImage imageNamed:@"audio_fast_forward"] forState:UIControlStateNormal];
        [fastForwardButton addTarget:self action:@selector(adjustProgress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:fastForwardButton];
        
        [fastForwardButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.mas_right).with.offset(- kMoreHalfMargin);
            make.centerY.mas_equalTo(fastBackButton.mas_centerY);
            make.width.height.mas_equalTo(30);
        }];
        
        self.timelineProgress = [[CKAudioProgressView alloc] initWithFrame:CGRectZero type:CKAudioProgressTypeTimeline];
        self.timelineProgress.playedBgColor = kMainColor;
        self.timelineProgress.cachedBgColor = kMainColorAlpha(0.2);
        self.timelineProgress.delegate = self;
        self.timelineProgress.userInteractionEnabled = NO;
        [self.timelineProgress updateProgress:0 audioLength:0];
        [self addSubview:self.timelineProgress];
        
        [self.timelineProgress mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(fastBackButton.mas_right).with.offset(kHalfMargin);
            make.right.mas_equalTo(fastForwardButton.mas_left).with.offset(- kHalfMargin);
            make.centerY.mas_equalTo(fastBackButton.mas_centerY);
            make.height.mas_equalTo(30);
        }];
    }
    
    playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.adjustsImageWhenHighlighted = NO;
    playButton.enabled = NO;
    playButton.touchEventInterval = 0.5;
    [playButton setImage:[UIImage imageNamed:@"audio_play_loading"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:playButton];
    
    [playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(bookImageView.mas_centerX);
        if (self.productionType == WXYZ_ProductionTypeAudio) {
            make.top.mas_equalTo(self.timelineProgress.mas_bottom).with.offset(kMargin);
        } else {
            make.top.mas_equalTo(bookNameLabel.mas_bottom).with.offset(kMargin);
        }
        make.width.height.mas_equalTo(bookImageView.mas_width).with.multipliedBy(0.5);
    }];
    
    playButtonIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhite)];
    playButtonIndicator.color = kWhiteColor;
    playButtonIndicator.hidesWhenStopped = YES;
    [playButton addSubview:playButtonIndicator];
    [playButtonIndicator startAnimating];
    
    [playButtonIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(playButton.mas_centerX).with.offset(1);
        make.centerY.mas_equalTo(playButton.mas_centerY).with.offset(1);
        make.width.height.mas_equalTo(playButton);
    }];
    
    previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previousButton.adjustsImageWhenHighlighted = NO;
    previousButton.enabled = NO;
    previousButton.tag = 1;
    previousButton.touchEventInterval = 0.5;
    [previousButton setImage:[UIImage imageNamed:@"audio_previous_unenable"] forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(skipToLastChapter) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:previousButton];
    
    [previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(playButton.mas_centerY);
        make.right.mas_equalTo(bookImageView.mas_left).with.offset(- kMargin);
        make.width.height.mas_equalTo(playButton.mas_width).with.multipliedBy(0.4);
    }];
    
    nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.adjustsImageWhenHighlighted = NO;
    nextButton.enabled = NO;
    nextButton.tag = 2;
    nextButton.touchEventInterval = 0.5;
    [nextButton setImage:[UIImage imageNamed:@"audio_next_unenable"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(skipToNextChapter) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextButton];
    
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(playButton.mas_centerY);
        make.left.mas_equalTo(bookImageView.mas_right).with.offset(kMargin);
        make.width.height.mas_equalTo(previousButton);
    }];
    
    CGFloat buttonSpace = (SCREEN_WIDTH - 2 * kMargin - 5 * 80) / 4;
    if (self.productionType == WXYZ_ProductionTypeAudio) {
        buttonSpace = (SCREEN_WIDTH - 2 * kMargin - 4 * 80) / 3;
    }
    
    self.timingButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"定时" buttonImageName:@"audio_speech_timing" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
    self.timingButton.tag = 0;
    self.timingButton.buttonTitleFont = kFont10;
    self.timingButton.graphicDistance = 5;
    self.timingButton.buttonImageScale = 0.5;
    [self.timingButton addTarget:self action:@selector(toolBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.timingButton];
    
    [self.timingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.top.mas_equalTo(playButton.mas_bottom).with.offset(kMargin);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(50);
    }];
    
    self.speedButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"语速" buttonImageName:[NSString stringWithFormat:@"audio_speech_speed%@", [WXYZ_UtilsHelper formatStringWithInteger:[[WXYZ_AudioSettingHelper sharedManager] getReadSpeedWithProducitionType:self.productionType]]]  buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
    self.speedButton.tag = 1;
    self.speedButton.buttonTitleFont = kFont10;
    self.speedButton.graphicDistance = 5;
    self.speedButton.buttonImageScale = 0.55;
    [self.speedButton addTarget:self action:@selector(toolBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.speedButton];
    
    [self.speedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.timingButton.mas_right).with.offset(buttonSpace);
        make.top.mas_equalTo(self.timingButton.mas_top);
        make.width.mas_equalTo(self.timingButton.mas_width);
        make.height.mas_equalTo(self.timingButton.mas_height);
    }];
    
    if (self.productionType == WXYZ_ProductionTypeAi) {
        self.voiceButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:[[WXYZ_AudioSettingHelper sharedManager] getReadVoiceTitleWithProducitionType:WXYZ_ProductionTypeAi] buttonImageName:@"audio_speech_tone" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
        self.voiceButton.tag = 2;
        self.voiceButton.buttonTitleFont = kFont10;
        self.voiceButton.graphicDistance = 5;
        self.voiceButton.buttonImageScale = 0.5;
        [self.voiceButton addTarget:self action:@selector(toolBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.voiceButton];
        
        [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.speedButton.mas_right).with.offset(buttonSpace);
            make.top.mas_equalTo(self.timingButton.mas_top);
            make.width.mas_equalTo(self.timingButton.mas_width);
            make.height.mas_equalTo(self.timingButton.mas_height);
        }];
    }
    
    chapterButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"目录" buttonImageName:@"audio_speech_catalogue" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
    chapterButton.tag = 3;
    chapterButton.buttonTitleFont = kFont10;
    chapterButton.graphicDistance = 5;
    chapterButton.buttonImageScale = 0.5;
    [chapterButton addTarget:self action:@selector(toolBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:chapterButton];
    
    [chapterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.productionType == WXYZ_ProductionTypeAudio) {
            make.left.mas_equalTo(self.speedButton.mas_right).with.offset(buttonSpace);
        } else {
            make.left.mas_equalTo(self.voiceButton.mas_right).with.offset(buttonSpace);
        }
        make.top.mas_equalTo(self.timingButton.mas_top);
        make.width.mas_equalTo(self.timingButton.mas_width);
        make.height.mas_equalTo(self.timingButton.mas_height);
    }];
    
    originalButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"原文" buttonImageName:@"audio_speech_original" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
    originalButton.tag = 4;
    originalButton.buttonTitleFont = kFont10;
    originalButton.graphicDistance = 5;
    originalButton.buttonImageScale = 0.5;
    [originalButton addTarget:self action:@selector(toolBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:originalButton];
    
    [originalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(chapterButton.mas_right).with.offset(buttonSpace);
        make.top.mas_equalTo(self.timingButton.mas_top);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(self.timingButton.mas_height);
    }];
    
    relationView = [UIButton buttonWithType:UIButtonTypeCustom];
    relationView.backgroundColor = kGrayViewColor;
    relationView.layer.cornerRadius = 6;
    relationView.clipsToBounds = YES;
    [relationView addTarget:self action:@selector(relationProductionClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:relationView];
    
    [relationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin);
        make.top.mas_equalTo(originalButton.mas_bottom).with.offset(kMargin);
        make.width.mas_equalTo(SCREEN_WIDTH - kMargin);
        make.height.mas_equalTo(80);
    }];
    
    UIImageView *relationIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_change_to_sound"]];
    if (self.productionType == WXYZ_ProductionTypeAudio) {
        relationIcon.image = [UIImage imageNamed:@"audio_change_to_ai"];
    }
    relationIcon.userInteractionEnabled = YES;
    [relationView addSubview:relationIcon];
    
    [relationIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.centerY.mas_equalTo(relationView.mas_centerY);
        make.width.height.mas_equalTo(relationView.mas_height).with.multipliedBy(0.5);
    }];
    
    UIImageView *connerImage = [[UIImageView alloc] init];
    connerImage.image = [UIImage imageNamed:@"public_more"];
    [relationView addSubview:connerImage];
    
    [connerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(relationView.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(relationView.mas_centerY);
        make.width.height.mas_equalTo(10);
    }];
    
    UILabel *relationLabel = [[UILabel alloc] init];
    relationLabel.text = @"切换到有声阅读";
    if (self.productionType == WXYZ_ProductionTypeAudio) {
        relationLabel.text = @"切换到AI语音阅读";
    }
    relationLabel.textColor = kBlackColor;
    relationLabel.textAlignment = NSTextAlignmentLeft;
    relationLabel.font = kMainFont;
    [relationView addSubview:relationLabel];
    
    [relationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(relationIcon.mas_right).with.offset(kHalfMargin);
        make.right.mas_equalTo(connerImage.mas_left).with.offset(- kHalfMargin);
        make.bottom.mas_equalTo(connerImage.mas_centerY);
        make.height.mas_equalTo(relationView.mas_height).multipliedBy(0.3);
    }];
    
    relationChapterTitle = [[UILabel alloc] init];
    relationChapterTitle.textColor = kGrayTextColor;
    relationChapterTitle.textAlignment = NSTextAlignmentLeft;
    relationChapterTitle.font = kFont10;
    [relationView addSubview:relationChapterTitle];
    
    [relationChapterTitle mas_makeConstraints:^(MASConstraintMaker *make) {
       make.left.mas_equalTo(relationIcon.mas_right).with.offset(kHalfMargin);
       make.right.mas_equalTo(connerImage.mas_left).with.offset(- kHalfMargin);
       make.top.mas_equalTo(connerImage.mas_centerY);
       make.height.mas_equalTo(relationView.mas_height).multipliedBy(0.3);
    }];
    
}

- (void)setProductionChapterModel:(WXYZ_ProductionChapterModel *)productionChapterModel
{
    _productionChapterModel = productionChapterModel;
    
    // 封面
    [bookImageView resetDefaultHoldImage];
    bookImageView.coverImageURL = productionChapterModel.cover;
    
    // 章节
    chapterNameLabel.text = [WXYZ_UtilsHelper formatStringWithObject:productionChapterModel.chapter_title?:@""];
    
    // 标题
    bookNameLabel.text = [WXYZ_UtilsHelper formatStringWithObject:productionChapterModel.name?:@""];
    
    // 设置总音频时长
    self.timelineProgress.totalTimeLength = productionChapterModel.duration_second;
    
    // 下一首
    if (productionChapterModel.last_chapter > 0 && productionChapterModel.last_chapter) {
        [previousButton setImage:[UIImage imageNamed:@"audio_previous_enable"] forState:UIControlStateNormal];
        previousButton.enabled = YES;
    } else {
        [previousButton setImage:[UIImage imageNamed:@"audio_previous_unenable"] forState:UIControlStateNormal];
        previousButton.enabled = NO;
    }
    
    // 上一首
    if (productionChapterModel.next_chapter > 0 && productionChapterModel.next_chapter) {
        [nextButton setImage:[UIImage imageNamed:@"audio_next_enable"] forState:UIControlStateNormal];
        nextButton.enabled = YES;
    } else {
        [nextButton setImage:[UIImage imageNamed:@"audio_next_unenable"] forState:UIControlStateNormal];
        nextButton.enabled = NO;
    }
    
    [self layoutIfNeeded];
}

- (void)setRelationModel:(WXYZ_RelationModel *)relationModel
{
    _relationModel = relationModel;

    // 更新关联作品章节标题
    relationChapterTitle.text = [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:(self.productionType == WXYZ_ProductionTypeAudio?WXYZ_ProductionTypeAi:WXYZ_ProductionTypeAudio)] getReadingRecordChapterTitleWithProduction_id:relationModel.production_id]?:relationModel.chapter_title?:@"";
    
    if (self.productionType == WXYZ_ProductionTypeAudio) {
        if (relationModel.production_id > 0) {
            relationView.hidden = NO;
            originalButton.hidden = NO;
            CGFloat buttonSpace = (SCREEN_WIDTH - 2 * kMargin - 4 * 80) / 3;
            [self.timingButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(kMargin);
            }];
            [self.speedButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.timingButton.mas_right).with.offset(buttonSpace);
            }];
            [chapterButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.speedButton.mas_right).with.offset(buttonSpace);
            }];
            
            if ([WXYZ_UtilsHelper getAiReadSwitchState]) {
                [relationView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(80);
                }];
            } else {
                [relationView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(CGFLOAT_MIN);
                }];
            }
        } else {
            relationView.hidden = YES;
            originalButton.hidden = YES;
            CGFloat buttonSpace = (SCREEN_WIDTH - 4 * kMargin - 3 * 80) / 2;
            [self.timingButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(2 * kMargin);
            }];
            [self.speedButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.timingButton.mas_right).with.offset(buttonSpace);
            }];
            [chapterButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.speedButton.mas_right).with.offset(buttonSpace);
            }];
            [relationView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(CGFLOAT_MIN);
            }];
        }
    } else {
        if (relationModel.production_id > 0 && [WXYZ_UtilsHelper getAiReadSwitchState]) {
            relationView.hidden = NO;
            [relationView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(80);
            }];
        } else {
            relationView.hidden = YES;
            [relationView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(CGFLOAT_MIN);
            }];
        }
    }
    
    [self layoutIfNeeded];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, relationView.bottom + kHalfMargin);
}

// 设置关联作品标题
- (void)setRelationViewTitle:(NSString *)title
{
    // 更新关联作品章节标题
    relationChapterTitle.text = title;
}

#pragma mark - CKAudioProgressViewDelegate
// 拖动进度条
- (void)audioProgresstouchEndhCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime
{
    if ([WXYZ_Player sharedPlayer].state == WXYZ_PlayPagePlayerStateStoped) {
        return;
    }
    
    self.playerState = WXYZ_PlayPagePlayerStateLoading;
    
    [[WXYZ_Player sharedPlayer] seekToTime:(float)currentTime / totalTime completionBlock:^{
        
    }];
}

#pragma mark - 点击事件

- (void)playButtonClick
{
    if (self.productionChapterModel.is_preview == 1 && ![WXYZ_UserInfoManager shareInstance].auto_sub) {
        [self showPayView];
        return;
    }
    
    if ([WXYZ_NetworkReachabilityManager networkingStatus] == NO && ![[WXYZ_AudioDownloadManager sharedManager] isChapterDownloadedWithProduction_id:self.productionChapterModel.production_id chapter_id:self.productionChapterModel.chapter_id]) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"当前为离线状态，只可查看缓存内容哦"];
        return;
    }
    
    if (self.productionType == WXYZ_ProductionTypeAi) {
        [[WXYZ_Player sharedPlayer] pause];
        
        if (self.playerState == WXYZ_PlayPagePlayerStatePlaying) {
            [[IFlySpeechSynthesizer sharedInstance] pauseSpeaking];
        } else {
            [[IFlySpeechSynthesizer sharedInstance] resumeSpeaking];
            if (self.resetPlayerBlock) {
                self.resetPlayerBlock(NO);
            }
        }
    } else {
        [[IFlySpeechSynthesizer sharedInstance] pauseSpeaking];
        
        if ([WXYZ_Player sharedPlayer].state == WXYZ_PlayPagePlayerStatePlaying) {
            [[WXYZ_Player sharedPlayer] pause];
            self.playerState = WXYZ_PlayPagePlayerStatePause;
        } else if ([WXYZ_Player sharedPlayer].state == WXYZ_PlayPagePlayerStatePause) {
            [[WXYZ_Player sharedPlayer] play];
            self.playerState = WXYZ_PlayPagePlayerStatePlaying;
            if ([WXYZ_BookAiPlayPageViewController sharedManager].speaking) {
                [[IFlySpeechSynthesizer sharedInstance] pauseSpeaking];
            }
        } else if ([WXYZ_Player sharedPlayer].state == WXYZ_PlayPagePlayerStateStoped) {
            [[WXYZ_Player sharedPlayer] reloadData]; // 需在传入数据源后调用
            [[WXYZ_Player sharedPlayer] playWithAudioId:0];
        } else if ([WXYZ_Player sharedPlayer].state == WXYZ_PlayPagePlayerStateFail) {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"播放出错"];
        }
    }
}

- (void)skipToLastChapter
{
    self.playerState = WXYZ_PlayPagePlayerStateLoading;
    
    NSInteger skipChapter_id = 0;
    if (self.productionChapterModel.last_chapter > 0) {
        skipChapter_id = self.productionChapterModel.last_chapter;
    }
    
    if (skipChapter_id == 0) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"章节正在更新中"];
        return;
    }
    
    if (self.productionType == WXYZ_ProductionTypeAi) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Change_AiBook_Chapter object:[WXYZ_UtilsHelper formatStringWithInteger:skipChapter_id]];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Change_Audio_Chapter object:[WXYZ_UtilsHelper formatStringWithInteger:skipChapter_id]];
    }
}

- (void)skipToNextChapter
{
    self.playerState = WXYZ_PlayPagePlayerStateLoading;
    
    NSInteger skipChapter_id = 0;
    if (self.productionChapterModel.next_chapter > 0) {
        skipChapter_id = self.productionChapterModel.next_chapter;
    }
    
    if (skipChapter_id == 0) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"章节正在更新中"];
        return;
    }
    
    if (self.productionType == WXYZ_ProductionTypeAi) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Change_AiBook_Chapter object:[WXYZ_UtilsHelper formatStringWithInteger:skipChapter_id]];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Change_Audio_Chapter object:[WXYZ_UtilsHelper formatStringWithInteger:skipChapter_id]];
    }
}

- (void)relationProductionClick
{
    if (self.checkRelationProductionBlock) {
        self.checkRelationProductionBlock(self.relationModel);
    }
}

// 快进或快退
- (void)adjustProgress:(UIButton *)sender
{
    sender.enabled = NO;
    CGFloat valuePercentage = 0;
    CGFloat currentTime = [[WXYZ_Player sharedPlayer] currentTime];
    CGFloat totalTime = [[WXYZ_Player sharedPlayer] totalTime];
    if (sender.tag == 0) { // 快进
        if (currentTime + 15 > totalTime) {
            valuePercentage = 1;
        } else {
            valuePercentage = (currentTime + 15) / totalTime;
        }
    } else { // 快退
        if (currentTime - 15 > 0) {
            valuePercentage = (currentTime - 15) / totalTime;
        }
    }
    
    [[WXYZ_Player sharedPlayer] seekToTime:valuePercentage completionBlock:^{
        sender.enabled = YES;
    }];
    [self.timelineProgress updateProgress:valuePercentage audioLength:totalTime];
    
}

- (void)toolBarButtonClick:(UIButton *)sender
{
    if (sender.tag == 4) {
        if (self.productionType == WXYZ_ProductionTypeAi) {
            [[WXYZ_ReaderSettingHelper sharedManager] setLocationMemoryOfChapterIndex:[self.productionChapterModel.display_order integerValue] pagerIndex:0 book_id:self.productionChapterModel.production_id];
            [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Retry_Chapter object:@"1"];
        }
        if (self.checkOriginalBlock) {
            self.checkOriginalBlock(self.productionChapterModel);
        }
        return;
    }
    WS(weakSelf)
    
    WXYZ_AudioPlayPageMenuView *playPageMenuView = [[WXYZ_AudioPlayPageMenuView alloc] init];
    switch (sender.tag) {
        case 0:
            [playPageMenuView showWithMenuType:WXYZ_MenuTypeTiming];
            break;
        case 1:
            if (self.productionType == WXYZ_ProductionTypeAudio) {
                [playPageMenuView showWithMenuType:WXYZ_MenuTypeAudioSpeed];
            } else {
                [playPageMenuView showWithMenuType:WXYZ_MenuTypeAiSpeed];
            }
            break;
        case 2:
            [playPageMenuView showWithMenuType:WXYZ_MenuTypeAiVoice];
            break;
        case 3:
            playPageMenuView.menuListArray = self.chapter_list;
            if (self.chapter_list.firstObject.total_chapters != 0) {
                playPageMenuView.totalChapter = self.chapter_list.firstObject.total_chapters;
            } else {
                playPageMenuView.totalChapter = self.chapter_list.count;
            }
            if (self.productionType == WXYZ_ProductionTypeAudio) {
                [playPageMenuView showWithMenuType:WXYZ_MenuTypeAudioDirectory];
            } else {
                [playPageMenuView showWithMenuType:WXYZ_MenuTypeAiDirectory];
            }
            
            break;
        default:
            break;
    }
    playPageMenuView.chooseMenuBlock = ^(WXYZ_MenuType menuType, NSInteger chooseIndex) {
        switch (menuType) {
            case WXYZ_MenuTypeTiming:
            {
                SS(strongSelf)
                [[WXYZ_AudioSettingHelper sharedManager] startTimingFinishBlock:^{
                    if ([[WXYZ_AudioSettingHelper sharedManager] getReadTiming] == 1) {
                        strongSelf.timingButton.buttonTitle = @"听完本章节";
                    } else if ([[WXYZ_AudioSettingHelper sharedManager] getReadTiming] == 0) {
                        strongSelf.timingButton.buttonTitle = @"定时";
                    }
                }];
            }
                break;
            case WXYZ_MenuTypeAiSpeed:
            case WXYZ_MenuTypeAudioSpeed:
                weakSelf.speedButton.buttonImageName = [NSString stringWithFormat:@"audio_speech_speed%@", [WXYZ_UtilsHelper formatStringWithInteger:chooseIndex]];
                
                if (weakSelf.productionType == WXYZ_ProductionTypeAudio) {
                    [[WXYZ_Player sharedPlayer] setRate:[[[[WXYZ_AudioSettingHelper sharedManager] getReadSpeedValuesWithProducitionType:weakSelf.productionType] objectAtIndex:[[WXYZ_AudioSettingHelper sharedManager] getReadSpeedWithProducitionType:weakSelf.productionType]] floatValue]];
                } else {
                    if (weakSelf.resetPlayerBlock) {
                        weakSelf.resetPlayerBlock(YES);
                    }
                }
                break;
            case WXYZ_MenuTypeAiVoice:
                self.voiceButton.buttonTitle = [[WXYZ_AudioSettingHelper sharedManager] getReadVoiceTitleWithProducitionType:WXYZ_ProductionTypeAi];
                if (weakSelf.resetPlayerBlock) {
                    weakSelf.resetPlayerBlock(YES);
                }
                break;
            default:
                break;
        }
    };
    playPageMenuView.chooseDirectoryMenuBlock = ^(NSInteger chapter_id, NSInteger chooseIndex) {
        if (weakSelf.productionType == WXYZ_ProductionTypeAudio) {
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Change_Audio_Chapter object:[WXYZ_UtilsHelper formatStringWithInteger:chapter_id]];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Change_AiBook_Chapter object:[WXYZ_UtilsHelper formatStringWithInteger:chapter_id]];
        }
    };
}

- (void)resetPlayerInfo
{
    self.temp_chapterModel = [[WXYZ_ProductionChapterModel alloc] init];
}

- (void)showPayView
{
    if (![[WXYZ_AudioSettingHelper sharedManager] isPlayPageShowingWithProductionType:WXYZ_ProductionTypeAi] && ![[WXYZ_AudioSettingHelper sharedManager] isPlayPageShowingWithProductionType:WXYZ_ProductionTypeAudio]) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"听到付费章节啦"];            
        });
        return;
    }
    
    WS(weakSelf)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        WXYZ_ChapterBottomPayBar *payBar = [[WXYZ_ChapterBottomPayBar alloc] initWithChapterModel:self.productionChapterModel barType:WXYZ_BottomPayBarTypeBuyChapter productionType:self.productionType];
        payBar.paySuccessChaptersBlock = ^(NSArray<NSString *> * _Nonnull success_chapter_ids) {
            if (weakSelf.productionType == WXYZ_ProductionTypeAi) {
                [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Change_AiBook_Chapter object:[WXYZ_UtilsHelper formatStringWithInteger:weakSelf.productionChapterModel.chapter_id] userInfo:@{@"success_chapter_ids":success_chapter_ids}];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Change_Audio_Chapter object:[WXYZ_UtilsHelper formatStringWithInteger:weakSelf.productionChapterModel.chapter_id]];
            }
        };
        [payBar showBottomPayBar];
    });
}

- (void)setPlayerState:(WXYZ_PlayPagePlayerState)playerState
{
    if (self) {
        _playerState = playerState;
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (playerState) {
                case WXYZ_PlayPagePlayerStateLoading:
                    fastForwardButton.enabled = NO;
                    fastBackButton.enabled = NO;
                    playButton.enabled = NO;
                    [playButton setImage:[UIImage imageNamed:@"audio_play_loading"] forState:UIControlStateNormal];
                    [playButtonIndicator startAnimating];
                    break;
                case WXYZ_PlayPagePlayerStatePlaying:
                    fastForwardButton.enabled = YES;
                    fastBackButton.enabled = YES;
                    playButton.enabled = YES;
                    [playButton setImage:[UIImage imageNamed:@"audio_suspended"] forState:UIControlStateNormal];
                    [playButtonIndicator stopAnimating];
                    self.timelineProgress.userInteractionEnabled = YES;
                    [[WXYZ_TouchAssistantView sharedManager] playPlayerState];
                    if (self.productionType == WXYZ_ProductionTypeAudio && [[WXYZ_Player sharedPlayer] progress] == 0) {
                        [self.timelineProgress updateProgress:0 audioLength:[[WXYZ_Player sharedPlayer] totalTime]];
                    }
                    break;
                case WXYZ_PlayPagePlayerStatePause:
                    fastForwardButton.enabled = YES;
                    fastBackButton.enabled = YES;
                    playButton.enabled = YES;
                    [playButton setImage:[UIImage imageNamed:@"audio_play"] forState:UIControlStateNormal];
                    [playButtonIndicator stopAnimating];
                    [[WXYZ_TouchAssistantView sharedManager] pausePlayerState];
                    break;
                case WXYZ_PlayPagePlayerStateFail:
                    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"播放出错"];
                case WXYZ_PlayPagePlayerStateStoped:
                    fastForwardButton.enabled = NO;
                    fastBackButton.enabled = NO;
                    playButton.enabled = YES;
                    [playButton setImage:[UIImage imageNamed:@"audio_play"] forState:UIControlStateNormal];
                    [playButtonIndicator stopAnimating];
                    [[WXYZ_TouchAssistantView sharedManager] stopPlayerState];
                    [self.timelineProgress updateCacheProgress:0];
                    [self.timelineProgress updateProgress:0 audioLength:0];
                    break;
                default:
                    break;
            }
        });
    }
}

@end

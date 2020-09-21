//
//  WXYZ_BookReaderTopBar.m
//  WXReader
//
//  Created by Andrew on 2018/6/12.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BookReaderTopBar.h"
#import "WXYZ_ReaderSettingHelper.h"
#import "WXYZ_ReaderBookManager.h"
#if WX_W_Share_Mode || WX_Q_Share_Mode
    #import "WXYZ_ShareManager.h"
#endif

#if WX_Download_Mode
    #import "WXYZ_BookDownloadMenuBar.h"
    #import "WXYZ_ReaderBookManager.h"
#endif

#if WX_Enable_Ai
    #import "WXYZ_BookAiPlayPageViewController.h"
    #import "WXYZ_AudioSoundPlayPageViewController.h"
    #import "WXYZ_AudioSettingHelper.h"
#endif

#import "WXYZ_ProductionReadRecordManager.h"

#import "WXYZ_MoreView.h"
#import "WXYZ_GiftView.h"

#import "AppDelegate.h"

@interface WXYZ_BookReaderTopBar ()

@property (nonatomic, assign) BOOL navBarShowing;

@end

@implementation WXYZ_BookReaderTopBar
{
    WXYZ_ReaderSettingHelper *functionalManager;
    UIButton *moreButton;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self initialize];
        [self createSubViews];
    }
    return self;
}

- (void)initialize
{
    self.backgroundColor = [UIColor whiteColor];
    functionalManager = [WXYZ_ReaderSettingHelper sharedManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenNavBar) name:NSNotification_Hidden_ToolNav object:nil];

}

- (void)createSubViews
{
    UIImageView *bottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, PUB_NAVBAR_HEIGHT, self.width, 10)];
    bottomLine.userInteractionEnabled = YES;
    bottomLine.image = [UIImage imageNamed:@"navbar_bottom_line"];
    [self addSubview:bottomLine];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0f, PUB_NAVBAR_HEIGHT - 64.0f, 64.0f, 64.0f);
    button.backgroundColor = [UIColor clearColor];
    button.adjustsImageWhenHighlighted = NO;
    [button.titleLabel setFont:kMainFont];
    [button setTitleColor:kBlackColor forState:UIControlStateNormal];
    [button setImage:[[UIImage imageNamed:@"public_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(30, 14, 10, 26)];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button setTintColor:kBlackColor];
    [button addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    UIView *menuView = [[UIView alloc] init];
    menuView.backgroundColor = [UIColor clearColor];
    [self addSubview:menuView];
    
    moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.backgroundColor = [UIColor clearColor];
    moreButton.tintColor = kBlackColor;
    [moreButton.titleLabel setFont:kMainFont];
    [moreButton setImage:[[UIImage imageNamed:@"book_more"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [moreButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreEvent) forControlEvents:UIControlEventTouchUpInside];
    moreButton.imageEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [menuView addSubview:moreButton];
    moreButton.hidden = isMagicState;
    
#if WX_Download_Mode
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    downloadButton.hidden = NO;
    downloadButton.adjustsImageWhenHighlighted = NO;
    downloadButton.tintColor = kBlackColor;
    [downloadButton setImage:[[UIImage imageNamed:@"public_download"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [downloadButton setImageEdgeInsets:UIEdgeInsetsMake(11, 11, 11, 11)];
    [downloadButton addTarget:self action:@selector(downloadButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:downloadButton];
    downloadButton.hidden = isMagicState;
#endif
    
#if WX_Enable_Ai
    UIButton *radioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    radioButton.hidden = NO;
    radioButton.adjustsImageWhenHighlighted = NO;
    radioButton.tintColor = kBlackColor;
    [radioButton setImage:[[UIImage imageNamed:@"audio_book"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [radioButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [radioButton addTarget:self action:@selector(radioButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:radioButton];
    radioButton.hidden = isMagicState;
#endif
    
#if WX_Enable_Gift
    UIButton *giftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    giftButton.hidden = NO;
    giftButton.adjustsImageWhenHighlighted = NO;
    giftButton.tintColor = kBlackColor;
    [giftButton setImage:[[YYImage imageNamed:@"book_gift"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [giftButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [giftButton addTarget:self action:@selector(giftButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:giftButton];
#endif
    
    NSMutableArray *buttonMenuArr = [NSMutableArray arrayWithObjects:
#if WX_Download_Mode
                              downloadButton,
#endif
                              moreButton,
                                  nil];
    
#if WX_Enable_Ai
    if (!isMagicState) {
        if ([WXYZ_UtilsHelper getAiReadSwitchState]) {
            [buttonMenuArr insertObject:radioButton atIndex:0];
        } else {
            radioButton.hidden = YES;
        }
    }
#endif
    
    AppDelegate *app = (AppDelegate *)kRCodeSync([UIApplication sharedApplication].delegate);
    WXYZ_CheckSettingModel *model = app.checkSettingModel;
    if (WX_Enable_Gift && (model.system_setting.novel_reward_switch == 1 || model.system_setting.monthly_ticket_switch == 1)) {
        if (!isMagicState) {
            [buttonMenuArr insertObject:giftButton atIndex:0];
            giftButton.hidden = NO;
        } else {
            giftButton.hidden = YES;
        }
    } else {
        giftButton.hidden = YES;
    }
    
    if (isMagicState) {
        giftButton.hidden = YES;
    }
    
    [menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).with.offset(- kHalfMargin);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.width.mas_equalTo(40 * buttonMenuArr.count + (buttonMenuArr.count - 1) * kHalfMargin);
        make.height.mas_equalTo(40);
    }];
        
    [buttonMenuArr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:10 leadSpacing:0 tailSpacing:0];
    [buttonMenuArr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(40);
    }];
}

// 隐藏导航条
- (void)hiddenNavBarCompletion:(void(^)(void))completion
{
    if (!_navBarShowing && functionalManager.state != WXReaderAutoReadStatePause && functionalManager.state != WXReaderAutoReadStateStop) {
        return;
    }
    [functionalManager hiddenStatusBar];
    [UIView animateWithDuration:kAnimatedDurationFast animations:^{
        self.frame = CGRectMake(0, - PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, PUB_NAVBAR_HEIGHT);
    } completion:^(BOOL finished) {
        if (completion) {
            self.navBarShowing = NO;
            !completion ?: completion();
        }
    }];
}

- (void)hiddenNavBar
{
    [self hiddenNavBarCompletion:nil];
}

// 显示导航条
- (void)showNavBarCompletion:(void(^)(void))completion
{
    if (_navBarShowing) {
        return;
    }
    [functionalManager showStatusBar];
    [WXYZ_ViewHelper setStateBarDefaultStyle];
    [UIView animateWithDuration:kAnimatedDurationFast animations:^{
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, PUB_NAVBAR_HEIGHT);
    } completion:^(BOOL finished) {
        if (completion) {
            self.navBarShowing = YES;
            !completion ?: completion();
        }
    }];
}

#if WX_Download_Mode
- (void)downloadButtonClick
{
    WXYZ_BookDownloadMenuBar *downloadBar = [[WXYZ_BookDownloadMenuBar alloc] init];
    downloadBar.book_id = [WXYZ_UtilsHelper formatStringWithInteger:[WXYZ_ReaderBookManager sharedManager].book_id];
    downloadBar.chapter_id = [WXYZ_UtilsHelper formatStringWithInteger:[WXYZ_ReaderBookManager sharedManager].chapter_id];
    [kMainWindow addSubview:downloadBar];
    
    [downloadBar showDownloadPayView];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Hidden_Bottom_ToolNav object:nil];
}
#endif

#if WX_Enable_Ai
- (void)radioButtonClick
{
    if ([WXYZ_NetworkReachabilityManager networkingStatus] == NO) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"听书功能仅支持在线使用"];
        return;
    }
    
    WXYZ_ProductionModel *bookModel = [WXYZ_ReaderBookManager sharedManager].bookModel;
    WXYZ_ProductionChapterModel *bookChapterModel = [[WXYZ_ProductionChapterModel alloc] init];
    for (WXYZ_ProductionChapterModel *t_model in bookModel.chapter_list) {
        if (t_model.chapter_id == [WXYZ_ReaderBookManager sharedManager].chapter_id) {
            bookChapterModel = t_model;
            break;
        }
    }
    
    WXYZ_BookAiPlayPageViewController *vc = [WXYZ_BookAiPlayPageViewController sharedManager];
    [vc loadDataWithBookModel:bookModel chapterModel:bookChapterModel];
    
    if ([[WXYZ_AudioSettingHelper sharedManager] isPlayPageShowingWithProductionType:WXYZ_ProductionTypeAi]) {
        [vc popViewController];
    } else if (![[WXYZ_AudioSettingHelper sharedManager] isPlayPageShowingWithProductionType:WXYZ_ProductionTypeAi] && [[WXYZ_AudioSettingHelper sharedManager] isPlayPageShowingWithProductionType:WXYZ_ProductionTypeAudio]) {
        [[WXYZ_AudioSoundPlayPageViewController sharedManager] popViewController];
        UINavigationController *nav = [WXYZ_ViewHelper getCurrentNavigationController];
        if ([nav.viewControllers.lastObject isKindOfClass:WXYZ_AudioMallDetailViewController.class]) {
            WXYZ_NavigationController *t_nav = [[WXYZ_NavigationController alloc] initWithRootViewController:vc];
            [[WXYZ_ViewHelper getCurrentViewController] presentViewController:t_nav animated:YES completion:nil];
        } else {
            [[WXYZ_AudioSoundPlayPageViewController sharedManager] popViewController];
        }
        
    } else if ([[WXYZ_AudioSettingHelper sharedManager] isPlayPageShowingWithProductionType:WXYZ_ProductionTypeAi] && [[WXYZ_AudioSettingHelper sharedManager] isPlayPageShowingWithProductionType:WXYZ_ProductionTypeAudio]) {
        [[WXYZ_AudioSoundPlayPageViewController sharedManager] popViewController];
        [[WXYZ_AudioSoundPlayPageViewController sharedManager] popViewController];
    } else {
        WXYZ_NavigationController *nav = [[WXYZ_NavigationController alloc] initWithRootViewController:vc];
        nav.view.tag = 2345;
        [[WXYZ_ViewHelper getWindowRootController] presentViewController:nav animated:YES completion:nil];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Hidden_Bottom_ToolNav object:nil];
}
#endif

- (void)giftButtonClick {
    WXYZ_GiftView *mainView = [[WXYZ_GiftView alloc] initWithFrame:CGRectZero bookModel:[WXYZ_ReaderBookManager sharedManager].bookModel];
    [mainView show];
    [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Hidden_Bottom_ToolNav object:nil];
}

// 返回
- (void)popViewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Reader_Back object:nil];
}

- (void)moreEvent {
    WXYZ_MoreView *mainView = [[WXYZ_MoreView alloc] init];
    [mainView show];
}

@end

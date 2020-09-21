//
//  WXYZ_ComicMenuBottomBar.m
//  WXReader
//
//  Created by Andrew on 2019/6/4.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicMenuBottomBar.h"
#import "WXYZ_ComicMenuSettingBar.h"

#import "WXYZ_ShareManager.h"
#import "WXYZ_ComicDownloadManager.h"
#import "WXYZ_ProductionCollectionManager.h"

#import "WXYZ_BadgeView.h"
#import "UIControl+EventInterval.h"

#define MenuButtonHeight 50

@implementation WXYZ_ComicMenuBottomBar
{
#if WX_Comments_Mode
    UIButton *commentsButton;
#endif
    
#if WX_Comments_Mode
    YYTextView *commentsTextView;
    UIButton *sendComments;
#endif
    
    UILabel *currentPageLabel;
    UIButton *previousButton;
    UIButton *nextButton;
    UIActivityIndicatorView *indicatorView;
    
    WXYZ_CustomButton *barrageSwitch;
    
    WXYZ_ComicMenuSettingBar *settingBar;
    
    UIButton *scrollToTop;
    UIButton *collectionButton;
    
    CGFloat keyboardHeight;     //键盘高度
    
    BOOL isCommentState;   // 是否是评论状态
    
    __weak UIButton *_leftImageButton;
    
    WXYZ_BadgeView *badgeView;
}

- (instancetype)init
{
    if (self = [super init]) {
        
#if WX_Comments_Mode
        self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, PUB_TABBAR_HEIGHT + Comic_Menu_Bottom_Bar_Top_Height);
#else
        self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, Comic_Menu_Bottom_Bar_Height - Comic_Menu_Bottom_Bar_Top_Height);
#endif
        
        self.backgroundColor = kGrayViewColor;
        
        //增加监听，当键盘出现或改变时收出消息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
        //增加监听，当键退出时收出消息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)name:UIKeyboardWillHideNotification object:nil];
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
#if WX_Comments_Mode
    sendComments = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:Enable_Barrage] isEqualToString:@"1"]) {
        [sendComments setTitle:@"发射" forState:UIControlStateNormal];
        isCommentState = NO;
    } else {
        [sendComments setTitle:@"发送" forState:UIControlStateNormal];
        isCommentState = YES;
    }
    sendComments.backgroundColor = [UIColor clearColor];
    [sendComments setTitleColor:kBlackColor forState:UIControlStateNormal];
    [sendComments.titleLabel setFont:kMainFont];
    [sendComments addTarget:self action:@selector(sendCommentsClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendComments];
    
    [sendComments mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right);
        make.top.mas_equalTo(kQuarterMargin);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(Comic_Menu_Bottom_Bar_Top_Height - kHalfMargin);
    }];
    
    commentsTextView = [[YYTextView alloc] init];
    commentsTextView.backgroundColor = kWhiteColor;
    commentsTextView.contentInset = UIEdgeInsetsMake(2, 30, 0, 0);
    commentsTextView.textVerticalAlignment = YYTextVerticalAlignmentCenter;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:Enable_Barrage] isEqualToString:@"1"]) {
        commentsTextView.placeholderText = @"发一条弹幕吧";
    } else {
        commentsTextView.placeholderText = @"发一条评论吧";
    }
    
    commentsTextView.placeholderFont = kFont12;
    commentsTextView.placeholderTextColor = kGrayTextColor;
    commentsTextView.font = kFont12;
    commentsTextView.returnKeyType = UIReturnKeySend;
    commentsTextView.layer.cornerRadius = (Comic_Menu_Bottom_Bar_Top_Height - kHalfMargin) / 2;
    commentsTextView.layer.borderColor = kGrayViewColor.CGColor;
    commentsTextView.layer.borderWidth = 0.8;
    commentsTextView.delegate = self;
    [self addSubview:commentsTextView];
    
    [commentsTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.top.mas_equalTo(kQuarterMargin);
        make.right.mas_equalTo(sendComments.mas_left).with.offset(kHalfMargin);
        make.height.mas_equalTo(sendComments.mas_height);
    }];

    
    UIButton *leftImageButton = [[UIButton alloc] init];
    _leftImageButton = leftImageButton;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:Enable_Barrage] isEqualToString:@"1"]) {
        leftImageButton.tag = 0;
        [leftImageButton setImage:[UIImage imageNamed:@"comic_barrage"] forState:UIControlStateNormal];
    } else {
        leftImageButton.tag = 1;
        [leftImageButton setImage:[UIImage imageNamed:@"comic_comments_icon"] forState:UIControlStateNormal];
    }
    
    leftImageButton.adjustsImageWhenHighlighted = NO;
    [leftImageButton addTarget:self action:@selector(changeCommentsState:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:leftImageButton];
    
    [leftImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(commentsTextView.mas_left).with.offset(kQuarterMargin);
        make.centerY.mas_equalTo(sendComments.mas_centerY);
        make.width.height.mas_equalTo(30 - kHalfMargin);
    }];
    
#endif
    
    // 上一话
    previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previousButton.backgroundColor = [UIColor clearColor];
    previousButton.adjustsImageWhenHighlighted = NO;
    previousButton.enabled = NO;
    [previousButton.titleLabel setFont:kMainFont];
    [previousButton setImage:[[UIImage imageNamed:@"public_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [previousButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [previousButton setTintColor:kGrayTextLightColor];
    [previousButton setImageEdgeInsets:UIEdgeInsetsMake(14, 20, 14, 8)];
    [previousButton addTarget:self action:@selector(previousButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:previousButton];
    
    [previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.bottom.mas_equalTo(self.mas_bottom).with.offset(- PUB_TABBAR_OFFSET);
        make.width.mas_equalTo(PUB_TABBAR_HEIGHT - PUB_TABBAR_OFFSET);
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT - PUB_TABBAR_OFFSET);
    }];
    
    currentPageLabel = [[UILabel alloc] init];
    currentPageLabel.text = @"当前话";
    currentPageLabel.textAlignment = NSTextAlignmentCenter;
    currentPageLabel.textColor = kBlackColor;
    currentPageLabel.font = kMainFont;
    [self addSubview:currentPageLabel];
    
    [currentPageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(previousButton.mas_right);
        make.centerY.mas_equalTo(previousButton.mas_centerY);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(previousButton.mas_height);
    }];
    
    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    indicatorView.color = kBlackColor;
    indicatorView.hidesWhenStopped = YES;
    [currentPageLabel addSubview:indicatorView];
    
    [indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(currentPageLabel.mas_centerX);
        make.centerY.mas_equalTo(currentPageLabel.mas_centerY);
        make.width.height.mas_equalTo(previousButton.mas_height);
    }];
    
    // 下一话
    nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.backgroundColor = [UIColor clearColor];
    nextButton.adjustsImageWhenHighlighted = NO;
    nextButton.transform = CGAffineTransformMakeRotation(M_PI);
    nextButton.enabled = NO;
    [nextButton.titleLabel setFont:kMainFont];
    [nextButton setImage:[[UIImage imageNamed:@"public_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [nextButton setTintColor:kGrayTextLightColor];
    [nextButton setImageEdgeInsets:UIEdgeInsetsMake(14, 20, 14, 8)];
    [nextButton addTarget:self action:@selector(nextButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextButton];
    
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(currentPageLabel.mas_right);
        make.centerY.mas_equalTo(previousButton.mas_centerY);
        make.width.mas_equalTo(previousButton.mas_width);
        make.height.mas_equalTo(previousButton.mas_height);
    }];
    
    UIView *buttonMenuBar = [[UIView alloc] init];
    buttonMenuBar.backgroundColor = [UIColor clearColor];
    [self addSubview:buttonMenuBar];
    
    [buttonMenuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(nextButton.mas_right).with.offset(kMargin);
        make.centerY.mas_equalTo(previousButton.mas_centerY);
        make.right.mas_equalTo(self.mas_right).with.offset(- kMargin);
        make.height.mas_equalTo(30);
    }];
    
    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingButton.adjustsImageWhenHighlighted = NO;
    settingButton.tintColor = kColorRGB(111, 111, 111);
    settingButton.touchEventInterval = 0.5;
    [settingButton setImage:[[UIImage imageNamed:@"comic_setting"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [settingButton setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    [settingButton addTarget:self action:@selector(settingButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [buttonMenuBar addSubview:settingButton];
    
#if WX_Download_Mode
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    downloadButton.adjustsImageWhenHighlighted = NO;
    downloadButton.tintColor = kColorRGB(111, 111, 111);
    downloadButton.touchEventInterval = 0.5;
    [downloadButton setImage:[[UIImage imageNamed:@"comic_download"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [downloadButton setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 4, 4)];
    [downloadButton addTarget:self action:@selector(downloadButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [buttonMenuBar addSubview:downloadButton];
#endif
    
#if WX_W_Share_Mode || WX_Q_Share_Mode
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.adjustsImageWhenHighlighted = NO;
    shareButton.tintColor = kColorRGB(111, 111, 111);
    shareButton.touchEventInterval = 0.5;
    [shareButton setImage:[[UIImage imageNamed:@"comic_share"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [shareButton setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    [shareButton addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [buttonMenuBar addSubview:shareButton];
#endif

#if WX_Comments_Mode
    commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    commentsButton.adjustsImageWhenHighlighted = NO;
    commentsButton.tintColor = kColorRGB(111, 111, 111);
    commentsButton.touchEventInterval = 0.5;
    [commentsButton setImage:[[UIImage imageNamed:@"comic_comments"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [commentsButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [commentsButton addTarget:self action:@selector(checkCommentsClick) forControlEvents:UIControlEventTouchUpInside];
    [buttonMenuBar addSubview:commentsButton];

    badgeView = [[WXYZ_BadgeView alloc] initWithView:commentsButton];
    [badgeView setCircleAtFrame:CGRectMake(0, 0, 17, 17)];
    [badgeView moveCircleByX:18 Y:- 2];
    badgeView.maxCount = 99;
    [badgeView setCircleColor:kRedColor labelColor:kWhiteColor];
    [badgeView setCountLabelFont:kFont9];
    
#endif
    
    NSArray *buttonMenuArr = [NSArray arrayWithObjects:
#if WX_Comments_Mode
                              commentsButton,
#endif
                              
#if WX_W_Share_Mode || WX_Q_Share_Mode
                              shareButton,
#endif
                              
#if WX_Download_Mode
                              downloadButton,
#endif
                              settingButton, nil];
    [buttonMenuArr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:30 leadSpacing:0 tailSpacing:0];
    [buttonMenuArr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(30);
    }];
    
#if WX_Comments_Mode
    NSString *imageName = nil;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:Enable_Barrage] isEqualToString:@"1"]) {
        imageName = @"comic_danmu_select";
    } else {
        imageName = @"comic_danmu";
    }
    barrageSwitch = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"弹幕" buttonSubTitle:@"" buttonImageName:imageName buttonIndicator:WXYZ_CustomButtonIndicatorTitleRight showMaskView:NO];
    barrageSwitch.buttonTitleFont = kFont10;
    barrageSwitch.buttonTitleColor = kWhiteColor;
    barrageSwitch.graphicDistance = 5;
    barrageSwitch.buttonImageScale = 0.5;
    barrageSwitch.tag = 1;
    barrageSwitch.backgroundColor = kBlackTransparentColor;
    barrageSwitch.layer.cornerRadius = 10;
    [barrageSwitch addTarget:self action:@selector(barrageSwitchClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:barrageSwitch];
    
    [barrageSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin);
        make.top.mas_equalTo(self.mas_top).with.offset(PUB_TABBAR_HEIGHT + Comic_Menu_Bottom_Bar_Top_Height);
        make.width.mas_equalTo(65);
        make.height.mas_equalTo(22);
    }];
#endif
    
    settingBar = [[WXYZ_ComicMenuSettingBar alloc] init];
    
    scrollToTop = [UIButton buttonWithType:UIButtonTypeCustom];
    scrollToTop.adjustsImageWhenHighlighted = NO;
    [scrollToTop setImage:[UIImage imageNamed:@"comic_top"] forState:UIControlStateNormal];
    [scrollToTop addTarget:self action:@selector(scrollToTopClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:scrollToTop];
    
    [scrollToTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).with.offset(- kHalfMargin);
        make.bottom.mas_equalTo(self.mas_top).with.offset(6 * MenuButtonHeight);
        make.width.height.mas_equalTo(MenuButtonHeight);
    }];
    
    if (![[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] isCollectedWithProduction_id:self.comicChapterModel.production_id]) {
        collectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        collectionButton.adjustsImageWhenHighlighted = NO;
        [collectionButton setImage:[UIImage imageNamed:@"comic_collection"] forState:UIControlStateNormal];
        [collectionButton addTarget:self action:@selector(collectionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:collectionButton];
        
        [collectionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.mas_right).with.offset(- kHalfMargin);
            make.bottom.mas_equalTo(scrollToTop.mas_top).with.offset(- kHalfMargin);
            make.width.height.mas_equalTo(MenuButtonHeight);
        }];
    }
}

- (void)showMenuBottomBar
{
    [UIView animateWithDuration:kAnimatedDurationFast animations:^{
#if WX_Comments_Mode
        self.frame = CGRectMake(0, SCREEN_HEIGHT - (PUB_TABBAR_HEIGHT + Comic_Menu_Bottom_Bar_Top_Height), SCREEN_WIDTH, PUB_TABBAR_HEIGHT + Comic_Menu_Bottom_Bar_Top_Height);
#else
        self.frame = CGRectMake(0, SCREEN_HEIGHT - (Comic_Menu_Bottom_Bar_Height - Comic_Menu_Bottom_Bar_Top_Height), SCREEN_WIDTH, Comic_Menu_Bottom_Bar_Height - Comic_Menu_Bottom_Bar_Top_Height);
#endif
    }];
    
    [barrageSwitch mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).with.offset(- kHalfMargin - 20);
    }];
    
    [scrollToTop mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_top).with.offset(- kHalfMargin);
    }];
}

- (void)reloadCollectionState
{
    if (![[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] isCollectedWithProduction_id:self.comicChapterModel.production_id]) {
        collectionButton.hidden = NO;
    } else {
        collectionButton.hidden = YES;
    }
}

- (void)hiddenMenuBottomBar
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [UIView animateWithDuration:kAnimatedDurationFast animations:^{
#if WX_Comments_Mode
        self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, PUB_TABBAR_HEIGHT + Comic_Menu_Bottom_Bar_Top_Height);
#else
        self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, Comic_Menu_Bottom_Bar_Height - Comic_Menu_Bottom_Bar_Top_Height);
#endif
    }];
    
    [barrageSwitch mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).with.offset(PUB_TABBAR_HEIGHT + Comic_Menu_Bottom_Bar_Top_Height);
    }];
    
    [scrollToTop mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_top).with.offset(6 * MenuButtonHeight);
    }];
}

- (void)startLoadingData
{
    currentPageLabel.text = @"";
    [indicatorView startAnimating];
    previousButton.enabled = NO;
    [previousButton setTintColor:kGrayTextLightColor];
    
    nextButton.enabled = NO;
    [nextButton setTintColor:kGrayTextLightColor];
}

- (void)stopLoadingData
{
    currentPageLabel.text = @"当前话";
    [indicatorView stopAnimating];
    
    previousButton.enabled = YES;
    [previousButton setTintColor:kBlackColor];
    
    nextButton.enabled = YES;
    [nextButton setTintColor:kBlackColor];
}

#pragma mark - 点击事件

- (void)changeCommentsState:(UIButton *)sender
{
    if (sender.tag == 0) { // 评论
        [self changeComentInput:YES];
    } else { // 吐槽
        [self changeComentInput:NO];
    }
}

// 改变评论输入框状态
- (void)changeComentInput:(BOOL)isComment {
    if (WX_Comments_Mode && isComment) {
        commentsTextView.placeholderText = @"发一条评论吧";
        [sendComments setTitle:@"发送" forState:UIControlStateNormal];
        isCommentState = YES;
        _leftImageButton.tag = 1;
        [_leftImageButton setImage:[UIImage imageNamed:@"comic_comments_icon"] forState:UIControlStateNormal];
        return;
    }
    
    if (!isComment && WX_Comments_Mode) {
        commentsTextView.placeholderText = @"发一条弹幕吧";
        [sendComments setTitle:@"发射" forState:UIControlStateNormal];
        isCommentState = NO;
        _leftImageButton.tag = 0;
        [_leftImageButton setImage:[UIImage imageNamed:@"comic_barrage"] forState:UIControlStateNormal];
        return;
    }
}

- (void)previousButtonClick
{
    if (self.comicChapterModel.last_chapter && self.comicChapterModel.last_chapter > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Switch_Chapter object:[WXYZ_UtilsHelper formatStringWithInteger:self.comicChapterModel.last_chapter]];
    }
}

- (void)nextButtonClick
{
    if (self.comicChapterModel.next_chapter && self.comicChapterModel.next_chapter > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Switch_Chapter object:[WXYZ_UtilsHelper formatStringWithInteger:self.comicChapterModel.next_chapter]];        
    }
}

- (void)settingButtonClick
{
    [settingBar showSettingBar];
}

- (void)barrageSwitchClick:(UIButton *)sender
{
    if (sender.tag == 0) {
        sender.tag = 1;
        barrageSwitch.buttonImageName = @"comic_danmu_select";
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:Enable_Barrage];
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Switch_Barrage object:@"1"];
        [self changeComentInput:NO];
    } else {
        sender.tag = 0;
        barrageSwitch.buttonImageName = @"comic_danmu";
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:Enable_Barrage];
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Switch_Barrage object:@"0"];
        [self changeComentInput:YES];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#if WX_W_Share_Mode || WX_Q_Share_Mode
- (void)shareButtonClick:(UIButton *)sender
{
    sender.enabled = NO;
    [[WXYZ_ShareManager sharedManager] shareProductionWithChapter_id:self.comicChapterModel.chapter_id controller:[WXYZ_ViewHelper getWindowRootController] type:WXYZ_ShareProductionComic shareState:WXYZ_ShareStateAll production_id:self.comicChapterModel.production_id complete:^{
        sender.enabled = YES;
    }];
}
#endif

- (void)checkCommentsClick
{
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Push_To_Comments object:nil];
}

- (void)scrollToTopClick
{
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Reader_Scroll_To_Top object:nil];
}

- (void)downloadButtonClick
{
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Push_To_Comic_Download object:nil];
}

- (void)collectionButtonClick:(UIButton *)sender
{
    if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] isCollectedWithProduction_id:self.comicChapterModel.production_id]) {
        return;
    }
    WS(weakSelf)
    
    [WXYZ_UtilsHelper synchronizationRackProductionWithProduction_id:self.comicChapterModel.production_id productionType:WXYZ_ProductionTypeComic complete:nil];
    
    if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] addCollectionWithProductionModel:weakSelf.productionModel]) {
        sender.hidden = YES;
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"已收藏"];
    } else {
        sender.hidden = NO;
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"收藏失败"];
    }
}

#if WX_Comments_Mode
- (void)sendCommentsClick
{
    if (!WXYZ_UserInfoManager.isLogin) {
        [WXYZ_LoginViewController presentLoginView];
        return;
    }
    
    if (commentsTextView.text.length < 1) {
        return;
    }
    
    NSString *t_text = commentsTextView.text;
    commentsTextView.text = @"";
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    WS(weakSelf)
    if (!isCommentState) {
        [WXYZ_NetworkRequestManger POST:Comic_Send_Barrage parameters:@{@"comic_id":[WXYZ_UtilsHelper formatStringWithInteger:self.comicChapterModel.production_id], @"chapter_id":[WXYZ_UtilsHelper formatStringWithInteger:self.comicChapterModel.chapter_id],  @"content":t_text} model:nil success:^(BOOL isSuccess, NSDictionary * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
            SS(strongSelf)
            if (isSuccess) {
                [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Change_Barrage object:t_text];
                strongSelf->commentsTextView.text = @"";
                strongSelf.frame = CGRectMake(0, SCREEN_HEIGHT - (PUB_TABBAR_HEIGHT + Comic_Menu_Bottom_Bar_Top_Height), SCREEN_WIDTH, PUB_TABBAR_HEIGHT + Comic_Menu_Bottom_Bar_Top_Height);
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"发射成功"];
            } else if (Compare_Json_isEqualTo(requestModel.code, 315)) {
                strongSelf->commentsTextView.text = @"";
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:requestModel.msg];
            } else if (requestModel.code == 319) {// 发送成功，但需要审核
                strongSelf->commentsTextView.text = @"";
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:requestModel.msg];
            } else {
                strongSelf->commentsTextView.text = t_text;
                [strongSelf->commentsTextView becomeFirstResponder];
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            SS(strongSelf)
            strongSelf->commentsTextView.text = t_text;
        }];
    } else {
        [WXYZ_NetworkRequestManger POST:Comic_Comment_Post parameters:@{@"comic_id":[WXYZ_UtilsHelper formatStringWithInteger:self.comicChapterModel.production_id], @"content":t_text} model:nil success:^(BOOL isSuccess, NSDictionary * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
            SS(strongSelf)
            if (isSuccess) {
                strongSelf->commentsTextView.text = @"";
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"评论成功"];
                [badgeView increment];
            } else if (Compare_Json_isEqualTo(requestModel.code, 315)) {
                strongSelf->commentsTextView.text = @"";
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:requestModel.msg];
            }  else if (requestModel.code == 318) {// 发送成功，但需要审核
                strongSelf->commentsTextView.text = @"";
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:requestModel.msg];
            } else {
                strongSelf->commentsTextView.text = t_text;
                [strongSelf->commentsTextView becomeFirstResponder];
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            SS(strongSelf)
            strongSelf->commentsTextView.text = t_text;
        }];
    }
}
#endif

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if ([barrageSwitch pointInside:[barrageSwitch convertPoint:point fromView:self] withEvent:event]) {
        return barrageSwitch;
    }
    
    if ([collectionButton pointInside:[collectionButton convertPoint:point fromView:self] withEvent:event]) {
        return collectionButton;
    }
    
    if ([scrollToTop pointInside:[scrollToTop convertPoint:point fromView:self] withEvent:event]) {
        return scrollToTop;
    }
    
    if ([view isKindOfClass:[self class]]) {
        return nil;
    }
    
    return view;
}

//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    keyboardHeight = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.frame = CGRectMake(0, SCREEN_HEIGHT - (PUB_TABBAR_HEIGHT + Comic_Menu_Bottom_Bar_Top_Height) - keyboardHeight + PUB_NAVBAR_OFFSET, SCREEN_WIDTH, PUB_TABBAR_HEIGHT + Comic_Menu_Bottom_Bar_Top_Height);
}

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    keyboardHeight = PUB_TABBAR_HEIGHT + Comic_Menu_Bottom_Bar_Top_Height;
    self.frame = CGRectMake(0, SCREEN_HEIGHT - (PUB_TABBAR_HEIGHT + Comic_Menu_Bottom_Bar_Top_Height), SCREEN_WIDTH, PUB_TABBAR_HEIGHT + Comic_Menu_Bottom_Bar_Top_Height);
}

- (void)textViewDidChange:(YYTextView *)textView
{
    CGFloat textViewHeight = [WXYZ_ViewHelper getDynamicHeightWithLabelFont:textView.font labelWidth:textView.width labelText:textView.text maxHeight:70] - kMargin;
    if (textViewHeight < 30) {
        textViewHeight = 30;
    }
    
#if WX_Comments_Mode
    [sendComments mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(textViewHeight);
    }];
#endif
    if (is_iPhone6) {
        self.frame = CGRectMake(0, SCREEN_HEIGHT - keyboardHeight - PUB_TABBAR_HEIGHT + PUB_TABBAR_OFFSET - textViewHeight, SCREEN_WIDTH, PUB_TABBAR_HEIGHT + Comic_Menu_Bottom_Bar_Top_Height);
    } else {
        if (![textView.text isEqualToString:@""]) {
            self.frame = CGRectMake(0, SCREEN_HEIGHT - keyboardHeight - PUB_TABBAR_HEIGHT + PUB_TABBAR_OFFSET - textViewHeight - kMargin, SCREEN_WIDTH, PUB_TABBAR_HEIGHT + Comic_Menu_Bottom_Bar_Top_Height);
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self sendCommentsClick];
        return NO;
    }
    return YES;
}

- (void)setComicChapterModel:(WXYZ_ProductionChapterModel *)comicChapterModel
{
    _comicChapterModel = comicChapterModel;
    
#if WX_Comments_Mode
    [badgeView setCount:(int)comicChapterModel.total_comment];
    [badgeView showCount];
#endif
    
    if (comicChapterModel.next_chapter == 0) {
        [nextButton setTintColor:kGrayTextLightColor];
        nextButton.enabled = NO;
    } else {
        [nextButton setTintColor:kBlackColor];
        nextButton.enabled = YES;
    }
    
    if (comicChapterModel.last_chapter == 0) {
        [previousButton setTintColor:kGrayTextLightColor];
        previousButton.enabled = NO;
    } else {
        [previousButton setTintColor:kBlackColor];
        previousButton.enabled = YES;
    }
}

@end

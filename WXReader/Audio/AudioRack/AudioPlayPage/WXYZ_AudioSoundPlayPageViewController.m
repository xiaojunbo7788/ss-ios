//
//  WXYZ_AudioSoundPlayPageViewController.m
//  WXReader
//
//  Created by Andrew on 2020/3/9.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AudioSoundPlayPageViewController.h"
#import "WXYZ_BookAiPlayPageViewController.h"
#import "WXYZ_CommentsViewController.h"
#import "WXYZ_AudioDownloadViewController.h"
#import "WXYZ_BookReaderViewController.h"

#import "WXYZ_AudioSoundPlayPageHeaderView.h"
#import "WXYZ_BookMallStyleSingleTableViewCell.h"
#import "WXYZ_CommentsTableViewCell.h"
#import "WXYZ_PublicADStyleTableViewCell.h"

#import "WXYZ_PlayPageModel.h"
#import "WXYZ_AudioSoundDetailModel.h"

#import "CXTextView.h"
#import "CXCustomTextView.h"
#import "WXYZ_TouchAssistantView.h"

#import "WXYZ_ShareManager.h"
#import "WXYZ_KeyboardManager.h"
#import "WXYZ_AudioDownloadManager.h"
#import "WXYZ_AudioSettingHelper.h"
#import "WXYZ_ProductionCollectionManager.h"
#import "WXYZ_ProductionReadRecordManager.h"

#if __has_include(<iflyMSC/IFlyMSC.h>)
#import "iflyMSC/IFlyMSC.h"
#endif

@interface WXYZ_AudioSoundPlayPageViewController () <UITableViewDelegate, UITableViewDataSource>
{
    CXTextView *commentTextView;
    
    UIButton *addAudioRack;
    WXYZ_KeyboardManager *keyboardManager;
}

@property (nonatomic, strong) WXYZ_AudioSoundPlayPageHeaderView *headerView;

@property (nonatomic, strong) WXYZ_PlayPageModel *playPageModel;

@property (nonatomic, strong) WXYZ_ProductionChapterModel *audioChapterModel;

@property (nonatomic, assign) NSInteger audio_id;

@property (nonatomic, assign) NSInteger chapter_id;

@property (nonatomic, strong) UIView *bottomMenu;

@property (nonatomic, strong) UIView *sectionHeaderView;

@property (nonatomic, strong) UILabel *sectionTitleLabel;

@property (nonatomic, strong) UIButton *sectionBottomCommentButton;

@property (nonatomic, strong) UILabel *commentConnerLabel;

@property (nonatomic, assign) BOOL needRefresh;

@end

@implementation WXYZ_AudioSoundPlayPageViewController

implementation_singleton(WXYZ_AudioSoundPlayPageViewController)

- (void)loadDataWithAudio_id:(NSInteger)audio_id chapter_id:(NSInteger)chapter_id
{
    if (audio_id > 0) {
        _audio_id = audio_id;
    }
    
    // 查找阅读记录
    if (chapter_id == 0) {
        chapter_id = [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] getReadingRecordChapter_idWithProduction_id:audio_id];
    }
    
    // 查找收藏记录
    if (chapter_id == 0) {
        
        WXYZ_ProductionModel *productionModel = [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] getCollectedProductionModelWithProduction_id:audio_id];
        
        if ([productionModel.chapter_list firstObject]) {
            WXYZ_ProductionChapterModel *chapterModel = [productionModel.chapter_list firstObject];
            chapter_id = chapterModel.chapter_id;
        }
    }
    
    // 查找下载记录
    if (chapter_id == 0) {
        WXYZ_ProductionModel *productionModel = [[WXYZ_DownloadHelper sharedManager] getDownloadProductionModelWithProduction_id:audio_id productionType:WXYZ_ProductionTypeAudio];
        
        if ([productionModel.chapter_list firstObject]) {
            WXYZ_ProductionChapterModel *chapterModel = [productionModel.chapter_list firstObject];
            chapter_id = chapterModel.chapter_id;
        }
    }
    
    if (chapter_id > 0) {
        _chapter_id = chapter_id;
    }
    self.needRefresh = YES;
    [self netRequest];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
}

- (void)initialize
{
    [self hiddenNavigationBar:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAudioChapter:) name:Notification_Change_Audio_Chapter object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarDefaultStyle];

    [[WXYZ_TouchAssistantView sharedManager] hiddenAssistiveTouchView];
    [[WXYZ_TouchAssistantView sharedManager] setPlayerProductionType:WXYZ_ProductionTypeAudio];
    [self.mainTableViewGroup scrollToTop];
    [[WXYZ_AudioSettingHelper sharedManager] playPageViewShow:YES productionType:WXYZ_ProductionTypeAudio];
    
    if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] isCollectedWithProduction_id:self.audio_id]) {
        [addAudioRack setTitleColor:kGrayTextColor forState:UIControlStateNormal];
        [addAudioRack setTitle:@"已收藏" forState:UIControlStateNormal];
        addAudioRack.tag = 2;
    } else {
        [addAudioRack setTitleColor:kBlackColor forState:UIControlStateNormal];
        [addAudioRack setTitle:@"收藏" forState:UIControlStateNormal];
        addAudioRack.tag = 1;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (![WXYZ_BookAiPlayPageViewController sharedManager].speaking) {
        [[WXYZ_TouchAssistantView sharedManager] showAssistiveTouchViewWithImageCover:self.audioChapterModel.cover productionType:WXYZ_ProductionTypeAudio];
    } else {
        [[WXYZ_TouchAssistantView sharedManager] showAssistiveTouchView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)createSubviews
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(10, PUB_NAVBAR_OFFSET + 20, 44, 44);
    backButton.backgroundColor = [UIColor clearColor];
    backButton.adjustsImageWhenHighlighted = NO;
    [backButton.titleLabel setFont:kMainFont];
    [backButton setTitleColor:kBlackColor forState:UIControlStateNormal];
    [backButton setImage:[[UIImage imageNamed:@"public_down_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [backButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [backButton setTintColor:kBlackColor];
    [backButton addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    addAudioRack = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] isCollectedWithProduction_id:self.audio_id]) {
        [addAudioRack setTitleColor:kGrayTextColor forState:UIControlStateNormal];
        [addAudioRack setTitle:@"已收藏" forState:UIControlStateNormal];
    } else {
        [addAudioRack setTitleColor:kBlackColor forState:UIControlStateNormal];
        [addAudioRack setTitle:@"收藏" forState:UIControlStateNormal];
    }
    addAudioRack.enabled = YES;
    addAudioRack.backgroundColor = kWhiteColor;
    [addAudioRack.titleLabel setFont:kMainFont];
    [addAudioRack setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [addAudioRack addTarget:self action:@selector(addAudioClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addAudioRack];
    
    [addAudioRack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(backButton.mas_centerY);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(44);
    }];
    
    self.mainTableViewGroup.delegate = self;
    self.mainTableViewGroup.dataSource = self;
    [self.view addSubview:self.mainTableViewGroup];
    
    [self.mainTableViewGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_height).with.offset(- PUB_TABBAR_HEIGHT - PUB_NAVBAR_HEIGHT);
    }];
        
    [self.mainTableViewGroup setTableHeaderView:self.headerView];
    self.headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH);
    [self.headerView setNeedsLayout];
    [self.headerView layoutIfNeeded];
    self.mainTableViewGroup.tableHeaderView = self.headerView;
    
    self.bottomMenu = [[UIView alloc] init];
    self.bottomMenu.backgroundColor = [UIColor whiteColor];
    self.bottomMenu.layer.shadowColor = kBlackColor.CGColor;
    self.bottomMenu.layer.shadowOpacity = 0.1;
    self.bottomMenu.layer.shadowRadius = 1;
    self.bottomMenu.layer.shadowOffset = CGSizeMake(0, - 1);
    [self.view addSubview:self.bottomMenu];
    
    [self.bottomMenu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.bottom.mas_equalTo(self.view.mas_bottom).with.offset(- PUB_TABBAR_OFFSET);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT - PUB_TABBAR_OFFSET);
    }];
    
    WXYZ_CustomButton *downloadButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"分享" buttonImageName:@"public_share" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
    downloadButton.tag = 0;
    downloadButton.buttonTitleFont = kFont12;
    downloadButton.graphicDistance = 5;
    downloadButton.buttonImageScale = 0.45;
    downloadButton.buttonTitleColor = kGrayTextLightColor;
    [downloadButton addTarget:self action:@selector(toolBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomMenu addSubview:downloadButton];
    
    [downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bottomMenu.mas_right).with.offset(- kHalfMargin);
        make.top.mas_equalTo(self.bottomMenu.mas_top).with.offset(5);
        make.width.height.mas_equalTo(40);
    }];
    
    WXYZ_CustomButton *collectButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"下载" buttonImageName:@"public_download" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
    collectButton.tag = 1;
    collectButton.buttonTitleFont = kFont12;
    collectButton.graphicDistance = 5;
    collectButton.buttonImageScale = 0.45;
    collectButton.buttonTitleColor = kGrayTextLightColor;
    [collectButton addTarget:self action:@selector(toolBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomMenu addSubview:collectButton];
    
    [collectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(downloadButton.mas_left).with.offset(- kHalfMargin);
        make.centerY.mas_equalTo(downloadButton.mas_centerY);
        make.width.height.mas_equalTo(downloadButton);
    }];
    
    WXYZ_CustomButton *commentButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"评论" buttonImageName:@"audio_comment" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
    commentButton.tag = 2;
    commentButton.buttonTitleFont = kFont12;
    commentButton.graphicDistance = 5;
    commentButton.buttonImageScale = 0.45;
    commentButton.buttonTitleColor = kGrayTextLightColor;
    [commentButton addTarget:self action:@selector(toolBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomMenu addSubview:commentButton];
    
    [commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(collectButton.mas_left).with.offset(- kHalfMargin);
        make.centerY.mas_equalTo(downloadButton.mas_centerY);
        make.width.height.mas_equalTo(downloadButton);
    }];
    
    self.commentConnerLabel = [[UILabel alloc] init];
    self.commentConnerLabel.text = @"0";
    self.commentConnerLabel.textAlignment = NSTextAlignmentCenter;
    self.commentConnerLabel.textColor = kMainColor;
    self.commentConnerLabel.backgroundColor = [UIColor whiteColor];
    self.commentConnerLabel.font = [UIFont systemFontOfSize:6];
    [commentButton addSubview:self.commentConnerLabel];
    
    [self.commentConnerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(commentButton.mas_centerX).with.offset(1);
        make.right.mas_equalTo(commentButton.mas_right).with.offset(- 5);
        make.top.mas_equalTo(commentButton.mas_top).with.offset(- 1);
        make.height.mas_equalTo(6);
    }];
    
    UIView *commentBottomView = [[UIView alloc] init];
    commentBottomView.backgroundColor = kGrayViewColor;
    commentBottomView.layer.cornerRadius = 20;
    [self.bottomMenu addSubview:commentBottomView];
    
    [commentBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bottomMenu.mas_left).with.offset(kHalfMargin);
        make.top.mas_equalTo(self.bottomMenu.mas_top).with.offset(5);
        make.right.mas_equalTo(commentButton.mas_left).with.offset(- kHalfMargin);
        make.height.mas_equalTo(40);
    }];
    
    UIImageView *leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_pencil"]];
    [commentBottomView addSubview:leftView];
    
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMoreHalfMargin);
        make.top.mas_equalTo(commentBottomView.mas_top).with.offset(10);
        make.height.width.mas_equalTo(16);
    }];
    
    WS(weakSelf)
    commentTextView = [[CXTextView alloc] initWithFrame:CGRectMake(kMoreHalfMargin + 16 + kHalfMargin, 0, SCREEN_WIDTH - (kMoreHalfMargin + 16 + kHalfMargin + kHalfMargin + 3 * 40 + 5 * kHalfMargin), 40)];
    commentTextView.placeholder = @"我来说两句..";
    commentTextView.maxLine = 5;
    commentTextView.maxLength = 200;
    commentTextView.v_margin = 10;
    commentTextView.font = kMainFont;
    commentTextView.backgroundColor = [UIColor clearColor];
    commentTextView.layer.cornerRadius = 15;
    commentTextView.textView.backgroundColor = [UIColor clearColor];
    commentTextView.textHeightChangeBlock = ^(CGFloat height) {
        [commentBottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
        }];
        
        [weakSelf.bottomMenu mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(10 + height);
        }];
        
        [weakSelf.mainTableViewGroup mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(weakSelf.view.mas_height).with.offset(- PUB_TABBAR_OFFSET - PUB_NAVBAR_HEIGHT - height - 10);
        }];
    };
    commentTextView.returnHandlerBlock = ^{
        [weakSelf sendCommentNetRequest];
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    };
    [commentBottomView addSubview:commentTextView];
    
    keyboardManager = [[WXYZ_KeyboardManager alloc] initObserverWithAdaptiveMovementView:commentBottomView];
    keyboardManager.keyboardHeightChanged = ^(CGFloat keyboardHeight, CGFloat shouldMoveDistance, CGRect shouldMoveFrame) {
        [weakSelf.bottomMenu mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(weakSelf.view.mas_bottom).with.offset(keyboardHeight == 0 ? - PUB_TABBAR_OFFSET:- keyboardHeight);
        }];
    };
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [WXYZ_KeyboardManager hideKeyboard];
}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if (self.playPageModel.advert.ad_type != 0) {
                return 1;
            }
            break;
        case 1:
            if (self.playPageModel.list.count > 0) {
                return 1;
            }
            break;
        case 2:
            if (self.playPageModel.comment.list.count > 3) {
                return 3;
            } else {
                return self.playPageModel.comment.list.count;
            }
            break;
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return [self createADCellWithTableView:tableView atIndexPath:indexPath];
            break;
        case 1:
            return [self createSingleStyleCellWithTableView:tableView atIndexPath:indexPath listArray:self.playPageModel.list];
            break;
        case 2:
            return [self createCommentCellWithTableView:tableView atIndexPath:indexPath labelModel:[self.playPageModel.comment.list objectOrNilAtIndex:indexPath.row]];
            break;
            
        default:
            break;
    }
    return [[UITableViewCell alloc] init];
}

- (UITableViewCell *)createSingleStyleCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath listArray:(NSArray *)listArray
{
    WS(weakSelf)
    static NSString *cellName = @"WXYZ_BookMallStyleSingleTableViewCell";
    
    WXYZ_MallCenterLabelModel *labelModel = [[WXYZ_MallCenterLabelModel alloc] init];
    labelModel.list = listArray;
    labelModel.label = @"猜你喜欢";
    for (WXYZ_ProductionModel *t_model in labelModel.list) {
        t_model.productionType = WXYZ_ProductionTypeAudio;
    }
    
    WXYZ_BookMallStyleSingleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_BookMallStyleSingleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.labelModel = labelModel;
    cell.cellDidSelectItemBlock = ^(NSInteger production_id) {
        WXYZ_AudioMallDetailViewController *vc = [[WXYZ_AudioMallDetailViewController alloc] init];
        vc.audio_id = production_id;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)createCommentCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath labelModel:(WXYZ_CommentsDetailModel *)commentModel
{
    static NSString *cellName = @"WXYZ_CommentsTableViewCell";
    WXYZ_CommentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_CommentsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.commentModel = commentModel;
    [cell setIsPreview:YES lastRow:(self.playPageModel.comment.list.count - 1 == indexPath.row)];
    cell.hiddenEndLine = NO;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)createADCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"WXYZ_PublicADStyleTableViewCell";
    WXYZ_PublicADStyleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_PublicADStyleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    [cell setAdModel:self.playPageModel.advert refresh:self.needRefresh];
    cell.mainTableView = tableView;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        WXYZ_CommentsDetailModel *t_model = [self.playPageModel.comment.list objectOrNilAtIndex:indexPath.row];
        [self commentWithComment_id:t_model.comment_id];
    }
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
#if WX_Comments_Mode
    if (!self.playPageModel) {
        return CGFLOAT_MIN;
    }
    
    if (section == 2) {// 评论头部高度
        return 54;
    }
#endif
    
    return kQuarterMargin;
}

//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        UIView *sectionView = self.sectionHeaderView;
        self.sectionTitleLabel.text = [NSString stringWithFormat:@"本章评论（%@）", [WXYZ_UtilsHelper formatStringWithInteger:self.playPageModel.comment_total_count]];
        return sectionView;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kHalfMargin)];
    view.backgroundColor = kGrayViewColor;
    return view;
}

- (UIView *)sectionHeaderView
{
    if (!_sectionHeaderView) {
        _sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 54)];
        _sectionHeaderView.backgroundColor = [UIColor whiteColor];
        
        UIView *grayLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
        grayLine.backgroundColor = kGrayViewColor;
        [_sectionHeaderView addSubview:grayLine];
        
        UIImageView *mainTitleHoldView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"book_label_hold"]];
        [_sectionHeaderView addSubview:mainTitleHoldView];
        
        [mainTitleHoldView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kHalfMargin);
            make.centerY.mas_equalTo(_sectionHeaderView.mas_centerY).with.offset(5);
            make.width.height.mas_equalTo(kHalfMargin + kQuarterMargin);
        }];
        
        [_sectionHeaderView addSubview:self.sectionTitleLabel];
        
    }
    return _sectionHeaderView;
}

- (UILabel *)sectionTitleLabel
{
    if (!_sectionTitleLabel) {
        _sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMargin + kHalfMargin, 10, SCREEN_WIDTH - kMargin, 44)];
        _sectionTitleLabel.textAlignment = NSTextAlignmentLeft;
        _sectionTitleLabel.textColor = kBlackColor;
        _sectionTitleLabel.backgroundColor = [UIColor whiteColor];
        _sectionTitleLabel.font = kBoldFont16;
    }
    return _sectionTitleLabel;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
#if WX_Comments_Mode
    if (!self.playPageModel) {
        return CGFLOAT_MIN;
    }
    
    if (section == 2) {
        return 56;
    }
#endif
    return CGFLOAT_MIN;
}

//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    view.backgroundColor = kWhiteColor;
    
    if (section == 2) {
        if (self.playPageModel) {
            
            if (self.playPageModel.comment.list.count == 0) {
                [self.sectionBottomCommentButton setTitle:@"暂无评论，点击抢沙发" forState:UIControlStateNormal];
            } else {
                [self.sectionBottomCommentButton setTitle:[NSString stringWithFormat:@"查看全部评论(%@条)", [WXYZ_UtilsHelper formatStringWithInteger:self.playPageModel.comment_total_count]] forState:UIControlStateNormal];
            }
            [view addSubview:self.sectionBottomCommentButton];
        }
    }
    
    return view;
}

- (UIButton *)sectionBottomCommentButton
{
    if (!_sectionBottomCommentButton) {
        
        _sectionBottomCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sectionBottomCommentButton.frame = CGRectMake(SCREEN_WIDTH / 4, kHalfMargin, SCREEN_WIDTH / 2, 36);
        _sectionBottomCommentButton.backgroundColor = [UIColor whiteColor];
        _sectionBottomCommentButton.layer.cornerRadius = 18;
        _sectionBottomCommentButton.layer.borderColor = kMainColor.CGColor;
        _sectionBottomCommentButton.layer.borderWidth = 0.4f;
        [_sectionBottomCommentButton setTitleColor:kMainColor forState:UIControlStateNormal];
        [_sectionBottomCommentButton.titleLabel setFont:kFont12];
        [_sectionBottomCommentButton addTarget:self action:@selector(commentClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sectionBottomCommentButton;
}

- (WXYZ_AudioSoundPlayPageHeaderView *)headerView
{
    if (!_headerView) {
        WS(weakSelf)
        _headerView = [[WXYZ_AudioSoundPlayPageHeaderView alloc] initWithProductionType:WXYZ_ProductionTypeAudio];
        _headerView.checkRelationProductionBlock = ^(WXYZ_RelationModel * _Nonnull relationModel) {
            [WXYZ_NetworkRequestManger POST:Book_Catalog parameters:@{@"book_id":[WXYZ_UtilsHelper formatStringWithInteger:relationModel.production_id]} model:WXYZ_ProductionModel.class success:^(BOOL isSuccess, WXYZ_ProductionModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
                if (isSuccess) {
                    WXYZ_BookAiPlayPageViewController *vc = [WXYZ_BookAiPlayPageViewController sharedManager];
                    [vc loadDataWithBookModel:t_model chapterModel:nil];
                    if (!vc.presentedViewController) {
                        WXYZ_NavigationController *nav = [[WXYZ_NavigationController alloc] initWithRootViewController:vc];
                        [[WXYZ_ViewHelper getWindowRootController] presentViewController:nav animated:YES completion:nil];
                    } else {
                        [weakSelf popViewController];
                    }
                }
            } failure:nil];
        };
        _headerView.checkOriginalBlock = ^(WXYZ_ProductionChapterModel * _Nonnull chapterModel) {
            if (weakSelf.navigationController.view.tag == 2345) {
                [weakSelf popViewController];
                return;
            }
            
            [WXYZ_NetworkRequestManger POST:Book_Catalog parameters:@{@"book_id":[WXYZ_UtilsHelper formatStringWithInteger:chapterModel.relation_production_id]} model:WXYZ_ProductionModel.class success:^(BOOL isSuccess, WXYZ_ProductionModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
                if (isSuccess) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        WXYZ_BookReaderViewController *vc = [[WXYZ_BookReaderViewController alloc] init];
                        vc.book_id = t_model.production_id;
                        vc.bookModel = t_model;
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                    });
                }
            } failure:nil];
        };
    }
    return _headerView;
}

- (BOOL)speaking
{
    if (self.headerView.playerState == WXYZ_PlayPagePlayerStatePlaying) {
        return YES;
    }
    return NO;
}

- (BOOL)stoped
{
    if (self.headerView.playerState == WXYZ_PlayPagePlayerStateStoped) {
        return YES;
    }
    return NO;
}

- (void)commentClick
{
    [self commentWithComment_id:0];
}

- (void)commentWithComment_id:(NSInteger)comment_id
{
    WS(weakSelf)
    WXYZ_CommentsViewController *vc = [[WXYZ_CommentsViewController alloc] init];
    vc.production_id = self.audio_id;
    vc.chapter_id = self.chapter_id;
    vc.comment_id = comment_id;
    vc.productionType = WXYZ_ProductionTypeAudio;
    vc.commentsSuccessBlock = ^(WXYZ_CommentsDetailModel *commentModel) {
        
        WXYZ_PlayPageModel *t_model = weakSelf.playPageModel;
        
        // 评论数组model添加
        NSMutableArray *t_array = [NSMutableArray arrayWithArray:weakSelf.playPageModel.comment.list];
        [t_array insertObject:commentModel atIndex:0];
        weakSelf.playPageModel.comment.list = [t_array copy];
        
        weakSelf.playPageModel = t_model;
        
        weakSelf.playPageModel.comment_total_count ++;
        
        [weakSelf.mainTableViewGroup reloadData];
        
        weakSelf.commentConnerLabel.text = [NSString stringWithFormat:@"%@", weakSelf.playPageModel.comment_total_count > 99?@"99+":[WXYZ_UtilsHelper formatStringWithInteger:weakSelf.playPageModel.comment_total_count]];
        
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)toolBarButtonClick:(WXYZ_CustomButton *)sender
{
    if (sender.tag == 0) {
        sender.enabled = NO;
        [[WXYZ_ShareManager sharedManager] shareProductionWithChapter_id:self.audioChapterModel.chapter_id controller:self type:WXYZ_ShareProductionAudio shareState:WXYZ_ShareStateAll production_id:self.audioChapterModel.production_id complete:^{
            sender.enabled = YES;
        }];
    }
    
    if (sender.tag == 1) {
        
        WXYZ_AudioDownloadViewController *vc = [[WXYZ_AudioDownloadViewController alloc] init];
        vc.production_id = self.audioChapterModel.production_id;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if (sender.tag == 2) {
        [self commentWithComment_id:0];
    }
}

- (void)addAudioClick:(UIButton *)sender
{
    if (![[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] isCollectedWithProduction_id:self.audio_id]) {
        [WXYZ_UtilsHelper synchronizationRackProductionWithProduction_id:self.audio_id productionType:WXYZ_ProductionTypeAudio complete:nil];
        
        [WXYZ_NetworkRequestManger POST:Audio_Info parameters:@{@"audio_id":[WXYZ_UtilsHelper formatStringWithInteger:self.audio_id]} model:WXYZ_AudioSoundDetailModel.class success:^(BOOL isSuccess, WXYZ_AudioSoundDetailModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
            if (isSuccess) {
                [sender setTitleColor:kGrayTextColor forState:UIControlStateNormal];
                [sender setTitle:@"已收藏" forState:UIControlStateNormal];
                
                [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] addCollectionWithProductionModel:t_model.audio];
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"已收藏"];
            }
        } failure:nil];
    }
}

- (void)changeAudioChapter:(NSNotification *)noti
{
    self.chapter_id = [[noti object] integerValue];
    [self netRequest];
}

- (void)netRequest
{
    if ([WXYZ_NetworkReachabilityManager networkingStatus] == NO) {
        
        WXYZ_ProductionModel *productionModel = [[WXYZ_DownloadHelper sharedManager] getDownloadProductionModelWithProduction_id:self.audio_id productionType:WXYZ_ProductionTypeAudio];
        WXYZ_ProductionChapterModel *chapterModel = [[WXYZ_AudioDownloadManager sharedManager] getDownloadChapterModelWithProduction_id:self.audio_id chapter_id:self.chapter_id];
        if (!chapterModel) {
            for (WXYZ_ProductionChapterModel *t_chapterModel in productionModel.chapter_list) {
                if (self.chapter_id == t_chapterModel.chapter_id) {
                    chapterModel = t_chapterModel;
                }
            }
        }
        chapterModel.cover = productionModel.cover;
        self.audioChapterModel = chapterModel;
        self.headerView.chapter_list = productionModel.chapter_list;
        self.headerView.productionChapterModel = self.audioChapterModel;
        self.headerView.relationModel = [[WXYZ_RelationModel alloc] init];
        [self.mainTableViewGroup setTableHeaderView:self.headerView];
        [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] addReadingRecordWithProduction_id:chapterModel.production_id chapter_id:chapterModel.chapter_id chapterTitle:chapterModel.chapter_title];
        return;
    }
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Audio_Chapter_Info parameters:@{@"audio_id":[WXYZ_UtilsHelper formatStringWithInteger:self.audio_id], @"chapter_id":[WXYZ_UtilsHelper formatStringWithInteger:self.chapter_id]} model:WXYZ_ProductionChapterModel.class success:^(BOOL isSuccess, WXYZ_ProductionChapterModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            weakSelf.chapter_id = t_model.chapter_id;
            weakSelf.audioChapterModel = t_model;
            weakSelf.headerView.productionChapterModel = weakSelf.audioChapterModel;
            [weakSelf.mainTableViewGroup setTableHeaderView:weakSelf.headerView];
            [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] addReadingRecordWithProduction_id:t_model.production_id chapter_id:t_model.chapter_id chapterTitle:t_model.chapter_title];
            
            if (t_model.is_preview == 0) {
                // 如果是自动订阅后,将通知刷新目录内容
                [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Auto_Buy_Audio_Chapter object:[WXYZ_UtilsHelper formatStringWithInteger:t_model.chapter_id]];
            }
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        }
    } failure:nil];
    
    [WXYZ_NetworkRequestManger POST:Audio_Chapter_Detail parameters:@{@"audio_id":[WXYZ_UtilsHelper formatStringWithInteger:self.audio_id], @"chapter_id":[WXYZ_UtilsHelper formatStringWithInteger:self.chapter_id]} model:WXYZ_PlayPageModel.class success:^(BOOL isSuccess, WXYZ_PlayPageModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            weakSelf.playPageModel = t_model;
            weakSelf.commentConnerLabel.text = [NSString stringWithFormat:@"%@", weakSelf.playPageModel.comment_total_count > 99?@"99+":[WXYZ_UtilsHelper formatStringWithInteger:weakSelf.playPageModel.comment_total_count]];
            weakSelf.headerView.relationModel = weakSelf.playPageModel.relation;
        }
        weakSelf.needRefresh = YES;
        [weakSelf.mainTableViewGroup reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.needRefresh = NO;
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        weakSelf.needRefresh = NO;
        [weakSelf.mainTableViewGroup reloadData];
    }];
    
    [WXYZ_NetworkRequestManger POST:Audio_Add_Read_Log parameters:@{@"audio_id":[WXYZ_UtilsHelper formatStringWithInteger:self.audio_id], @"chapter_id":[WXYZ_UtilsHelper formatStringWithInteger:self.chapter_id]} model:nil success:nil failure:nil];
    
    if (!self.chapter_list || self.chapter_list.count == 0) {
        [WXYZ_NetworkRequestManger POST:Audio_Catalog parameters:@{@"audio_id":[WXYZ_UtilsHelper formatStringWithInteger:self.audio_id]} model:WXYZ_ProductionModel.class success:^(BOOL isSuccess, WXYZ_ProductionModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
            if (isSuccess) {
                // 更新本地记录
                [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] modificationCollectionWithProductionModel:t_model];
                
                weakSelf.chapter_list = t_model.chapter_list;
                weakSelf.headerView.chapter_list = t_model.chapter_list;
            }
        } failure:nil];
    } else {
        self.headerView.chapter_list = [self.chapter_list copy];
        self.chapter_list = [NSArray array];
    }
}

- (void)sendCommentNetRequest
{
    if (!WXYZ_UserInfoManager.isLogin) {
        WXYZ_AlertView *alert = [[WXYZ_AlertView alloc] init];
        alert.alertViewDetailContent = @"登录后才可以进行评论";
        alert.alertViewConfirmTitle = @"去登录";
        alert.alertViewCancelTitle = @"暂不";
        alert.confirmButtonClickBlock = ^{
            [WXYZ_LoginViewController presentLoginView];
        };
        [alert showAlertView];
        return;
    }
    
    if ([commentTextView.text isEqualToString:@""]) {
        return;
    }
    
    NSString *t_text = commentTextView.text;
    commentTextView.text = @"";
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"audio_id":[WXYZ_UtilsHelper formatStringWithInteger:self.audioChapterModel.production_id]?:@"", @"chapter_id":[WXYZ_UtilsHelper formatStringWithInteger:self.audioChapterModel.chapter_id], @"content":t_text}];
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Audio_Comment_Post parameters:parameters model:WXYZ_CommentsDetailModel.class success:^(BOOL isSuccess, WXYZ_CommentsDetailModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"评论成功"];
                        
            // 评论数组model添加
            NSMutableArray<WXYZ_CommentsDetailModel *> *t_arr = [NSMutableArray arrayWithArray:weakSelf.playPageModel.comment.list];
            [t_arr insertObject:t_model atIndex:0];
            weakSelf.playPageModel.comment.list = [t_arr copy];
            weakSelf.playPageModel.comment_total_count++;
                        
            [weakSelf.mainTableViewGroup reloadSection:2 withRowAnimation:UITableViewRowAnimationNone];
            
            weakSelf.commentConnerLabel.text = [NSString stringWithFormat:@"%@", weakSelf.playPageModel.comment_total_count > 99?@"99+":[WXYZ_UtilsHelper formatStringWithInteger:weakSelf.playPageModel.comment_total_count]];
            
        } else if (Compare_Json_isEqualTo(requestModel.code, 315)) {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:requestModel.msg];
        }  else {
            commentTextView.text = t_text;
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        }
    } failure:nil];
}

@end

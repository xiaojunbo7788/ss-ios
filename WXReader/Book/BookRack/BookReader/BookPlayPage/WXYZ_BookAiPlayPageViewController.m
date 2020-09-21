//
//  WXYZ_BookAiPlayPageViewController.m
//  WXReader
//
//  Created by Andrew on 2020/3/8.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BookAiPlayPageViewController.h"
#import "WXYZ_CommentsViewController.h"
#import "WXYZ_BookReaderViewController.h"
#import "WXYZ_AudioSoundPlayPageViewController.h"

#import "WXYZ_BookAiPlayPageHeaderView.h"
#import "WXYZ_BookMallStyleSingleTableViewCell.h"
#import "WXYZ_CommentsTableViewCell.h"
#import "WXYZ_PublicADStyleTableViewCell.h"

#import "CXTextView.h"
#import "CXCustomTextView.h"
#import "WXYZ_TouchAssistantView.h"

#import "WXYZ_PlayPageModel.h"

#import "WXYZ_Player.h"
#import "WXYZ_AudioSettingHelper.h"
#import "WXYZ_ShareManager.h"
#import "WXYZ_KeyboardManager.h"
#import "WXYZ_ProductionCollectionManager.h"
#import "WXYZ_ProductionReadRecordManager.h"

@interface WXYZ_BookAiPlayPageViewController () <UITableViewDelegate, UITableViewDataSource>
{
    CXTextView *commentTextView;
    WXYZ_KeyboardManager *keyboardManager;
}

@property (nonatomic, strong) WXYZ_ProductionChapterModel *chapterModel;

@property (nonatomic, strong) WXYZ_PlayPageModel *audioPlayPageModel;

@property (nonatomic, strong) WXYZ_BookAiPlayPageHeaderView *headerView;

@property (nonatomic, strong) UIButton *addBookRack;

@property (nonatomic, strong) UIView *bottomMenu;

@property (nonatomic, strong) UIView *sectionHeaderView;

@property (nonatomic, strong) UILabel *sectionTitleLabel;

@property (nonatomic, strong) UIButton *sectionBottomCommentButton;

@property (nonatomic, strong) UILabel *commentConnerLabel;

@property (nonatomic, assign) BOOL needRefresh;

@end

@implementation WXYZ_BookAiPlayPageViewController

implementation_singleton(WXYZ_BookAiPlayPageViewController)

- (instancetype)init
{
    if (self = [super init]) {
        [self initialize];
        [self createSubviews];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self hiddenNavigationBar:YES];
}

- (void)loadDataWithBookModel:(WXYZ_ProductionModel *)bookModel chapterModel:(WXYZ_ProductionChapterModel *)chapterModel
{
    [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] moveCollectionToTopWithProductionModel:bookModel];
    if (self.bookModel.production_id == bookModel.production_id && self.chapterModel.chapter_id == chapterModel.chapter_id) {
        
        chapterModel.production_id = self.bookModel.production_id;
        chapterModel.name = self.bookModel.name;
        chapterModel.cover = self.bookModel.cover;
        return;
    }
    
    if (bookModel) {
        self.bookModel = bookModel;
    }
    
    if (!chapterModel) {
        
        NSInteger recordChapter_id = [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAi] getReadingRecordChapter_idWithProduction_id:self.bookModel.production_id];
        if (recordChapter_id == 0) {
            
            if (self.bookModel.chapter_list.count > 0) {
                chapterModel = [self.bookModel.chapter_list firstObject];
            } else {
                chapterModel = [[WXYZ_ProductionChapterModel alloc] init];
            }
        } else {
            for (WXYZ_ProductionChapterModel *t_model in self.bookModel.chapter_list) {
                if (t_model.chapter_id == recordChapter_id) {
                    chapterModel = t_model;
                    break;
                }
            }
        }
    }
    
    chapterModel.production_id = self.bookModel.production_id;
    chapterModel.name = self.bookModel.name;
    chapterModel.cover = self.bookModel.cover;
    
    self.chapterModel = chapterModel;
    
    [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAi] addReadingRecordWithProduction_id:chapterModel.production_id chapter_id:chapterModel.chapter_id chapterTitle:chapterModel.chapter_title];
    
    self.headerView.productionChapterModel = chapterModel;
    self.headerView.chapter_list = self.bookModel.chapter_list;
    
    [self.mainTableViewGroup setTableHeaderView:self.headerView];
    
    if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] isCollectedWithProductionModel:self.bookModel]) {
        [self.addBookRack setTitle:@"已收藏" forState:UIControlStateNormal];
        [self.addBookRack setTitleColor:kGrayTextColor forState:UIControlStateNormal];
        self.addBookRack.enabled = NO;
    } else {
        [self.addBookRack setTitle:@"收藏" forState:UIControlStateNormal];
        [self.addBookRack setTitleColor:kBlackColor forState:UIControlStateNormal];
        self.addBookRack.enabled = YES;
    }
    
    [self netRequest];
}

- (void)initialize
{
    self.needRefresh = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAiChapter:) name:Notification_Change_AiBook_Chapter object:nil];   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarDefaultStyle];

    [[WXYZ_AudioSettingHelper sharedManager] playPageViewShow:YES productionType:WXYZ_ProductionTypeAi];
    [[WXYZ_TouchAssistantView sharedManager] hiddenAssistiveTouchView];
    [[WXYZ_TouchAssistantView sharedManager] setPlayerProductionType:WXYZ_ProductionTypeBook];
    if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] isCollectedWithProductionModel:self.bookModel]) {
        [self.addBookRack setTitle:@"已收藏" forState:UIControlStateNormal];
        [self.addBookRack setTitleColor:kGrayTextColor forState:UIControlStateNormal];
        self.addBookRack.enabled = NO;
    } else {
        [self.addBookRack setTitle:@"收藏" forState:UIControlStateNormal];
        [self.addBookRack setTitleColor:kBlackColor forState:UIControlStateNormal];
        self.addBookRack.enabled = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (!([WXYZ_Player sharedPlayer].state == WXYZ_PlayPagePlayerStatePlaying)) {
        [[WXYZ_TouchAssistantView sharedManager] showAssistiveTouchViewWithImageCover:self.bookModel.cover productionType:WXYZ_ProductionTypeBook];
    } else {
        [[WXYZ_TouchAssistantView sharedManager] showAssistiveTouchView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[WXYZ_TouchAssistantView sharedManager] hiddenAssistiveTouchView];
}

- (void)createSubviews
{
    WS(weakSelf)
    
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
    
    self.addBookRack = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] isCollectedWithProductionModel:self.bookModel]) {
        [self.addBookRack setTitle:@"已收藏" forState:UIControlStateNormal];
        [self.addBookRack setTitleColor:kGrayTextColor forState:UIControlStateNormal];
        self.addBookRack.enabled = NO;
    } else {
        [self.addBookRack setTitle:@"收藏" forState:UIControlStateNormal];
        [self.addBookRack setTitleColor:kBlackColor forState:UIControlStateNormal];
        self.addBookRack.enabled = YES;
    }
    self.addBookRack.backgroundColor = kWhiteColor;
    [self.addBookRack setTitleColor:kBlackColor forState:UIControlStateNormal];
    [self.addBookRack.titleLabel setFont:kMainFont];
    [self.addBookRack setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.addBookRack addTarget:self action:@selector(addBookRackClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addBookRack];
    
    [self.addBookRack mas_makeConstraints:^(MASConstraintMaker *make) {
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
        make.height.mas_equalTo(self.view.mas_height).with.offset(- PUB_TABBAR_HEIGHT- PUB_NAVBAR_HEIGHT);
    }];
    
    [self.mainTableViewGroup setTableHeaderView:self.headerView];
    
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
    
    WXYZ_CustomButton *shareButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"分享" buttonImageName:@"public_share" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
    shareButton.tag = 0;
    shareButton.graphicDistance = 5;
    shareButton.buttonImageScale = 0.4;
    shareButton.buttonTintColor = kBlackColor;
    shareButton.buttonTitleColor = kGrayTextLightColor;
    [shareButton addTarget:self action:@selector(toolBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomMenu addSubview:shareButton];
    
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bottomMenu.mas_right).with.offset(- kHalfMargin);
        make.top.mas_equalTo(self.bottomMenu.mas_top).with.offset(5);
        make.width.height.mas_equalTo(40);
    }];
    
    WXYZ_CustomButton *commentButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"评论" buttonImageName:@"audio_comment" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
    commentButton.tag = 1;
    commentButton.graphicDistance = 5;
    commentButton.buttonImageScale = 0.45;
    commentButton.buttonTitleColor = kGrayTextLightColor;
    [commentButton addTarget:self action:@selector(toolBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomMenu addSubview:commentButton];
    
    [commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(shareButton.mas_left).with.offset(- kHalfMargin);
        make.centerY.mas_equalTo(shareButton.mas_centerY);
        make.width.height.mas_equalTo(shareButton);
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
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        [weakSelf sendCommentNetRequest];
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
            if (self.audioPlayPageModel.advert.ad_type != 0) {
                return 1;
            }
            break;
        case 1:
            if (self.audioPlayPageModel.list.count > 0) {
                return 1;
            }
            break;
        case 2:
            return self.audioPlayPageModel.comment.list.count;
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
            return [self createSingleStyleCellWithTableView:tableView atIndexPath:indexPath listArray:self.audioPlayPageModel.list];
            break;
        case 2:
            return [self createCommentCellWithTableView:tableView atIndexPath:indexPath labelModel:[self.audioPlayPageModel.comment.list objectOrNilAtIndex:indexPath.row]];
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
    
    WXYZ_BookMallStyleSingleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_BookMallStyleSingleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.labelModel = labelModel;
    cell.cellDidSelectItemBlock = ^(NSInteger production_id) {
        
        WXYZ_BookMallDetailViewController *vc = [[WXYZ_BookMallDetailViewController alloc] init];
        vc.book_id = production_id;
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
    [cell setIsPreview:YES lastRow:(self.audioPlayPageModel.comment.list.count - 1 == indexPath.row)];
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
    [cell setAdModel:self.audioPlayPageModel.advert refresh:self.needRefresh];
    cell.mainTableView = tableView;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
#if WX_Comments_Mode
    if (!self.bookModel) {
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
        self.sectionTitleLabel.text = [NSString stringWithFormat:@"本章评论（%@）", [WXYZ_UtilsHelper formatStringWithInteger:self.audioPlayPageModel.comment_total_count]];
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
    if (!self.bookModel) {
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
        if (self.audioPlayPageModel) {
            
            if (self.audioPlayPageModel.comment.list.count == 0) {
                [self.sectionBottomCommentButton setTitle:@"暂无评论，点击抢沙发" forState:UIControlStateNormal];
            } else {
                [self.sectionBottomCommentButton setTitle:[NSString stringWithFormat:@"查看全部评论(%@条)", [WXYZ_UtilsHelper formatStringWithInteger:self.audioPlayPageModel.comment_total_count]] forState:UIControlStateNormal];
            }
            [view addSubview:self.sectionBottomCommentButton];
        }
    }
    
    return view;
}

- (void)changeAiChapter:(NSNotification *)noti
{
    NSInteger chapter_id = [[WXYZ_UtilsHelper formatStringWithObject:noti.object] integerValue];
    
    // 支付成功的章节更新预览内容
    NSArray *success_chapter_ids = [noti.userInfo objectForKey:@"success_chapter_ids"];
    if (success_chapter_ids.count > 0) {
        for (NSString *chapter_id in success_chapter_ids) {
            for (WXYZ_ProductionChapterModel *t_model in self.bookModel.chapter_list) {
                if (t_model.chapter_id == [chapter_id integerValue]) {
                    t_model.is_preview = 0;
                    break;
                }
            }
        }
    }
    
    for (WXYZ_ProductionChapterModel *t_model in self.bookModel.chapter_list) {
        if (t_model.chapter_id == chapter_id) {
            t_model.name = self.chapterModel.name;
            t_model.cover = self.chapterModel.cover;
            t_model.production_id = self.chapterModel.production_id;
            self.headerView.productionChapterModel = t_model;
            [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAi] addReadingRecordWithProduction_id:self.bookModel.production_id chapter_id:chapter_id chapterTitle:t_model.chapter_title];
            break;
        }
    }
    
    if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] isCollectedWithProductionModel:self.bookModel]) {
        [self.addBookRack setTitle:@"已收藏" forState:UIControlStateNormal];
        [self.addBookRack setTitleColor:kGrayTextColor forState:UIControlStateNormal];
        self.addBookRack.enabled = NO;
    } else {
        [self.addBookRack setTitle:@"收藏" forState:UIControlStateNormal];
        [self.addBookRack setTitleColor:kBlackColor forState:UIControlStateNormal];
        self.addBookRack.enabled = YES;
    }
    
    [self requestChapterCommentWithChapter_id:chapter_id];
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

- (WXYZ_BookAiPlayPageHeaderView *)headerView
{
    if (!_headerView) {
        WS(weakSelf)
        _headerView = [[WXYZ_BookAiPlayPageHeaderView alloc] initWithProductionType:WXYZ_ProductionTypeAi];
        _headerView.checkOriginalBlock = ^(WXYZ_ProductionChapterModel * _Nonnull chapterModel) {
            if (weakSelf.navigationController.view.tag == 2345) {
                [weakSelf popViewController];
                return;
            }
            WXYZ_BookReaderViewController *vc = [[WXYZ_BookReaderViewController alloc] init];
            vc.book_id = weakSelf.bookModel.production_id;
            vc.bookModel = weakSelf.bookModel;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        };
        _headerView.checkRelationProductionBlock = ^(WXYZ_RelationModel * _Nonnull relationModel) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] moveCollectionToTopWithProductionModel:weakSelf.bookModel];
                WXYZ_AudioSoundPlayPageViewController *vc = [WXYZ_AudioSoundPlayPageViewController sharedManager];
                [vc loadDataWithAudio_id:relationModel.production_id chapter_id:relationModel.chapter_id];
                if (!vc.presentedViewController) {
                    WXYZ_NavigationController *nav = [[WXYZ_NavigationController alloc] initWithRootViewController:vc];
                    [[WXYZ_ViewHelper getWindowRootController] presentViewController:nav animated:YES completion:nil];
                } else {
                    [weakSelf popViewController];
                    if ([weakSelf.navigationController.viewControllers.lastObject isKindOfClass:WXYZ_BookAiPlayPageViewController.class]) {
                        [kNotification postNotificationName:NSNotification_Reader_Back object:@"1"];
                    }
                }
            });
        };
    }
    return _headerView;
}

#pragma mark - 点击事件

- (void)addBookRackClick
{
    [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] addCollectionWithProductionModel:self.bookModel];
    if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] isCollectedWithProductionModel:self.bookModel]) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"已收藏"];
        [self.addBookRack setTitle:@"已收藏" forState:UIControlStateNormal];
        [self.addBookRack setTitleColor:kGrayTextColor forState:UIControlStateNormal];
        self.addBookRack.enabled = NO;
    } else {
        [self.addBookRack setTitle:@"收藏" forState:UIControlStateNormal];
        [self.addBookRack setTitleColor:kBlackColor forState:UIControlStateNormal];
        self.addBookRack.enabled = YES;
    }
    
    [WXYZ_UtilsHelper synchronizationRackProductionWithProduction_id:self.bookModel.production_id productionType:WXYZ_ProductionTypeBook complete:nil];
}

- (void)commentClick
{
    WS(weakSelf)
    WXYZ_CommentsViewController *vc = [[WXYZ_CommentsViewController alloc] init];
    vc.production_id = self.bookModel.production_id;
    vc.chapter_id = [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAi] getReadingRecordChapter_idWithProduction_id:self.bookModel.production_id];
    vc.productionType = WXYZ_ProductionTypeBook;
    vc.commentsSuccessBlock = ^(WXYZ_CommentsDetailModel *commentModel) {
        
        WXYZ_ProductionModel *t_model = weakSelf.bookModel;
        
        // 评论数++
        t_model.total_comment ++;
        
        // 评论数组model添加
        NSMutableArray *t_array = [NSMutableArray arrayWithArray:weakSelf.audioPlayPageModel.comment.list];
        [t_array insertObject:commentModel atIndex:0];
        weakSelf.audioPlayPageModel.comment.list = [t_array copy];
        
        weakSelf.bookModel = t_model;
        
        [weakSelf.mainTableViewGroup reloadData];
        
        weakSelf.commentConnerLabel.text = [NSString stringWithFormat:@"%@", weakSelf.audioPlayPageModel.comment_total_count > 99?@"99+":[WXYZ_UtilsHelper formatStringWithInteger:weakSelf.audioPlayPageModel.comment_total_count]];
        
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)toolBarButtonClick:(WXYZ_CustomButton *)sender
{
    if (sender.tag == 0) { // 分享
        [[WXYZ_ShareManager sharedManager] shareProductionInController:self shareTitle:self.bookModel.name shareDescribe:self.bookModel.production_descirption shareImageURL:self.bookModel.cover productionType:WXYZ_ShareProductionAudio production_id:self.bookModel.production_id shareState:WXYZ_ShareStateAll];
    }
    
    if (sender.tag == 1) {
        [self commentClick];
    }
}

- (void)netRequest
{
    WS(weakSelf)
    
    NSInteger chapter_id = [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAi] getReadingRecordChapter_idWithProduction_id:self.bookModel.production_id];
    
    if (chapter_id == 0) {
        WXYZ_ProductionChapterModel *t_model = [self.bookModel.chapter_list firstObject];
        chapter_id = t_model.chapter_id;
    }
    
    [WXYZ_NetworkRequestManger POST:Ai_Audio_Detail parameters:@{@"book_id":[WXYZ_UtilsHelper formatStringWithInteger:self.bookModel.production_id]?:@"", @"chapter_id":[WXYZ_UtilsHelper formatStringWithInteger:chapter_id]} model:WXYZ_PlayPageModel.class success:^(BOOL isSuccess, WXYZ_PlayPageModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            weakSelf.audioPlayPageModel = t_model;
            weakSelf.commentConnerLabel.text = [NSString stringWithFormat:@"%@", weakSelf.audioPlayPageModel.comment_total_count > 99?@"99+":[WXYZ_UtilsHelper formatStringWithInteger:weakSelf.audioPlayPageModel.comment_total_count]];
            weakSelf.headerView.relationModel = weakSelf.audioPlayPageModel.relation;
        }
        weakSelf.needRefresh = YES;
        [weakSelf.mainTableViewGroup reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.needRefresh = NO;
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        weakSelf.needRefresh = YES;
        [weakSelf.mainTableViewGroup reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.needRefresh = NO;
        });
    }];
}

- (void)requestChapterCommentWithChapter_id:(NSInteger)chapter_id
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Book_Comment_List parameters:@{@"page_num":@"1", @"book_id":[WXYZ_UtilsHelper formatStringWithInteger:self.bookModel.production_id]?:@"", @"chapter_id":[WXYZ_UtilsHelper formatStringWithInteger:chapter_id]} model:WXYZ_CommentsModel.class success:^(BOOL isSuccess, WXYZ_CommentsModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            weakSelf.audioPlayPageModel.comment.list = t_model.list;
            weakSelf.needRefresh = YES;
            [weakSelf.mainTableViewGroup reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.needRefresh = NO;
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        weakSelf.needRefresh = YES;
        [weakSelf.mainTableViewGroup reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.needRefresh = NO;
        });
    }];
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
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Book_Comment_Post parameters:@{@"book_id":[WXYZ_UtilsHelper formatStringWithInteger:self.bookModel.production_id]?:@"", @"chapter_id":[WXYZ_UtilsHelper formatStringWithInteger:self.chapterModel.chapter_id], @"content":t_text} model:WXYZ_CommentsDetailModel.class success:^(BOOL isSuccess, WXYZ_CommentsDetailModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"评论成功"];
            
            // 评论数组model添加
            NSMutableArray *t_array = [NSMutableArray arrayWithArray:weakSelf.audioPlayPageModel.comment.list];
            [t_array insertObject:t_model atIndex:0];
            weakSelf.audioPlayPageModel.comment.list = [t_array copy];
            weakSelf.audioPlayPageModel.comment_total_count++;
            
            [weakSelf.mainTableViewGroup reloadSection:2 withRowAnimation:UITableViewRowAnimationNone];
            
            weakSelf.commentConnerLabel.text = [NSString stringWithFormat:@"%@", weakSelf.audioPlayPageModel.comment_total_count > 99?@"99+":[WXYZ_UtilsHelper formatStringWithInteger:weakSelf.audioPlayPageModel.comment_total_count]];
            
        } else if (Compare_Json_isEqualTo(requestModel.code, 315)) {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:requestModel.msg];
        }  else {
            commentTextView.text = t_text;
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
    }];
}

@end

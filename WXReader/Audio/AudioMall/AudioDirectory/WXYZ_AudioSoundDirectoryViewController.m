//
//  WXYZ_AudioSoundDirectoryViewController.m
//  WXReader
//
//  Created by Andrew on 2020/3/12.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AudioSoundDirectoryViewController.h"
#import "WXYZ_AudioSoundPlayPageViewController.h"
#import "WXYZ_TaskViewController.h"

#import "WXYZ_AudioSoundDirectoryTableViewCell.h"
#import "WXYZ_AudioPlayPageMenuView.h"
#import "WXYZ_ChapterBottomPayBar.h"

#import "WXYZ_AudioDownloadManager.h"
#import "WXYZ_ProductionReadRecordManager.h"
#import "WXYZ_ProductionCollectionManager.h"

@interface WXYZ_AudioSoundDirectoryViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *headerSectionView;

@property (nonatomic, strong) UILabel *headerSectionLabel;

@property (nonatomic, assign) BOOL toolSelect;  // 工具栏状态选择

@end

@implementation WXYZ_AudioSoundDirectoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mainTableView reloadData];
}

- (void)initialize
{
    [self hiddenNavigationBar:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeChapterList:) name:NSNotification_Auto_Buy_Audio_Chapter object:nil];
}

- (void)createSubviews
{
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.contentInset = UIEdgeInsetsMake(0, 0, PUB_TABBAR_OFFSET, 0);
    [self.view addSubview:self.mainTableView];
    
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self setEmptyOnView:self.mainTableView title:@"暂无目录列表" buttonTitle:@"" tapBlock:^{
        
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.toolSelect) {
        return;
    }
    
    if ([scrollView isEqual:self.mainTableView]) {
           if (!self.canScroll) {
               scrollView.contentOffset = CGPointZero;
           }
           
           if (scrollView.contentOffset.y > 0) {
               [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Audio_Can_Leave_Top object:@NO];
           }
       }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.toolSelect = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y <= 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Audio_Can_Leave_Top object:@YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.directoryModel.chapter_list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WS(weakSelf)
    WXYZ_ProductionChapterModel *t_chapterList = [self.directoryModel.chapter_list objectOrNilAtIndex:indexPath.row];
    WXYZ_AudioSoundDirectoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_AudioSoundDirectoryTableViewCell"];
    
    if (!cell) {
        cell = [[WXYZ_AudioSoundDirectoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_AudioSoundDirectoryTableViewCell"];
    }
    cell.chapterListModel = t_chapterList;
    cell.cellIndexPath = indexPath;
    cell.cellDownloadState = [[WXYZ_AudioDownloadManager sharedManager] getChapterDownloadStateWithProduction_id:t_chapterList.production_id chapter_id:t_chapterList.chapter_id];
    cell.hiddenEndLine = self.directoryModel.chapter_list.count - 1 == indexPath.row;
    cell.downloadChapterBlock = ^(NSInteger audio_id, NSInteger chapter_id, NSIndexPath *cellIndexPath) {
        [weakSelf requestChapterDownloadDataWithAudio_id:audio_id chapter_ids:@[[WXYZ_UtilsHelper formatStringWithInteger:chapter_id]] indexPath:cellIndexPath];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Reset_Player_Inof object:nil];
    
    WS(weakSelf)
    WXYZ_ProductionChapterModel *t_chapterListModel = [self.directoryModel.chapter_list objectOrNilAtIndex:indexPath.row];
    
    WXYZ_AudioSoundPlayPageViewController *vc = [WXYZ_AudioSoundPlayPageViewController sharedManager];
    vc.chapter_list = self.directoryModel.chapter_list;
    [vc loadDataWithAudio_id:t_chapterListModel.production_id chapter_id:t_chapterListModel.chapter_id];
    
    for (UIViewController *vc in weakSelf.navigationController.viewControllers) {
        if ([vc isKindOfClass:[WXYZ_AudioSoundPlayPageViewController class]]) {
            [weakSelf popViewController];
            return;
        }
    }
    
    [weakSelf closeContinuePlayButton];
    [WXYZ_TaskViewController taskReadRequestWithProduction_id:self.audio_id];
    
    WXYZ_NavigationController *nav = [[WXYZ_NavigationController alloc] initWithRootViewController:vc];
    [[WXYZ_ViewHelper getWindowRootController] presentViewController:nav animated:YES completion:^{
        [weakSelf.mainTableView reloadData];
    }];
    
    [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] moveCollectionToTopWithProductionModel:self.directoryModel];
}

//section头间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.directoryModel.chapter_list.count > 0) {
        return 60;
    }
    return CGFLOAT_MIN;
}

//section头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.headerSectionView;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, PUB_TABBAR_OFFSET == 0 ? 10 : PUB_TABBAR_OFFSET)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UIView *)headerSectionView
{
    if (!_headerSectionView) {
        _headerSectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
        _headerSectionView.backgroundColor = kWhiteColor;
        
        [_headerSectionView addSubview:self.headerSectionLabel];
        
        if (![[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio]
              isCurrentPlayingProductionWithProduction_id:self.audio_id]    // 不是正在播放的作品
            &&
            ([[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio]
              getReadingRecordChapter_idWithProduction_id:self.audio_id] > 0)   // 记录章节id存在
            &&
            ([[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio]
              getReadingRecordChapterTitleWithProduction_id:self.audio_id].length > 0) // 记录的章节名称存在
            ) {
            UIButton *continuePlay = [UIButton buttonWithType:UIButtonTypeCustom];
            continuePlay.frame = CGRectMake(kMargin, kHalfMargin + 5, 150, 30);
            continuePlay.tag = 1123;
            continuePlay.backgroundColor = kWhiteColor;
            continuePlay.layer.cornerRadius = 15;
            continuePlay.layer.borderColor = kMainColor.CGColor;
            continuePlay.layer.borderWidth = 1;
            continuePlay.clipsToBounds = YES;
            [continuePlay addTarget:self action:@selector(continueButtonClick) forControlEvents:UIControlEventTouchUpInside];
            [_headerSectionView addSubview:continuePlay];

            UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_play"]];
            icon.frame = CGRectMake(5, 5, continuePlay.height - 10, continuePlay.height - 10);
            [continuePlay addSubview:icon];
            
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"续播|%@", [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] getReadingRecordChapterTitleWithProduction_id:self.audio_id]]];
            text.font = kFont10;
            text.color = kMainColor;
            [text addAttribute:NSFontAttributeName value:kBoldFont10 range:NSMakeRange(0, 2)];
            
            continuePlay.ly_width = [WXYZ_ViewHelper getDynamicWidthWithLabelFont:kFont10 labelHeight:30 labelText:text.string maxWidth:140] + 30;
            
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(icon.right + 5, 0, continuePlay.width - icon.width - 3 * 5, continuePlay.height)];
            title.attributedText = text;
            [continuePlay addSubview:title];
            
            UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            closeButton.frame = CGRectMake(continuePlay.right - continuePlay.height / 2 + 5, continuePlay.top - 5, continuePlay.height / 2 + 10, continuePlay.height / 2 + 10);
            closeButton.layer.cornerRadius = continuePlay.height / 4;
            closeButton.clipsToBounds = YES;
            closeButton.tag = 1123;
            closeButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
            closeButton.contentHorizontalAlignment = UIControlContentVerticalAlignmentFill;
            [closeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 10)];
            [closeButton setImage:[UIImage imageNamed:@"audio_continue_close"] forState:UIControlStateNormal];
            [closeButton addTarget:self action:@selector(closeContinuePlayButton) forControlEvents:UIControlEventTouchUpInside];
            [_headerSectionView addSubview:closeButton];
            
        }
        
        WXYZ_CustomButton *selectionButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40 - kHalfMargin, 10, 40, 40) buttonTitle:@"选章" buttonImageName:@"audio_selection" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
        selectionButton.tag = 0;
        selectionButton.buttonTintColor = kBlackColor;
        selectionButton.buttonTitleFont = kFont10;
        selectionButton.graphicDistance = 2;
        selectionButton.buttonImageScale = 0.4;
        [selectionButton addTarget:self action:@selector(toolBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_headerSectionView addSubview:selectionButton];
        
        WXYZ_CustomButton *sortButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectMake(selectionButton.left - 40 - kHalfMargin, selectionButton.top, selectionButton.width, selectionButton.height) buttonTitle:@"排序" buttonImageName:@"audio_order_sequence" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
        sortButton.selected = NO;
        sortButton.tag = 1;
        sortButton.buttonTintColor = kBlackColor;
        sortButton.buttonTitleFont = kFont10;
        sortButton.graphicDistance = 2;
        sortButton.buttonImageScale = 0.4;
        [sortButton addTarget:self action:@selector(toolBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_headerSectionView addSubview:sortButton];
        
    }
    return _headerSectionView;
}

- (UILabel *)headerSectionLabel
{
    if (!_headerSectionLabel) {
        _headerSectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMargin, 0, SCREEN_WIDTH / 2, 60)];
        _headerSectionLabel.textColor = kGrayTextDeepColor;
        _headerSectionLabel.font = kFont12;
        _headerSectionLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _headerSectionLabel;
}

- (void)setDirectoryModel:(WXYZ_ProductionModel *)directoryModel
{
    _directoryModel = directoryModel;
    self.headerSectionLabel.text = [NSString stringWithFormat:@"共%@章", [WXYZ_UtilsHelper formatStringWithInteger:directoryModel.chapter_list.count]];
    [self.mainTableView reloadData];
    self.emptyView.contentViewY = kHalfMargin;
    [self.mainTableView endRefreshing];
    [self.mainTableView ly_endLoading];
}

- (void)continueButtonClick
{
    WS(weakSelf)
    WXYZ_AudioSoundPlayPageViewController *vc = [WXYZ_AudioSoundPlayPageViewController sharedManager];
    vc.chapter_list = self.directoryModel.chapter_list;
    [vc loadDataWithAudio_id:self.audio_id chapter_id:[[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] getReadingRecordChapter_idWithProduction_id:self.audio_id]];
    WXYZ_NavigationController *nav = [[WXYZ_NavigationController alloc] initWithRootViewController:vc];
    [[WXYZ_ViewHelper getWindowRootController] presentViewController:nav animated:YES completion:^{
        [weakSelf closeContinuePlayButton];
        [weakSelf.mainTableView reloadData];
    }];
}

- (void)closeContinuePlayButton
{
    [self.headerSectionView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == 1123) {
            [obj removeAllSubviews];
            [obj removeFromSuperview];
            obj = nil;
        }
    }];
}

- (void)toolBarButtonClick:(WXYZ_CustomButton *)sender
{
    switch (sender.tag) {
        case 0: // 选章
        {
            WS(weakSelf)
            WXYZ_AudioPlayPageMenuView *chooseMenuView = [[WXYZ_AudioPlayPageMenuView alloc] init];
            chooseMenuView.menuListArray = self.directoryModel.chapter_list;
            chooseMenuView.totalChapter = self.directoryModel.total_chapters;
            chooseMenuView.chooseMenuBlock = ^(WXYZ_MenuType menuType, NSInteger chooseIndex) {
                /* 滚动指定段的指定row  到 指定位置*/
                weakSelf.toolSelect = YES;
                [weakSelf.mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:chooseIndex * 30 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            };
            [chooseMenuView showWithMenuType:WXYZ_MenuTypeAudioSelection];
        }
            break;
        case 1: // 排序
        {
            if (sender.selected) {
                sender.selected = NO;
                sender.buttonImageName = @"audio_order_sequence";
            } else {
                sender.selected = YES;
                sender.buttonImageName = @"audio_orider_reversed";
            }
            self.directoryModel.chapter_list = [[self.directoryModel.chapter_list reverseObjectEnumerator] allObjects];
            [self.mainTableView reloadData];
        }
            break;
            
        default:
            break;
    }
}

- (void)changeChapterList:(NSNotification *)noti
{
    // 需要改变状态的chapter的is_preview状态
    if ([noti.object isKindOfClass:[NSString class]]) {
        NSInteger t_chapter_id = [noti.object integerValue];
        
        for (WXYZ_ProductionChapterModel *t_chapterModel in self.directoryModel.chapter_list) {
            if (t_chapter_id == t_chapterModel.chapter_id) {
                t_chapterModel.is_preview = 0;
                break;
            }
        }
    }
}

- (void)requestChapterDownloadDataWithAudio_id:(NSInteger)audio_id chapter_ids:(NSArray <NSString *>*)chapter_ids indexPath:(NSIndexPath *)indexPath
{
    WS(weakSelf)
    WXYZ_AudioDownloadManager *audioDownloadManager = [WXYZ_AudioDownloadManager sharedManager];
    [audioDownloadManager downloadChaptersWithProductionModel:self.directoryModel production_id:audio_id chapter_ids:chapter_ids];
    audioDownloadManager.downloadChapterStateChangeBlock = ^(WXYZ_DownloadChapterState state, NSInteger production_id, NSInteger chapter_id) {
        
        WXYZ_AudioSoundDirectoryTableViewCell *cell = [self.mainTableView cellForRowAtIndexPath:indexPath];
        switch (state) {
            case WXYZ_DownloadStateChapterDownloadStart:
                cell.cellDownloadState = WXYZ_ProductionDownloadStateDownloading;
                break;
            case WXYZ_DownloadStateChapterDownloadFinished:
                cell.cellDownloadState = WXYZ_ProductionDownloadStateDownloaded;
                break;
            case WXYZ_DownloadStateChapterDownloadFail:
                cell.cellDownloadState = WXYZ_ProductionDownloadStateFail;
                break;
                
            default:
                break;
        }
    };
    
    audioDownloadManager.downloadMissionStateChangeBlock = ^(WXYZ_DownloadMissionState state, NSInteger production_id, NSArray * _Nonnull chapter_ids) {
        switch (state) {
            case WXYZ_DownloadStateMissionShouldPay:
            {
                WXYZ_ProductionChapterModel *t_chapterList = [weakSelf.directoryModel.chapter_list objectOrNilAtIndex:indexPath.row];
                t_chapterList.chapter_ids = @[[WXYZ_UtilsHelper formatStringWithInteger:t_chapterList.chapter_id]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    WXYZ_ChapterBottomPayBar *payBar = [[WXYZ_ChapterBottomPayBar alloc] initWithChapterModel:t_chapterList barType:WXYZ_BottomPayBarTypeDownload productionType:WXYZ_ProductionTypeAudio];
                    payBar.paySuccessChaptersBlock = ^(NSArray<NSString *> * _Nonnull success_chapter_ids) {
                        [weakSelf requestChapterDownloadDataWithAudio_id:audio_id chapter_ids:chapter_ids indexPath:indexPath];
                    };
                    payBar.payFailChaptersBlock = ^(NSArray<NSString *> * _Nonnull fail_chapter_ids) {
                        WXYZ_AudioSoundDirectoryTableViewCell *cell = [self.mainTableView cellForRowAtIndexPath:indexPath];
                        cell.chapterListModel = cell.chapterListModel;
                        cell.cellDownloadState = WXYZ_ProductionDownloadStateNormal;
                        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"购买失败"];
                    };
                    payBar.payCancleChapterBlock = ^(NSArray<NSString *> * _Nonnull fail_chapter_ids) {
                        WXYZ_AudioSoundDirectoryTableViewCell *cell = [self.mainTableView cellForRowAtIndexPath:indexPath];
                        cell.chapterListModel = cell.chapterListModel;
                        cell.cellDownloadState = WXYZ_ProductionDownloadStateNormal;
                    };
                    [payBar showBottomPayBar];
                });
            }
                break;
                
            default:
                break;
        }
    };
}

@end

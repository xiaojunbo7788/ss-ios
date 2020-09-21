//
//  WXYZ_AudioDownloadViewController.m
//  WXReader
//
//  Created by Andrew on 2020/3/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AudioDownloadViewController.h"

#import "WXYZ_AudioDownloadTableViewCell.h"

#import "WXYZ_AudioPlayPageMenuView.h"
#import "WXYZ_AudioDownloadManager.h"
#import "WXYZ_ProductionReadRecordManager.h"
#import "WXYZ_ChapterBottomPayBar.h"

@interface WXYZ_AudioDownloadViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) WXYZ_ProductionModel *audioModel;

@property (nonatomic, assign) CGFloat totalMemorySize;

@property (nonatomic, assign) BOOL payBarShowing;

@property (nonatomic, strong) UIButton *downloadButton;

@property (nonatomic, strong) UIActivityIndicatorView *downloadIndicatorView;

@property (nonatomic, strong) WXYZ_AudioDownloadManager *audioDownloadManager;

@property (nonatomic, weak) UILabel *headerTitleLabel;

@end

@implementation WXYZ_AudioDownloadViewController
{
    UILabel *memoryBarView;
    
    WXYZ_CustomButton *selectAllButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
    [self initDownloadManager];
    [self netRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarDefaultStyle];
}

- (void)initialize
{
    [self setNavigationBarTitle:@"批量下载"];
    self.totalMemorySize = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netRequest) name:Notification_Login_Success object:nil];
}

- (void)createSubviews
{
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    [self.view addSubview:self.mainTableView];
    
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_height).with.offset(- PUB_NAVBAR_HEIGHT - PUB_TABBAR_HEIGHT - 20);
    }];
    
    memoryBarView = [[UILabel alloc] init];
    memoryBarView.backgroundColor = kColorRGB(251, 251, 251);
    memoryBarView.font = kFont10;
    memoryBarView.textAlignment = NSTextAlignmentCenter;
    memoryBarView.textColor = kGrayTextColor;
    memoryBarView.text = [NSString stringWithFormat:@"可用空间%@", [WXYZ_UtilsHelper getRemainingMemorySpace]];
    [self.view addSubview:memoryBarView];
    
    [memoryBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(self.mainTableView.mas_bottom);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(20);
    }];
    
    selectAllButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"全选" buttonImageName:@"audio_download_unselect" buttonIndicator:WXYZ_CustomButtonIndicatorImageLeftBothLeft];
    selectAllButton.buttonTitleColor = kBlackColor;
    selectAllButton.buttonTitleFont = kMainFont;
    selectAllButton.graphicDistance = 10;
    selectAllButton.buttonImageScale = 0.4;
    selectAllButton.hidden = YES;
    selectAllButton.tag = 0;
    selectAllButton.backgroundColor = [UIColor whiteColor];
    [selectAllButton addTarget:self action:@selector(checkallClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectAllButton];
    
    [selectAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.top.mas_equalTo(self.mainTableView.mas_bottom).with.offset(20);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT - PUB_TABBAR_OFFSET);
    }];
    
    self.downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.downloadButton.backgroundColor = kGrayTextLightColor;
    self.downloadButton.enabled = NO;
    [self.downloadButton setTitle:@"立即下载" forState:UIControlStateNormal];
    [self.downloadButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [self.downloadButton.titleLabel setFont:kMainFont];
    [self.downloadButton addTarget:self action:@selector(downloadClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.downloadButton];
    
    [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right);
        make.top.mas_equalTo(selectAllButton.mas_top);
        make.width.mas_equalTo(SCREEN_WIDTH / 3);
        make.height.mas_equalTo(selectAllButton.mas_height);
    }];
    
    self.downloadIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    self.downloadIndicatorView.hidesWhenStopped = YES;
    [self.downloadButton addSubview:self.downloadIndicatorView];
    
    [self.downloadIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.downloadButton.mas_centerX);
        make.centerY.mas_equalTo(self.downloadButton.mas_centerY);
        make.width.height.mas_equalTo(self.downloadButton.mas_height);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionChapterModel *chapterModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    static NSString *cellName = @"WXYZ_AudioDownloadTableViewCell";
    WXYZ_AudioDownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_AudioDownloadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.chapterModel = chapterModel;
    cell.cellDownloadState = [[self.selectSourceDictionary objectForKey:[WXYZ_UtilsHelper formatStringWithInteger:chapterModel.chapter_id]] integerValue];
    cell.hiddenEndLine = self.dataSourceArray.count - 1 == indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//section头间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
//section头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    view.backgroundColor = [UIColor clearColor];
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    mainView.backgroundColor = kColorRGB(251, 251, 251);
    [view addSubview:mainView];
    
    UILabel *headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMargin, 0, SCREEN_WIDTH / 2, 30)];
    self.headerTitleLabel = headerTitleLabel;
    headerTitleLabel.backgroundColor = [UIColor clearColor];
    headerTitleLabel.font = kFont12;
    headerTitleLabel.text = [NSString stringWithFormat:@"已下载%zd章", [[WXYZ_AudioDownloadManager sharedManager] getDownloadChapterCountWithProduction_id:self.audioModel.production_id]];
    headerTitleLabel.textColor = kGrayTextColor;
    [mainView addSubview:headerTitleLabel];
    
    WXYZ_CustomButton *selectionButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60 - kHalfMargin, 0, 60, 30) buttonTitle:@"选章" buttonImageName:@"audio_selection" buttonIndicator:WXYZ_CustomButtonIndicatorTitleRight];
    selectionButton.tag = 0;
    selectionButton.buttonTintColor = kGrayTextColor;
    selectionButton.buttonTitleFont = kFont12;
    selectionButton.graphicDistance = 2;
    selectionButton.buttonImageScale = 0.4;
    [selectionButton addTarget:self action:@selector(selectionButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:selectionButton];
    
    return view;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionChapterModel *chapterModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    WXYZ_AudioDownloadTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    switch (cell.cellDownloadState) {
        case WXYZ_ProductionDownloadStateNormal:
        case WXYZ_ProductionDownloadStateFail:
            [self setCollectionCellDownloadStateWithChapter_id:chapterModel.chapter_id downloadState:WXYZ_ProductionDownloadStateSelected];
            [self reloadToolBar];
            break;
        case WXYZ_ProductionDownloadStateSelected:
            [self setCollectionCellDownloadStateWithChapter_id:chapterModel.chapter_id downloadState:WXYZ_ProductionDownloadStateNormal];
            [self reloadToolBar];
            break;
        default:
            break;
    }
}

- (void)checkallClick:(WXYZ_CustomButton *)sender
{
    self.totalMemorySize = 0;
    for (WXYZ_ProductionChapterModel *chapterModel in self.dataSourceArray) {
        if ([[WXYZ_AudioDownloadManager sharedManager] getChapterDownloadStateWithProduction_id:chapterModel.production_id chapter_id:chapterModel.chapter_id] == WXYZ_ProductionDownloadStateNormal) {
            self.totalMemorySize = self.totalMemorySize + chapterModel.size;
        }
    }
    
    for (NSString *t_chapter_id in self.selectSourceDictionary.allKeys) {
        
        if (!sender.selected) { // 全选状态
            if ([[self.selectSourceDictionary objectForKey:t_chapter_id] integerValue] == WXYZ_ProductionDownloadStateNormal || [[self.selectSourceDictionary objectForKey:t_chapter_id] integerValue] == WXYZ_ProductionDownloadStateFail) {
                
                [self setCollectionCellDownloadStateWithChapter_id:[t_chapter_id integerValue] downloadState:WXYZ_ProductionDownloadStateSelected];
            }
        } else {
            if ([[self.selectSourceDictionary objectForKey:t_chapter_id] integerValue] == WXYZ_ProductionDownloadStateSelected) {
                [self setCollectionCellDownloadStateWithChapter_id:[t_chapter_id integerValue] downloadState:WXYZ_ProductionDownloadStateNormal];
            }
        }
    }
    
    sender.selected = !sender.selected;

    [self reloadToolBar];
}

- (void)selectionButtonClick
{
    WS(weakSelf)
    WXYZ_AudioPlayPageMenuView *chooseMenuView = [[WXYZ_AudioPlayPageMenuView alloc] init];
    chooseMenuView.menuListArray = self.dataSourceArray;
    chooseMenuView.totalChapter = self.audioModel.total_chapters;
    chooseMenuView.chooseMenuBlock = ^(WXYZ_MenuType menuType, NSInteger chooseIndex) {
        /* 滚动指定段的指定row  到 指定位置*/
        [weakSelf.mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:chooseIndex * 30 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    };
    [chooseMenuView showWithMenuType:WXYZ_MenuTypeAudioSelection];
}

- (void)initDownloadManager
{
    WS(weakSelf)
    self.audioDownloadManager = [WXYZ_AudioDownloadManager sharedManager];
    self.audioDownloadManager.downloadChapterStateChangeBlock = ^(WXYZ_DownloadChapterState state, NSInteger production_id, NSInteger chapter_id) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            switch (state) {
                case WXYZ_DownloadStateChapterDownloadFinished: // 章节下载完成
                {
                    [weakSelf setCollectionCellDownloadStateWithChapter_id:chapter_id downloadState:WXYZ_ProductionDownloadStateDownloaded];
                }
                    break;
                case WXYZ_DownloadStateChapterDownloadFail:     // 下载失败
                {
                    [weakSelf setCollectionCellDownloadStateWithChapter_id:chapter_id downloadState:WXYZ_ProductionDownloadStateFail];
                }
                    break;
                case WXYZ_DownloadStateChapterDownloadStart:    // 开始下载
                {
                    [weakSelf setCollectionCellDownloadStateWithChapter_id:chapter_id downloadState:WXYZ_ProductionDownloadStateDownloading];
                }
                    break;
                default:
                    break;
            }
            
            [weakSelf reloadToolBar];
        });
    };
    
    self.audioDownloadManager.downloadMissionStateChangeBlock = ^(WXYZ_DownloadMissionState state, NSInteger production_id, NSArray * _Nonnull chapter_ids) {
        
        SS(strongSelf)
        switch (state) {
                // 任务开始
            case WXYZ_DownloadStateMissionStart:
            {
                [weakSelf.downloadIndicatorView stopAnimating];
                [weakSelf.downloadButton setTitle:@"立即下载" forState:UIControlStateNormal];
                
                for (NSString *t_chapter_id in chapter_ids) {
                    [weakSelf setCollectionCellDownloadStateWithChapter_id:[t_chapter_id integerValue] downloadState:WXYZ_ProductionDownloadStateDownloading];
                }
            }
                break;
                // 任务失败
            case WXYZ_DownloadStateMissionFail:
            {
                [weakSelf.downloadIndicatorView stopAnimating];
                [weakSelf.downloadButton setTitle:@"立即下载" forState:UIControlStateNormal];
                for (NSString *t_chapter_id in chapter_ids) {
                    [weakSelf setCollectionCellDownloadStateWithChapter_id:[t_chapter_id integerValue] downloadState:WXYZ_ProductionDownloadStateNormal];
                }
            }
                break;
            case WXYZ_DownloadStateMissionShouldPay:
            {
                [weakSelf.downloadIndicatorView stopAnimating];
                [weakSelf.downloadButton setTitle:@"立即下载" forState:UIControlStateNormal];
                if (!weakSelf.payBarShowing) {
                    weakSelf.payBarShowing = YES;
                    
                    WXYZ_ProductionChapterModel *chapterModel = [[WXYZ_ProductionChapterModel alloc] init];
                    chapterModel.production_id = production_id;
                    chapterModel.chapter_ids = chapter_ids;
                    
                    WXYZ_ChapterBottomPayBar *payBar = [[WXYZ_ChapterBottomPayBar alloc] initWithChapterModel:chapterModel barType:WXYZ_BottomPayBarTypeDownload productionType:WXYZ_ProductionTypeAudio];
                    
                    payBar.paySuccessChaptersBlock = ^(NSArray<NSString *> * _Nonnull success_chapter_ids) {
                        [strongSelf downloadClick];
                    };
                    payBar.payFailChaptersBlock = ^(NSArray<NSString *> * _Nonnull fail_chapter_ids) {
                        
                        for (NSString *t_chapter_id in fail_chapter_ids) {
                            [weakSelf setCollectionCellDownloadStateWithChapter_id:[t_chapter_id integerValue] downloadState:WXYZ_ProductionDownloadStateNormal];
                        }
                        
                        [weakSelf reloadToolBar];
                        
                        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"购买失败"];
                    };
                    payBar.payCancleChapterBlock = ^(NSArray<NSString *> * _Nonnull fail_chapter_ids) {
                        
                        for (NSString *t_chapter_id in fail_chapter_ids) {
                            [weakSelf setCollectionCellDownloadStateWithChapter_id:[t_chapter_id integerValue] downloadState:WXYZ_ProductionDownloadStateNormal];
                        }
                        
                        [weakSelf reloadToolBar];
                    };
                    SS(strongSelf)
                    payBar.bottomPayBarHiddenBlock = ^{
                        strongSelf.payBarShowing = NO;
                    };
                    [payBar showBottomPayBar];
                }
            }
                break;
            case WXYZ_DownloadStateMissionFinished:
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"下载完成"];
                weakSelf.headerTitleLabel.text = [NSString stringWithFormat:@"已下载%zd章", [[WXYZ_AudioDownloadManager sharedManager] getDownloadChapterCountWithProduction_id:weakSelf.audioModel.production_id]];
                break;
                
            default:
                break;
        }
        weakSelf.downloadButton.userInteractionEnabled = YES;
    };
}

- (void)downloadClick
{
    self.downloadButton.userInteractionEnabled = NO;
    
    NSMutableArray *chapter_ids = [NSMutableArray array];
    for (NSString *t_chapter_id in self.selectSourceDictionary.allKeys) {
        if ([[self.selectSourceDictionary objectForKey:t_chapter_id] integerValue] == WXYZ_ProductionDownloadStateSelected) {
            [chapter_ids addObject:t_chapter_id];
        }
    }
    
    [self.downloadIndicatorView startAnimating];
    [self.downloadButton setTitle:@"" forState:UIControlStateNormal];
    
    [self reloadToolBar];
    
    [self.audioDownloadManager downloadChaptersWithProductionModel:self.audioModel production_id:self.audioModel.production_id chapter_ids:chapter_ids];
}

- (void)reloadToolBar
{
    NSInteger normalIndex = 0;
    
    NSInteger selectIndex = 0;
    
    NSInteger downloadedIndex = 0;
    
    
    for (NSString *t_key in self.selectSourceDictionary) {
        switch ([[self.selectSourceDictionary objectForKey:t_key] integerValue]) {
            case WXYZ_ProductionDownloadStateNormal:
                normalIndex ++;
                break;
            case WXYZ_ProductionDownloadStateDownloaded:
                downloadedIndex ++;
                break;
            case WXYZ_ProductionDownloadStateSelected:
                selectIndex ++;
                break;
                
            default:
                break;
        }
    }
    
    if (selectIndex > 0) {
        memoryBarView.text = [NSString stringWithFormat:@"已选择%@条声音，占用%@/可用空间%@", [WXYZ_UtilsHelper formatStringWithInteger:selectIndex], [WXYZ_UtilsHelper convertFileSize:self.totalMemorySize * 1024], [WXYZ_UtilsHelper getRemainingMemorySpace]];
    } else {
        memoryBarView.text = [NSString stringWithFormat:@"可用空间%@", [WXYZ_UtilsHelper getRemainingMemorySpace]];
    }
    
    if (downloadedIndex == self.dataSourceArray.count) {
        selectAllButton.hidden = YES;
        
        self.downloadButton.enabled = NO;
        self.downloadButton.selected = NO;
        self.downloadButton.backgroundColor = [UIColor whiteColor];
        [self.downloadButton setTitle:@"已全部下载" forState:UIControlStateNormal];
        [self.downloadButton setTitleColor:kGrayTextLightColor forState:UIControlStateNormal];
        [self.downloadButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SCREEN_WIDTH);
        }];
        return;
    }
    
    self.downloadButton.enabled = NO;
    self.downloadButton.backgroundColor = kGrayTextLightColor;
    [self.downloadButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH / 3);
    }];
    
    selectAllButton.selected = NO;
    selectAllButton.enabled = YES;
    selectAllButton.hidden = NO;
    selectAllButton.buttonTitle = @"全选";
    selectAllButton.buttonImageName = @"audio_download_unselect";
    
    if (selectIndex > 0 && normalIndex == 0) { // 有选中的文件并且没有未选中的文件
        
        self.downloadButton.enabled = YES;
        self.downloadButton.backgroundColor = kMainColor;
        
        selectAllButton.selected = YES;
        selectAllButton.buttonTitle = @"取消全选";
        selectAllButton.buttonImageName = @"audio_download_select";

    } else if (normalIndex > 0 && selectIndex > 0) { // 有未选中的文件
        self.downloadButton.enabled = YES;
        self.downloadButton.backgroundColor = kMainColor;
    }
}

- (void)setCollectionCellDownloadStateWithChapter_id:(NSInteger)chapter_id downloadState:(WXYZ_ProductionDownloadState)downloadState
{
    WXYZ_AudioDownloadTableViewCell *cell = (WXYZ_AudioDownloadTableViewCell *)[self.mainTableView cellForRowAtIndexPath:(NSIndexPath *)[self.cellIndexDictionary objectForKey:[WXYZ_UtilsHelper formatStringWithInteger:chapter_id]]];
    cell.cellDownloadState = downloadState;
    [self.selectSourceDictionary setObject:[WXYZ_UtilsHelper formatStringWithInteger:downloadState] forKey:[WXYZ_UtilsHelper formatStringWithInteger:chapter_id]];
}

- (void)netRequest
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Audio_Catalog parameters:@{@"audio_id":[WXYZ_UtilsHelper formatStringWithInteger:self.production_id]} model:WXYZ_ProductionModel.class success:^(BOOL isSuccess, WXYZ_ProductionModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            if (t_model.chapter_list.count > 0) {
                weakSelf.audioModel = t_model;
                weakSelf.dataSourceArray = [NSMutableArray arrayWithArray:t_model.chapter_list];
                [weakSelf resetSelectSourceDicWithDataSourceArray:t_model.chapter_list productionType:WXYZ_ProductionTypeAudio];
            }
            
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        }
        
        [weakSelf.mainTableView reloadData];
        [weakSelf reloadToolBar];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf.mainTableView reloadData];
    }];
}

@end

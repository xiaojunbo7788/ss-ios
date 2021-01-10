//
//  WXYZ_ComicReaderDownloadViewController.m
//  WXReader
//
//  Created by Andrew on 2019/6/8.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicReaderDownloadViewController.h"

#import "WXYZ_ComicReaderDownloadCollectionViewCell.h"
#import "WXYZ_ChapterBottomPayBar.h"

#import "WXYZ_ComicReaderDownloadModel.h"

#import "WXYZ_ComicDownloadManager.h"
#import "WXYZ_ProductionReadRecordManager.h"
#import "WXZY_CommonPayAlertView.h"
#import "WXYZ_MemberViewController.h"
#import "WXYZ_ComicOptionsView.h"
#import "WXYZ_ShareManager.h"
@interface WXYZ_ComicReaderDownloadViewController () <UICollectionViewDelegate, UICollectionViewDataSource,WXYZ_ComicOptionsViewDelegate>
{
    UIView *toolBarView;
    YYLabel *toolBarLeftLabel;
    UILabel *toolBarRightLabel;
    
    UIButton *selectAllButton;
}

@property (nonatomic, strong) WXYZ_ComicDownloadManager *comicDownloadManager;

@property (nonatomic, strong) UIButton *downloadButton;

@property (nonatomic, strong) UIActivityIndicatorView *downloadIndicatorView;

@property (nonatomic, strong) WXYZ_ComicOptionsView *optionsView;

@property (nonatomic, assign) BOOL payBarShowing;

@end

@implementation WXYZ_ComicReaderDownloadViewController

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
    [self setNavigationBarTitle:@"选择章节"];
    
    self.view.backgroundColor = kGrayViewColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netRequest) name:Notification_Login_Success object:nil];
}

- (void)createSubviews
{
    WXYZ_CustomButton *sortButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - kHalfMargin - 60, PUB_NAVBAR_HEIGHT - 30 - kQuarterMargin, 60, 30) buttonTitle:@"正序" buttonImageName:@"comic_positive_order" buttonIndicator:WXYZ_CustomButtonIndicatorImageRightBothRight];
    sortButton.selected = NO;
    sortButton.buttonImageScale = 0.4;
    sortButton.buttonTitleFont = kFont11;
    sortButton.graphicDistance = 5;
    sortButton.buttonTitleColor = kGrayTextColor;
    [sortButton addTarget:self action:@selector(sortClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:sortButton];
    
    self.mainCollectionViewFlowLayout.minimumLineSpacing = kHalfMargin;
    self.mainCollectionViewFlowLayout.minimumInteritemSpacing = kHalfMargin;
    self.mainCollectionViewFlowLayout.itemSize = CGSizeMake((SCREEN_WIDTH - 5 * kHalfMargin) / 4, 40);
    self.mainCollectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(kHalfMargin, kHalfMargin, kHalfMargin, kHalfMargin);
    
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.dataSource = self;
    self.mainCollectionView.alwaysBounceVertical = YES;
    [self.mainCollectionView registerClass:[WXYZ_ComicReaderDownloadCollectionViewCell class] forCellWithReuseIdentifier:@"WXYZ_ComicReaderDownloadCollectionViewCell"];
    [self.view addSubview:self.mainCollectionView];
    
    [self.mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_height).with.offset(- PUB_NAVBAR_HEIGHT - PUB_TABBAR_HEIGHT - 20);
    }];
    
    toolBarView = [[UIView alloc] init];
    toolBarView.backgroundColor = kWhiteColor;
    [self.view addSubview:toolBarView];
    
    [toolBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(self.view.mas_bottom);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT + 20);
    }];
    
    toolBarLeftLabel = [[YYLabel alloc] init];
    toolBarLeftLabel.textColor = kGrayTextColor;
    toolBarLeftLabel.textContainerInset = UIEdgeInsetsMake(3, kHalfMargin, 0, 0);
    toolBarLeftLabel.textAlignment = NSTextAlignmentLeft;
    toolBarLeftLabel.font = kFont10;
    toolBarLeftLabel.backgroundColor = kGrayDeepViewColor;
    [toolBarView addSubview:toolBarLeftLabel];
    
    [toolBarLeftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(toolBarView.mas_width);
        make.height.mas_equalTo(20);
    }];
    
    toolBarRightLabel = [[UILabel alloc] init];
    toolBarRightLabel.text = @"已选0话";
    toolBarRightLabel.textColor = kGrayTextColor;
    toolBarRightLabel.textAlignment = NSTextAlignmentRight;
    toolBarRightLabel.font = kFont10;
    toolBarRightLabel.backgroundColor = [UIColor clearColor];
    [toolBarView addSubview:toolBarRightLabel];
    
    [toolBarRightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(toolBarView.mas_right).with.offset(- kHalfMargin);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(toolBarView.mas_width).with.multipliedBy(0.5);
        make.height.mas_equalTo(20);
    }];
    
    
    
    WXYZ_ComicOptionsView *optionsView = [[WXYZ_ComicOptionsView alloc] init];
    optionsView.delegate = self;
    [toolBarView addSubview:optionsView];
    self.optionsView = optionsView;
    [optionsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(toolBarView.mas_left);
        make.top.mas_equalTo(toolBarRightLabel.mas_bottom);
        make.width.mas_equalTo(SCREEN_WIDTH/2);
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT - PUB_TABBAR_OFFSET);
    }];
    
    [optionsView refreshStateView];
    
    
    selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectAllButton setTitle:@"全选" forState:UIControlStateNormal];
    [selectAllButton setTitleColor:kBlackColor forState:UIControlStateNormal];
    [selectAllButton.titleLabel setFont:kMainFont];
    [selectAllButton addTarget:self action:@selector(checkallClick:) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:selectAllButton];
    
    [selectAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.optionsView.mas_right);
        make.top.mas_equalTo(toolBarRightLabel.mas_bottom);
        make.width.mas_equalTo(SCREEN_WIDTH / 4);
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT - PUB_TABBAR_OFFSET);
    }];
    
    self.downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.downloadButton.enabled = NO;
    [self.downloadButton setTitle:@"下载" forState:UIControlStateNormal];
    [self.downloadButton setTitleColor:kGrayTextLightColor forState:UIControlStateNormal];
    [self.downloadButton.titleLabel setFont:kMainFont];
    [self.downloadButton addTarget:self action:@selector(downloadClick) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:self.downloadButton];
    
    [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(selectAllButton.mas_right);
        make.top.mas_equalTo(toolBarRightLabel.mas_bottom);
        make.right.mas_equalTo(toolBarView.mas_right);
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT - PUB_TABBAR_OFFSET);
    }];
    
    self.downloadIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    self.downloadIndicatorView.hidesWhenStopped = YES;
    [toolBarView addSubview:self.downloadIndicatorView];
    
    [self.downloadIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.downloadButton.mas_centerX);
        make.centerY.mas_equalTo(self.downloadButton.mas_centerY);
        make.width.height.mas_equalTo(self.downloadButton.mas_height);
    }];
}



- (void)changeClearData {
    WS(weakSelf);
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
           if (is_iPad) {
               UIPopoverPresentationController *popover = actionSheet.popoverPresentationController;
               
               if (popover) {
                   popover.sourceView = self.view;
                   popover.sourceRect = self.view.bounds;
                   popover.permittedArrowDirections = UIPopoverArrowDirectionDown;
               }
           }
           [actionSheet addAction:[UIAlertAction actionWithTitle:@"标清" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
               if (!WXYZ_UserInfoManager.isLogin) {
                   [WXYZ_LoginViewController presentLoginView];
                   return;
               }
               [[WXYZ_UserInfoManager shareInstance] setClearData:0];
               [weakSelf.optionsView refreshStateView];
           }]];

           [actionSheet addAction:[UIAlertAction actionWithTitle:@"高清" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
               if (!WXYZ_UserInfoManager.isLogin) {
                   [WXYZ_LoginViewController presentLoginView];
                   return;
               }
               if ([WXYZ_UserInfoManager shareInstance].isVip) {
                   [[WXYZ_UserInfoManager shareInstance] setClearData:1];
               } else {
                   [weakSelf showPayAlerView];
               }
               [weakSelf.optionsView refreshStateView];
           }]];
    
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"超清" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if (!WXYZ_UserInfoManager.isLogin) {
                    [WXYZ_LoginViewController presentLoginView];
                    return;
                }
                if ([WXYZ_UserInfoManager shareInstance].isVip) {
                    [[WXYZ_UserInfoManager shareInstance] setClearData:2];
                } else {
                    [weakSelf showPayAlerView];
                }
                [weakSelf.optionsView refreshStateView];
            }]];

           [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

           [[WXYZ_ViewHelper getWindowRootController] presentViewController:actionSheet animated:YES completion:nil];
}

- (void)changeLineData {
    WS(weakSelf);
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
           if (is_iPad) {
               UIPopoverPresentationController *popover = actionSheet.popoverPresentationController;
               
               if (popover) {
                   popover.sourceView = self.view;
                   popover.sourceRect = self.view.bounds;
                   popover.permittedArrowDirections = UIPopoverArrowDirectionDown;
               }
           }
           [actionSheet addAction:[UIAlertAction actionWithTitle:@"普通线路" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
               if (!WXYZ_UserInfoManager.isLogin) {
                   [WXYZ_LoginViewController presentLoginView];
                   return;
               }
               [[WXYZ_UserInfoManager shareInstance] setLineData:0];
               [weakSelf.optionsView refreshStateView];
           }]];

           [actionSheet addAction:[UIAlertAction actionWithTitle:@"VIP线路" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
               if (!WXYZ_UserInfoManager.isLogin) {
                   [WXYZ_LoginViewController presentLoginView];
                   return;
               }
               if ([WXYZ_UserInfoManager shareInstance].isVip) {
                   [[WXYZ_UserInfoManager shareInstance] setLineData:1];
               } else {
                   [weakSelf showPayAlerView];
               }
               [weakSelf.optionsView refreshStateView];
           }]];

           [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

           [[WXYZ_ViewHelper getWindowRootController] presentViewController:actionSheet animated:YES completion:nil];
}

- (void)showPayAlerView {
    //TODO:弹窗
    WXZY_CommonPayAlertView *payAlertView = [[WXZY_CommonPayAlertView alloc]initWithFrame:CGRectZero];
    payAlertView.isShowRecharge  = false;
    payAlertView.msg = @"升级VIP后即可享受高清漫画，还有提供国内高速线路！";
    [payAlertView showInView:[UIApplication sharedApplication].keyWindow];
    WS(weakSelf)
    payAlertView.onClick = ^(int type) {
        if (type == 1) {
            //分享
            [[WXYZ_ShareManager sharedManager] shareApplicationInController:weakSelf shareState:WXYZ_ShareStateAll];
        } else if (type == 2) {
            //vip
            WXYZ_MemberViewController *vc = [[WXYZ_MemberViewController alloc] init];
            vc.productionType = weakSelf.productionType;
            WXYZ_NavigationController *t_nav = [[WXYZ_NavigationController alloc] initWithRootViewController:vc];
            [[WXYZ_ViewHelper getWindowRootController] presentViewController:t_nav animated:YES completion:nil];
            [kMainWindow sendSubviewToBack:weakSelf.view];
        }
    };
                   
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionChapterModel *chapterModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    static NSString *cellIdentifier = @"WXYZ_ComicReaderDownloadCollectionViewCell";
    WXYZ_ComicReaderDownloadCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.chapterModel = chapterModel;
    cell.cellDownloadState = [[self.selectSourceDictionary objectForKey:[WXYZ_UtilsHelper formatStringWithInteger:chapterModel.chapter_id]] integerValue];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionChapterModel *chapterModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    WXYZ_ComicReaderDownloadCollectionViewCell *cell = (WXYZ_ComicReaderDownloadCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

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

#pragma mark - 点击事件
- (void)sortClick:(WXYZ_CustomButton *)sender
{
    if (sender.selected) {
        sender.buttonImageName = @"comic_positive_order";
        sender.buttonTitle = @"正序";
    } else {
        sender.buttonImageName = @"comic_reverse_order";
        sender.buttonTitle = @"倒序";
    }
    
    sender.selected = !sender.selected;
    
    self.dataSourceArray = [[[self.dataSourceArray reverseObjectEnumerator] allObjects] mutableCopy];
    [self.mainCollectionView reloadData];
}

- (void)checkallClick:(UIButton *)sender
{
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

- (void)initDownloadManager
{
    WS(weakSelf)
    self.comicDownloadManager = [WXYZ_ComicDownloadManager sharedManager];
    self.comicDownloadManager.downloadChapterStateChangeBlock = ^(WXYZ_DownloadChapterState state, NSInteger production_id, NSInteger chapter_id) {
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
    
    self.comicDownloadManager.downloadMissionStateChangeBlock = ^(WXYZ_DownloadMissionState state, NSInteger production_id, NSArray * _Nonnull chapter_ids) {
        
        switch (state) {
                
            // 任务开始
            case WXYZ_DownloadStateMissionStart:
            {
                [weakSelf.downloadIndicatorView stopAnimating];
                weakSelf.downloadButton.hidden = NO;
                
                for (NSString *t_chapter_id in chapter_ids) {
                    [weakSelf setCollectionCellDownloadStateWithChapter_id:[t_chapter_id integerValue] downloadState:WXYZ_ProductionDownloadStateDownloading];
                }
            }
                break;
            // 任务失败
            case WXYZ_DownloadStateMissionFail:
            {
                [weakSelf.downloadIndicatorView stopAnimating];
                weakSelf.downloadButton.hidden = NO;
                for (NSString *t_chapter_id in chapter_ids) {
                    [weakSelf setCollectionCellDownloadStateWithChapter_id:[t_chapter_id integerValue] downloadState:WXYZ_ProductionDownloadStateFail];
                }
            }
                break;
                
            // 需要支付
            case WXYZ_DownloadStateMissionShouldPay:
            {
                [weakSelf.downloadIndicatorView stopAnimating];
                weakSelf.downloadButton.hidden = NO;
                
                if (!weakSelf.payBarShowing) {
                    weakSelf.payBarShowing = YES;
                    
                    WXYZ_ProductionChapterModel *chapterModel = [[WXYZ_ProductionChapterModel alloc] init];
                    chapterModel.production_id = production_id;
                    chapterModel.chapter_ids = chapter_ids;
                    
                    WXYZ_ChapterBottomPayBar *payBar = [[WXYZ_ChapterBottomPayBar alloc] initWithChapterModel:chapterModel barType:WXYZ_BottomPayBarTypeDownload productionType:WXYZ_ProductionTypeComic];
                    
                    payBar.paySuccessChaptersBlock = ^(NSArray<NSString *> * _Nonnull success_chapter_ids) {
                        [weakSelf downloadClick];
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
    self.downloadButton.hidden = YES;
    
    [self reloadToolBar];
    
    [self.comicDownloadManager downloadChaptersWithProductionModel:self.comicModel production_id:self.comicModel.production_id chapter_ids:chapter_ids];
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
    
    toolBarRightLabel.text = [NSString stringWithFormat:@"已选%@话", [WXYZ_UtilsHelper formatStringWithInteger:selectIndex]];
    
    if (downloadedIndex == self.dataSourceArray.count) {
        toolBarRightLabel.text = @"";
        
        selectAllButton.enabled = NO;
        selectAllButton.selected = NO;
        [selectAllButton setTitle:@"已全部下载" forState:UIControlStateNormal];
        [selectAllButton setTitleColor:kGrayTextLightColor forState:UIControlStateNormal];
        [selectAllButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SCREEN_WIDTH/2);
        }];
        return;
    }
    
    self.downloadButton.enabled = NO;
    [self.downloadButton setTitleColor:kGrayTextLightColor forState:UIControlStateNormal];
    
    selectAllButton.enabled = YES;
    selectAllButton.selected = NO;
    [selectAllButton setTitle:@"全选" forState:UIControlStateNormal];
    [selectAllButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH / 4);
    }];
    
    
    if (selectIndex > 0 && normalIndex == 0) { // 有选中的文件并且没有未选中的文件
        
        self.downloadButton.enabled = YES;
        [self.downloadButton setTitleColor:kBlackColor forState:UIControlStateNormal];
        
        selectAllButton.selected = YES;
        [selectAllButton setTitle:@"取消全选" forState:UIControlStateNormal];
        [selectAllButton setTitleColor:kBlackColor forState:UIControlStateNormal];
    } else if (normalIndex > 0 && selectIndex > 0) { // 有未选中的文件
        
        self.downloadButton.enabled = YES;
        [self.downloadButton setTitleColor:kBlackColor forState:UIControlStateNormal];
    }
}

- (void)setCollectionCellDownloadStateWithChapter_id:(NSInteger)chapter_id downloadState:(WXYZ_ProductionDownloadState)downloadState
{
    WXYZ_ComicReaderDownloadCollectionViewCell *cell = (WXYZ_ComicReaderDownloadCollectionViewCell *)[self.mainCollectionView cellForItemAtIndexPath:(NSIndexPath *)[self.cellIndexDictionary objectForKey:[WXYZ_UtilsHelper formatStringWithInteger:chapter_id]]];
    cell.cellDownloadState = downloadState;
    [self.selectSourceDictionary setObject:[WXYZ_UtilsHelper formatStringWithInteger:downloadState] forKey:[WXYZ_UtilsHelper formatStringWithInteger:chapter_id]];
}

- (void)netRequest
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POSTQuick:Comic_DownloadOption parameters:@{@"comic_id":[WXYZ_UtilsHelper formatStringWithInteger:self.comicModel.production_id]} model:WXYZ_ComicReaderDownloadModel.class success:^(BOOL isSuccess, WXYZ_ComicReaderDownloadModel *_Nullable t_model, BOOL isCache, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            
            toolBarLeftLabel.text = t_model.display_label?:@"";
            if (t_model.down_list.count > 0) {
                weakSelf.dataSourceArray = [NSMutableArray arrayWithArray:t_model.down_list];
                
                [weakSelf resetSelectSourceDicWithDataSourceArray:t_model.down_list productionType:WXYZ_ProductionTypeComic];
            }
            
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        }
        
        [weakSelf.mainCollectionView reloadData];
        [weakSelf reloadToolBar];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf.mainCollectionView reloadData];
    }];
}

@end

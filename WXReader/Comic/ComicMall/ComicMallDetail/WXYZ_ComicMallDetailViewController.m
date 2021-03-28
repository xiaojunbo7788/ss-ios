//
//  WXYZ_ComicMallDetailViewController.m
//  WXReader
//
//  Created by Andrew on 2019/5/28.
//  Copyright © 2019 Andrew. All rights reserved.
//  漫画详情
//

#import "WXYZ_ComicReaderViewController2.h"
#import "WXYZ_ComicReaderDownloadViewController.h"
#import "WXYZ_TaskViewController.h"

#import "WXYZ_ComicMallDetailHeaderView.h"
#import "WXYZ_ComicMallDetailFooterView.h"
#import "WXYZ_CompositeEmbeddedTableView.h"

#import "WXYZ_ComicMallDetailModel.h"
#import "WXYZ_ComicDirectoryListModel.h"
#import "WXZY_CommonPayAlertView.h"
#import "WXYZ_ProductionReadRecordManager.h"
#import "WXYZ_ShareManager.h"
#import "WXYZ_DownloadHelper.h"
#import "WXYZ_ComicOptionsView.h"
#import "WXYZ_MemberViewController.h"
@interface WXYZ_ComicMallDetailViewController () <UITableViewDelegate, UITableViewDataSource,WXYZ_ComicOptionsViewDelegate>
{
    UIButton *menuButton;
    UILabel *menuTitle;
}

@property (nonatomic, assign) BOOL canScroll;

// 是否到顶 到底
@property (nonatomic, assign) BOOL isAutoScroll;

@property (nonatomic, strong) UIView *bottomMenuBar;

@property (nonatomic, strong) UIButton *shareButton;

@property (nonatomic, strong) UIButton *downloadButton;

@property (nonatomic, strong) WXYZ_ComicMallDetailHeaderView *headerView;

@property (nonatomic, strong) WXYZ_ComicMallDetailFooterView *footerView;

@property (nonatomic, strong) WXYZ_ComicMallDetailModel *comicDetailModel;

@property (nonatomic, strong) WXYZ_CompositeEmbeddedTableView *mallTableView;

@property (nonatomic, strong) WXYZ_ComicOptionsView *optionsView;

@end

@implementation WXYZ_ComicMallDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
    [self netRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Hidden_Tabbar object:nil];
    
    [self setStatusBarLightContentStyle];
    
    [self reloadToolBarState];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Hidden_Tabbar object:nil];
}

- (void)initialize
{
    [self hiddenSeparator];
    self.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationBar.navTitleLabel.alpha = 0;
    self.navigationBar.navTitleLabel.textColor = kWhiteColor;
    [self.navigationBar setLightLeftButton];
    
#if WX_W_Share_Mode || WX_Q_Share_Mode
    self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.shareButton.adjustsImageWhenHighlighted = NO;
    self.shareButton.tintColor = kWhiteColor;
    self.shareButton.hidden = YES;
    [self.shareButton setImage:[[UIImage imageNamed:@"comic_share"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.shareButton setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 3, 3)];
    [self.shareButton addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:self.shareButton];
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(self.navigationBar.navTitleLabel.mas_centerY);
        make.width.height.mas_equalTo(30);
    }];
    
#endif
    
#if WX_Download_Mode
    self.downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.downloadButton.adjustsImageWhenHighlighted = NO;
    self.downloadButton.tintColor = kWhiteColor;
    self.downloadButton.hidden = YES;
    [self.downloadButton setImage:[[UIImage imageNamed:@"comic_download"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.downloadButton setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    [self.downloadButton addTarget:self action:@selector(downloadButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:self.downloadButton];
    
    [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
#if WX_W_Share_Mode || WX_Q_Share_Mode
        make.right.mas_equalTo(self.shareButton.mas_left).with.offset(- kHalfMargin);
#else
        make.right.mas_equalTo(self.view.mas_right).with.offset(- kMargin);
#endif
        make.centerY.mas_equalTo(self.navigationBar.navTitleLabel.mas_centerY);
        make.width.height.mas_equalTo(30);
    }];
#endif
    
    self.canScroll = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeScrollStatus:) name:Notification_Can_Leave_Top object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollMove:) name:Notification_Directory_Move object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(catalogRequest) name:Notification_Production_Pay_Success object:nil];
    
}

- (void)createSubviews
{
    self.mallTableView = [[WXYZ_CompositeEmbeddedTableView alloc] initWithFrame:CGRectMake(1, 1, 1, 1) style:UITableViewStylePlain];
    self.mallTableView.delegate = self;
    self.mallTableView.dataSource = self;
    [self.mallTableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addSubview:self.mallTableView];
    
    [self.mallTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_height);
    }];
    
    self.headerView = [[WXYZ_ComicMallDetailHeaderView alloc] init];
    self.headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, Comic_Detail_HeaderView_Height);
    [self.mallTableView setTableHeaderView:self.headerView];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(Comic_Detail_HeaderView_Height);
    }];
    
    WS(weakSelf)
    self.footerView = [[WXYZ_ComicMallDetailFooterView alloc] init];
    self.footerView.view.hidden = YES;
    self.footerView.view.frame = CGRectMake(0, Comic_Detail_HeaderView_Height, SCREEN_WIDTH, SCREEN_HEIGHT - (Comic_Detail_HeaderView_Height));
    self.footerView.pushToComicDetailBlock = ^(NSInteger production_id) {
        WXYZ_ComicMallDetailViewController *vc = [[WXYZ_ComicMallDetailViewController alloc] init];
        vc.comic_id = production_id;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    [self.mallTableView setTableFooterView:self.footerView.view];
    [self addChildViewController:self.footerView];
    
    self.bottomMenuBar = [[UIView alloc] init];
    self.bottomMenuBar.hidden = YES;
    self.bottomMenuBar.backgroundColor = kGrayViewColor;
    [self.view addSubview:self.bottomMenuBar];
    
    [self.bottomMenuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(self.view.mas_bottom);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT);
    }];
    
    menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.backgroundColor = kMainColor;
    [menuButton setTitle:@"开始阅读" forState:UIControlStateNormal];
    [menuButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [menuButton.titleLabel setFont:[UIFont boldSystemFontOfSize:kFontSize13]];
    [menuButton addTarget:self action:@selector(startReading) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomMenuBar addSubview:menuButton];
    
    [menuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bottomMenuBar.mas_right);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT - PUB_TABBAR_OFFSET);
        make.width.mas_equalTo(120);
    }];
    
//    menuTitle = [[UILabel alloc] init];
//    menuTitle.textColor = kBlackColor;
//    menuTitle.textAlignment = NSTextAlignmentLeft;
//    menuTitle.font = kFont13;
//    [self.bottomMenuBar addSubview:menuTitle];
//
//    [menuTitle mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(kMargin);
//        make.top.mas_equalTo(0);
//        make.right.mas_equalTo(menuButton.mas_left);
//        make.height.mas_equalTo(PUB_TABBAR_HEIGHT - PUB_TABBAR_OFFSET);
//    }];
    
    WXYZ_ComicOptionsView *optionsView = [[WXYZ_ComicOptionsView alloc] init];
    optionsView.delegate = self;
    [self.bottomMenuBar addSubview:optionsView];
    self.optionsView = optionsView;
    [optionsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bottomMenuBar.mas_left);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(menuButton.mas_left);
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT - PUB_TABBAR_OFFSET);
    }];
    
    [optionsView refreshStateView];
    
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

- (void)scrollMove:(NSNotification *)noti
{
    self.isAutoScroll = YES;
    if ([noti.object isEqualToString:@"top"]) {
        self.footerView.canScroll = NO;
        self.canScroll = YES;
        self.mallTableView.contentOffset = CGPointMake(0, 0);
    } else {
        self.footerView.canScroll = YES;
        self.canScroll = NO;
        self.mallTableView.contentOffset = CGPointMake(0, Comic_Detail_HeaderView_Height - PUB_NAVBAR_HEIGHT);
    }
}

- (void)changeScrollStatus:(NSNotification *)noti
{
    self.canScroll = [noti.object boolValue];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isAutoScroll = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isAutoScroll) {
        return;
    }
    if (scrollView.contentOffset.y <= Comic_Detail_HeaderView_Height - PUB_NAVBAR_HEIGHT) {
        if (self.canScroll) {
            self.canScroll = YES;
            self.footerView.canScroll = NO;
            if (scrollView.contentOffset.y <= 0) {
                scrollView.contentOffset = CGPointMake(0, 0);
            }
        } else {
            scrollView.contentOffset = CGPointMake(0, Comic_Detail_HeaderView_Height - PUB_NAVBAR_HEIGHT);
        }
        
    } else {
        self.canScroll = NO;
        scrollView.contentOffset = CGPointMake(0, Comic_Detail_HeaderView_Height - PUB_NAVBAR_HEIGHT);
        self.footerView.canScroll = YES;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint point = [((NSValue *)[self.mallTableView valueForKey:@"contentOffset"]) CGPointValue];
        if (self.canScroll) {
            self.footerView.contentOffSetY = point.y;
        } else {
            self.footerView.contentOffSetY = Comic_Detail_HeaderView_Height - PUB_NAVBAR_HEIGHT;
        }
        
        [self changeHeaderViewAlpha:point.y];
    }
}

- (void)changeHeaderViewAlpha:(CGFloat)contentOffsetY
{
    if (contentOffsetY >= 120) {
        contentOffsetY = 120;
    }
    
    if (contentOffsetY <= 0) {
        contentOffsetY = 0;
    }
    
    CGFloat viewAlpha = (120 - contentOffsetY) / 120;
    
    self.headerView.headerViewAlpha = viewAlpha;
    
    self.navigationBar.navTitleLabel.alpha = 1 - viewAlpha;
}

#pragma mark - 点击事件
#if WX_Download_Mode
- (void)downloadButtonClick
{
    if (self.comicDetailModel.productionModel.chapter_list.count == 0) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"章节正在更新中"];
        return;
    }
    WXYZ_ComicReaderDownloadViewController *vc = [[WXYZ_ComicReaderDownloadViewController alloc] init];
    vc.comicModel = self.comicDetailModel.productionModel;
    [self.navigationController pushViewController:vc animated:YES];
}
#endif

- (void)shareButtonClick:(UIButton *)sender
{
    sender.enabled = NO;
    NSInteger chapter_id = [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] getReadingRecordChapter_idWithProduction_id:self.comic_id];
    [[WXYZ_ShareManager sharedManager] shareProductionWithChapter_id:chapter_id controller:[WXYZ_ViewHelper getWindowRootController] type:WXYZ_ShareProductionComic shareState:WXYZ_ShareStateAll production_id:self.comic_id complete:^{
        sender.enabled = YES;
    }];
}

//TODO:开始阅读
- (void)startReading
{
    if (self.comicDetailModel.productionModel.chapter_list.count == 0) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"章节正在更新中"];
        return;
    }
    
    [WXYZ_TaskViewController taskReadRequestWithProduction_id:self.comic_id];
    
    WXYZ_ComicReaderViewController2 *vc = [[WXYZ_ComicReaderViewController2 alloc] init];
    vc.comicProductionModel = self.comicDetailModel.productionModel;
    vc.chapter_id = [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] getReadingRecordChapter_idWithProduction_id:self.comic_id];
    if (vc.chapter_id == 0) {// 如果没有阅读记录默认阅读第一章
        WXYZ_ProductionChapterModel *t_model = self.comicDetailModel.productionModel.chapter_list.firstObject;
        if ([t_model.display_order isEqualToString:@"0"]) {// 判断一下目录的
            vc.chapter_id = t_model.chapter_id;
        } else {
            vc.chapter_id = self.comicDetailModel.productionModel.chapter_list.lastObject.chapter_id;
        }
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)reloadToolBarState
{
     if ([[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] productionHasReadedWithProduction_id:self.comicDetailModel.productionModel.production_id]) {
//         menuTitle.text = [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] getReadingRecordChapterTitleWithProduction_id:self.comicDetailModel.productionModel.production_id]?:@"";
         [menuButton setTitle:@"继续阅读" forState:UIControlStateNormal];
     } else {
         if (self.comicDetailModel.productionModel.chapter_list.count > 0) {
             WXYZ_ProductionChapterModel *t_chapterList = [self.comicDetailModel.productionModel.chapter_list objectOrNilAtIndex:0];
//             menuTitle.text = t_chapterList.chapter_title?:@"";
         } else {
//             menuTitle.text = self.comicDetailModel.productionModel.name?:@"";
         }
         [menuButton setTitle:@"开始阅读" forState:UIControlStateNormal];
     }
    
    [self.headerView reloadHeaderView];
}

- (void)netRequest
{
    if ([WXYZ_NetworkReachabilityManager networkingStatus] == NO) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"当前无网络连接"];
        return;
    }
    //TODO:漫画详情
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Comic_Detail parameters:@{@"comic_id":[WXYZ_UtilsHelper formatStringWithInteger:self.comic_id]} model:WXYZ_ComicMallDetailModel.class success:^(BOOL isSuccess, WXYZ_ComicMallDetailModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            [weakSelf.navigationBar setNavigationBarTitle:t_model.productionModel.name?:@""];
            weakSelf.comicDetailModel = t_model;
        }
        weakSelf.bottomMenuBar.hidden = NO;
        weakSelf.footerView.view.hidden = NO;
        weakSelf.downloadButton.hidden = NO;
        weakSelf.shareButton.hidden = NO;
        [weakSelf catalogRequest];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf catalogRequest];
    }];
}

- (void)catalogRequest
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Comic_Catalog parameters:@{@"comic_id":[WXYZ_UtilsHelper formatStringWithInteger:self.comic_id]} model:WXYZ_ComicDirectoryListModel.class success:^(BOOL isSuccess, WXYZ_ComicDirectoryListModel *_Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            weakSelf.comicDetailModel.productionModel.chapter_list = t_model.chapter_list;
            weakSelf.headerView.comicProductionModel = weakSelf.comicDetailModel.productionModel;
            weakSelf.footerView.detailModel = weakSelf.comicDetailModel;
            
            // 存储作品信息
            [[WXYZ_DownloadHelper sharedManager] recordDownloadProductionWithProductionModel:weakSelf.comicDetailModel.productionModel productionType:WXYZ_ProductionTypeComic];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf reloadToolBarState];
            });
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg ?:@"获取失败"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.mallTableView reloadData];
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:@"获取失败"];
    }];
}

- (void)dealloc
{
    @try {
        [self.mallTableView removeObserver:self forKeyPath:@"contentOffset" context:NULL];
    } @catch (NSException *exception) {
        
    }
}

@end

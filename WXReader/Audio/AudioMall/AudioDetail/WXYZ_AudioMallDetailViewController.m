//
//  WXYZ_AudioMallDetailViewController.m
//  WXReader
//
//  Created by Andrew on 2020/3/12.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AudioMallDetailViewController.h"
#import "WXYZ_AudioDownloadViewController.h"

#import "WXYZ_AudioSoundDetailHeaderView.h"
#import "WXYZ_AudioSoundDetailFooterView.h"
#import "WXYZ_CompositeEmbeddedTableView.h"
#import "WXYZ_TouchAssistantView.h"

#import "WXYZ_AudioSoundDetailModel.h"

#import "WXYZ_ShareManager.h"
#import "UIView+BorderLine.h"

@interface WXYZ_AudioMallDetailViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UIView *gradientColorView;

@property (nonatomic, assign) BOOL canScroll;

@property (nonatomic, assign) CGFloat lastContentOffset;    // 滑动距离

@property (nonatomic, assign) BOOL slidingUp;  // 滑动方向

@property (nonatomic, strong) WXYZ_AudioSoundDetailModel *detailModel;

@property (nonatomic, strong) UIButton *shareButton;

@property (nonatomic, strong) UIButton *downloadButton;

@property (nonatomic, strong) WXYZ_CompositeEmbeddedTableView *mallTableView;

@property (nonatomic, strong) WXYZ_AudioSoundDetailHeaderView *headerView;

@property (nonatomic, strong) WXYZ_AudioSoundDetailFooterView *footerView;

@property (nonatomic, assign) CGFloat headerViewHeight;

@end

@implementation WXYZ_AudioMallDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
    [self netRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarLightContentStyle];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Hidden_Tabbar object:nil];
    if (self.headerView) {
        [self.headerView reloadCollectionButtonState];
    }
}

- (void)initialize
{
    [self hiddenSeparator];
    self.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationBar.navTitleLabel.alpha = 0;
    self.navigationBar.navTitleLabel.textColor = kWhiteColor;
    [self.navigationBar setLightLeftButton];
    
    self.canScroll = YES;
    self.headerViewHeight = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeScrollStatus:) name:Notification_Audio_Can_Leave_Top object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAudioDetail:) name:Notification_Audio_Check_Recommend object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netRequest) name:Notification_Recharge_Success object:nil];
}

- (void)createSubviews
{
#if WX_W_Share_Mode || WX_Q_Share_Mode
    self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.shareButton.adjustsImageWhenHighlighted = NO;
    self.shareButton.tintColor = kWhiteColor;
    self.shareButton.hidden = YES;
    [self.shareButton setImage:[[UIImage imageNamed:@"public_share"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.shareButton setImageEdgeInsets:UIEdgeInsetsMake(6, 12, 6, 0)];
    [self.shareButton addTarget:self action:@selector(shareButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:self.shareButton];
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.navigationBar.mas_right).with.offset(- kMargin);
        make.bottom.mas_equalTo(self.navigationBar.mas_bottom).with.offset(- 7);
        make.width.height.mas_equalTo(30);
    }];
#endif
    
#if WX_Download_Mode
    if ([WXYZ_UtilsHelper getAiReadSwitchState]) {
        self.downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.downloadButton.hidden = YES;
        self.downloadButton.adjustsImageWhenHighlighted = NO;
        self.downloadButton.tintColor = kWhiteColor;
        [self.downloadButton setImage:[[UIImage imageNamed:@"public_download"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.downloadButton setImageEdgeInsets:UIEdgeInsetsMake(6, 12, 6, 0)];
        [self.downloadButton addTarget:self action:@selector(downloadClick) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationBar addSubview:self.downloadButton];
        
        [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
#if WX_W_Share_Mode || WX_Q_Share_Mode
            make.right.mas_equalTo(self.shareButton.mas_left).with.offset(- kHalfMargin);
#else
            make.right.mas_equalTo(self.navigationBar.mas_right).with.offset(- kMargin);
#endif
            make.bottom.mas_equalTo(self.navigationBar.mas_bottom).with.offset(- 7);
            make.width.height.mas_equalTo(30);
        }];
    }
#endif
    
    self.navigationBar.touchEnabled = YES;
    
    self.gradientColorView = [[UIView alloc] init];
    self.gradientColorView.backgroundColor = kGrayViewColor;
    [self.view addSubview:self.gradientColorView];
    
    [self.gradientColorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    self.mallTableView = [[WXYZ_CompositeEmbeddedTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    self.mallTableView.delegate = self;
    self.mallTableView.dataSource = self;
    self.mallTableView.bounces = NO;
    [self.mallTableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addSubview:self.mallTableView];
    
    WS(weakSelf)
    self.headerView = [[WXYZ_AudioSoundDetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    self.headerView.changeIntroductionBlock = ^(CGFloat headerViewHeight, BOOL viewEnable) {
        weakSelf.headerViewHeight = headerViewHeight;
        weakSelf.mallTableView.scrollEnabled = viewEnable;
        // 重置headerView高度
        [UIView animateWithDuration:kAnimatedDurationFast animations:^{
            UIView *t_headerView = weakSelf.headerView;
            t_headerView.height = headerViewHeight;
            [weakSelf.mallTableView beginUpdates];
            [weakSelf.mallTableView setTableHeaderView:t_headerView];
            [weakSelf.mallTableView endUpdates];
        }];
    };
    
    [self.mallTableView setTableHeaderView:self.headerView];
    
    self.footerView = [[WXYZ_AudioSoundDetailFooterView alloc] init];
    self.footerView.view.hidden = YES;
    self.footerView.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.footerView.audio_id = self.audio_id;
    [self.footerView.view addRoundingCornersWithRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)];
    [self.mallTableView setTableFooterView:self.footerView.view];
    [self addChildViewController:self.footerView];
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
            self.headerView.contentOffSetY = point.y;
        } else {
            self.footerView.contentOffSetY = self.headerViewHeight - PUB_NAVBAR_HEIGHT;
            self.headerView.contentOffSetY = self.headerViewHeight - PUB_NAVBAR_HEIGHT;
        }
    }
}

- (void)changeScrollStatus:(NSNotification *)noti
{
    self.canScroll = [noti.object boolValue];
}

- (void)reloadAudioDetail:(NSNotification *)noti
{
    self.audio_id = [noti.object integerValue];
    self.footerView.audio_id = self.audio_id;
    [self netRequest];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.lastContentOffset = scrollView.contentOffset.y;    //判断上下滑动时
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y <= self.headerViewHeight - PUB_NAVBAR_HEIGHT) {
        
        if (self.canScroll) {
            self.canScroll = YES;
            self.footerView.canScroll = NO;
            if (scrollView.contentOffset.y <= 0) {
                scrollView.contentOffset = CGPointMake(0, 0);
            }
        } else {
            scrollView.contentOffset = CGPointMake(0, self.headerViewHeight - PUB_NAVBAR_HEIGHT);
        }
        
        if (scrollView.contentOffset.y < self.lastContentOffset ){
            self.slidingUp = NO;
        } else if (scrollView.contentOffset.y > self.lastContentOffset ){
            self.slidingUp = YES;
        }
        
    } else {
        self.canScroll = NO;
        scrollView.contentOffset = CGPointMake(0, self.headerViewHeight - PUB_NAVBAR_HEIGHT);
        self.footerView.canScroll = YES;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.footerView.canScroll || scrollView.contentOffset.y == 0) {
        return;
    }
    if (self.slidingUp) {
        if (fabs(scrollView.contentOffset.y - self.lastContentOffset) > self.headerViewHeight * 0.2) {
            [scrollView setContentOffset:CGPointMake(0, self.headerViewHeight - PUB_NAVBAR_HEIGHT) animated:YES];
        } else {
            [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    } else {
        if (fabs(scrollView.contentOffset.y - self.lastContentOffset) > self.headerViewHeight * 0.2) {
            [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        } else {
            [scrollView setContentOffset:CGPointMake(0, self.headerViewHeight - PUB_NAVBAR_HEIGHT) animated:YES];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.canScroll) {
        if (self.slidingUp) {
               if (fabs(scrollView.contentOffset.y - self.lastContentOffset) > self.headerViewHeight * 0.2) {
                   [scrollView setContentOffset:CGPointMake(0, self.headerViewHeight - PUB_NAVBAR_HEIGHT) animated:YES];
               } else {
                   [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
               }
           } else {
               if (fabs(scrollView.contentOffset.y - self.lastContentOffset) > self.headerViewHeight * 0.2) {
                   [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
               } else {
                   [scrollView setContentOffset:CGPointMake(0, self.headerViewHeight - PUB_NAVBAR_HEIGHT) animated:YES];
               }
           }
    }
}

- (void)shareButtonClick
{
    [[WXYZ_ShareManager sharedManager] shareProductionInController:self shareTitle:self.detailModel.audio.name shareDescribe:self.detailModel.audio.production_descirption shareImageURL:self.detailModel.audio.cover productionType:WXYZ_ShareProductionAudio production_id:self.detailModel.audio.production_id shareState:WXYZ_ShareStateAll];
}

- (void)downloadClick
{
    if (!self.audio_id || self.audio_id == 0) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"书籍获取失败"];
        return;
    }
    
    if (!self.footerView.directoryModel.chapter_list || self.footerView.directoryModel.chapter_list.count == 0) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"书籍获取失败"];
        return;
    }
    
    WXYZ_AudioDownloadViewController *vc = [[WXYZ_AudioDownloadViewController alloc] init];
    vc.production_id = self.audio_id;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)netRequest
{
    if ([WXYZ_NetworkReachabilityManager networkingStatus] == NO) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"当前无网络连接"];
        return;
    }
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Audio_Info parameters:@{@"audio_id":[WXYZ_UtilsHelper formatStringWithInteger:self.audio_id]} model:nil success:^(BOOL isSuccess, id  _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            NSMutableDictionary *t_dic = [t_model mutableCopy];
            NSMutableDictionary *t_data_dic = [[t_dic objectForKey:@"data"] mutableCopy];
            
            NSMutableDictionary *t_production_dic = [NSMutableDictionary dictionaryWithDictionary:[t_data_dic objectForKey:@"audio"]];
            NSMutableDictionary *t_ad_dic = [NSMutableDictionary dictionaryWithDictionary:[t_data_dic objectForKey:@"advert"]];
            
            [t_production_dic addEntriesFromDictionary:t_ad_dic];
            
            [t_data_dic setObject:t_production_dic forKey:@"audio"];
            
            WXYZ_AudioSoundDetailModel *t_model = [WXYZ_AudioSoundDetailModel modelWithDictionary:t_data_dic];
   
            weakSelf.headerView.audioModel = t_model.audio;
            weakSelf.detailModel = t_model;
            if (t_model.color.count > 1) {
                CAGradientLayer *gradientLayer = [CAGradientLayer layer];
                gradientLayer.frame = weakSelf.view.frame;
                gradientLayer.colors = @[(__bridge id)[UIColor colorWithHexString:[t_model.color firstObject]?:@""].CGColor,(__bridge id)[UIColor colorWithHexString:[t_model.color objectAtIndex:1]?:@""].CGColor];
                gradientLayer.startPoint = CGPointMake(0, 0);
                gradientLayer.endPoint = CGPointMake(0, 1.0);
                [weakSelf.gradientColorView.layer addSublayer:gradientLayer];
            }
        }
        
        weakSelf.shareButton.hidden = NO;
        weakSelf.downloadButton.hidden = isMagicState?YES:NO;
        weakSelf.footerView.view.hidden = NO;
    } failure:nil];
    
    [WXYZ_NetworkRequestManger POST:Audio_Catalog parameters:@{@"audio_id":[WXYZ_UtilsHelper formatStringWithInteger:self.audio_id]} model:WXYZ_ProductionModel.class success:^(BOOL isSuccess, WXYZ_ProductionModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            weakSelf.footerView.directoryModel = t_model;
            [weakSelf.mallTableView reloadData];
        }
    } failure:nil];
}

- (void)dealloc
{
    @try {
        [self.mallTableView removeObserver:self forKeyPath:@"contentOffset" context:NULL];
    } @catch (NSException *exception) {
        
    }
}

@end

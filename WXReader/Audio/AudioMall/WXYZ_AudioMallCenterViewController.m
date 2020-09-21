//
//  WXYZ_AudioMallCenterViewController.m
//  WXReader
//
//  Created by Andrew on 2020/3/12.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AudioMallCenterViewController.h"
#import "WXYZ_LimitTimeFreeViewController.h"

#import "WXYZ_BookMallStyleSingleTableViewCell.h"
#import "WXYZ_BookMallStyleDoubleTableViewCell.h"
#import "WXYZ_BookMallStyleMixtureTableViewCell.h"
#import "WXYZ_BookMallStyleMixtureMoreTableViewCell.h"
#import "WXYZ_PublicADStyleTableViewCell.h"

#import "WXYZ_MallCenterHeaderView.h"

#import "WXYZ_MallCenterLabelModel.h"

#import "WXYZ_BannerActionManager.h"

// 分类
#import "WXYZ_ClassifyViewController.h"
// 排行榜
#import "WXYZ_RankListViewController.h"
// 包月
#import "WXYZ_MonthlyViewController.h"
// 完本
#import "WXYZ_CompleteViewController.h"
// 限免
#import "WXYZ_LimitFreeViewController.h"

@interface WXYZ_AudioMallCenterViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) WXYZ_MallCenterHeaderView *headerView;

@property (nonatomic, strong) WXYZ_MallCenterModel *audioMallModel;

@property (nonatomic, assign) BOOL needRefresh;

@end

@implementation WXYZ_AudioMallCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
    [self netRequest];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netRequest) name:Notification_Restore_Network object:nil];
}

- (void)initialize
{
    self.needRefresh = YES;
    [self hiddenNavigationBar:YES];
    
    self.hotwordArray = [NSArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netRequest) name:Notification_Channel_Change object:nil];
}

- (void)createSubviews
{
    self.mainTableViewGroup.delegate = self;
    self.mainTableViewGroup.dataSource = self;
    [self.view addSubview:self.mainTableViewGroup];
    
    [self.mainTableViewGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_height).with.offset(- PUB_TABBAR_HEIGHT);
    }];
    
    WS(weakSelf)
    self.headerView = [[WXYZ_MallCenterHeaderView alloc] init];
    self.headerView.productionType = self.productionType;
    self.headerView.bannerrImageClickBlock = ^(WXYZ_BannerModel * _Nonnull bannerModel) {
        if ([WXYZ_BannerActionManager getBannerActionWithBannerModel:bannerModel productionType:WXYZ_ProductionTypeAudio]) {
            [weakSelf.navigationController pushViewController:[WXYZ_BannerActionManager getBannerActionWithBannerModel:bannerModel productionType:WXYZ_ProductionTypeAudio] animated:YES];
        }
    };
    self.headerView.menuButtonClickBlock = ^(WXYZ_MenuButtonType menuButtonType, NSString * _Nonnull menuButtonTitle) {
        switch (menuButtonType) {
            case WXYZ_MenuButtonTypeFree:
            {
                WXYZ_LimitFreeViewController *vc = [[WXYZ_LimitFreeViewController alloc] init];
                vc.productionType = weakSelf.productionType;
                vc.navTitle = menuButtonTitle;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
                break;
            case WXYZ_MenuButtonTypeFinish:
            {
                WXYZ_CompleteViewController *vc = [[WXYZ_CompleteViewController alloc] init];
                vc.productionType = weakSelf.productionType;
                vc.navTitle = menuButtonTitle;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
                break;
            case WXYZ_MenuButtonTypeClass:
            {
                WXYZ_ClassifyViewController *vc = [[WXYZ_ClassifyViewController alloc] init];
                vc.productionType = weakSelf.productionType;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
                break;
            case WXYZ_MenuButtonTypeRank:
            {
                WXYZ_RankListViewController *vc = [[WXYZ_RankListViewController alloc] init];
                vc.productionType = weakSelf.productionType;
                vc.navTitle = menuButtonTitle;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
                break;
            case WXYZ_MenuButtonTypeMember:
            {
                WXYZ_MonthlyViewController *vc = [[WXYZ_MonthlyViewController alloc] init];
                vc.productionType = weakSelf.productionType;
                vc.navTitle = menuButtonTitle;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
                break;
                
            default:
                break;
        }
    };
    
    self.mainTableViewGroup.tableHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH);
    [self.mainTableViewGroup setTableHeaderView:self.headerView];
    
    [self.mainTableViewGroup addHigherHeaderRefreshWithRefreshingBlock:^{
        [weakSelf netRequest];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.audioMallModel.label.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_MallCenterLabelModel *labelModel = [self.audioMallModel.label objectOrNilAtIndex:indexPath.section];
    for (WXYZ_ProductionModel *t_model in labelModel.list) {
        t_model.productionType = self.productionType;
    }
    if (labelModel.ad_type == 0) {
        switch (labelModel.style) {
            case 1:
                return [self createCellWithTabelView:tableView cellClass:WXYZ_BookMallStyleSingleTableViewCell.class indexPath:indexPath labelModel:labelModel];
                break;
            case 2:
                return [self createCellWithTabelView:tableView cellClass:WXYZ_BookMallStyleDoubleTableViewCell.class indexPath:indexPath labelModel:labelModel];
                break;
            case 3:
                return [self createCellWithTabelView:tableView cellClass:WXYZ_BookMallStyleMixtureTableViewCell.class indexPath:indexPath labelModel:labelModel];
                break;
            case 4:
                return [self createCellWithTabelView:tableView cellClass:WXYZ_BookMallStyleMixtureMoreTableViewCell.class indexPath:indexPath labelModel:labelModel];
                break;
                
            default:
                return [self createCellWithTabelView:tableView cellClass:WXYZ_BookMallStyleSingleTableViewCell.class indexPath:indexPath labelModel:labelModel];
                break;
        }
    } else {
        return [self createADStyleCellWithTableView:tableView atIndexPath:indexPath adModel:labelModel];
    }
}

- (UITableViewCell *)createCellWithTabelView:(UITableView *)tableView cellClass:(Class)cellClass indexPath:(NSIndexPath *)indexPath labelModel:(WXYZ_MallCenterLabelModel *)labelModel
{
    WS(weakSelf)
    WXYZ_BookMallBasicStyleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(cellClass)];
    if (!cell) {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(cellClass)];
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

- (UITableViewCell *)createADStyleCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath adModel:(WXYZ_MallCenterLabelModel *)labelModel
{
    static NSString *cellName = @"WXYZ_PublicADStyleTableViewCell";
    WXYZ_PublicADStyleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_PublicADStyleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    [cell setAdModel:labelModel refresh:self.needRefresh];
    cell.mainTableView = tableView;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    WXYZ_MallCenterLabelModel *labelModel = [self.audioMallModel.label objectOrNilAtIndex:section];
    if (labelModel.can_more || labelModel.can_refresh) {
        return 50;
    }
    return CGFLOAT_MIN;
}

//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    view.backgroundColor = [UIColor whiteColor];
    
    CGFloat buttonX = SCREEN_WIDTH / 4;
    CGFloat buttonY = 10;
    CGFloat buttonW = SCREEN_WIDTH / 2;
    CGFloat buttonH = 30;
    
    WXYZ_MallCenterLabelModel *labelModel = [self.audioMallModel.label objectOrNilAtIndex:section];
    
    if (!labelModel.can_more && !labelModel.can_refresh) {
        return view;
    }
    
    WXYZ_CustomButton *moreButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH) buttonTitle:@"更多" buttonImageName:@"comic_mall_more" buttonIndicator:WXYZ_CustomButtonIndicatorTitleLeft];
    moreButton.buttonTintColor = kGrayTextLightColor;
    moreButton.graphicDistance = 5;
    moreButton.backgroundColor = kGrayViewColor;
    moreButton.layer.cornerRadius = 15;
    moreButton.tag = section;
    [moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    WXYZ_CustomButton *changeButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH) buttonTitle:@"换一换" buttonImageName:@"comic_mall_refresh" buttonIndicator:WXYZ_CustomButtonIndicatorTitleLeft];
    changeButton.buttonTintColor = kGrayTextLightColor;
    changeButton.graphicDistance = 5;
    changeButton.buttonImageScale = 0.5;
    changeButton.backgroundColor = kGrayViewColor;
    changeButton.layer.cornerRadius = 15;
    changeButton.tag = section;
    [changeButton addTarget:self action:@selector(changeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if (labelModel.can_more && !labelModel.can_refresh) {
        [view addSubview:moreButton];
    }
    
    if (!labelModel.can_more && labelModel.can_refresh) {
        [view addSubview:changeButton];
    }
    
    if (labelModel.can_more && labelModel.can_refresh) {
        moreButton.frame = CGRectMake(kMargin, buttonY, (SCREEN_WIDTH - 3 * kMargin) / 2, buttonH);
        changeButton.frame = CGRectMake(2 * kMargin + (SCREEN_WIDTH - 3 * kMargin) / 2, buttonY, (SCREEN_WIDTH - 3 * kMargin) / 2, buttonH);
        [view addSubview:moreButton];
        [view addSubview:changeButton];
    }
    
    return view;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pointY = scrollView.contentOffset.y;
    self.scrollViewContentOffsetY = pointY;
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat pointY = scrollView.contentOffset.y;
    self.scrollViewContentOffsetY = pointY;
}

#pragma mark - 点击事件

- (void)moreButtonClick:(UIButton *)sender
{
    WXYZ_MallCenterLabelModel *t_labelModel = [self.audioMallModel.label objectOrNilAtIndex:sender.tag];
    WXYZ_MallRecommendMoreViewController *vc = [[WXYZ_MallRecommendMoreViewController alloc] init];
    vc.productionType = self.productionType;
    vc.recommend_id = [WXYZ_UtilsHelper formatStringWithInteger:t_labelModel.recommend_id];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)changeButtonClick:(UIButton *)sender
{
    WXYZ_CustomButton *button = (WXYZ_CustomButton *)sender;
    [button startSpin];
    [self changeBookRecommendRequestAtIndex:sender.tag complete:^{
        [button stopSpin];
    }];
}

- (void)netRequest
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POSTQuick:Audio_Mall parameters:@{@"channel_id":self.channel != 0?[WXYZ_UtilsHelper formatStringWithInteger:self.channel]:@(WXYZ_SystemInfoManager.sexChannel)} model:WXYZ_MallCenterModel.class success:^(BOOL isSuccess, WXYZ_MallCenterModel * _Nullable t_model, BOOL isCache, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            weakSelf.audioMallModel = t_model;
            weakSelf.headerView.mallCenterModel = t_model;
            weakSelf.hotwordArray = t_model.hot_word;
                        
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Reload_Mall_Hot_Word object:nil];
        }
        [weakSelf.mainTableViewGroup endRefreshing];
        weakSelf.needRefresh = YES;
        [weakSelf.mainTableViewGroup reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.needRefresh = NO;
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf.mainTableViewGroup endRefreshing];
    }];
}

- (void)changeBookRecommendRequestAtIndex:(NSInteger)index complete:(void(^)(void))complete;
{
    WXYZ_MallCenterLabelModel *t_labelModel = [self.audioMallModel.label objectOrNilAtIndex:index];
    NSString *recommend_id = [WXYZ_UtilsHelper formatStringWithInteger:t_labelModel.recommend_id];
    
    if (recommend_id.length <= 0) return;
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Audio_Refresh parameters:@{@"recommend_id":recommend_id} model:WXYZ_MallCenterLabelModel.class success:^(BOOL isSuccess, WXYZ_MallCenterLabelModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            for (WXYZ_ProductionModel *obj in t_model.list) {
                obj.productionType = weakSelf.productionType;
            }
            [weakSelf.audioMallModel.label objectAtIndex:index].list = t_model.list;
            
            WXYZ_BookMallBasicStyleTableViewCell *cell = [weakSelf.mainTableViewGroup cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
            t_model.style = cell.labelModel.style;
            cell.labelModel = t_model;
            !complete ?: complete();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !complete ?: complete();
    }];
}


@end

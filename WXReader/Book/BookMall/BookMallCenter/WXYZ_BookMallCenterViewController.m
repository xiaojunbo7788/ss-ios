//
//  WXYZ_BookMallCenterViewController.m
//  WXReader
//
//  Created by Andrew on 2019/5/24.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_BookMallCenterViewController.h"
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
#import "WXYZ_WebViewViewController.h"

@interface WXYZ_BookMallCenterViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) WXYZ_MallCenterModel *bookModel;

@property (nonatomic, strong) WXYZ_MallCenterHeaderView *headerView;

@property (nonatomic, assign) BOOL needRefresh;

@end

@implementation WXYZ_BookMallCenterViewController

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
        if ([WXYZ_BannerActionManager getBannerActionWithBannerModel:bannerModel productionType:WXYZ_ProductionTypeBook]) {
            [weakSelf.navigationController pushViewController:[WXYZ_BannerActionManager getBannerActionWithBannerModel:bannerModel productionType:WXYZ_ProductionTypeBook] animated:YES];
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
    return self.bookModel.label.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_MallCenterLabelModel *labelModel = [self.bookModel.label objectOrNilAtIndex:indexPath.section];
    
    if (labelModel.ad_type == 0) {
        return [self createCellWithTabelView:tableView indexPath:indexPath labelModel:labelModel];
    } else {
        return [self createADStyleCellWithTableView:tableView atIndexPath:indexPath adModel:labelModel];
    }
}

- (UITableViewCell *)createCellWithTabelView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath labelModel:(WXYZ_MallCenterLabelModel *)labelModel
{
    Class cellClass = WXYZ_BookMallStyleSingleTableViewCell.class;
    switch (labelModel.style) {
        case 1:
             cellClass = WXYZ_BookMallStyleSingleTableViewCell.class;
            break;
        case 2:
            cellClass = WXYZ_BookMallStyleDoubleTableViewCell.class;
            break;
        case 3:
            cellClass = WXYZ_BookMallStyleMixtureTableViewCell.class;
            break;
        case 4:
            cellClass = WXYZ_BookMallStyleMixtureMoreTableViewCell.class;
            break;
            
        default:
            cellClass = WXYZ_BookMallStyleSingleTableViewCell.class;
            break;
    }
    
    WS(weakSelf)
    WXYZ_BookMallBasicStyleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(cellClass)];
    if (!cell) {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(cellClass)];
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
    WXYZ_MallCenterLabelModel *labelModel = [self.bookModel.label objectOrNilAtIndex:section];
    if (labelModel.ad_type != 0) {
        return kHalfMargin;
    }
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
    WXYZ_MallCenterLabelModel *labelModel = [self.bookModel.label objectOrNilAtIndex:section];
    if (labelModel.can_more || labelModel.can_refresh) {
        
        if (section == self.bookModel.label.count - 1) {
            return 40;
        }
        return 30;
    }
    
    return CGFLOAT_MIN;
}

//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    view.backgroundColor = [UIColor whiteColor];
    
    CGFloat buttonX = SCREEN_WIDTH / 4;
    CGFloat buttonW = SCREEN_WIDTH / 2;
    CGFloat buttonH = 30;
    
    WXYZ_MallCenterLabelModel *labelModel = [self.bookModel.label objectOrNilAtIndex:section];
    
    if (!labelModel.can_more && !labelModel.can_refresh) {
        return view;
    }
    
    if (labelModel.style == 5) { // 排行榜
        WXYZ_CustomButton *moreButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectMake(kMargin, 0, SCREEN_WIDTH - 2 * kMargin, buttonH) buttonTitle:@"查看更多排行榜" buttonImageName:@"comic_mall_more" buttonIndicator:WXYZ_CustomButtonIndicatorTitleLeft];
        moreButton.buttonTintColor = kGrayTextLightColor;
        moreButton.graphicDistance = 5;
        moreButton.backgroundColor = kGrayViewColor;
        moreButton.layer.cornerRadius = 15;
        moreButton.tag = section;
        [moreButton addTarget:self action:@selector(rankButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:moreButton];
        
        return view;
    }
    
    WXYZ_CustomButton *moreButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectMake(buttonX, 0, buttonW, buttonH) buttonTitle:@"更多" buttonImageName:@"comic_mall_more" buttonIndicator:WXYZ_CustomButtonIndicatorTitleLeft];
    moreButton.buttonTintColor = kGrayTextLightColor;
    moreButton.graphicDistance = 5;
    moreButton.backgroundColor = kGrayViewColor;
    moreButton.layer.cornerRadius = 15;
    moreButton.tag = section;
    [moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    WXYZ_CustomButton *changeButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectMake(buttonX, 0, buttonW, buttonH) buttonTitle:@"换一换" buttonImageName:@"comic_mall_refresh" buttonIndicator:WXYZ_CustomButtonIndicatorTitleLeft];
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
        moreButton.frame = CGRectMake(kMargin, 0, (SCREEN_WIDTH - 3 * kMargin) / 2, buttonH);
        changeButton.frame = CGRectMake(2 * kMargin + (SCREEN_WIDTH - 3 * kMargin) / 2, 0, (SCREEN_WIDTH - 3 * kMargin) / 2, buttonH);
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
    WXYZ_MallCenterLabelModel *t_labelModel = [self.bookModel.label objectOrNilAtIndex:sender.tag];
    
    if (t_labelModel.expire_time > 0) {
        WXYZ_LimitTimeFreeViewController *vc = [[WXYZ_LimitTimeFreeViewController alloc] init];
        vc.productionType = self.productionType;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        WXYZ_MallRecommendMoreViewController *vc = [[WXYZ_MallRecommendMoreViewController alloc] init];
        vc.productionType = self.productionType;
        vc.recommend_id = [WXYZ_UtilsHelper formatStringWithInteger:t_labelModel.recommend_id];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)changeButtonClick:(WXYZ_CustomButton *)sender
{
    [sender startSpin];
    [self changeBookRecommendRequestAtIndex:sender.tag complete:^{
        [sender stopSpin];
    }];
}

- (void)rankButtonClick:(UIButton *)sender
{
    WXYZ_RankListViewController *vc = [[WXYZ_RankListViewController alloc] init];
    vc.productionType = self.productionType;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)netRequest
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POSTQuick:Book_Mall_Center parameters:@{@"channel_id":self.channel != 0?[WXYZ_UtilsHelper formatStringWithInteger:self.channel]:@(WXYZ_SystemInfoManager.sexChannel)} model:WXYZ_MallCenterModel.class success:^(BOOL isSuccess, WXYZ_MallCenterModel * _Nullable t_model, BOOL isCache, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (weakSelf.bookModel && isCache) return;
        if (isSuccess) {
            weakSelf.bookModel = t_model;
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
        [weakSelf.mainTableViewGroup reloadData];
    }];
    
}

- (void)changeBookRecommendRequestAtIndex:(NSInteger)index complete:(void(^)(void))complete
{
    WXYZ_MallCenterLabelModel *t_labelModel = [self.bookModel.label objectOrNilAtIndex:index];
    
    if (t_labelModel.recommend_id <= 0) {
        return;
    }
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Book_Refresh parameters:@{@"recommend_id":[WXYZ_UtilsHelper formatStringWithInteger:t_labelModel.recommend_id]} model:WXYZ_MallCenterLabelModel.class success:^(BOOL isSuccess, WXYZ_MallCenterLabelModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            [weakSelf.bookModel.label objectAtIndex:index].list = t_model.list;
            
            WXYZ_BookMallBasicStyleTableViewCell *cell = [weakSelf.mainTableViewGroup cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
            t_model.style = cell.labelModel.style;
            cell.labelModel = t_model;
            !complete ?: complete();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !complete ?: complete();
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

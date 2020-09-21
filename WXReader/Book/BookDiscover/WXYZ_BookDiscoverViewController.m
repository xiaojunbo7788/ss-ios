//
//  DiscoverViewController.m
//  WXReader
//
//  Created by Andrew on 2018/5/15.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BookDiscoverViewController.h"
#import "WXYZ_LimitTimeFreeViewController.h"

#import "WXYZ_BasicComicMallTableViewCell.h"
#import "WXYZ_BookMallStyleSingleTableViewCell.h"
#import "WXYZ_BookMallStyleDoubleTableViewCell.h"
#import "WXYZ_BookMallStyleMixtureTableViewCell.h"
#import "WXYZ_BookMallStyleMixtureMoreTableViewCell.h"
#import "WXYZ_PublicADStyleTableViewCell.h"

#import "WXYZ_DiscoverHeaderView.h"

#import "WXYZ_BannerActionManager.h"

@interface WXYZ_BookDiscoverViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) WXYZ_DiscoverHeaderView *headerView;

@property (nonatomic, strong) WXYZ_MallCenterModel *bookDiscoverModel;

@property (nonatomic, assign) BOOL needRefresh;

@end

@implementation WXYZ_BookDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
    [self netRequest];   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarDefaultStyle];
}

- (void)initialize
{
    self.needRefresh = YES;
    [self hiddenNavigationBar:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netRequest) name:Notification_EndOfTimeLimit object:nil];
}

- (void)createSubviews
{
    self.mainTableViewGroup.delegate = self;
    self.mainTableViewGroup.dataSource = self;
    [self.view addSubview:self.mainTableViewGroup];

    [self.mainTableViewGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_height).with.offset(- PUB_TABBAR_HEIGHT - PUB_NAVBAR_HEIGHT);
    }];

   
    WS(weakSelf)
    [self.mainTableViewGroup addHeaderRefreshWithRefreshingBlock:^{
        [weakSelf netRequest];
    }];
    
    self.headerView = [[WXYZ_DiscoverHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN)];
    self.headerView.bannerrImageClickBlock = ^(WXYZ_BannerModel * _Nonnull bannerModel) {
        if ([WXYZ_BannerActionManager getBannerActionWithBannerModel:bannerModel productionType:WXYZ_ProductionTypeBook]) {
            [weakSelf.navigationController pushViewController:[WXYZ_BannerActionManager getBannerActionWithBannerModel:bannerModel productionType:WXYZ_ProductionTypeBook] animated:YES];
        }
    };
    [self.mainTableViewGroup setTableHeaderView:self.headerView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.bookDiscoverModel.label.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_MallCenterLabelModel *labelModel = [self.bookDiscoverModel.label objectOrNilAtIndex:indexPath.section];
    
    if (labelModel.ad_type == 0) {
        switch (labelModel.style) {
            case 1:
                return [self createSingleStyleCellWithTableView:tableView atIndexPath:indexPath labelModel:labelModel];
                break;
            case 2:
                return [self createDoubleStyleCellWithTableView:tableView atIndexPath:indexPath labelModel:labelModel];
                break;
            case 3:
                return [self createMixtureStyleCellWithTableView:tableView atIndexPath:indexPath labelModel:labelModel];
                break;
            case 4:
                return [self createMixtureMoreStyleCellWithTableView:tableView atIndexPath:indexPath labelModel:labelModel];
                break;
                
            default:
                return [self createSingleStyleCellWithTableView:tableView atIndexPath:indexPath labelModel:labelModel];
                break;
        }
    } else {
        return [self createADStyleCellWithTableView:tableView atIndexPath:indexPath adModel:labelModel];
    }
}

- (UITableViewCell *)createSingleStyleCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath labelModel:(WXYZ_MallCenterLabelModel *)labelModel
{
    WS(weakSelf)
    static NSString *cellName = @"WXYZ_BookMallStyleSingleTableViewCell";
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

- (UITableViewCell *)createDoubleStyleCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath labelModel:(WXYZ_MallCenterLabelModel *)labelModel
{
    WS(weakSelf)
    static NSString *cellName = @"WXYZ_BookMallStyleDoubleTableViewCell";
    WXYZ_BookMallStyleDoubleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_BookMallStyleDoubleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
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

- (UITableViewCell *)createMixtureStyleCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath labelModel:(WXYZ_MallCenterLabelModel *)labelModel
{
    WS(weakSelf)
    static NSString *cellName = @"WXYZ_BookMallStyleMixtureTableViewCell";
    WXYZ_BookMallStyleMixtureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_BookMallStyleMixtureTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
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

- (UITableViewCell *)createMixtureMoreStyleCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath labelModel:(WXYZ_MallCenterLabelModel *)labelModel
{
    WS(weakSelf)
    static NSString *cellName = @"WXYZ_BookMallStyleMixtureMoreTableViewCell";
    WXYZ_BookMallStyleMixtureMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_BookMallStyleMixtureMoreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
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
    WXYZ_MallCenterLabelModel *labelModel = [self.bookDiscoverModel.label objectOrNilAtIndex:section];
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
    
    WXYZ_MallCenterLabelModel *labelModel = [self.bookDiscoverModel.label objectOrNilAtIndex:section];
    
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

- (void)moreButtonClick:(UIButton *)sender
{
    WXYZ_MallCenterLabelModel *t_labelModel = [self.bookDiscoverModel.label objectOrNilAtIndex:sender.tag];
    
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

- (void)changeButtonClick:(UIButton *)sender
{
    WXYZ_CustomButton *button = (WXYZ_CustomButton *)sender;
    [button startSpin];
    [self changeRecommendRequestAtIndex:sender.tag complete:^{
        [button stopSpin];
    }];
}

- (void)changeRecommendRequestAtIndex:(NSInteger)index complete:(void(^)(void))complete
{
    WXYZ_MallCenterLabelModel *t_labelModel = [self.bookDiscoverModel.label objectOrNilAtIndex:index];
    
    if (t_labelModel.recommend_id <= 0) {
        return;
    }
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Book_Refresh parameters:@{@"recommend_id":[WXYZ_UtilsHelper formatStringWithInteger:t_labelModel.recommend_id]} model:WXYZ_MallCenterLabelModel.class success:^(BOOL isSuccess, WXYZ_MallCenterLabelModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            if (t_model.list.count > 0) {
                [weakSelf.bookDiscoverModel.label objectAtIndex:index].list = t_model.list;
                t_model.style = t_labelModel.style;
                WXYZ_BasicComicMallTableViewCell *cell = [weakSelf.mainTableViewGroup cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
                cell.labelModel = t_model;
                !complete ?: complete();
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !complete ?: complete();
    }];
}

- (void)netRequest
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POSTQuick:Book_Discover parameters:nil model:WXYZ_MallCenterModel.class success:^(BOOL isSuccess, WXYZ_MallCenterModel * _Nullable t_model, BOOL isCache, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            weakSelf.headerView.banner = t_model.banner;
            if (t_model.banner.count > 0) {
                weakSelf.headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH / 4);
            } else {
                weakSelf.headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN);
            }
            weakSelf.bookDiscoverModel = t_model;
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

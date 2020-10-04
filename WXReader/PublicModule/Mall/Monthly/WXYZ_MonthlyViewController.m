//
//  WXYZ_MonthlyViewController.m
//  WXReader
//
//  Created by Andrew on 2018/6/15.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_MonthlyViewController.h"
#import "WXYZ_ClassifyViewController.h"
#import "WXYZ_MemberViewController.h"

#import "WXYZ_MonthlyHeaderView.h"
#import "WXYZ_BookMallStyleSingleTableViewCell.h"
#import "WXYZ_BookMallStyleDoubleTableViewCell.h"
#import "WXYZ_BookMallStyleMixtureTableViewCell.h"
#import "WXYZ_BookMallStyleMixtureMoreTableViewCell.h"
#import "WXYZ_ComicMaxStyleTableViewCell.h"
#import "WXYZ_ComicMiddleSytleTableViewCell.h"
#import "WXYZ_ComicNormalStyleTableViewCell.h"
#import "WXYZ_PublicADStyleTableViewCell.h"

#import "WXYZ_MonthlyModel.h"

#import "WXYZ_BannerActionManager.h"
//TODO:会员页面
@interface WXYZ_MonthlyViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) WXYZ_MonthlyHeaderView *headerView;

@property (nonatomic, strong) WXYZ_MonthlyModel *monthlyModel;

@property (nonatomic, assign) BOOL needRefresh;

@end

@implementation WXYZ_MonthlyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarDefaultStyle];
    [self netRequest];
}

- (void)initialize
{
    self.needRefresh = YES;
    [self setNavigationBarTitle:self.navTitle?:@"会员中心"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netRequest) name:Notification_Recharge_Success object:nil];
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
        make.height.mas_equalTo(SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT);
    }];
    
    WS(weakSelf)
    self.headerView = [[WXYZ_MonthlyHeaderView alloc] init];
    self.headerView.functionButtonClickBlock = ^(WXYZ_PrivilegeModel *privilegeModel) {
        if ([privilegeModel.action isEqualToString:@"library"]) {
            WXYZ_ClassifyViewController *vc = [[WXYZ_ClassifyViewController alloc] init];
            vc.productionType = weakSelf.productionType;
            vc.isMemberStore = YES;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        } else {
            if (!WXYZ_UserInfoManager.isLogin) {
                [WXYZ_LoginViewController presentLoginView];
                return;
            }
            [weakSelf.navigationController pushViewController:[[WXYZ_MemberViewController alloc] init] animated:YES];
        }
    };
    self.headerView.bannerrImageClickBlock = ^(WXYZ_BannerModel *bannerModel) {
        if ([WXYZ_BannerActionManager getBannerActionWithBannerModel:bannerModel productionType:weakSelf.productionType]) {
            [weakSelf.navigationController pushViewController:[WXYZ_BannerActionManager getBannerActionWithBannerModel:bannerModel productionType:weakSelf.productionType] animated:YES];
        }
    };
    [self.mainTableViewGroup setTableHeaderView:self.headerView];
    
    [self setEmptyOnView:self.mainTableViewGroup title:@"暂无数据" tapBlock:^{
        
    }];
    
    [self.mainTableViewGroup addHeaderRefreshWithRefreshingBlock:^{
        [weakSelf netRequest];
    }];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.monthlyModel.label.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_MallCenterLabelModel *labelModel = [self.monthlyModel.label objectOrNilAtIndex:indexPath.section];
    
    if (labelModel.ad_type == 0) {
        if (self.productionType == WXYZ_ProductionTypeComic) {
            switch (labelModel.style) {
                case 1:
                    return [self createMiddleSytleComicCellWithTableView:tableView atIndexPath:indexPath labelModel:labelModel];
                    break;
                case 2:
                    return [self createNormalStyleComicCellWithTableView:tableView atIndexPath:indexPath labelModel:labelModel];
                    break;
                case 3:
                    return [self createMaxStyleComicCellWithTableView:tableView atIndexPath:indexPath labelModel:labelModel];
                    break;
                    
                default:
                    return [self createNormalStyleComicCellWithTableView:tableView atIndexPath:indexPath labelModel:labelModel];
                    break;
            }
        } else {
            for (WXYZ_ProductionModel *t_model in labelModel.list) {
                t_model.productionType = self.productionType;
            }
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
    cell.cellSelectMoreBlock = ^(WXYZ_MallCenterLabelModel * _Nonnull labelModel) {
        WXYZ_MallRecommendMoreViewController *vc = [[WXYZ_MallRecommendMoreViewController alloc] init];
        vc.productionType = weakSelf.productionType;
        vc.recommend_id = [WXYZ_UtilsHelper formatStringWithInteger:labelModel.recommend_id];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    cell.cellDidSelectItemBlock = ^(NSInteger production_id) {
        [weakSelf pushToMallDetail:production_id];
    };
    cell.showTopMoreButton = labelModel.can_more;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)createMaxStyleComicCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath labelModel:(WXYZ_MallCenterLabelModel *)labelModel
{
    WS(weakSelf)
    static NSString *cellName = @"WXYZ_ComicMaxStyleTableViewCell";
    WXYZ_ComicMaxStyleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_ComicMaxStyleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.labelModel = labelModel;
    cell.showTopMoreButton = labelModel.can_more;
    cell.cellSelectMoreBlock = ^(WXYZ_MallCenterLabelModel * _Nonnull labelModel) {
        WXYZ_MallRecommendMoreViewController *vc = [[WXYZ_MallRecommendMoreViewController alloc] init];
        vc.productionType = weakSelf.productionType;
        vc.recommend_id = [WXYZ_UtilsHelper formatStringWithInteger:labelModel.recommend_id];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    cell.cellDidSelectItemBlock = ^(NSInteger production_id) {
        [weakSelf pushToMallDetail:production_id];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)createMiddleSytleComicCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath labelModel:(WXYZ_MallCenterLabelModel *)labelModel
{
    WS(weakSelf)
    static NSString *cellName = @"WXYZ_ComicMiddleSytleTableViewCell";
    WXYZ_ComicMiddleSytleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_ComicMiddleSytleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.labelModel = labelModel;
    cell.showTopMoreButton = labelModel.can_more;
    cell.cellSelectMoreBlock = ^(WXYZ_MallCenterLabelModel * _Nonnull labelModel) {
        WXYZ_MallRecommendMoreViewController *vc = [[WXYZ_MallRecommendMoreViewController alloc] init];
        vc.productionType = weakSelf.productionType;
        vc.recommend_id = [WXYZ_UtilsHelper formatStringWithInteger:labelModel.recommend_id];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    cell.cellDidSelectItemBlock = ^(NSInteger production_id) {
        [weakSelf pushToMallDetail:production_id];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)createNormalStyleComicCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath labelModel:(WXYZ_MallCenterLabelModel *)labelModel
{
    WS(weakSelf)
    static NSString *cellName = @"WXYZ_ComicNormalStyleTableViewCell";
    WXYZ_ComicNormalStyleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_ComicNormalStyleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.labelModel = labelModel;
    cell.showTopMoreButton = labelModel.can_more;
    cell.cellSelectMoreBlock = ^(WXYZ_MallCenterLabelModel * _Nonnull labelModel) {
        WXYZ_MallRecommendMoreViewController *vc = [[WXYZ_MallRecommendMoreViewController alloc] init];
        vc.productionType = weakSelf.productionType;
        vc.recommend_id = [WXYZ_UtilsHelper formatStringWithInteger:labelModel.recommend_id];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    cell.cellDidSelectItemBlock = ^(NSInteger production_id) {
        [weakSelf pushToMallDetail:production_id];
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
    if (section == 0) {
        return kHalfMargin;
    }
    return CGFLOAT_MIN;
}

//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kHalfMargin)];
    view.backgroundColor = kGrayViewColor;
    return view;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == self.monthlyModel.label.count - 1) {
        return PUB_TABBAR_OFFSET == 0 ? 10 : PUB_TABBAR_OFFSET;
    }
    return CGFLOAT_MIN;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, PUB_TABBAR_OFFSET == 0 ? 10 : PUB_TABBAR_OFFSET)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)pushToMallDetail:(NSInteger)production_id
{
    switch (self.productionType) {
#if WX_Enable_Book
        case WXYZ_ProductionTypeBook:
        {
            WXYZ_BookMallDetailViewController *vc = [[WXYZ_BookMallDetailViewController alloc] init];
            vc.book_id = production_id;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
#endif
            
#if WX_Enable_Comic
        case WXYZ_ProductionTypeComic:
        {
            WXYZ_ComicMallDetailViewController *vc = [[WXYZ_ComicMallDetailViewController alloc] init];
            vc.comic_id = production_id;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
#endif
            
#if WX_Enable_Audio
        case WXYZ_ProductionTypeAudio:
        {
            WXYZ_AudioMallDetailViewController *vc = [[WXYZ_AudioMallDetailViewController alloc] init];
            vc.audio_id = production_id;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
#endif
            
        default:
            break;
    }
}

- (void)netRequest
{
    NSString *site_type = @"";
    switch (self.productionType) {
        case WXYZ_ProductionTypeBook:
            site_type = @"1";
            break;
        case WXYZ_ProductionTypeComic:
            site_type = @"2";
            break;
        case WXYZ_ProductionTypeAudio:
            site_type = @"3";
            break;
            
        default:
            break;
    }

    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Member_Monthly parameters:@{@"site_id":site_type} model:WXYZ_MonthlyModel.class success:^(BOOL isSuccess, WXYZ_MonthlyModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            weakSelf.monthlyModel = t_model;
        }
        weakSelf.headerView.userInfoModel = weakSelf.monthlyModel.user;
        weakSelf.headerView.banner = weakSelf.monthlyModel.banner;
        weakSelf.headerView.privilege = weakSelf.monthlyModel.privilege;
        
        if (weakSelf.monthlyModel.banner.count > 0) {
            weakSelf.emptyView.contentViewY = 350;
        } else {
            weakSelf.emptyView.contentViewY = 200;
        }
        
        [weakSelf.mainTableViewGroup setTableHeaderView:weakSelf.headerView];
        
        [weakSelf.mainTableViewGroup endRefreshing];
        weakSelf.needRefresh = YES;
        [weakSelf.mainTableViewGroup reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.needRefresh = NO;
        });
        [weakSelf.mainTableViewGroup ly_endLoading];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf.mainTableViewGroup endRefreshing];
        [weakSelf.mainTableViewGroup ly_endLoading];
    }];
}

@end

//
//  WXYZ_BookBackSideViewController.m
//  WXReader
//
//  Created by LL on 2020/5/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BookBackSideViewController.h"
#import "WXYZ_CommentsViewController.h"

#import "WXYZ_BookBackSideHeaderView.h"
#import "WXYZ_BookMallStyleSingleTableViewCell.h"
#import "WXYZ_BookMallStyleDoubleTableViewCell.h"
#import "WXYZ_BookMallStyleMixtureTableViewCell.h"
#import "WXYZ_BookMallStyleMixtureMoreTableViewCell.h"
#import "WXYZ_PublicADStyleTableViewCell.h"

#import "WXYZ_BookBackSideModel.h"
#import "WXYZ_MallCenterLabelModel.h"

@interface WXYZ_BookBackSideViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) WXYZ_BookBackSideModel *backSideModel;

@property (nonatomic, strong) WXYZ_BookBackSideHeaderView *headerView;

@property (nonatomic, assign) BOOL needRefresh;

@end

@implementation WXYZ_BookBackSideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
    [self netRequest];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Hidden_Tabbar object:@"1"];
    [self setStatusBarDefaultStyle];
}

- (void)initialize
{
    self.needRefresh = YES;
    [self setNavigationBarTitle:self.bookModel.name ?: @""];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *_rightBtn;
    [self setNavigationBarRightButton:({
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn = rightBtn;
        [rightBtn setImage:[YYImage imageNamed:@"public_home"] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(goHome) forControlEvents:UIControlEventTouchUpInside];
        rightBtn;
    })];
    [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-kMargin);
        make.centerY.equalTo(self.navigationBar.navTitleLabel);
    }];
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
        make.height.mas_equalTo(self.view.mas_height);
    }];
    
    WS(weakSelf)
    [self.mainTableViewGroup addHeaderRefreshWithRefreshingBlock:^{
        [weakSelf netRequest];
    }];
    
    self.headerView = [[WXYZ_BookBackSideHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
    self.headerView.commentClickBlock = ^{
        WXYZ_CommentsViewController *vc = [[WXYZ_CommentsViewController alloc] init];
        vc.production_id = weakSelf.bookModel.production_id;
        vc.commentsSuccessBlock = ^(WXYZ_CommentsDetailModel *commentModel) {
            weakSelf.backSideModel.comment_num ++;
            weakSelf.headerView.headerModel = weakSelf.backSideModel;
        };
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    [self.mainTableViewGroup setTableHeaderView:self.headerView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_MallCenterLabelModel *labelModel = self.backSideModel.guess_like;
    
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

- (void)netRequest
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Book_Endof_Recommend parameters:@{@"book_id":[WXYZ_UtilsHelper formatStringWithInteger:self.bookModel.production_id]} model:WXYZ_BookBackSideModel.class success:^(BOOL isSuccess, WXYZ_BookBackSideModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            weakSelf.backSideModel = t_model;
            weakSelf.headerView.headerModel = t_model;
            weakSelf.needRefresh = YES;
            [weakSelf.mainTableViewGroup reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.needRefresh = NO;
            });
        }
        [weakSelf.mainTableViewGroup endRefreshing];
    } failure:nil];
}

- (void)refreshRequestWithLabelModel:(WXYZ_MallCenterLabelModel *)labelModel indexPath:(NSIndexPath *)indexPath
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Book_Guess_Like parameters:@{@"book_id":[WXYZ_UtilsHelper formatStringWithInteger:self.bookModel.production_id]} model:WXYZ_MallCenterLabelModel.class success:^(BOOL isSuccess, WXYZ_MallCenterLabelModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            weakSelf.backSideModel.guess_like.list = t_model.list;
            WXYZ_BookMallBasicStyleTableViewCell *cell = [weakSelf.mainTableViewGroup cellForRowAtIndexPath:indexPath];
            cell.labelModel = t_model;
            [cell stopRefreshing];
        }
    } failure:nil];
}

- (void)goHome
{
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Change_Tabbar_Index object:@"1"];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end

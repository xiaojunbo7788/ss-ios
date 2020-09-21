//
//  WXYZ_AppraiseDetailViewController.m
//  WXReader
//
//  Created by Andrew on 2020/4/13.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AppraiseDetailViewController.h"

#import "WXYZ_AppraiseDetailHeaderView.h"
#import "WXYZ_CommentsTableViewCell.h"

#import "WXYZ_AppraiseDetailModel.h"

@interface WXYZ_AppraiseDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) WXYZ_AppraiseDetailModel *appraiseDetailModel;

@property (nonatomic, strong) UILabel *footerView;

@end

@implementation WXYZ_AppraiseDetailViewController

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
    [self hiddenSeparator];
    [self setNavigationBarTitle:@"评论详情"];
}

- (void)createSubviews
{
    self.mainTableViewGroup.delegate = self;
    self.mainTableViewGroup.dataSource = self;
    [self.view addSubview:self.mainTableViewGroup];
    
    [self.mainTableViewGroup setTableFooterView:self.footerView];
    
    [self.mainTableViewGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_height).with.offset(- PUB_NAVBAR_HEIGHT - PUB_TABBAR_OFFSET);
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        WS(weakSelf)
        static NSString *cellName = @"WXYZ_AppraiseDetailHeaderView";
        WXYZ_AppraiseDetailHeaderView *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (!cell) {
            cell = [[WXYZ_AppraiseDetailHeaderView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        cell.commentProductionClickBlock = ^{
            switch (weakSelf.productionType) {
#if WX_Enable_Book
                case WXYZ_ProductionTypeBook:
                {
                    WXYZ_BookMallDetailViewController *vc = [[WXYZ_BookMallDetailViewController alloc] init];
                    vc.book_id = weakSelf.appraiseDetailModel.production_id;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }
                    break;
#endif
                    
#if WX_Enable_Comic
                case WXYZ_ProductionTypeComic:
                {
                    WXYZ_ComicMallDetailViewController *vc = [[WXYZ_ComicMallDetailViewController alloc] init];
                    vc.comic_id = weakSelf.appraiseDetailModel.production_id;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }
                    break;
#endif
                    
#if WX_Enable_Audio
                case WXYZ_ProductionTypeAudio:
                {
                    WXYZ_AudioMallDetailViewController *vc = [[WXYZ_AudioMallDetailViewController alloc] init];
                    vc.audio_id = weakSelf.appraiseDetailModel.production_id;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }
                    break;
#endif
                    
                default:
                    break;
            }
        };
        cell.appraiseDetailModel = self.appraiseDetailModel;
        cell.productionType = self.productionType;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        static NSString *cellName = @"WXYZ_CommentsTableViewCell";
        WXYZ_CommentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (!cell) {
            cell = [[WXYZ_CommentsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        cell.commentModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.hiddenEndLine = indexPath.row == self.dataSourceArray.count - 1;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_CommentsDetailModel *t_model = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    self.comment_id = t_model.comment_id;
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    return 44;
}
//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    
    if (section == 1) {
        UILabel *headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMargin, 0, SCREEN_WIDTH - kMargin, 44)];
        headerTitleLabel.textColor = kBlackColor;
        headerTitleLabel.text = [NSString stringWithFormat:@"全部回复（%@）", [WXYZ_UtilsHelper formatStringWithInteger:self.appraiseDetailModel.total_count]];
        headerTitleLabel.font = kBoldMainFont;
        headerTitleLabel.backgroundColor = [UIColor clearColor];
        [view addSubview:headerTitleLabel];
    }
    
    return view;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }
    return CGFLOAT_MIN;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, PUB_TABBAR_OFFSET == 0 ? 10 : PUB_TABBAR_OFFSET)];
    if (section == 0) {
        view.backgroundColor = kGrayViewColor;
    } else {
        view.backgroundColor = [UIColor clearColor];
    }
    return view;
}

- (UILabel *)footerView
{
    if (!_footerView) {
        _footerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN)];
        _footerView.textColor = kGrayTextColor;
        _footerView.textAlignment = NSTextAlignmentCenter;
        _footerView.font = kFont10;
    }
    return _footerView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (void)netRequest
{
    WS(weakSelf)
    NSDictionary *parameters = [NSDictionary dictionary];
    switch (self.productionType) {
        case WXYZ_ProductionTypeBook:
            parameters = @{@"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber], @"comment_id":[WXYZ_UtilsHelper formatStringWithInteger:self.comment_id], @"type":@"1"};
            break;
        case WXYZ_ProductionTypeComic:
            parameters = @{@"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber], @"comment_id":[WXYZ_UtilsHelper formatStringWithInteger:self.comment_id], @"type":@"2"};
            break;
        case WXYZ_ProductionTypeAudio:
            parameters = @{@"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber], @"comment_id":[WXYZ_UtilsHelper formatStringWithInteger:self.comment_id], @"type":@"3"};
            break;
            
        default:
            break;
    }
    
    [WXYZ_NetworkRequestManger POST:Comment_Detail parameters:parameters model:WXYZ_AppraiseDetailModel.class success:^(BOOL isSuccess, WXYZ_AppraiseDetailModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            if (weakSelf.currentPageNumber == 1) {
                weakSelf.appraiseDetailModel = t_model;
                
                [weakSelf.mainTableViewGroup showRefreshFooter];
                [weakSelf.dataSourceArray removeAllObjects];
                weakSelf.dataSourceArray = [NSMutableArray arrayWithArray:t_model.list];
            } else {
                [weakSelf.dataSourceArray addObjectsFromArray:t_model.list];
            }
            if (t_model.total_page <= t_model.current_page) {
                [weakSelf.mainTableViewGroup hideRefreshFooter];
                weakSelf.footerView.text = @"已显示全部";
                weakSelf.footerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 30);
            } else {
                weakSelf.footerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN);
            }
            
            if (t_model.total_count == 0) {
                weakSelf.footerView.text = @"暂无评论回复";
                weakSelf.footerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 30);
            }
            [weakSelf.mainTableViewGroup setTableFooterView:weakSelf.footerView];
        }
        [weakSelf.mainTableViewGroup endRefreshing];
        [weakSelf.mainTableViewGroup reloadData];
        [weakSelf.mainTableViewGroup ly_endLoading];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf.mainTableViewGroup endRefreshing];
        [weakSelf.mainTableViewGroup ly_endLoading];
    }];
}

@end

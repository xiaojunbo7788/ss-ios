//
//  WXYZ_FeedbackListViewController.m
//  WXReader
//
//  Created by Andrew on 2019/12/28.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_FeedbackListViewController.h"
#import "WXYZ_FeedbackListTableViewCell.h"
#import "WXYZ_FeedbackListModel.h"

@interface WXYZ_FeedbackListViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation WXYZ_FeedbackListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
    [self netRequest];
}

- (void)initialize
{
    [self setNavigationBarTitle:@"我的反馈"];
}

- (void)createSubviews
{
    self.view.backgroundColor = kGrayViewColor;
    
    self.mainTableViewGroup.delegate = self;
    self.mainTableViewGroup.dataSource = self;
    [self.view addSubview:self.mainTableViewGroup];
    
    [self.mainTableViewGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT);
    }];
    
    WS(weakSelf)
    [self.mainTableViewGroup addHeaderRefreshWithRefreshingBlock:^{
        weakSelf.currentPageNumber = 1;
        [weakSelf netRequest];
    }];
    
    [self.mainTableViewGroup addFooterRefreshWithRefreshingBlock:^{
        weakSelf.currentPageNumber ++;
        [weakSelf netRequest];
    }];
    
    [self setEmptyOnView:self.mainTableViewGroup title:@"您还没有任何反馈" tapBlock:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSourceArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"WXYZ_FeedbackListTableViewCell";
    WXYZ_FeedbackListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_FeedbackListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.contentModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//section头间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHalfMargin;
}
//section头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kHalfMargin)];
    view.backgroundColor = kGrayViewColor;
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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, PUB_TABBAR_OFFSET == 0 ? 10 : PUB_TABBAR_OFFSET)];
    view.backgroundColor = kGrayViewColor;
    return view;
}

- (void)netRequest
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Feed_Back_List parameters:nil model:WXYZ_FeedbackListModel.class success:^(BOOL isSuccess, WXYZ_FeedbackListModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            if (weakSelf.currentPageNumber == 1) {
                weakSelf.dataSourceArray = [NSMutableArray arrayWithArray:t_model.list];
            } else {
                [weakSelf.dataSourceArray addObjectsFromArray:t_model.list];
            }
            
            [weakSelf.mainTableViewGroup reloadData];
            if (t_model.total_page <= t_model.current_page) {
                [weakSelf.mainTableViewGroup hideRefreshFooter];
            }
        }
        
        [weakSelf.mainTableViewGroup endRefreshing];
        [weakSelf.mainTableViewGroup ly_endLoading];
    } failure:nil];
}

@end

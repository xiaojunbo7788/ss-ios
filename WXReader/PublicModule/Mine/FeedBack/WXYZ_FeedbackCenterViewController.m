//
//  WXYZ_FeedbackCenterViewController.m
//  WXReader
//
//  Created by Andrew on 2019/12/23.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_FeedbackCenterViewController.h"
#import "WXYZ_FeedbackSubViewController.h"
#import "WXYZ_FeedbackListViewController.h"

#import "WXYZ_FeedbackCenterHeaderView.h"
#import "WXYZ_FeedbackCenterTableViewCell.h"

#import "WXYZ_FeedbackCenterModel.h"

@interface WXYZ_FeedbackCenterViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) WXYZ_FeedbackCenterModel *feedbackModel;

@property (nonatomic, assign) NSUInteger selectIndex; // 当前选择位置

@end

@implementation WXYZ_FeedbackCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
    [self netRequest];
}

- (void)initialize
{
    [self setNavigationBarTitle:@"帮助反馈"];
    self.selectIndex = 99999;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePhoto:) name:WX_DELETE_PHOTO object:nil];
}

- (void)createSubviews
{
    self.mainTableViewGroup.delegate = self;
    self.mainTableViewGroup.dataSource = self;
    [self.view addSubview:self.mainTableViewGroup];
    
    WS(weakSelf)
    WXYZ_FeedbackCenterHeaderView *headerView = [[WXYZ_FeedbackCenterHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    headerView.leftButtonClick = ^{
        [weakSelf.navigationController pushViewController:[[WXYZ_FeedbackListViewController alloc] init] animated:YES];
    };
    headerView.rightButtonClick = ^{
        [weakSelf.navigationController pushViewController:[[WXYZ_FeedbackSubViewController alloc] init] animated:YES];
    };
    [self.mainTableViewGroup setTableHeaderView:headerView];
    
    [self.mainTableViewGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT);
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.feedbackModel.help_list.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.feedbackModel.help_list objectAtIndex:section].list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_HelpListModel *sectionModel = [self.feedbackModel.help_list objectAtIndex:indexPath.section];
    WXYZ_QuestionListModel *indexModel = [sectionModel.list objectOrNilAtIndex:indexPath.row];
    
    static NSString *cellName = @"WXYZ_FeedbackCenterTableViewCell";
    WXYZ_FeedbackCenterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_FeedbackCenterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.questionModel = indexModel;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//section头间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
//section头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    view.backgroundColor = kGrayViewColor;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kHalfMargin, 0, SCREEN_WIDTH - 2 * kHalfMargin, 40)];
    titleLabel.text = [self.feedbackModel.help_list objectAtIndex:section].name?:@"";
    titleLabel.textColor = kGrayTextColor;
    titleLabel.font = kFont15;
    [view addSubview:titleLabel];
    
    return view;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == self.feedbackModel.help_list.count - 1) {
        return PUB_TABBAR_OFFSET == 0 ? 10 : PUB_TABBAR_OFFSET;
    }
    return CGFLOAT_MIN;
}

//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kHalfMargin)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_FeedbackCenterTableViewCell *cell = [self.mainTableViewGroup cellForRowAtIndexPath:indexPath];
    [self.mainTableViewGroup beginUpdates];
    if (cell.detailCellShowing) {
        [cell hiddenDetail];
    } else {
        [cell showDetail];        
    }
    [self.mainTableViewGroup endUpdates];
}

- (void)netRequest
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Answer_List parameters:nil model:WXYZ_FeedbackCenterModel.class success:^(BOOL isSuccess, WXYZ_FeedbackCenterModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            weakSelf.feedbackModel = t_model;
            [weakSelf.mainTableViewGroup reloadData];
        }
    } failure:nil];
}

- (void)deletePhoto:(NSNotification *)noti
{
    [WXYZ_NetworkRequestManger POST:Delete_Upload_Image parameters:@{@"image":[WXYZ_UtilsHelper formatStringWithObject:noti.object]} model:nil success:nil failure:nil];
}

@end

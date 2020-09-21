//
//  WXYZ_SticketViewController.m
//  WXReader
//
//  Created by LL on 2020/6/1.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_SticketLogViewController.h"

#import "WXYZ_SticketLogModel.h"
#import "NSObject+Observer.h"

#import "WXYZ_WebViewViewController.h"

@interface WXYZ_SticketLogViewController ()<UITableViewDataSource>

@property (nonatomic, strong) WXYZ_SticketLogModel *logModel;

@end

@implementation WXYZ_SticketLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netRequest) name:Notification_Login_Success object:nil];
    [self createSubviews];
    [self netRequest];
}

- (void)createSubviews {
    [self setNavigationBarTitle:@"月票记录"];
    
    UIButton *_rightBtn = nil;
    WS(weakSelf)
    [self setNavigationBarRightButton:({
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn = rightBtn;
        rightBtn.hidden = YES;
        rightBtn.adjustsImageWhenHighlighted = NO;
        [rightBtn setImage:[YYImage imageNamed:@"book_help"] forState:UIControlStateNormal];
        [rightBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            WXYZ_WebViewViewController *vc = [[WXYZ_WebViewViewController alloc] init];
            vc.URLString = weakSelf.logModel.ticket_rule ?: @"";
            vc.navTitle = @"月票说明";
            vc.isPresentState = NO;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }]];
        rightBtn;
    })];
    [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navigationBar.navTitleLabel);
        make.right.equalTo(self.view).offset(- kMoreHalfMargin);
        make.height.width.mas_equalTo(21);
    }];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.mainTableView];
    [self.mainTableView setContentInset:UIEdgeInsetsMake(0, 0, PUB_TABBAR_OFFSET, 0)];
    self.mainTableView.dataSource = self;
    [self.mainTableView registerClass:WXYZ_SticketViewCell.class forCellReuseIdentifier:@"Identifier"];
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(PUB_NAVBAR_HEIGHT);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    [self createEmptyView];
    
    [self.mainTableView addFooterRefreshWithRefreshingBlock:^{
        weakSelf.currentPageNumber++;
        [weakSelf netRequest];
    }];
}

- (void)createEmptyView {
    WS(weakSelf)
    if (!WXYZ_UserInfoManager.isLogin) {
        [self setEmptyOnView:self.mainTableView title:@"登录后查看月票记录" buttonTitle:@"立即登录" tapBlock:^{
            [WXYZ_LoginViewController presentLoginView:^(WXYZ_UserInfoManager * _Nonnull userDataModel) {
                weakSelf.emptyView = nil;
                [weakSelf createEmptyView];
            }];
        }];
    } else {
        [self setEmptyOnView:self.mainTableView title:@"暂无月票记录" buttonTitle:@"" tapBlock:^{
            
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.logModel.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXYZ_SticketViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier" forIndexPath:indexPath];
    [cell setLogModel:self.logModel.list[indexPath.row]];
    [cell setSplitLineHidden:self.logModel.list.count == indexPath.row + 1];
    return cell;
}

- (void)netRequest {
    if (!WXYZ_UserInfoManager.isLogin) {
        [self.mainTableView ly_showEmptyView];
        return;
    }
    
    NSDictionary *params = @{
        @"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber]
    };
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POSTQuick:Book_Reward_Ticket_Log parameters:params model:WXYZ_SticketLogModel.class success:^(BOOL isSuccess, WXYZ_SticketLogModel *_Nullable t_model, BOOL isCache, WXYZ_NetworkRequestModel *requestModel) {
        [weakSelf.mainTableView endRefreshing];
        if (isSuccess) {
            if (t_model.current_page == 1) {
                weakSelf.logModel = t_model;
            } else {
                weakSelf.logModel.list = [weakSelf.logModel.list arrayByAddingObjectsFromArray:t_model.list];
            }
            
            [weakSelf.mainTableView reloadData];
            
            if (t_model.current_page >= t_model.total_page) {
                [weakSelf.mainTableView hideRefreshFooter];
            }
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        }
        if (weakSelf.logModel.list.count > 0) {
            [weakSelf.mainTableView ly_hideEmptyView];
        } else {
            [weakSelf.mainTableView ly_showEmptyView];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
    }];
}

@end


@implementation WXYZ_SticketViewCell {
    UIView *_splitLine;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews {
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.textColor = kBlackColor;
    nameLabel.font = kFont14;
    [self.contentView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kMoreHalfMargin);
        make.left.equalTo(self.contentView).offset(kMoreHalfMargin);
    }];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.textColor = kGrayTextColor;
    timeLabel.font = kFont14;
    [self.contentView addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).offset(kHalfMargin);
        make.left.equalTo(self.contentView).offset(kMoreHalfMargin);
    }];
    
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.textColor = kGrayTextColor;
    descLabel.font = kFont14;
    [self.contentView addSubview:descLabel];
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-kMoreHalfMargin);
    }];
    
    _splitLine = [[UIView alloc] init];
    _splitLine.backgroundColor = kGrayLineColor;
    [self.contentView addSubview:_splitLine];
    [_splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kCellLineHeight);
        make.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(kMoreHalfMargin);
        make.right.equalTo(self.contentView).offset(-kMoreHalfMargin);
        make.top.equalTo(timeLabel.mas_bottom).offset(kMoreHalfMargin).priorityLow();
    }];
    
    [self addObserver:KEY_PATH(self, logModel) complete:^(id  _Nonnull obj, id  _Nullable oldVal, WXYZ_SticketLogListModel * _Nullable newVal) {
        nameLabel.text = newVal.title ?: @"";
        timeLabel.text = newVal.time ?: @"";
        descLabel.text = newVal.desc ?: @"";
    }];
}

- (void)setSplitLineHidden:(BOOL)hidden {
    _splitLine.hidden = hidden;
}

@end

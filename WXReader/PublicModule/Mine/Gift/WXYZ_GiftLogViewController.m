//
//  WXYZ_GiftLogViewController.m
//  WXReader
//
//  Created by LL on 2020/6/1.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_GiftLogViewController.h"

#import "WXYZ_GiftLogModel.h"

#import "NSObject+Observer.h"

@interface WXYZ_GiftLogViewController ()<UITableViewDataSource>

@property (nonatomic, strong) WXYZ_GiftLogModel *logModel;

@end

@implementation WXYZ_GiftLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netRequest) name:Notification_Login_Success object:nil];
    [self createSubviews];
    [self netRequest];
}

- (void)createSubviews {
    [self setNavigationBarTitle:@"打赏记录"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.mainTableView];
    [self.mainTableView setContentInset:UIEdgeInsetsMake(0, 0, PUB_TABBAR_OFFSET, 0)];
    self.mainTableView.dataSource = self;
    [self.mainTableView registerClass:WXYZ_GiftLogViewCell.class forCellReuseIdentifier:@"Identifier"];
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(PUB_NAVBAR_HEIGHT);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    [self createEmptyView];
    
    WS(weakSelf)
    [self.mainTableView addFooterRefreshWithRefreshingBlock:^{
        weakSelf.currentPageNumber++;
        [weakSelf netRequest];
    }];
}

- (void)createEmptyView {
    WS(weakSelf)
    if (!WXYZ_UserInfoManager.isLogin) {
        [self setEmptyOnView:self.mainTableView title:@"登录后查看打赏记录" buttonTitle:@"立即登录" tapBlock:^{
            [WXYZ_LoginViewController presentLoginView:^(WXYZ_UserInfoManager * _Nonnull userDataModel) {
                weakSelf.emptyView = nil;
                [weakSelf createEmptyView];
            }];
        }];
    } else {
        [self setEmptyOnView:self.mainTableView title:@"暂无打赏记录" buttonTitle:@"" tapBlock:^{
            
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.logModel.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXYZ_GiftLogViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier" forIndexPath:indexPath];
    [cell setLogModel:self.logModel.list[indexPath.row]];
    [cell setSplitLineHidden:self.logModel.list.count == indexPath.row + 1];
    return cell;
}

- (void)netRequest {
    if (!WXYZ_UserInfoManager.isLogin || [WXYZ_NetworkReachabilityManager networkingStatus] == NO) {
        [self.mainTableView ly_showEmptyView];
        return;
    }
    
    NSDictionary *params = @{
        @"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber]
    };
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POSTQuick:Book_Reward_Gift_Log parameters:params model:WXYZ_GiftLogModel.class success:^(BOOL isSuccess, WXYZ_GiftLogModel *_Nullable t_model, BOOL isCache, WXYZ_NetworkRequestModel *requestModel) {
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
        if (weakSelf.logModel.list.count > 0) {
            [weakSelf.mainTableView ly_hideEmptyView];
        } else {
            [weakSelf.mainTableView ly_showEmptyView];
        }
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
    }];
}

@end


@implementation WXYZ_GiftLogViewCell {
    UIView *_splitLine;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
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
        make.top.equalTo(self.contentView).offset(kMargin);
        make.left.equalTo(self.contentView).offset(kMoreHalfMargin);
    }];
    
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.textColor = kGrayTextColor;
    descLabel.font = kFont13;
    [self.contentView addSubview:descLabel];
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).offset(kHalfMargin);
        make.left.equalTo(nameLabel);
    }];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.textColor = kGrayTextColor;
    timeLabel.font = kFont13;
    [self.contentView addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(descLabel.mas_bottom).offset(kHalfMargin);
        make.left.equalTo(nameLabel);
    }];
    
    _splitLine = [[UIView alloc] init];
    _splitLine.backgroundColor = kGrayLineColor;
    [self.contentView addSubview:_splitLine];
    [_splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kCellLineHeight);
        make.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(kMoreHalfMargin);
        make.right.equalTo(self.contentView).offset(-kMoreHalfMargin);
        make.top.equalTo(timeLabel.mas_bottom).offset(kHalfMargin).priorityLow();
    }];
    
    [self addObserver:KEY_PATH(self, logModel) complete:^(id  _Nonnull obj, id  _Nullable oldVal, WXYZ_GiftLogListModel * _Nullable newVal) {
        nameLabel.text = newVal.title ?: @"";
        timeLabel.text = newVal.time ?: @"";
        descLabel.text = newVal.desc ?: @"";
    }];
}

- (void)setSplitLineHidden:(BOOL)hidden {
    _splitLine.hidden = hidden;
}

@end

//
//  WXYZ_FeedbackSubViewController.m
//  WXReader
//
//  Created by Andrew on 2018/7/4.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_FeedbackSubViewController.h"

#import "WXYZ_FeedbackTextViewTableViewCell.h"
#import "WXYZ_FeedbackPhotoTableViewCell.h"
#import "WXYZ_FeedbackContactTableViewCell.h"

#import "WXYZ_TextView.h"
#import "WXYZ_KeyboardManager.h"
#import "WXYZ_FeedbackPhotoManager.h"

@interface WXYZ_FeedbackSubViewController () <UITableViewDelegate, UITableViewDataSource>
{
    UIButton *submitButton;
    WXYZ_KeyboardManager *keyboardManager;
}

@property (nonatomic, strong) NSString *contentString;

@property (nonatomic, strong) NSString *contactString;

@end

@implementation WXYZ_FeedbackSubViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarDefaultStyle];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self navigationCanSlidingBack:NO];
}

- (void)initialize
{
    [self setNavigationBarTitle:@"意见反馈"];
    [self hiddenNavigationBarLeftButton];
    self.view.backgroundColor = kGrayViewColor;
}

- (void)createSubviews
{
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.backgroundColor = [UIColor clearColor];
    leftButton.frame = CGRectMake(kHalfMargin, PUB_NAVBAR_OFFSET + 20, 44, 44);
    leftButton.adjustsImageWhenHighlighted = NO;
    [leftButton.titleLabel setFont:kMainFont];
    [leftButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(12, 6, 12, 18)];
    [leftButton setImage:[[UIImage imageNamed:@"public_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [leftButton setTintColor:kBlackColor];
    [leftButton addTarget:self action:@selector(giveUpSubmit) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:leftButton];
    
    self.mainTableViewGroup.delegate = self;
    self.mainTableViewGroup.dataSource = self;
    [self.view addSubview:self.mainTableViewGroup];
    
    [self.mainTableViewGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT - PUB_TABBAR_HEIGHT);
    }];
    
    submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitButton.backgroundColor = kRedColor;
    [submitButton setTitle:@"提交" forState:UIControlStateNormal];
    [submitButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [submitButton.titleLabel setFont:kMainFont];
    [submitButton addTarget:self action:@selector(netRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitButton];
    
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).with.offset(- PUB_TABBAR_OFFSET);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT - PUB_TABBAR_OFFSET);
    }];
    
    WS(weakSelf)
    keyboardManager = [[WXYZ_KeyboardManager alloc] initObserverWithAdaptiveMovementView:self.mainTableViewGroup];
    keyboardManager.keyboardHeightChanged = ^(CGFloat keyboardHeight, CGFloat shouldMoveDistance, CGRect shouldMoveFrame) {
        [weakSelf.mainTableViewGroup setMj_y:weakSelf.mainTableViewGroup.mj_y + shouldMoveDistance];
    };
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WS(weakSelf)
    switch (indexPath.section) {
        case 0:
        {
            static NSString *cellName = @"WXYZ_FeedbackTextViewTableViewCell";
            WXYZ_FeedbackTextViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (!cell) {
                cell = [[WXYZ_FeedbackTextViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            }
            cell.textViewDidChange = ^(NSString * _Nonnull contentString) {
                weakSelf.contentString = contentString;
            };
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
        case 1:
        {
            static NSString *cellName = @"WXYZ_FeedbackPhotoTableViewCell";
            WXYZ_FeedbackPhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (!cell) {
                cell = [[WXYZ_FeedbackPhotoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            }
            cell.operationPhotosBlock = ^(NSMutableArray * _Nonnull photosSource) {
                weakSelf.dataSourceArray = photosSource;
            };
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
        case 2:
        {
            static NSString *cellName = @"WXYZ_FeedbackContactTableViewCell";
            WXYZ_FeedbackContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (!cell) {
                cell = [[WXYZ_FeedbackContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            }
            cell.contactDidChange = ^(NSString * _Nonnull contactString) {
                weakSelf.contactString = contactString;
            };
            
            __weak WXYZ_FeedbackContactTableViewCell *weakCell = cell;
            cell.willBeginEditing = ^{
                keyboardManager.adaptiveMovementView = weakCell;
            };
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
        default:
            break;
    }
    
    return [[UITableViewCell alloc] init];
}

//section头间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return KCellHeight;
}
//section头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, KCellHeight)];
    view.backgroundColor = kGrayViewColor;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kHalfMargin, 0, SCREEN_WIDTH - 2 * kHalfMargin, 40)];
    titleLabel.textColor = kGrayTextColor;
    titleLabel.font = kFont15;
    [view addSubview:titleLabel];
    
    switch (section) {
        case 0:
            titleLabel.text = @"问题反馈";
            break;
        case 1:
            titleLabel.text = @"提供问题截图（选填）";
            break;
        case 2:
            titleLabel.text = @"联系方式（至少填写一项）";
            break;
            
        default:
            break;
    }
    
    return view;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 2) {
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [WXYZ_KeyboardManager hideKeyboard];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [WXYZ_KeyboardManager hideKeyboard];
}

- (void)giveUpSubmit
{
    WS(weakSelf)
    if (self.contentString.length > 0 || self.contactString.length > 0 || [WXYZ_FeedbackPhotoManager sharedManager].isUploading || self.dataSourceArray.count > 0) {
        WXYZ_AlertView *alert = [[WXYZ_AlertView alloc] init];
        alert.alertViewDetailContent = @"您有修改尚未提交，是否放弃修改？";
        alert.alertViewConfirmTitle = @"放弃修改";
        alert.alertViewCancelTitle = @"取消";
        alert.confirmButtonClickBlock = ^{
            [[WXYZ_FeedbackPhotoManager sharedManager] removeAllPhotoImageWithPhotoArray:weakSelf.dataSourceArray];
            [weakSelf popViewController];
        };
        [alert showAlertView];
        return;
    }
    
    [self popViewController];
}

- (void)netRequest
{
    [WXYZ_KeyboardManager hideKeyboard];
    
    if (self.contentString.length == 0) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"请完善问题描述"];
        return;
    }
    
    if (self.contactString.length == 0) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"请填写联系方式"];
        return;
    }
    
    if ([WXYZ_FeedbackPhotoManager sharedManager].isUploading) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"图片正在上传中，请稍后"];
        return;
    }
    
    NSMutableDictionary *t_dic = [NSMutableDictionary dictionary];
    [t_dic setObject:self.contentString forKey:@"content"];
    [t_dic setObject:self.contactString forKey:@"contact"];
    if (self.dataSourceArray.count > 0) {
        NSMutableArray *imgs = [NSMutableArray arrayWithCapacity:3];
        for (WXYZ_FeedbackPhotoModel *t_model in self.dataSourceArray) {
            [imgs addObject:t_model.img];
        }
        [t_dic setObject:[imgs componentsJoinedByString:@"||"] forKey:@"imgs"];
    }
    
    submitButton.enabled = NO;
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Sub_Feed_Back parameters:t_dic model:nil success:^(BOOL isSuccess, id _Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"反馈成功"];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {
            SS(strongSelf)
            strongSelf->submitButton.enabled = YES;
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        }
    } failure:nil];
}

- (void)dealloc
{
    [keyboardManager stopKeyboardObserver];
}

@end

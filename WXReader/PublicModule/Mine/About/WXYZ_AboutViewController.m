//
//  WXYZ_AboutViewController.m
//  WXReader
//
//  Created by Andrew on 2018/10/15.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "WXYZ_AboutViewController.h"
#import "WXYZ_AboutModel.h"
#import "WXYZ_AboutTableViewCell.h"
#import "WXYZ_WebViewViewController.h"

@interface WXYZ_AboutViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) WXYZ_AboutModel *aboutModel;

@property (nonatomic, strong) UILabel *companyLabel;

@end

@implementation WXYZ_AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
    [self netRequest];
}
- (void)initialize
{
    [self setNavigationBarTitle:@"联系客服"];
    self.view.backgroundColor = kGrayViewColor;
}
- (void)createSubviews
{
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    [self.view addSubview:self.mainTableView];
    
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_height).with.offset(- PUB_NAVBAR_HEIGHT);
    }];
    
    [self.mainTableView setTableHeaderView:[self headerView]];
    
    self.companyLabel = [[UILabel alloc] init];
    self.companyLabel.textAlignment = NSTextAlignmentCenter;
    self.companyLabel.textColor = [UIColor grayColor];
    self.companyLabel.numberOfLines = 0;
    self.companyLabel.font = kFont10;
    [self.mainTableView addSubview:self.companyLabel];
    
    [self.companyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(30);
        make.bottom.mas_equalTo(SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT - (is_iPhoneX?15.0f:0.0f));
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.aboutModel.about.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_AboutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_AboutTableViewCell"];
    
    if (!cell) {
        cell = [[WXYZ_AboutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_AboutTableViewCell"];
        
    }
    cell.contactInfoModel = [self.aboutModel.about objectAtIndex:indexPath.row];
    cell.hiddenEndLine = (indexPath.row == self.aboutModel.about.count - 1);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ContactInfoModel *t_model = [self.aboutModel.about objectAtIndex:indexPath.row];
    
    if ([t_model.action isEqualToString:@"url"]) {
        WXYZ_WebViewViewController *vc = [[WXYZ_WebViewViewController alloc] init];
        vc.navTitle = t_model.title?:@"";
        vc.URLString = t_model.content?:@"";
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([t_model.action isEqualToString:@"telphone"]) {
        NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",t_model.content]];
        [[UIApplication sharedApplication] openURL:phoneURL options:@{} completionHandler:nil];
    } else {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = t_model.content?:@"";
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"已复制到粘贴板"];
    }
}

- (UIView *)headerView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 180)];
    view.backgroundColor = kWhiteColor;
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[[[[NSBundle mainBundle] infoDictionary] valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject]]];
    [iconImageView zy_cornerRadiusAdvance:12.0f rectCornerType:UIRectCornerAllCorners];
    [view addSubview:iconImageView];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(view.mas_centerX);
        make.bottom.mas_equalTo(view.mas_centerY).with.offset(10);
        make.width.height.mas_equalTo(60);
    }];
    
    UILabel *appNameLabel = [[UILabel alloc] init];
    appNameLabel.text = App_Name;
    appNameLabel.textAlignment = NSTextAlignmentCenter;
    appNameLabel.textColor = kBlackColor;
    appNameLabel.font = kMainFont;
    [view addSubview:appNameLabel];
    
    [appNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(iconImageView.mas_centerX);
        make.top.mas_equalTo(iconImageView.mas_bottom).with.offset(10);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(20);
    }];
    
    return view;
}

- (void)netRequest
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:About_Soft parameters:nil model:WXYZ_AboutModel.class success:^(BOOL isSuccess, WXYZ_AboutModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            weakSelf.aboutModel = t_model;
            weakSelf.companyLabel.text = t_model.company;
        }
        [weakSelf.mainTableView reloadData];
    } failure:nil];
}

@end

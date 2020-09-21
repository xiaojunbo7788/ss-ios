//
//  WXYZ_InsterestViewController.m
//  WXReader
//
//  Created by Andrew on 2018/11/16.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "WXYZ_InsterestViewController.h"
#import "WXYZ_InsterestSexViewController.h"
#import "WXYZ_InsterestBooksViewController.h"

#import "WXYZ_InsterestBookModel.h"

@interface WXYZ_InsterestViewController ()
{
    WXYZ_InsterestSexViewController *insterestSex;
    WXYZ_InsterestBooksViewController *insterestBooks;
}

@end

@implementation WXYZ_InsterestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self setStatusBarDefaultStyle];
}

- (void)initialize
{
    [self hiddenNavigationBar:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextStep:) name:Notification_Insterest_Change object:nil];
}

- (void)createSubviews
{
    insterestBooks = [[WXYZ_InsterestBooksViewController alloc] init];
    [self addChildViewController:insterestBooks];
    [self.view addSubview:insterestBooks.view];
    
    insterestSex = [[WXYZ_InsterestSexViewController alloc] init];
    [self addChildViewController:insterestSex];
    [self.view addSubview:insterestSex.view];
    
    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    skipButton.backgroundColor = [UIColor clearColor];
    [skipButton setTitle:@"跳过" forState:UIControlStateNormal];
    [skipButton setTitleColor:kGrayTextColor forState:UIControlStateNormal];
    [skipButton.titleLabel setFont:kFont12];
    [skipButton addTarget:self action:@selector(skipButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipButton];
    
    [skipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).with.offset(- kHalfMargin);
        make.top.mas_equalTo(kStatusBarHeight + kMargin);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(20);
    }];
}

- (void)nextStep:(NSNotification *)noti
{
    if ([noti.object isEqualToString:@"step_one"]) {
        [self networkRequest];
        
    } else if ([noti.object isEqualToString:@"step_two"]) {
        [self skipButtonClick];
    }
    
}

- (void)skipButtonClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)networkRequest
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Start_Recommend parameters:@{@"channel_id":@(WXYZ_SystemInfoManager.sexChannel)} model:WXYZ_InsterestBookModel.class success:^(BOOL isSuccess, WXYZ_InsterestBookModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            NSMutableArray *t_arr = [NSMutableArray array];
            
            for (WXYZ_ProductionModel *model in t_model.book) {
                model.productionType = WXYZ_ProductionTypeBook;
                [t_arr addObject:model];
            }
            
            for (WXYZ_ProductionModel *model in t_model.comic) {
                model.productionType = WXYZ_ProductionTypeComic;
                [t_arr addObject:model];
            }
            
            for (WXYZ_ProductionModel *model in t_model.audio) {
                model.productionType = WXYZ_ProductionTypeAudio;
                [t_arr addObject:model];
            }

            SS(strongSelf)
            if (t_arr.count == 0) {
                [weakSelf skipButtonClick];
            } else {
                [insterestSex willMoveToParentViewController:nil];
                [insterestSex removeFromParentViewController];
                [insterestSex.view removeFromSuperview];
                strongSelf->insterestBooks.productionArray = [t_arr copy];
            }
        } else {
            [weakSelf skipButtonClick];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf skipButtonClick];
    }];
}

@end

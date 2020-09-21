//
//  WXYZ_BookReaderMenuPayView.m
//  WXReader
//
//  Created by Andrew on 2018/7/15.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BookReaderMenuPayView.h"
#import "WXYZ_RechargeViewController.h"

#import "WXYZ_ChapterBottomPayBar.h"

#import "WXYZ_ReaderSettingHelper.h"
#import "WXYZ_ReaderBookManager.h"

@interface WXYZ_BookReaderMenuPayView ()
{
    WXYZ_ReaderSettingHelper *functionalManager;
}

@end

@implementation WXYZ_BookReaderMenuPayView

- (instancetype)init
{
    if (self = [super init]) {
        [self initialize];        
        [self createSubViews];
    }
    return self;
}

- (void)initialize
{
    self.frame = CGRectMake(0, SCREEN_HEIGHT / 2 - PUB_TABBAR_OFFSET - 2 * kMargin, SCREEN_WIDTH, SCREEN_HEIGHT / 2);
    self.backgroundColor = [UIColor clearColor];
    
    functionalManager = [WXYZ_ReaderSettingHelper sharedManager];
}

- (void)createSubViews
{
    UIButton *buyBulkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    buyBulkButton.layer.cornerRadius = 4;
    buyBulkButton.layer.borderColor = [functionalManager getReaderTextColor].CGColor;
    buyBulkButton.layer.borderWidth = 0.7;
    buyBulkButton.clipsToBounds = YES;
    [buyBulkButton setTitle:@"批量购买更优惠" forState:UIControlStateNormal];
    [buyBulkButton setTitleColor:[functionalManager getReaderTextColor] forState:UIControlStateNormal];
    [buyBulkButton.titleLabel setFont:kMainFont];
    [buyBulkButton addTarget:self action:@selector(buyBulkButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:buyBulkButton];
    
    [buyBulkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).with.offset(- 2 * kMargin);
        make.left.mas_equalTo(self.mas_left).with.offset(2 * kMargin);
        make.right.mas_equalTo(self.mas_right).with.offset(- 2 * kMargin);
        make.height.mas_equalTo(40);
    }];
    
    UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    buyButton.layer.cornerRadius = 4;
    buyButton.layer.borderColor = [functionalManager getReaderTextColor].CGColor;
    buyButton.layer.borderWidth = 0.7;
    buyButton.clipsToBounds = YES;
    [buyButton setTitle:@"确定购买" forState:UIControlStateNormal];
    [buyButton setTitleColor:[functionalManager getReaderTextColor] forState:UIControlStateNormal];
    [buyButton.titleLabel setFont:kMainFont];
    [buyButton addTarget:self action:@selector(buyCurrentChapter) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:buyButton];
    
    [buyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(buyBulkButton.mas_top).with.offset(- 15);
        make.left.mas_equalTo(buyBulkButton.mas_left);
        make.right.mas_equalTo(buyBulkButton.mas_right);
        make.height.mas_equalTo(buyBulkButton.mas_height);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"支持正版";
    titleLabel.textColor = [functionalManager getReaderTextColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = kFont10;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.bottom.mas_equalTo(buyButton.mas_top).with.offset( - 2 * kMargin);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(20);
    }];
    
    UIView *leftLine = [[UIView alloc] init];
    leftLine.backgroundColor = [functionalManager getReaderTextColor];
    [self addSubview:leftLine];
    
    [leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(titleLabel.mas_centerY);
        make.left.mas_equalTo(buyBulkButton.mas_left);
        make.right.mas_equalTo(titleLabel.mas_left).with.offset(- kHalfMargin);
        make.height.mas_equalTo(kCellLineHeight);
    }];
    
    UIView *rightLine = [[UIView alloc] init];
    rightLine.backgroundColor = [functionalManager getReaderTextColor];
    [self addSubview:rightLine];
    
    [rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(titleLabel.mas_centerY);
        make.left.mas_equalTo(titleLabel.mas_right).with.offset(kHalfMargin);
        make.right.mas_equalTo(buyBulkButton.mas_right);
        make.height.mas_equalTo(kCellLineHeight);
    }];
}

- (void)buyBulkButtonClick
{
    WXYZ_ReaderBookManager *bookManager = [WXYZ_ReaderBookManager sharedManager];
    
    WXYZ_ProductionChapterModel *t_model = [[WXYZ_ProductionChapterModel alloc] init];
    t_model.production_id = bookManager.book_id;
    t_model.chapter_id = bookManager.chapter_id;
    
    
    WXYZ_ChapterBottomPayBar *payBar = [[WXYZ_ChapterBottomPayBar alloc] initWithChapterModel:t_model barType:WXYZ_BottomPayBarTypeBuyChapter productionType:WXYZ_ProductionTypeBook];
    [payBar showBottomPayBar];
}

- (void)buyCurrentChapter
{
    if (!WXYZ_UserInfoManager.isLogin) {
        [WXYZ_LoginViewController presentLoginView];
        return;
    }
    
    WXYZ_ReaderBookManager *bookManager = [WXYZ_ReaderBookManager sharedManager];
    
    WXYZ_ProductionChapterModel *t_model = [[WXYZ_ProductionChapterModel alloc] init];
    t_model.production_id = bookManager.book_id;
    t_model.chapter_id = bookManager.chapter_id;
    
    [WXYZ_NetworkRequestManger POST:Book_Buy_Chapter parameters:@{@"book_id":[WXYZ_UtilsHelper formatStringWithInteger:bookManager.book_id], @"chapter_id":[WXYZ_UtilsHelper formatStringWithInteger:bookManager.chapter_id], @"num":@"1"} model:nil success:^(BOOL isSuccess, id  _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            NSArray<NSString *> *t_arr = [requestModel.data objectForKey:@"chapter_ids"];
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"购买成功"];
            NSInteger index = [WXYZ_ReaderBookManager sharedManager].currentChapterIndex;
            [WXYZ_ReaderBookManager sharedManager].bookModel.chapter_list[index].is_preview = NO;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Retry_Chapter object:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Production_Pay_Success object:t_arr];

        } else if (requestModel.code == 802) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Reader_Push object:@"WXYZ_RechargeViewController"];
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        }
            
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
    }];
}

@end

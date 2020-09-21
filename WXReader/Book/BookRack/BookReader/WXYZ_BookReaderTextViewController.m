//
//  WXYZ_BookReaderTextViewController.m
//  WXReader
//
//  Created by Andrew on 2018/5/29.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BookReaderTextViewController.h"
#import "TYAttributedLabel.h"
#import "WXYZ_ReaderBookManager.h"
#import "WXYZ_ReaderSettingHelper.h"
#import "WXYZ_BatteryView.h"
#import "LYEmptyViewHeader.h"
#import "WXYZ_BookReaderMenuPayView.h"
#import "NSAttributedString+TReaderPage.h"
#import "WXYZ_NetworkReachabilityManager.h"

#import "WXYZ_ReaderBookManager.h"

@interface WXYZ_BookReaderTextViewController ()
{
    UILabel *emptyTitleLabel;
    UIButton *emptyButton;
}

@property (nonatomic, strong) UILabel *chapterTitleLabel;

@property (nonatomic, strong) UILabel *bookNameLabel;

@property (nonatomic, strong) UILabel *pageNumberLabel;

@property (nonatomic, strong) TYAttributedLabel *chapterContentLabel;

@property (nonatomic, strong) WXYZ_BatteryView *battery;

@property (nonatomic, strong) WXYZ_BookReaderMenuPayView *payView;

@end

@implementation WXYZ_BookReaderTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [[WXYZ_ReaderSettingHelper sharedManager] getReaderBackgroundColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFrame) name:Notification_Check_Setting_Update object:nil];
    
    WS(weakSelf)
    [WXYZ_ReaderSettingHelper sharedManager].readerBackgroundViewChanged = ^() {
        [weakSelf reloadSubviews];
        [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Retry_Chapter object:nil];
    };
}

- (void)setContentString:(NSAttributedString *)contentString
{
    if ([contentString.string isEqualToString:k_Chapter_RequstFail] || !contentString) {
        [self createEmptyView];
        [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_EmptyView_Changed object:@1];
        return;
    }
    [self reloadSubviews];
    
    if ([[WXYZ_ReaderBookManager sharedManager] isPreviewChapter] && contentString.length > 1) {
        CGSize size = CGSizeMake(CGRectGetWidth(self.chapterContentLabel.bounds), CGRectGetHeight(self.chapterContentLabel.bounds) / 2.0);
        NSArray<NSValue *> *t_arr = [contentString pageRangeArrayWithConstrainedToSize:size];
        if (t_arr.count > 0) {
            NSRange range = [t_arr.firstObject rangeValue];
            contentString = [contentString attributedSubstringFromRange:range];
        }
        
        [self payView];
    } else {
        WXYZ_ReaderBookManager *manager = [WXYZ_ReaderBookManager sharedManager];
        NSString *chapter_id = [NSString stringWithFormat:@"%zd", manager.chapter_id];
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Production_Pay_Success object:@[chapter_id]];
        _payView.hidden = YES;
    }
    
    _contentString = contentString;
    self.chapterContentLabel.attributedText = contentString;
    
    // 总章节页数
    NSUInteger totalChapterPagerCount = [[WXYZ_ReaderBookManager sharedManager] totalChapterPagerCount];
    NSUInteger readedPagerCount = ([[WXYZ_ReaderBookManager sharedManager] currentPagerIndex] + 1) + (([[WXYZ_ReaderBookManager sharedManager] currentChapterPagerCount]) * ([[WXYZ_ReaderBookManager sharedManager] currentChapterIndex]));
    
    float progressValue = [[NSNumber numberWithUnsignedInteger:readedPagerCount] floatValue] / [[NSNumber numberWithUnsignedInteger:totalChapterPagerCount] floatValue] * 100;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.pageNumberLabel.text = [NSString stringWithFormat:@"%.1lf%@", progressValue < 0.1?0.1f:progressValue, @"%"];
    });
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_EmptyView_Changed object:@0];
}

- (void)reloadSubviews
{
    kCodeSync({
        self.view.backgroundColor = [[WXYZ_ReaderSettingHelper sharedManager] getReaderBackgroundColor];
        
        UIColor *textColor = [[WXYZ_ReaderSettingHelper sharedManager] getReaderTextColor];
        UIColor *titleTextColor = [[WXYZ_ReaderSettingHelper sharedManager] getReaderTitleTextColor];
        
        self.chapterContentLabel.font = [UIFont systemFontOfSize:[[WXYZ_ReaderSettingHelper sharedManager] getReaderFontSize]];
        self.chapterContentLabel.linesSpacing = [[WXYZ_ReaderSettingHelper sharedManager] getReaderLinesSpacing];
        
        self.bookNameLabel.text = [[WXYZ_ReaderBookManager sharedManager] getBookName];
        self.bookNameLabel.textColor = titleTextColor;
        
        self.chapterTitleLabel.text = [[WXYZ_ReaderBookManager sharedManager] getChapterTitle];
        self.chapterTitleLabel.textColor = titleTextColor;
        
        self.chapterContentLabel.textColor = textColor;
        
        self.battery.batteryTintColor = titleTextColor;
        
        self.pageNumberLabel.textColor = [[WXYZ_ReaderSettingHelper sharedManager] getReaderTitleTextColor];
        self.pageNumberLabel.hidden = NO;
        
        emptyButton.hidden = YES;
        emptyTitleLabel.hidden = YES;
        
        if ([WXYZ_ReaderBookManager sharedManager].currentChapterIndex == 0 && [WXYZ_ReaderBookManager sharedManager].currentPagerIndex == 0) {
            self.chapterTitleLabel.hidden = YES;
            self.battery.hidden = YES;
            self.pageNumberLabel.hidden = YES;
            self.bookNameLabel.hidden = YES;
        } else {
            self.chapterTitleLabel.hidden = NO;
            self.battery.hidden = NO;
            self.pageNumberLabel.hidden = NO;
            self.bookNameLabel.hidden = NO;
        }
    });
}

- (void)reloadFrame
{
    [self reloadSubviews];
    _pageNumberLabel.frame = CGRectMake(SCREEN_WIDTH / 2, [[WXYZ_ReaderSettingHelper sharedManager] getReaderViewBottom] + kHalfMargin, (SCREEN_WIDTH - 2 * kMargin) / 2, kMargin);
    _battery.frame = CGRectMake(kMargin, [[WXYZ_ReaderSettingHelper sharedManager] getReaderViewBottom] + kHalfMargin, SCREEN_WIDTH / 2, kMargin);
    _bookNameLabel.frame = CGRectMake(SCREEN_WIDTH / 3, [[WXYZ_ReaderSettingHelper sharedManager] getReaderViewBottom] + kHalfMargin, SCREEN_WIDTH / 3, kMargin);
    _chapterContentLabel.frame = [[WXYZ_ReaderSettingHelper sharedManager] getReaderViewFrame];
}

- (UILabel *)pageNumberLabel
{
    if (!_pageNumberLabel) {
        _pageNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2, [[WXYZ_ReaderSettingHelper sharedManager] getReaderViewBottom] + kHalfMargin, (SCREEN_WIDTH - 2 * kMargin) / 2, kMargin)];
        _pageNumberLabel.text = @"0.1%";
        _pageNumberLabel.font = kFont12;
        _pageNumberLabel.hidden = YES;
        _pageNumberLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:_pageNumberLabel];
    }
    return _pageNumberLabel;
}

- (WXYZ_BatteryView *)battery
{
    if (!_battery) {
        _battery = [[WXYZ_BatteryView alloc] initWithFrame:CGRectMake(kMargin, [[WXYZ_ReaderSettingHelper sharedManager] getReaderViewBottom] + kHalfMargin, SCREEN_WIDTH / 2, kMargin)];
        [self.view addSubview:_battery];
    }
    return _battery;
}

- (UILabel *)bookNameLabel
{
    if (!_bookNameLabel) {
        _bookNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 3, [[WXYZ_ReaderSettingHelper sharedManager] getReaderViewBottom] + kHalfMargin, SCREEN_WIDTH / 3, kMargin)];
        _bookNameLabel.font = kFont12;
        _bookNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_bookNameLabel];
    }
    return _bookNameLabel;
}

- (UILabel *)chapterTitleLabel
{
    if (!_chapterTitleLabel) {
        _chapterTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMargin, kMargin + PUB_NAVBAR_OFFSET, (SCREEN_WIDTH - 2 * kMargin) / 2, kMargin)];
        _chapterTitleLabel.font = kFont12;
        _chapterTitleLabel.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:_chapterTitleLabel];
    }
    return _chapterTitleLabel;
}

- (TYAttributedLabel *)chapterContentLabel
{
    if (!_chapterContentLabel) {
        _chapterContentLabel = nil;
        kCodeSync({
            _chapterContentLabel = [[TYAttributedLabel alloc] init];
            _chapterContentLabel.frame = [[WXYZ_ReaderSettingHelper sharedManager] getReaderViewFrame];
            _chapterContentLabel.font = [UIFont systemFontOfSize:[[WXYZ_ReaderSettingHelper sharedManager] getReaderFontSize]];
            _chapterContentLabel.backgroundColor = [UIColor clearColor];
            _chapterContentLabel.linesSpacing = [[WXYZ_ReaderSettingHelper sharedManager] getReaderLinesSpacing];
            _chapterContentLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [self.view addSubview:_chapterContentLabel];
        });
    }
    return _chapterContentLabel;
}

- (WXYZ_BookReaderMenuPayView *)payView
{
    if (!_payView) {
        _payView = [[WXYZ_BookReaderMenuPayView alloc] init];
        [self.view addSubview:_payView];
    }
    _payView.hidden = NO;
    return _payView;
}

- (void)createEmptyView
{
    if (!emptyTitleLabel) {
        emptyTitleLabel = [[UILabel alloc] init];
        emptyTitleLabel.textColor = [WXYZ_ReaderSettingHelper sharedManager].getReaderTextColor;
        emptyTitleLabel.font = kFont16;
        emptyTitleLabel.text = @"内容加载失败";
        emptyTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:emptyTitleLabel];
        
        [emptyTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.view.mas_centerY).with.offset(- kHalfMargin);
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.height.mas_equalTo(kLabelHeight);
        }];
    }
    
    if (!emptyButton) {
        emptyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        emptyButton.backgroundColor = [UIColor clearColor];
        emptyButton.layer.cornerRadius = 15;
        emptyButton.layer.borderColor = [WXYZ_ReaderSettingHelper sharedManager].getReaderTextColor.CGColor;
        emptyButton.layer.borderWidth = 1.0;
        [emptyButton setTitle:@"重试" forState:UIControlStateNormal];
        [emptyButton setTitleColor:[WXYZ_ReaderSettingHelper sharedManager].getReaderTextColor forState:UIControlStateNormal];
        [emptyButton.titleLabel setFont:kFont12];
        [emptyButton addTarget:self action:@selector(retryClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:emptyButton];
        
        [emptyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.top.mas_equalTo(emptyTitleLabel.mas_bottom);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(kLabelHeight);
        }];
    }
    
    emptyButton.hidden = NO;
    emptyTitleLabel.hidden = NO;
}

- (void)retryClick:(UIButton *)sender
{
    if (![WXYZ_NetworkReachabilityManager networkingStatus] || [WXYZ_NetworkReachabilityManager currentNetworkStatus] == kCTCellularDataRestrictedStateUnknown) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Retry_Chapter object:@"1"];
}

@end

//
//  WXYZ_AnnouncementInfoViewController.m
//  WXReader
//
//  Created by Andrew on 2018/8/6.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_AnnouncementInfoViewController.h"

@interface WXYZ_AnnouncementInfoViewController ()

@end

@implementation WXYZ_AnnouncementInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
    
}
- (void)initialize
{
    [self setNavigationBarTitle:self.titleText.length > 0?self.titleText:@"公告栏"];
    self.view.backgroundColor = kWhiteColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Hidden_Tabbar object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Show_Tabbar object:@"animation"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setStatusBarDefaultStyle];
}

- (void)createSubviews
{
    YYTextView *textView = [[YYTextView alloc] init];
    textView.editable = NO;
    textView.textColor = kBlackColor;
    textView.font = kMainFont;
    [self.view addSubview:textView];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString: self.contentText.length > 0 ?self.contentText:@""];
    text.lineSpacing = 5;
    text.font = kMainFont;
    textView.attributedText = text;
    
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT + kHalfMargin);
        make.width.mas_equalTo(SCREEN_WIDTH - kMargin);
        make.height.mas_equalTo(SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT - kHalfMargin);
    }];
}

@end

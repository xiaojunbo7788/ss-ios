//
//  WXYZ_GuideViewController.m
//  WXReader
//
//  Created by Andrew on 2019/4/1.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_GuideViewController.h"
#import "YYTextView.h"

@interface WXYZ_GuideViewController ()
{
    YYTextView *rulesView;
}
@end

@implementation WXYZ_GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
}

- (void)initialize
{
    [self setNavigationBarTitle:@"签到规则"];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)createSubviews
{
    rulesView = [[YYTextView alloc] init];
    rulesView.backgroundColor = kWhiteColor;
    rulesView.editable = NO;
    rulesView.selectable = NO;
    rulesView.textColor = KGrayTextMiddleColor;
    rulesView.font = kMainFont;
    [self.view addSubview:rulesView];
    
    [rulesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT + kHalfMargin);
        make.left.mas_equalTo(kHalfMargin);
        make.width.mas_equalTo(SCREEN_WIDTH - kMargin);
        make.height.mas_equalTo(SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT);
    }];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:self.guideString?:@""];
    text.lineSpacing = 8;
    text.font = kMainFont;
    text.color = KGrayTextMiddleColor;
    rulesView.attributedText = text;
}

@end

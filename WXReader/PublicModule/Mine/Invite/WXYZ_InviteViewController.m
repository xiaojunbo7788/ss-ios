//
//  WXYZ_InviteViewController.m
//  WXReader
//
//  Created by LL on 2020/8/11.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_InviteViewController.h"

#import "UIColor+Gradient.h"
#import "NSObject+Observer.h"

@interface WXYZ_InviteViewController ()

/// 红包码输入框
@property (nonatomic, weak) UITextField *inviteField;

@end

@implementation WXYZ_InviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createSubviews];
}

- (void)createSubviews {
    [self setNavigationBarTitle:@"输入红包码领现金"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.text = @"输入好友的红包\n领取随机红包";
    titleLabel.numberOfLines = 2;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = kFont17;
    titleLabel.textColor = kMainColor;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationBar.mas_bottom).offset(kMargin);
        make.left.equalTo(self.view).offset(kMargin);
        make.right.equalTo(self.view).offset(-kMargin);
    }];
    
    UITextField *inviteField = [[UITextField alloc] init];
    self.inviteField = inviteField;
    inviteField.backgroundColor = kGrayDeepViewColor;
    inviteField.placeholder = @"在此输入红包码";
    inviteField.textAlignment = NSTextAlignmentCenter;
    inviteField.layer.cornerRadius = 14.5;
    inviteField.layer.masksToBounds = YES;
    [self.view addSubview:inviteField];
    [inviteField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(kMargin * 2);
        make.left.equalTo(self.view).offset(kMargin * 2);
        make.right.equalTo(self.view).offset(- kMargin * 2);
        make.height.equalTo(inviteField.mas_width).multipliedBy(1.0 / 4.0);
    }];
    
    UIButton *receiveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [receiveBtn setTitle:@"领取红包" forState:UIControlStateNormal];
    [receiveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    receiveBtn.layer.cornerRadius = 23.5;
    receiveBtn.layer.masksToBounds = YES;
    receiveBtn.titleLabel.font = kFont14;
    [receiveBtn addTarget:self action:@selector(receiveEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:receiveBtn];
    [receiveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(inviteField.mas_bottom).offset(kMargin);
        make.left.right.equalTo(inviteField);
        make.height.mas_equalTo(50.0);
    }];
    [receiveBtn setNeedsLayout];
    [receiveBtn layoutIfNeeded];
    receiveBtn.backgroundColor = [UIColor colorGradientChangeWithSize:receiveBtn.bounds.size direction:LLGradientChangeDirectionLevel startColor:kColorRGB(255, 147, 35) endColor:kColorRGB(255, 91, 69)];
    
    UITextView *tipsView = [[UITextView alloc] init];
    tipsView.contentInset = UIEdgeInsetsMake(kMargin * 2, kMargin * 2, PUB_NAVBAR_OFFSET, 0);
    tipsView.backgroundColor = kGrayViewColor;
    tipsView.editable = NO;
    [tipsView addObserver:KEY_PATH(tipsView, text) complete:^(UITextView * _Nonnull obj, id  _Nullable oldVal, NSString * _Nullable newVal) {
        NSArray<NSString *> *t_arr = [newVal componentsSeparatedByString:@"\n"];
        NSString *title = t_arr.firstObject;
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 15.0;
        NSMutableAttributedString *t_atr = [[NSMutableAttributedString alloc] initWithString:newVal ?: @"" attributes:@{NSFontAttributeName : kFont12, NSForegroundColorAttributeName : [UIColor blackColor], NSParagraphStyleAttributeName : style}];
        [t_atr setAttributes:@{NSFontAttributeName : kBoldFont15, NSParagraphStyleAttributeName : style} range:NSMakeRange(0, title.length)];
        obj.attributedText = t_atr;
    }];
    [self.view addSubview:tipsView];
    [tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(receiveBtn.mas_bottom).offset(kMargin * 2);
        make.left.right.bottom.equalTo(self.view);
    }];    
}

- (void)netRequest {
    [WXYZ_NetworkRequestManger POST:@"" parameters:@{} model:nil success:^(BOOL isSuccess, id  _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
//            NSArray<NSString *> *t_arr = @[
//                @"温馨提示",
//                @"1、红包码可向好友索取，填写后可获得随机红包",
//                @"2、红包码注册起3天内可填写，超过3天后不可填写。",
//                @"3、一台手机只能填写一次红包码，填写成功后，即使再切换账号也无法填写其他红包码。"
//            ];
//            tipsView.text = [t_arr componentsJoinedByString:@"\n"];
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg ?: @"页面获取失败"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:@"页面获取失败"];
    }];
}

/// 领取红包
- (void)receiveEvent {
    NSString *text = [self.inviteField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) return;
    
    [WXYZ_NetworkRequestManger POST:@"" parameters:@{} model:nil success:^(BOOL isSuccess, id  _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:@"获取失败"];
    }];
}

@end

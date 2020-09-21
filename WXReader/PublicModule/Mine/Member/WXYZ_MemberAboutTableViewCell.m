//
//  WXYZ_MemberAboutTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/4/21.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_MemberAboutTableViewCell.h"
#import "WXYZ_WebViewViewController.h"
#import "WXYZ_FeedbackSubViewController.h"
#import "AppDelegate.h"

@implementation WXYZ_MemberAboutTableViewCell
{
    YYTextView *aboutTextView;
}

- (void)createSubviews
{
    [super createSubviews];
    
    aboutTextView = [[YYTextView alloc] init];
    aboutTextView.backgroundColor = [UIColor whiteColor];
    aboutTextView.editable = NO;
    aboutTextView.scrollEnabled = NO;
    aboutTextView.selectable = NO;
    [self.contentView addSubview:aboutTextView];
    
    [aboutTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kHalfMargin);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kHalfMargin);
        make.height.mas_equalTo(10);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- kHalfMargin).priorityLow();
    }];
}

- (void)setAbout:(NSArray<NSString *> *)about
{
    _about = about;
    
    if (about.count > 0 && ![[about firstObject] isEqualToString:@""]) {
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
        
        for (NSString *t_str in about) {
            [str appendString:[t_str stringByAppendingString:@"\n\n"]];
        }
        
        [str setColor:kGrayTextColor];
        
        [str setFont:kFont12];
        
        [str setTextHighlightRange:[str.string localizedStandardRangeOfString:@"《用户协议》"] color:kMainColor backgroundColor:[UIColor whiteColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            WXYZ_WebViewViewController *vc = [[WXYZ_WebViewViewController alloc] init];
            vc.navTitle = @"用户协议";
            AppDelegate *delegate = (AppDelegate *)kRCodeSync([UIApplication sharedApplication].delegate);
            vc.URLString = delegate.checkSettingModel.protocol_list.user ?: [NSString stringWithFormat:@"%@%@", APIURL, User_Agreement];
            vc.isPresentState = NO;
            [[WXYZ_ViewHelper getCurrentNavigationController] pushViewController:vc animated:YES];
        }];

        [str setTextHighlightRange:[str.string localizedStandardRangeOfString:@"《隐私协议》"] color:kMainColor backgroundColor:[UIColor whiteColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            WXYZ_WebViewViewController *vc = [[WXYZ_WebViewViewController alloc] init];
            vc.navTitle = @"隐私协议";
            AppDelegate *delegate = (AppDelegate *)kRCodeSync([UIApplication sharedApplication].delegate);
            vc.URLString = delegate.checkSettingModel.protocol_list.privacy ?: [NSString stringWithFormat:@"%@%@", APIURL, Privacy_Policy];;
            vc.isPresentState = NO;
            [[WXYZ_ViewHelper getCurrentNavigationController] pushViewController:vc animated:YES];
        }];

        [str setTextHighlightRange:[str.string localizedStandardRangeOfString:@"《会员服务协议》"] color:kMainColor backgroundColor:[UIColor whiteColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            WXYZ_WebViewViewController *vc = [[WXYZ_WebViewViewController alloc] init];
            vc.navTitle = @"会员服务协议";
            vc.URLString = [NSString stringWithFormat:@"%@%@", APIURL, Membership_Service];
            vc.isPresentState = NO;
            [[WXYZ_ViewHelper getCurrentNavigationController] pushViewController:vc animated:YES];
        }];

        [str setTextHighlightRange:[str.string localizedStandardRangeOfString:@"【意见反馈】"] color:kMainColor backgroundColor:[UIColor whiteColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            [[WXYZ_ViewHelper getWindowRootController] presentViewController:[[WXYZ_FeedbackSubViewController alloc] init] animated:YES completion:nil];
        }];
        
        aboutTextView.attributedText = str;
        CGFloat footerHeight = [WXYZ_ViewHelper getDynamicHeightWithLabelFont:kFont12 labelWidth:SCREEN_WIDTH - kMargin labelText:str.string] - 2 * kMargin;
        [aboutTextView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(footerHeight);
        }];
    }
}

@end

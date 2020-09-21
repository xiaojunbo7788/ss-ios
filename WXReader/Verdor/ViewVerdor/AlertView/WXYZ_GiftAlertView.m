//
//  WXYZ_GiftAlertView.m
//  WXReader
//
//  Created by LL on 2020/7/24.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_GiftAlertView.h"

#import "WXYZ_TickectAlertModel.h"
#import "WXYZ_GiftMonthlyPassModel.h"

#import "WXYZ_ReaderBookManager.h"
#import "WXYZ_RechargeViewController.h"

@implementation WXYZ_GiftAlertView

- (void)createSubviews {
    [super createSubviews];
    
    self.alertButtonType = WXYZ_AlertButtonTypeSingleConfirm;
}

- (void)setAlertModel:(WXYZ_TickectAlertModel *)alertModel giftModel:(WXYZ_GiftMonthlyPassListModel *)giftModel production_id:(NSInteger)production_id ticketBlock:(void(^)(NSInteger number))ticketBlock {
    self.alertViewTitle = alertModel.title ?: @"";
    
    NSString *str = [alertModel.desc componentsJoinedByString:@"\n"];
    NSRange range = [str rangeOfString:@"###.*###" options:NSRegularExpressionSearch];
    if (range.length == 0) range = NSMakeRange(0, 0);
    NSString *suffix = [[str substringWithRange:range] stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSMutableString *prefix = [NSMutableString stringWithString:[str stringByReplacingCharactersInRange:range withString:@""]];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 9.0;
    [prefix insertString:suffix atIndex:range.location];
    
    NSMutableAttributedString *t_atr = [[NSMutableAttributedString alloc] initWithString:prefix attributes:@{NSFontAttributeName : kFont13, NSForegroundColorAttributeName : kGrayTextColor, NSParagraphStyleAttributeName : style}];
    [t_atr addAttributes:@{NSForegroundColorAttributeName : kMainColor} range:NSMakeRange(range.location, suffix.length)];
    self.alertViewDetailAttributeContent = t_atr;
    self.alertViewConfirmTitle = alertModel.items.firstObject.title ?: @"";
    
    [self.alertViewContentScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.alertViewTitleLabel.mas_bottom).offset(0);
        make.left.equalTo(self.alertBackView).offset(kMargin * 3);
        make.right.equalTo(self.alertBackView).offset(-kHalfMargin);
        make.height.mas_equalTo([WXYZ_ViewHelper getDynamicHeightWithLabelFont:kMainFont labelWidth:SCREEN_WIDTH - 3 * kMargin labelText:self.alertViewDetailAttributeContent.string] + kMargin);
    }];
    
    [self.alertBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.alertBackView.superview).offset(kMargin * 2);
        make.right.equalTo(self.alertBackView.superview).offset(-kMargin * 2);
        make.bottom.mas_equalTo(self.confirmButton.mas_bottom).with.offset(0).priorityLow();
        make.center.equalTo(self.alertBackView.superview);
    }];
    
    [self.alertViewContentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.alertViewContentScrollView);
    }];
    
    [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.alertBackView.mas_right).with.offset(0);
        make.top.mas_equalTo(self.alertViewContentLabel.mas_bottom).offset(kHalfMargin);
        make.height.mas_equalTo(45.0);
        make.width.equalTo(self.alertBackView);
    }];
    
    self.confirmButtonClickBlock = ^{
        if ([alertModel.items.firstObject.action isEqualToString:@"recharge"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Reader_Push object:@""];
            [[WXYZ_ViewHelper getCurrentNavigationController] pushViewController:[[WXYZ_RechargeViewController alloc] init] animated:YES];
        } else {
            NSDictionary *params = @{
                @"book_id" : @(production_id),
                @"chapter_id" : @([WXYZ_ReaderBookManager sharedManager].chapter_id),
                @"num" : @(giftModel.num),
                @"use_gold" : @"1"
            };
            [WXYZ_NetworkRequestManger POST:Book_Reward_Ticket_Vote parameters:params model:nil success:^(BOOL isSuccess, NSDictionary * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
                if (isSuccess) {
                    NSString *text = [NSString stringWithFormat:@"%@", t_model[@"data"][@"ticket_num"]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTicket" object:text];
                    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"投票成功"];
                    [WXYZ_ReaderBookManager sharedManager].ticket_num = text ?: @"";
                    !ticketBlock ?: ticketBlock([text integerValue]);
                } else {
                    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
            }];
        }
    };
}

@end

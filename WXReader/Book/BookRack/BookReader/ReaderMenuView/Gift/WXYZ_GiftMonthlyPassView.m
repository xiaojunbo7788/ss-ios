//
//  WXYZ_GiftMonthlyPassView.m
//  WXReader
//
//  Created by LL on 2020/5/28.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_GiftMonthlyPassView.h"

#import "WXYZ_GiftMonthlyPassModel.h"
#import "NSObject+Observer.h"
#import "WXYZ_ReaderBookManager.h"
#import "WXYZ_TickectAlertModel.h"
#import "WXYZ_ProductionCoverView.h"

#import "WXYZ_GiftView.h"
#import "WXYZ_RechargeViewController.h"
#import "WXYZ_WebViewViewController.h"
#import "WXYZ_GiftAlertView.h"

@interface WXYZ_GiftMonthlyPassView ()

@property (nonatomic, strong) WXYZ_ProductionModel *bookModel;

@property (nonatomic, strong) WXYZ_GiftMonthlyPassModel *monthlyPassModel;

/// 当前选择按钮的下标
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) NSArray<UIButton *> *tickectBtnArray;

@property (nonatomic, weak) UIView *alertView;

@property (nonatomic, weak) UIButton *voteBtn;

@end

@implementation WXYZ_GiftMonthlyPassView

- (instancetype)initWithFrame:(CGRect)frame bookModel:(WXYZ_ProductionModel *)bookModel {
    if (self = [super initWithFrame:frame]) {
        self.bookModel = bookModel;
        [self initialize];
        [self netRequest];
        [self createSubviews];
    }
    return self;
}

- (void)initialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netRequest) name:Notification_Login_Success object:nil];
}

- (void)createSubviews {
    WXYZ_ProductionCoverView *coverImageView = [[WXYZ_ProductionCoverView alloc] initWithProductionType:WXYZ_ProductionTypeBook productionCoverDirection:WXYZ_ProductionCoverDirectionVertical];
    [self addSubview:coverImageView];
    [coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kMargin);
        make.left.equalTo(self).offset(kMoreHalfMargin);
        make.size.mas_equalTo(CGSizeMake(55.0, 74.0));
    }];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = kBlackColor;
    nameLabel.font = kFont14;
    [self addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(coverImageView).offset(16);
        make.left.equalTo(coverImageView.mas_right).offset(kHalfMargin);
    }];
    
    UILabel *tickerLabel = [[UILabel alloc] init];
    tickerLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:tickerLabel];

    UILabel *rankLabel = [[UILabel alloc] init];
    rankLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:rankLabel];

    UILabel *last_distanceLabel = [[UILabel alloc] init];
    last_distanceLabel.backgroundColor = [UIColor clearColor];
    last_distanceLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:last_distanceLabel];

    NSArray<UILabel *> *labelArr = @[tickerLabel, rankLabel, last_distanceLabel];
    [labelArr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:80 tailSpacing:0];
    [labelArr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(coverImageView).offset(-kHalfMargin);
    }];
    
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = kGrayViewColor;
    [self addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(65.0 + PUB_TABBAR_OFFSET);
    }];
    
    UILabel *remainLabel = [[UILabel alloc] init];
    remainLabel.backgroundColor = [UIColor clearColor];
    [bottomView addSubview:remainLabel];
    [remainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomView).offset(kMoreHalfMargin + 1.0f);
        make.left.equalTo(bottomView).offset(kMoreHalfMargin);
    }];
    
    UIImageView *helpImageView = [[UIImageView alloc] init];
    helpImageView.image = [YYImage imageNamed:@"book_help"];
    [bottomView addSubview:helpImageView];
    [helpImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(remainLabel);
        make.left.equalTo(remainLabel.mas_right).offset(kHalfMargin);
        make.size.mas_equalTo(CGSizeMake(kMoreHalfMargin, kMoreHalfMargin));
    }];
    helpImageView.userInteractionEnabled = YES;
    WS(weakSelf)
    [helpImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        [weakSelf.giftView removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Reader_Push object:@""];
        WXYZ_WebViewViewController *vc = [[WXYZ_WebViewViewController alloc] init];
        vc.URLString = weakSelf.monthlyPassModel.info.ticket_rule;
        vc.navTitle = @"月票说明";
        vc.isPresentState = NO;
        [[WXYZ_ViewHelper getCurrentNavigationController] pushViewController:vc animated:YES];
    }]];
    helpImageView.hidden = YES;
    
    UILabel *detailLabel = [[UILabel alloc] init];
    detailLabel.backgroundColor = [UIColor clearColor];
    [bottomView addSubview:detailLabel];
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(remainLabel.mas_bottom).offset(kHalfMargin - 1.0f);
        make.left.equalTo(remainLabel);
    }];
    
    UIButton *voteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.voteBtn = voteBtn;
    [voteBtn setImage:[YYImage imageNamed:@"book_ticketBtn"] forState:UIControlStateNormal];
    voteBtn.layer.cornerRadius = 19.0f;
    voteBtn.layer.masksToBounds = YES;
    [voteBtn addTarget:self action:@selector(voteEvent) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:voteBtn];
    [voteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomView).offset(kMoreHalfMargin);
        make.right.equalTo(bottomView).offset(-kMoreHalfMargin);
        make.size.mas_equalTo(CGSizeMake(105.0f, 38.0f));
    }];
    
    
    [self addObserver:KEY_PATH(self, monthlyPassModel) complete:^(WXYZ_GiftMonthlyPassView * _Nonnull obj, id  _Nullable oldVal, WXYZ_GiftMonthlyPassModel * _Nullable newVal) {
        coverImageView.coverImageURL = newVal.info.cover;
        nameLabel.text = newVal.info.name ?: @"";
        tickerLabel.attributedText = [obj attributeStringWithStr:newVal.info.stickerNumber ?: @"" speFont:kFont16 speColor:kBlackColor];
        rankLabel.attributedText = [obj attributeStringWithStr:newVal.info.ranking ?: @"" speFont:kFont16 speColor:kBlackColor];
        last_distanceLabel.attributedText = [obj attributeStringWithStr:newVal.info.last_distance ?: @"" speFont:kFont16 speColor:kBlackColor];
        NSString *prefix = @"拥有";
        NSString *suffix = @"月票";
        NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@", prefix, newVal.info.ticket_remain, suffix] attributes:@{NSFontAttributeName : kFont14, NSForegroundColorAttributeName : kBlackColor}];
        [atr addAttribute:NSForegroundColorAttributeName value:kMainColor range:NSMakeRange(prefix.length, newVal.info.ticket_remain.length)];
        remainLabel.attributedText = atr;
        detailLabel.attributedText = [obj attributeStringWithStr:newVal.info.monthly_tips speFont:kFont11 speColor:kMainColor];
        
        if (newVal.info.can_vote == 1) {
            voteBtn.alpha = 1;
            voteBtn.enabled = YES;
        } else {
            voteBtn.alpha = 0.5;
            voteBtn.enabled = NO;
        }
        
        NSMutableArray<UIButton *> *btnArr = [NSMutableArray array];
        if (obj.tickectBtnArray.count == 0) {
            obj.tickectBtnArray = btnArr;
            NSInteger index = 0;
            for (WXYZ_GiftMonthlyPassListModel *model in newVal.list) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                NSString *text = [NSString stringWithFormat:@"%@\n%@", model.title, @"月票"];
                NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName : kBlackColor, NSFontAttributeName : kFont11}];
                [atr addAttribute:NSFontAttributeName value:kFont15 range:NSMakeRange(0, model.title.length)];
                if (model.enabled == 0) {
                    [atr addAttribute:NSForegroundColorAttributeName value:kColorRGB(153, 153, 153) range:NSMakeRange(0, atr.length)];
                    button.enabled = NO;
                }
                [button setAttributedTitle:atr forState:UIControlStateNormal];
                button.titleLabel.numberOfLines = 0;
                button.titleLabel.textAlignment = NSTextAlignmentCenter;
                button.layer.cornerRadius = 2.5;
                button.layer.masksToBounds = YES;
                button.layer.borderWidth = 0.5;
                button.layer.borderColor = kColorRGB(221, 221, 221).CGColor;
                button.tag = index;
                [button addTarget:obj action:@selector(tickectOptionEvent:) forControlEvents:UIControlEventTouchUpInside];
                [obj addSubview:button];
                [btnArr addObject:button];
                index++;
            }
            
            [btnArr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:kQuarterMargin leadSpacing:15.0 tailSpacing:15.0];
            [btnArr mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(coverImageView.mas_bottom).offset(24.0);
                make.height.equalTo(btnArr.firstObject.mas_width);
            }];
            [btnArr.firstObject sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }];
}

- (void)tickectOptionEvent:(UIButton *)button {
    
    if (self.monthlyPassModel.list[button.tag].enabled == 1) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:button.currentAttributedTitle];
        [str setAttribute:NSForegroundColorAttributeName value:kMainColor];
        [button setAttributedTitle:str forState:UIControlStateNormal];
        button.layer.borderColor = kMainColor.CGColor;
        self.selectedIndex = button.tag;
    }
        
    for (UIButton *obj in self.tickectBtnArray) {
        if (obj != button) {
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:obj.currentAttributedTitle];
            [str setAttribute:NSForegroundColorAttributeName value:self.monthlyPassModel.list[obj.tag].enabled ? kBlackColor : kColorRGB(153, 153, 153)];
            [obj setAttributedTitle:str forState:UIControlStateNormal];
            obj.layer.borderColor = kColorRGB(221, 221, 221).CGColor;
        }
    }
    
    if (self.monthlyPassModel.info.can_vote == 1) {
        self.voteBtn.alpha = 1;
        self.voteBtn.enabled = YES;
    } else {
        self.voteBtn.alpha = 0.5;
        self.voteBtn.enabled = NO;
    }
}

// 投月票
- (void)voteEvent {
    if (self.selectedIndex == -1) {
        return;
    }
    
    if (!WXYZ_UserInfoManager.isLogin) {
        [WXYZ_LoginViewController presentLoginView];
        return;
    }
    
    WXYZ_GiftMonthlyPassListModel *model = self.monthlyPassModel.list[self.selectedIndex];
    NSDictionary *params = @{
        @"book_id" : @(self.bookModel.production_id),
        @"chapter_id" : @([WXYZ_ReaderBookManager sharedManager].chapter_id),
        @"num" : @(model.num),
    };
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Book_Reward_Ticket_Vote parameters:params model:WXYZ_TickectAlertModel.class success:^(BOOL isSuccess, WXYZ_TickectAlertModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            [weakSelf netRequest];
            NSString *text = [NSString stringWithFormat:@"%@", requestModel.data[@"ticket_num"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTicket" object:text];
            !weakSelf.ticketNumBlock ?: weakSelf.ticketNumBlock([text integerValue]);
            [WXYZ_ReaderBookManager sharedManager].ticket_num = text ?: @"";
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"投票成功"];
        } else if (Compare_Json_isEqualTo(requestModel.code, 902)) {
            [weakSelf showAlert:t_model t_model:weakSelf.monthlyPassModel.list[weakSelf.selectedIndex] production_id:weakSelf.bookModel.production_id ticketNumBlock:weakSelf.ticketNumBlock];
            [weakSelf.giftView hide];
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
    }];
}

- (NSMutableAttributedString *)attributeStringWithStr:(NSString *)str speFont:(UIFont *)speFont speColor:(UIColor *)speColor {
    NSRange range = [str rangeOfString:@"###.*###" options:NSRegularExpressionSearch];
    if (range.length == 0) range = NSMakeRange(0, 0);
    NSString *suffix = [[str substringWithRange:range] stringByReplacingOccurrencesOfString:@"#" withString:@""];
    suffix = [NSString stringWithFormat:@" %@ ", suffix];
    NSMutableString *prefix = [NSMutableString stringWithString:[str stringByReplacingCharactersInRange:range withString:@""]];
    [prefix insertString:suffix atIndex:range.location];
    
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:prefix attributes:@{NSFontAttributeName : kFont11, NSForegroundColorAttributeName : kGrayTextColor}];
    [atr addAttributes:@{NSFontAttributeName : speFont, NSForegroundColorAttributeName : speColor} range:NSMakeRange(range.location, suffix.length)];
    return atr;
}

- (void)netRequest {
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Book_Gift_Montyly_Pass parameters:@{@"book_id":@(self.bookModel.production_id)} model:WXYZ_GiftMonthlyPassModel.class success:^(BOOL isSuccess, id  _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            weakSelf.monthlyPassModel = t_model;
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
    }];
}

- (void)showAlert:(WXYZ_TickectAlertModel *)model t_model:(WXYZ_GiftMonthlyPassListModel *)t_model production_id:(NSInteger)production_id ticketNumBlock:(void(^)(NSInteger number))ticketNumBlock {
    
    WXYZ_GiftAlertView *alertView = [[WXYZ_GiftAlertView alloc] init];
    [alertView setAlertModel:model giftModel:t_model production_id:production_id ticketBlock:ticketNumBlock];
    [alertView showAlertView];
}

@end

//
//  WXYZ_TaskHeaderView.m
//  WXReader
//
//  Created by Andrew on 2018/11/15.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "WXYZ_TaskHeaderView.h"

#import "WXYZ_TaskModel.h"
#import "WXYZ_SignModel.h"

#import "WXYZ_SignAlertView.h"

@implementation WXYZ_TaskHeaderView
{
    UILabel *signLabel;
    
    UIButton *signButton;
    
    UILabel *signPromptLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    UILabel *signLeftLabel = [[UILabel alloc] init];
    signLeftLabel.backgroundColor = [UIColor clearColor];
    signLeftLabel.text = @"您已连续签到";
    signLeftLabel.font = kBoldFont19;
    signLeftLabel.textColor = kBlackColor;
    signLeftLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:signLeftLabel];
    
    [signLeftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabelFont:kBoldFont19 labelHeight:50 labelText:signLeftLabel.text] - 1);
        make.height.mas_equalTo(50);
    }];
    
    UIImageView *signImage = [[UIImageView alloc] init];
    signImage.image = [UIImage imageNamed:@"task_label_bk"];
    [self addSubview:signImage];
    
    [signImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(signLeftLabel.mas_right).with.offset(5);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(kGeometricWidth(50, 196, 276));
    }];
    
    signLabel = [[UILabel alloc] init];
    signLabel.text = @"0";
    signLabel.backgroundColor = [UIColor clearColor];
    signLabel.font = kBoldFont27;
    signLabel.textColor = kWhiteColor;
    signLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:signLabel];
    
    [signLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(signImage);
    }];
    
    UILabel *signRightLabel = [[UILabel alloc] init];
    signRightLabel.text = @"天";
    signRightLabel.font = kBoldFont19;
    signRightLabel.textColor = kBlackColor;
    signRightLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:signRightLabel];
    
    [signRightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(signImage.mas_right).with.offset(5);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabelFont:kBoldFont19 labelHeight:50 labelText:signRightLabel.text] - 1);
        make.height.mas_equalTo(50);
    }];
    
    signButton = [UIButton buttonWithType:UIButtonTypeCustom];
    signButton.userInteractionEnabled = NO;
//    signButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
//    signButton.contentHorizontalAlignment = UIControlContentVerticalAlignmentFill;
    [signButton setImage:[UIImage imageNamed:@"task_unsign"] forState:UIControlStateNormal];
    [signButton addTarget:self action:@selector(signClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:signButton];
    
    [signButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(120);
    }];
    
    signPromptLabel = [[UILabel alloc] init];
    signPromptLabel.font = kFont10;
    signPromptLabel.textColor = kGrayTextLightColor;
    signPromptLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:signPromptLabel];
    
    [signPromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(signLeftLabel.mas_left);
        make.bottom.mas_equalTo(self.mas_bottom).with.offset(- kHalfMargin);
        make.width.mas_equalTo(self.mas_width);
        make.height.mas_equalTo(20);
    }];
}

- (void)setSignInfoModel:(WXYZ_SignInfoModel *)signInfoModel
{
    _signInfoModel = signInfoModel;
    
    if (signInfoModel.sign_status == 0) {
        [signButton setImage:[UIImage imageNamed:@"task_unsign"] forState:UIControlStateNormal];
        signButton.userInteractionEnabled = YES;
    } else {
        [signButton setImage:[UIImage imageNamed:@"task_signed"] forState:UIControlStateNormal];
        signButton.userInteractionEnabled = NO;
    }
    
    signLabel.text = [WXYZ_UtilsHelper formatStringWithInteger:signInfoModel.sign_days];

    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"提示：连续签到最高可获得%@%@", [WXYZ_UtilsHelper formatStringWithInteger:signInfoModel.max_award], signInfoModel.unit?:WXYZ_SystemInfoManager.masterUnit]];
    [attributedStr addAttribute:NSForegroundColorAttributeName value:kColorRGBA(251, 100, 26, 1) range:NSMakeRange(12, attributedStr.length - 12)];
    signPromptLabel.attributedText = attributedStr;
    
}

- (void)signClick
{
    if (!WXYZ_UserInfoManager.isLogin) {
        [WXYZ_LoginViewController presentLoginView];
        return;
    }
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Sign_Click parameters:nil model:WXYZ_SignModel.class success:^(BOOL isSuccess, WXYZ_SignModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            if ((t_model.book.count > 0 || t_model.comic.count > 0) && t_model.award.length > 0 && t_model.tomorrow_award.length > 0) {
                
                NSMutableArray *t_arr = [NSMutableArray array];
                
                for (WXYZ_ProductionModel *t in t_model.book) {
                    t.productionType = WXYZ_ProductionTypeBook;
                    [t_arr addObject:t];
                }
                
                for (WXYZ_ProductionModel *t in t_model.comic) {
                    t.productionType = WXYZ_ProductionTypeComic;
                    [t_arr addObject:t];
                }
                
                for (WXYZ_ProductionModel *t in t_model.audio) {
                    t.productionType = WXYZ_ProductionTypeAudio;
                    [t_arr addObject:t];
                }
                
                WXYZ_SignAlertView *alert = [[WXYZ_SignAlertView alloc] init];
                alert.alertViewTitle = t_model.award;
                alert.alertViewDetailContent = t_model.tomorrow_award;
                alert.bookList = [t_arr copy];
                [alert showAlertView];
            }

            !weakSelf.signClickBlock ?: weakSelf.signClickBlock();
            
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:requestModel.msg];
        }
    } failure:nil];
}

@end

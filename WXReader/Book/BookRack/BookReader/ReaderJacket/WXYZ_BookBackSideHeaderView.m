//
//  WXYZ_BookBackSideHeaderView.m
//  WXReader
//
//  Created by Andrew on 2020/5/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BookBackSideHeaderView.h"
#if WX_W_Share_Mode || WX_Q_Share_Mode
    #import "WXYZ_ShareManager.h"
#endif

#import "WXYZ_GiftView.h"
#import "AppDelegate.h"

@implementation WXYZ_BookBackSideHeaderView
{
    UILabel *headerTitleLabel;
    UILabel *headerDescLabel;
    WXYZ_CustomButton *commentButton;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    headerTitleLabel = [[UILabel alloc] init];
    headerTitleLabel.font = kBoldFont22;
    headerTitleLabel.numberOfLines = 0;
    headerTitleLabel.textAlignment = NSTextAlignmentLeft;
    headerTitleLabel.textColor = kBlackColor;
    [self addSubview:headerTitleLabel];
    
    [headerTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).with.offset(kMargin);
        make.width.mas_equalTo(SCREEN_WIDTH - 2 * kMargin);
        make.top.mas_equalTo(self.mas_top).with.offset(kMargin);
        make.height.mas_equalTo(CGFLOAT_MIN);
    }];
    
    headerDescLabel = [[UILabel alloc] init];
    headerDescLabel.font = kMainFont;
    headerDescLabel.numberOfLines = 0;
    headerDescLabel.textAlignment = NSTextAlignmentLeft;
    headerDescLabel.textColor = kGrayTextLightColor;
    [self addSubview:headerDescLabel];
    
    [headerDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(headerTitleLabel.mas_left);
        make.right.mas_equalTo(headerTitleLabel.mas_right);
        make.top.mas_equalTo(headerTitleLabel.mas_bottom);
        make.height.mas_equalTo(CGFLOAT_MIN);
    }];
    
    
    CGFloat buttonWidth = (SCREEN_WIDTH - kMargin) / 3;
    AppDelegate *app = (AppDelegate *)kRCodeSync([UIApplication sharedApplication].delegate);
    if (app.checkSettingModel.system_setting.novel_reward_switch == 0 && app.checkSettingModel.system_setting.monthly_ticket_switch == 0) {
        buttonWidth = (SCREEN_WIDTH - kMargin) / 2;
    }
    
    commentButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"评论" buttonImageName:@"book_back_side_comment" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
    commentButton.tag = 0;
    commentButton.buttonTitleColor = kGrayTextLightColor;
    commentButton.graphicDistance = 8;
    commentButton.buttonImageScale = 0.4;
    [commentButton addTarget:self action:@selector(toolBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:commentButton];
    
    [commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin);
        make.top.mas_equalTo(headerDescLabel.mas_bottom).with.offset(kMargin);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(50);
    }];
    
    {
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = kColorRGB(204, 204, 204);
        [self addSubview:line];
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(commentButton.mas_right);
            make.centerY.mas_equalTo(commentButton.mas_centerY);
            make.width.mas_equalTo(0.8);
            make.height.mas_equalTo(commentButton.mas_height).multipliedBy(0.7);
        }];
    }
    
    WXYZ_CustomButton *exceptionalButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"打赏" buttonImageName:@"book_back_side_exceptional" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
    exceptionalButton.tag = 1;
    exceptionalButton.buttonTitleColor = kGrayTextLightColor;
    exceptionalButton.graphicDistance = 8;
    exceptionalButton.buttonImageScale = 0.4;
    [exceptionalButton addTarget:self action:@selector(toolBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:exceptionalButton];
    
    [exceptionalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(commentButton.mas_right);
        make.top.mas_equalTo(commentButton.mas_top);
        make.width.mas_equalTo(CGFLOAT_MIN);
        make.height.mas_equalTo(commentButton.mas_height);
    }];
    
    if (app.checkSettingModel.system_setting.novel_reward_switch == 1 || app.checkSettingModel.system_setting.monthly_ticket_switch == 1) {
        
        [exceptionalButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(commentButton.mas_right);
            make.top.mas_equalTo(commentButton.mas_top);
            make.width.mas_equalTo(buttonWidth);
            make.height.mas_equalTo(commentButton.mas_height);
        }];
        
        if (app.checkSettingModel.system_setting.novel_reward_switch == 0 && app.checkSettingModel.system_setting.monthly_ticket_switch == 1) {
            exceptionalButton.buttonTitle = @"月票";
        }
        
        {
            UIView *line = [[UIView alloc] init];
            line.backgroundColor = kColorRGB(204, 204, 204);
            [self addSubview:line];
            
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(exceptionalButton.mas_right);
                make.centerY.mas_equalTo(exceptionalButton.mas_centerY);
                make.width.mas_equalTo(0.8);
                make.height.mas_equalTo(exceptionalButton.mas_height).multipliedBy(0.7);
            }];
        }
    }
    
    WXYZ_CustomButton *shareButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"分享" buttonImageName:@"public_share" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
    shareButton.tag = 2;
    shareButton.buttonTitleColor = kGrayTextLightColor;
    shareButton.graphicDistance = 8;
    shareButton.buttonImageScale = 0.35;
    [shareButton addTarget:self action:@selector(toolBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:shareButton];
    
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(exceptionalButton.mas_right);
        make.top.mas_equalTo(commentButton.mas_top);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(commentButton.mas_height);
    }];
        
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, (headerDescLabel.bottom + kHalfMargin + 50 + kMargin));
}

- (void)setHeaderModel:(WXYZ_BookBackSideModel *)headerModel
{
    _headerModel = headerModel;
    
    headerTitleLabel.text = headerModel.title?:@"";
    [headerTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([WXYZ_ViewHelper getDynamicHeightWithLabel:headerTitleLabel]);
    }];
    
    headerDescLabel.text = headerModel.desc?:@"";
    [headerDescLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([WXYZ_ViewHelper getDynamicHeightWithLabel:headerDescLabel]);
    }];
    
    if (headerModel.comment_num > 0) {
        commentButton.cornerTitle = [WXYZ_UtilsHelper formatStringWithInteger:headerModel.comment_num];
        if (headerModel.comment_num > 99) {
            commentButton.cornerTitle = @"99+";
        }
    } else {
        commentButton.cornerTitle = @"";
    }
    
    [self layoutIfNeeded];
}

- (void)setBookModel:(WXYZ_ProductionModel *)bookModel
{
    _bookModel = bookModel;
}

- (void)toolBarButtonClick:(WXYZ_CustomButton *)sender
{
    switch (sender.tag) {
        case 0:
        {
            if (self.commentClickBlock) {
                self.commentClickBlock();
            }
        }
            break;
        case 1:
        {
            WXYZ_GiftView *mainView = [[WXYZ_GiftView alloc] initWithFrame:CGRectZero bookModel:self.bookModel];
            [mainView show];
        }
            break;
        case 2:
        {
#if __has_include(<WXYZ_ShareManager.h>)
            [[WXYZ_ShareManager sharedManager] shareProductionInController:[WXYZ_ViewHelper getWindowRootController] shareTitle:self.bookModel.name shareDescribe:self.bookModel.production_descirption shareImageURL:self.bookModel.cover productionType:WXYZ_ProductionTypeBook production_id:self.bookModel.production_id shareState:WXYZ_ShareStateAll];
#endif
        }
            break;
            
        default:
            break;
    }
}

@end

//
//  WXYZ_FeedbackCenterTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/12/25.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_FeedbackCenterTableViewCell.h"

@implementation WXYZ_FeedbackCenterTableViewCell
{
    UILabel *questionTitleLabel;
    UILabel *questionDetailLabel;
}

- (void)createSubviews
{
    [super createSubviews];
    
    questionTitleLabel = [[UILabel alloc] init];
    questionTitleLabel.backgroundColor = kWhiteColor;
    questionTitleLabel.textColor = kBlackColor;
    questionTitleLabel.font = kMainFont;
    questionTitleLabel.numberOfLines = 0;
    questionTitleLabel.userInteractionEnabled = YES;
    [self.contentView addSubview:questionTitleLabel];
    
    [questionTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kHalfMargin);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kHalfMargin);
        make.height.mas_equalTo(40);
    }];
    
    questionDetailLabel = [[UILabel alloc] init];
    questionDetailLabel.textColor = kGrayTextColor;
    questionDetailLabel.font = kMainFont;
    questionDetailLabel.numberOfLines = 0;
    [self.contentView addSubview:questionDetailLabel];
    
    [questionDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(questionTitleLabel.mas_left).with.offset(kHalfMargin);
        make.top.mas_equalTo(questionTitleLabel.mas_bottom);
        make.right.mas_equalTo(questionTitleLabel.mas_right).with.offset(- kHalfMargin);
        make.height.mas_equalTo(CGFLOAT_MIN);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).priorityLow();
    }];
    
}

- (void)setQuestionModel:(WXYZ_QuestionListModel *)questionModel
{
    _questionModel = questionModel;
    
    questionTitleLabel.text = [NSString stringWithFormat:@"Q：%@", questionModel.title]?:@"";
    [questionTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([WXYZ_ViewHelper getDynamicHeightWithLabelFont:kMainFont labelWidth:(SCREEN_WIDTH - kMargin) labelText:questionTitleLabel.text]);
    }];
    
    questionDetailLabel.text = [NSString stringWithFormat:@"A：%@", questionModel.answer]?:@"";
}

- (void)showDetail
{
    self.detailCellShowing = YES;
    
    [UIView animateWithDuration:kAnimatedDurationFast animations:^{
        [self->questionDetailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo([WXYZ_ViewHelper getDynamicHeightWithLabel:self->questionDetailLabel] - kHalfMargin);
        }];
        [self->questionDetailLabel.superview layoutIfNeeded];//强制绘制
    }];
}

- (void)hiddenDetail
{
    self.detailCellShowing = NO;
    
    [UIView animateWithDuration:kAnimatedDurationFast animations:^{
        [self->questionDetailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(CGFLOAT_MIN);
        }];
        [self->questionDetailLabel.superview layoutIfNeeded];//强制绘制
    }];
}

@end

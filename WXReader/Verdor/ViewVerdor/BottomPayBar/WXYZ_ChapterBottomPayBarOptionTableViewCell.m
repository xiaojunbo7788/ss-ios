//
//  WXYZ_ChapterBottomPayBarOptionTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/7/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ChapterBottomPayBarOptionTableViewCell.h"

@implementation WXYZ_ChapterBottomPayBarOptionTableViewCell
{
    UIScrollView *optionScorllView;
}

- (void)createSubviews
{
    [super createSubviews];
    
    optionScorllView = [[UIScrollView alloc] init];
    optionScorllView.showsVerticalScrollIndicator = NO;
    optionScorllView.showsHorizontalScrollIndicator = NO;
    optionScorllView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:optionScorllView];
    
    [optionScorllView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.width.mas_equalTo(self.contentView.mas_width);
        make.height.mas_equalTo(self.contentView.mas_height);
    }];
}

- (void)setPay_options:(NSArray<WXYZ_ChapterPayBarOptionModel *> *)pay_options
{
    if (_pay_options != pay_options) {
        _pay_options = pay_options;

        [optionScorllView removeAllSubviews];
        
        NSInteger buttonNum = pay_options.count;
        CGFloat button_H = 30;//按钮高
        CGFloat margin_X = kMargin;//第一个按钮的X坐标
        CGFloat margin_Y = 10;//第一个按钮的Y坐标
        CGFloat space_X = kHalfMargin;//按钮间距
        CGFloat button_X = margin_X;
        CGFloat button_W = - 10;
        for (NSInteger i = 0; i < buttonNum; i++) {
            WXYZ_ChapterPayBarOptionModel *option = [pay_options objectOrNilAtIndex:i];
            button_X = button_X + button_W + space_X;
            button_W = [WXYZ_ViewHelper getDynamicWidthWithLabelFont:kMainFont labelHeight:30 labelText:option.label] + 10;//按钮宽
            
            UIButton *optionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            optionButton.frame = CGRectMake(button_X, margin_Y, button_W, button_H);
            optionButton.layer.cornerRadius = 4;
            optionButton.backgroundColor = [UIColor whiteColor];
            optionButton.tag = i;
            [optionButton.titleLabel setFont:kMainFont];
            [optionButton setTitle:option.label?:@"" forState:UIControlStateNormal];
            [optionButton setTitleColor:kGrayTextColor forState:UIControlStateNormal];
            [optionButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [optionScorllView addSubview:optionButton];
            
            if (i == buttonNum - 1) {
                [optionScorllView setContentSize:CGSizeMake(optionButton.right, 0)];
            }
            
            if (buttonNum > 0 && i == 0) {
                optionButton.backgroundColor = kMainColor;
                [optionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)optionButtonClick:(UIButton *)sender
{
    [optionScorllView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)obj;
            button.backgroundColor = [UIColor whiteColor];
            [button setTitleColor:kGrayTextColor forState:UIControlStateNormal];
        }
    }];
    
    sender.backgroundColor = kMainColor;
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if (self.payOptionClickBlock) {
        self.payOptionClickBlock([self.pay_options objectOrNilAtIndex:sender.tag], sender.tag);
    }
}

@end

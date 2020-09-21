//
//  WXYZ_ComicInfoListTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/8/17.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_TagTableViewCell.h"

@interface WXYZ_TagTableViewCell ()

@end

@implementation WXYZ_TagTableViewCell {
    UIView *backView;
}


- (void)createSubviews {
    [super createSubviews];
    

   backView = [[UIView alloc] init];
       backView.backgroundColor = [UIColor whiteColor];
       [self.contentView addSubview:backView];
       
       [backView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.mas_equalTo(self.contentView.mas_top);
           make.left.mas_equalTo(self.contentView.mas_left).with.offset(kMargin);
           make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
           make.height.mas_equalTo(40);
           make.bottom.mas_equalTo(self.contentView.mas_bottom).priorityLow();
       }];
}

- (void)setDetailArray:(NSArray *)detailArray
{
    _detailArray = detailArray;
    
    CGFloat kScreenW = SCREEN_WIDTH - 40 - 3 * kHalfMargin;
    
    //间距
    CGFloat padding = 10;
    
    CGFloat titBtnX = 0;
    CGFloat titBtnH = 30;
    CGFloat titBtnY = (40 - titBtnH) / 2;
    
    for (int i = 0; i < detailArray.count; i++) {
        UILabel *titBtn = [[UILabel alloc] init];
        //设置按钮的样式
        titBtn.backgroundColor = [UIColor colorWithHexString:@"#F9F9F9"];
        titBtn.textColor = [UIColor colorWithHexString:@"#0A0A0A"];
        titBtn.font = kFont13;
        CGFloat titBtnW = 0.0;
        NSDictionary *dic = detailArray[i];
        titBtn.text = dic[@"title"];
        //计算文字大小
        titBtnW = [WXYZ_ViewHelper getDynamicWidthWithLabelFont:kFont13 labelHeight:titBtnH labelText:dic[@"title"]?:@""] + padding;
        
       
        titBtn.layer.cornerRadius = titBtnH / 2;
        titBtn.clipsToBounds = YES;
        
       
        //判断按钮是否超过屏幕的宽
        if ((titBtnX + titBtnW) > kScreenW) {
            titBtnX = 0;
            titBtnY += titBtnH + padding;
        }
        
        titBtn.textAlignment = NSTextAlignmentCenter;
        //设置按钮的位置
        titBtn.frame = CGRectMake(titBtnX, titBtnY, titBtnW, titBtnH);
        titBtnX += titBtnW + padding;
        [backView addSubview:titBtn];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = titBtn.frame;
        button.opaque = true;
        [backView addSubview:button];
        [button addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [backView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo((titBtnY + titBtnH + padding) < 40?40:(titBtnY + titBtnH + padding));
    }];
}

- (void)buttonPress:(UIButton *)button {
    [self.delegate selectTag:(int)button.tag];
}



@end

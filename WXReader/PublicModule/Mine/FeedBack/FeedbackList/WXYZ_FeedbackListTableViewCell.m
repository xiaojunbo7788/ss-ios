//
//  WXYZ_FeedbackListTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/12/28.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_FeedbackListTableViewCell.h"
#import "WMPhotoBrowser.h"

@implementation WXYZ_FeedbackListTableViewCell
{
    UILabel *dateLabel;
    UILabel *questionLabel;
    UIView *questionImageBack;
    UILabel *replyLabel;
    
    NSArray *questionImageArray;
    
    UIView *line;
}

- (void)createSubviews
{
    [super createSubviews];
    
    dateLabel = [[UILabel alloc] init];
    dateLabel.textColor = kGrayTextColor;
    dateLabel.textAlignment = NSTextAlignmentLeft;
    dateLabel.font = kFont11;
    [self.contentView addSubview:dateLabel];
    
    [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kHalfMargin);
        make.top.mas_equalTo(self.contentView.mas_top).with.offset(kHalfMargin);
        make.width.mas_equalTo(self.contentView.mas_width).with.offset(- kMargin);
        make.height.mas_equalTo(20);
    }];
    
    questionLabel = [[UILabel alloc] init];
    questionLabel.textColor = kBlackColor;
    questionLabel.textAlignment = NSTextAlignmentLeft;
    questionLabel.font = kMainFont;
    questionLabel.numberOfLines = 0;
    [self.contentView addSubview:questionLabel];
    [questionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(dateLabel.mas_left);
        make.width.mas_equalTo(dateLabel.mas_width);
        make.top.mas_equalTo(dateLabel.mas_bottom);
    }];
    
    questionImageBack = [[UIView alloc] init];
    questionImageBack.backgroundColor = kWhiteColor;
    [self.contentView addSubview:questionImageBack];
    
    [questionImageBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(dateLabel.mas_left);
        make.top.mas_equalTo(questionLabel.mas_bottom).with.offset(kHalfMargin);
        make.right.mas_equalTo(dateLabel.mas_right);
        make.height.mas_equalTo(CGFLOAT_MIN);
    }];
    
    line = [[UIView alloc] init];
    line.backgroundColor = kGrayLineColor;
    line.hidden = YES;
    [self.contentView addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.top.mas_equalTo(questionImageBack.mas_bottom).with.offset(kHalfMargin);
        make.width.mas_equalTo(SCREEN_WIDTH - kMargin);
        make.height.mas_equalTo(kCellLineHeight);
    }];
    
    replyLabel = [[UILabel alloc] init];
    replyLabel.textColor = kGrayTextColor;
    replyLabel.textAlignment = NSTextAlignmentLeft;
    replyLabel.font = kMainFont;
    replyLabel.numberOfLines = 10;
    [self.contentView addSubview:replyLabel];
    
    [replyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(dateLabel.mas_left);
        make.top.mas_equalTo(questionImageBack.mas_bottom).with.offset(kMargin);
        make.right.mas_equalTo(dateLabel.mas_right);
        make.height.mas_equalTo(CGFLOAT_MIN);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- kHalfMargin).priorityLow();
    }];
}

- (void)setContentModel:(WXYZ_FeedbackContentModel *)contentModel
{
    _contentModel = contentModel;
    
    dateLabel.text = contentModel.created_at?:@"";
    
    questionLabel.text = [@"问题：\n\n" stringByAppendingString:contentModel.content?:@""];
    
    if (questionImageArray.count != contentModel.images.count) {
        NSInteger buttonNum = contentModel.images.count;//每行多少按钮
        CGFloat button_W = 60;//按钮宽
        CGFloat button_H = 60;//按钮高
        CGFloat space_X = 10;//按钮间距
        for (NSInteger i = 0; i < buttonNum; i++) {
            NSInteger loc = i % buttonNum;//列号
            
            CGFloat button_X = (space_X + button_W) * loc;
            CGFloat button_Y = 0;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(button_X, button_Y, button_W, button_H);
            button.tag = i;
            button.adjustsImageWhenHighlighted = NO;
            [button setImageWithURL:[NSURL URLWithString:[contentModel.images objectOrNilAtIndex:i]] forState:UIControlStateNormal options:YYWebImageOptionSetImageWithFadeAnimation];
            [button addTarget:self action:@selector(watchPhoto:) forControlEvents:UIControlEventTouchUpInside];
            [questionImageBack addSubview:button];
        }
        [questionImageBack mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(70);
        }];
    }
    
    if (contentModel.reply.length > 0) {
        line.hidden = NO;
        replyLabel.text = [@"回复：\n\n" stringByAppendingString:contentModel.reply?:@""];
        [replyLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(questionImageBack.mas_bottom).with.offset(kMargin);
            make.height.mas_equalTo([WXYZ_ViewHelper getDynamicHeightWithLabelFont:replyLabel.font labelWidth:(SCREEN_WIDTH - kMargin) labelText:replyLabel.text] - kHalfMargin);
        }];
    } else {
        line.hidden = YES;
        [replyLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(questionImageBack.mas_bottom).with.offset(CGFLOAT_MIN);
            make.height.mas_equalTo(CGFLOAT_MIN);
        }];
    }
}

- (void)watchPhoto:(UIButton *)sender
{
    WMPhotoBrowser *browser = [WMPhotoBrowser new];
    browser.dataSource = self.contentModel.images.mutableCopy;
    browser.downLoadNeeded = YES;
    browser.currentPhotoIndex = sender.tag;
    [[WXYZ_ViewHelper getCurrentViewController] presentViewController:browser animated:YES completion:nil];
}

@end

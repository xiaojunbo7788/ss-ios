//
//  WXYZ_FeedbackTextViewTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/12/27.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_FeedbackTextViewTableViewCell.h"
#import "WXYZ_TextView.h"

@interface WXYZ_FeedbackTextViewTableViewCell () <WXYZ_TextViewDelegate>

@property (nonatomic, copy) NSString *contentString;

@end

@implementation WXYZ_FeedbackTextViewTableViewCell
{
    WXYZ_TextView *textView;
}

- (void)createSubviews
{
    [super createSubviews];
    
    textView = [[WXYZ_TextView alloc] initWithFrame:CGRectZero];
    textView.maxWordCount = 200;
    textView.delegate = self;
    textView.layer.cornerRadius = 4;
    [textView resetPlaceholderText:@"请详细描述您遇到的问题并告知具体操作步骤，我们会尽快答复您的问题哦"];
    [self.contentView addSubview:textView];
    
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kHalfMargin);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.width.mas_equalTo(SCREEN_WIDTH - kMargin);
        make.height.mas_equalTo(200);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).priorityLow();
    }];
}

- (void)textViewDidChange:(NSString *)text
{
    if (self.textViewDidChange) {
        self.textViewDidChange(text);
    }
}

@end

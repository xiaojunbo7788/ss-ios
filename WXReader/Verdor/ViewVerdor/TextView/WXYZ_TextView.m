//
//  DPTextView.m
//  WXReader
//
//  Created by Andrew on 2018/6/27.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_TextView.h"
#import <YYKit.h>

@interface WXYZ_TextView () <YYTextViewDelegate>
{
    YYTextView *textView;
    UILabel *wordCountLabel;
    NSString *_text;
}

@end

@implementation WXYZ_TextView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.layer.borderColor = kGrayViewColor.CGColor;
        self.layer.borderWidth = 0.6;
        self.backgroundColor = [UIColor whiteColor];
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    textView = [[YYTextView alloc] initWithFrame:CGRectZero];
    textView.placeholderText = @"说说你的看法...";
    textView.placeholderFont = kFont13;
    textView.placeholderTextColor = [UIColor grayColor];
    textView.font = kMainFont;
    textView.textColor = kBlackColor;
    textView.delegate = self;
    [self addSubview:textView];
    
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).with.offset(5);
        make.top.mas_equalTo(self.mas_top).with.offset(5);
        make.width.mas_equalTo(self.mas_width).with.offset(- 10);
        make.height.mas_equalTo(self.mas_height).with.offset(- 20);
    }];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    toolBar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(hideKeyboard)];
    [toolBar setItems:@[flexibleSpaceItem, doneItem]];
    textView.inputAccessoryView = toolBar;
    
    wordCountLabel = [[UILabel alloc] init];
    wordCountLabel.font = kFont10;
    wordCountLabel.textColor = kGrayTextColor;
    wordCountLabel.hidden = YES;
    wordCountLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:wordCountLabel];
    
    [wordCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(textView.mas_left);
        make.bottom.mas_equalTo(self.mas_bottom).with.offset(- 5);
        make.width.mas_equalTo(textView.mas_width);
        make.height.mas_equalTo(10);
    }];
}

- (void)setMaxWordCount:(NSUInteger)maxWordCount
{
    _maxWordCount = maxWordCount;
    if (maxWordCount > 0) {
        wordCountLabel.hidden = NO;
        wordCountLabel.text = [NSString stringWithFormat:@"%@/%@", [WXYZ_UtilsHelper formatStringWithInteger:0], [WXYZ_UtilsHelper formatStringWithInteger:_maxWordCount]];
    }
}

- (NSString *)text
{
    return [textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

- (void)resetPlaceholderText:(NSString *)placeholderText
{
    textView.placeholderText = placeholderText;
}

#pragma mark - YYTextViewDelegate
- (void)textViewDidChange:(YYTextView *)textView
{
    if (textView.text.length >= _maxWordCount) {
        textView.text = [textView.text substringToIndex:_maxWordCount];
    }
    
    if ([self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
        [self.delegate textViewDidChange:textView.text];
    }
    
    wordCountLabel.text = [NSString stringWithFormat:@"%@/%@", [WXYZ_UtilsHelper formatStringWithInteger:textView.text.length], [WXYZ_UtilsHelper formatStringWithInteger:_maxWordCount]];
}

- (void)hideKeyboard
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

@end

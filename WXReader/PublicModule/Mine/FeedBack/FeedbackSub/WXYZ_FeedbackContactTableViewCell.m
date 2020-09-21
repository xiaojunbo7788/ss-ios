//
//  WXYZ_FeedbackContactTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/12/27.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_FeedbackContactTableViewCell.h"

@interface WXYZ_FeedbackContactTableViewCell () <UITextFieldDelegate>
{
    UITextField *textField;
}

@property (nonatomic, copy) NSString *contactString;

@end

@implementation WXYZ_FeedbackContactTableViewCell

- (void)createSubviews
{
    [super createSubviews];
    
    textField = [[UITextField alloc] init];
    textField.backgroundColor = [UIColor clearColor];
    textField.font = kMainFont;
    textField.delegate = self;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.textColor = kBlackColor;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"QQ号/微信号/手机号"];
    [attributedString setAttributes:@{NSFontAttributeName:kMainFont, NSForegroundColorAttributeName:kColorRGBA(199, 199, 205, 1)} range:NSMakeRange(0, 11)];
    textField.attributedPlaceholder = attributedString;
    [self.contentView addSubview:textField];
    
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kMargin);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.width.mas_equalTo(SCREEN_WIDTH - 2 * kMargin);
        make.height.mas_equalTo(KCellHeight);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).priorityLow();
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    if (textField.text.length >= 30) {
        textField.text = [textField.text substringToIndex:30];
        return NO;
    }
    
    if (self.contactDidChange) {
        self.contactDidChange(textField.text);
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.willBeginEditing) {
        self.willBeginEditing();
    }
    return YES;
}

@end

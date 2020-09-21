//
//  DPSearchBar.m
//  WXReader
//
//  Created by Andrew on 2018/7/5.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_SearchBar.h"

#define SearchBar_Height 44

@implementation WXYZ_SearchBar
{
    UITextField *searchTextField;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    searchTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    searchTextField.backgroundColor = kColorRGBA(237, 238, 238, 1);
    searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchTextField.font = kMainFont;
    searchTextField.delegate = self;
    searchTextField.textColor = kBlackColor;
    searchTextField.returnKeyType = UIReturnKeySearch;
    [searchTextField addTarget:self action:@selector(changeText:) forControlEvents:UIControlEventEditingChanged];
    searchTextField.layer.cornerRadius = 4;
    searchTextField.clipsToBounds = YES;
    [self addSubview:searchTextField];
    
    [searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin);
        make.top.mas_equalTo(5);
        make.right.mas_equalTo(self.mas_right).with.offset(- 2 * kHalfMargin - SearchBar_Height);
        make.height.mas_equalTo(SearchBar_Height - 10);
    }];
    
    UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    leftImageView.image = [[UIImage imageNamed:@"public_search"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    leftImageView.tintColor = kColorRGBA(156, 155, 157, 1);
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, SearchBar_Height)];
    leftView.backgroundColor = [UIColor clearColor];
    [leftView addSubview:leftImageView];
    
    leftImageView.center = leftView.center;
    searchTextField.leftViewMode = UITextFieldViewModeAlways;
    searchTextField.leftView = leftView;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.backgroundColor = [UIColor clearColor];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:kGrayTextColor forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton.titleLabel setFont:kMainFont];
    [self addSubview:cancelButton];
    
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).with.offset(- kHalfMargin);
        make.centerY.equalTo(searchTextField);
        make.height.mas_equalTo(self.mas_height);
        make.width.mas_equalTo(SearchBar_Height);
    }];
}

- (void)cancelClick
{
    if ([self.delegate respondsToSelector:@selector(cancelButtonClicked)]) {
        [self.delegate cancelButtonClicked];
    }
}

- (void)setPlaceholderText:(NSString *)placeholderText
{
    _placeholderText = placeholderText;
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:placeholderText attributes:@{NSForegroundColorAttributeName:kColorRGBA(156, 155, 157, 1),NSFontAttributeName:kMainFont}];
    searchTextField.attributedPlaceholder = attrString;
}

- (void)setSearchText:(NSString *)searchText
{
    _searchText = searchText;
    searchTextField.text = searchText;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //如果为回车则将键盘收起
    if ([string isEqualToString:@"\n"]) {
        if (textField.text.length > 0) {
            if ([self.delegate respondsToSelector:@selector(searchButtonClickedWithSearchText:)]) {
                [self.delegate searchButtonClickedWithSearchText:searchTextField.text];
            }
        } else if (_placeholderText.length > 0) {
            if ([self.delegate respondsToSelector:@selector(searchButtonClickedWithSearchText:)]) {
                [self.delegate searchButtonClickedWithSearchText:_placeholderText];
            }
        }
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)changeText:(UITextField *)sender
{
    if ([sender.text isEqualToString:@""]) {
        if ([self.delegate respondsToSelector:@selector(searchBarCleanText)]) {
            [self.delegate searchBarCleanText];
        }
    }
}

- (void)searchBarResignFirstResponder
{
    if ([searchTextField isFirstResponder]) {
        [searchTextField resignFirstResponder];
    }
}

@end

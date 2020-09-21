//
//  WXYZ_BookReaderBottomSettingBar.m
//  WXReader
//
//  Created by Andrew on 2018/6/12.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BookReaderBottomSettingBar.h"
#import "WXYZ_ReaderSettingHelper.h"

#define ToolBarSettingView_Height ((50 * 4) + kHalfMargin)

@implementation WXYZ_BookReaderBottomSettingBar
{
    // 字号显示
    UILabel *fontSizeLabel;
    UIButton *decreaseFontBtn;
    UIButton *increaseFontBtn;
    
    WXYZ_ReaderSettingHelper *functionalManager;
    
    
    UIScrollView *backgroundScorll;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        functionalManager = [WXYZ_ReaderSettingHelper sharedManager];
        
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    CGFloat titleHeight = 50;
    CGFloat titleWidth = 50;
    CGFloat factoryButtonWidth = (SCREEN_WIDTH - titleWidth - 6 * kHalfMargin) / 4;
    CGFloat factoryButtonHeight = 30;
    
#pragma mark - 字号
    UILabel *fontTitle = [[UILabel alloc] init];
    fontTitle.text = @"字号";
    fontTitle.textAlignment = NSTextAlignmentCenter;
    fontTitle.textColor = kGrayTextColor;
    fontTitle.font = kFont13;
    [self addSubview:fontTitle];
    
    [fontTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).with.offset(kHalfMargin);
        make.top.mas_equalTo(self.mas_top).with.offset(kHalfMargin);
        make.width.mas_equalTo(titleWidth);
        make.height.mas_equalTo(titleHeight);
    }];
    
#pragma mark - 字号减小
    
    decreaseFontBtn = [self factorySettingButtonWithBackViewImageName:@"book_menu_font_sub" buttonTitle:nil tag:0 fitImageView:YES];
    decreaseFontBtn.adjustsImageWhenHighlighted = NO;
    [decreaseFontBtn addTarget:self action:@selector(fontSizeChangeClick:) forControlEvents:UIControlEventTouchUpInside];
    [decreaseFontBtn addTarget:self action:@selector(fontSizeChangeHighlighted:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:decreaseFontBtn];
    
    [decreaseFontBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(fontTitle.mas_right).with.offset(kHalfMargin);
        make.centerY.mas_equalTo(fontTitle.mas_centerY);
        make.width.mas_equalTo(factoryButtonWidth);
        make.height.mas_equalTo(factoryButtonHeight);
    }];
    
#pragma mark - 字号增加
    increaseFontBtn = [self factorySettingButtonWithBackViewImageName:@"book_menu_font_add" buttonTitle:nil tag:1 fitImageView:YES];
    increaseFontBtn.adjustsImageWhenHighlighted = NO;
    [increaseFontBtn addTarget:self action:@selector(fontSizeChangeClick:) forControlEvents:UIControlEventTouchUpInside];
    [increaseFontBtn addTarget:self action:@selector(fontSizeChangeHighlighted:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:increaseFontBtn];
    
    [increaseFontBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(decreaseFontBtn.mas_centerY);
        make.width.mas_equalTo(decreaseFontBtn.mas_width);
        make.height.mas_equalTo(decreaseFontBtn.mas_height);
    }];
    
    if ([functionalManager getReaderFontSize] == [functionalManager getReaderMinFontSize]) {
        decreaseFontBtn.imageView.tintColor = kGrayTextColor;
    } else if ([functionalManager getReaderFontSize] == [functionalManager getReaderMaxFontSize]) {
        increaseFontBtn.imageView.tintColor = kGrayTextColor;
    }
    
#pragma mark - 显示字号
    fontSizeLabel = [[UILabel alloc] init];
    fontSizeLabel.textAlignment = NSTextAlignmentCenter;
    fontSizeLabel.font = kFont15;
    fontSizeLabel.text = [NSString stringWithFormat:@"%.lf",[functionalManager getReaderFontSize]];
    fontSizeLabel.textColor = kBlackColor;
    [self addSubview:fontSizeLabel];
    
    [fontSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(decreaseFontBtn.mas_right);
        make.right.mas_equalTo(increaseFontBtn.mas_left);
        make.centerY.mas_equalTo(decreaseFontBtn.mas_centerY);
        make.height.mas_equalTo(decreaseFontBtn.mas_height);
    }];
    
#pragma mark - 字体间距
    UILabel *spaceLineTitle = [[UILabel alloc] init];
    spaceLineTitle.text = @"间距";
    spaceLineTitle.textAlignment = NSTextAlignmentCenter;
    spaceLineTitle.textColor = kGrayTextColor;
    spaceLineTitle.font = kFont13;
    [self addSubview:spaceLineTitle];
    
    [spaceLineTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).with.offset(kHalfMargin);
        make.top.mas_equalTo(fontTitle.mas_bottom);
        make.width.mas_equalTo(titleWidth);
        make.height.mas_equalTo(titleHeight);
    }];
    
#pragma mark - 字体间距大
    UIButton *lineSpacingSmall = [self factorySettingButtonWithBackViewImageName:@"book_menu_line_spacing_big" buttonTitle:nil tag:10 fitImageView:YES];
    [lineSpacingSmall addTarget:self action:@selector(lineSpacingChangeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:lineSpacingSmall];
    
    [lineSpacingSmall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(decreaseFontBtn.mas_left);
        make.centerY.mas_equalTo(spaceLineTitle.mas_centerY);
        make.width.mas_equalTo(decreaseFontBtn.mas_width);
        make.height.mas_equalTo(decreaseFontBtn.mas_height);
    }];
    
#pragma mark - 字体间距中
    UIButton *lineSpacingMedium = [self factorySettingButtonWithBackViewImageName:@"book_menu_line_spacing_medium" buttonTitle:nil tag:11 fitImageView:YES];
    [lineSpacingMedium addTarget:self action:@selector(lineSpacingChangeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:lineSpacingMedium];
    
    [lineSpacingMedium mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(fontSizeLabel.mas_centerX);
        make.centerY.mas_equalTo(spaceLineTitle.mas_centerY);
        make.width.mas_equalTo(decreaseFontBtn.mas_width);
        make.height.mas_equalTo(decreaseFontBtn.mas_height);
    }];
    
#pragma mark - 字体间距小
    UIButton *lineSpacingBig = [self factorySettingButtonWithBackViewImageName:@"book_menu_line_spacing_small" buttonTitle:nil tag:12 fitImageView:YES];
    [lineSpacingBig addTarget:self action:@selector(lineSpacingChangeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:lineSpacingBig];
    
    [lineSpacingBig mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(spaceLineTitle.mas_centerY);
        make.width.mas_equalTo(decreaseFontBtn.mas_width);
        make.height.mas_equalTo(decreaseFontBtn.mas_height);
    }];
    
    CGFloat t_lineSpacing = [functionalManager getReaderLinesSpacing];
    if (t_lineSpacing == line_spacing_small) {
        lineSpacingSmall.backgroundColor = kMainColor;
        lineSpacingSmall.imageView.tintColor = kWhiteColor;
    } else if (t_lineSpacing == line_spacing_medium) {
        lineSpacingMedium.backgroundColor = kMainColor;
        lineSpacingMedium.imageView.tintColor = kWhiteColor;
    } else {
        lineSpacingBig.backgroundColor = kMainColor;
        lineSpacingBig.imageView.tintColor = kWhiteColor;
    }
    
#pragma mark - 翻页
    UILabel *pageTitle = [[UILabel alloc] init];
    pageTitle.text = @"翻页";
    pageTitle.textAlignment = NSTextAlignmentCenter;
    pageTitle.textColor = kGrayTextColor;
    pageTitle.font = kFont13;
    [self addSubview:pageTitle];
    
    [pageTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).with.offset(kHalfMargin);
        make.top.mas_equalTo(spaceLineTitle.mas_bottom);
        make.width.mas_equalTo(titleWidth);
        make.height.mas_equalTo(titleHeight);
    }];
    
#pragma mark - 仿真
    UIButton *pageCurlButton = [self factorySettingButtonWithBackViewImageName:nil buttonTitle:@"仿真" tag:100 fitImageView:YES];
    [pageCurlButton addTarget:self action:@selector(transitionStyleChangeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:pageCurlButton];
    
    [pageCurlButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(decreaseFontBtn.mas_left);
        make.centerY.mas_equalTo(pageTitle.mas_centerY);
        make.width.mas_equalTo(decreaseFontBtn.mas_width);
        make.height.mas_equalTo(decreaseFontBtn.mas_height);
    }];
    
#pragma mark - 滚动
    UIButton *scrollButton = [self factorySettingButtonWithBackViewImageName:nil buttonTitle:@"滑动" tag:101 fitImageView:YES];
    [scrollButton addTarget:self action:@selector(transitionStyleChangeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:scrollButton];
    
    [scrollButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(pageCurlButton.mas_right).with.offset(7);
        make.centerY.mas_equalTo(pageTitle.mas_centerY);
        make.width.mas_equalTo(decreaseFontBtn.mas_width);
        make.height.mas_equalTo(decreaseFontBtn.mas_height);
    }];
    
#pragma mark - 覆盖
    UIButton *coverButton = [self factorySettingButtonWithBackViewImageName:nil buttonTitle:@"覆盖" tag:102 fitImageView:YES];
    [coverButton addTarget:self action:@selector(transitionStyleChangeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:coverButton];
    
    [coverButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(scrollButton.mas_right).with.offset(7);
        make.centerY.mas_equalTo(pageTitle.mas_centerY);
        make.width.mas_equalTo(decreaseFontBtn.mas_width);
        make.height.mas_equalTo(decreaseFontBtn.mas_height);
    }];
    
#pragma mark - 无效果
    UIButton *noneButton = [self factorySettingButtonWithBackViewImageName:nil buttonTitle:@"无" tag:103 fitImageView:YES];
    [noneButton addTarget:self action:@selector(transitionStyleChangeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:noneButton];
    
    [noneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(coverButton.mas_right).with.offset(7);
        make.centerY.mas_equalTo(pageTitle.mas_centerY);
        make.width.mas_equalTo(decreaseFontBtn.mas_width);
        make.height.mas_equalTo(decreaseFontBtn.mas_height);
    }];
    
    switch ([functionalManager getTransitionStyle]) {
        case WXReaderTransitionStylePageCurl:
            pageCurlButton.selected = YES;
            pageCurlButton.backgroundColor = kMainColor;
            break;
        case WXReaderTransitionStyleScroll:
            scrollButton.selected = YES;
            scrollButton.backgroundColor = kMainColor;
            break;
        case WXReaderTransitionStyleCover:
            coverButton.selected = YES;
            coverButton.backgroundColor = kMainColor;
            break;
        case WXReaderTransitionStyleNone:
            noneButton.selected = YES;
            noneButton.backgroundColor = kMainColor;
            break;
            
        default:
            break;
    }
    
#pragma mark - 背景
    UILabel *backViewTitle = [[UILabel alloc] init];
    backViewTitle.text = @"背景";
    backViewTitle.textAlignment = NSTextAlignmentCenter;
    backViewTitle.textColor = kGrayTextColor;
    backViewTitle.font = kFont13;
    [self addSubview:backViewTitle];
    
    [backViewTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).with.offset(kHalfMargin);
        make.top.mas_equalTo(pageTitle.mas_bottom);
        make.width.mas_equalTo(titleWidth);
        make.height.mas_equalTo(titleHeight);
    }];
    
#pragma mark - 背景滚动
    backgroundScorll = [[UIScrollView alloc] init];
    backgroundScorll.backgroundColor = kWhiteColor;
    backgroundScorll.showsVerticalScrollIndicator = NO;
    backgroundScorll.showsHorizontalScrollIndicator = NO;
    [self addSubview:backgroundScorll];
    
    [backgroundScorll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(decreaseFontBtn.mas_left);
        make.right.mas_equalTo(self.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(backViewTitle.mas_centerY);
        make.height.mas_equalTo(backViewTitle.mas_height);
    }];
    [backgroundScorll setNeedsLayout];
    [backgroundScorll layoutIfNeeded];
    
    NSMutableArray *backgroundImageArr = [[functionalManager getReaderBackgroundColorModeArray] mutableCopy];
    [backgroundImageArr removeLastObject];
    NSUInteger buttonNum = backgroundImageArr.count;//每行多少按钮
    CGFloat button_W = factoryButtonHeight + 5; //按钮宽
    CGFloat button_H = factoryButtonHeight + 5; //按钮高
    CGFloat space_X = (CGRectGetWidth(backgroundScorll.bounds) - (button_W * buttonNum)) / (buttonNum - 1);// 按钮间距
    for (int i = 0; i < backgroundImageArr.count; i++) {
        int loc = i % buttonNum;//列号
        CGFloat button_X = (space_X + button_W) * loc;
        
        UIButton *button = [self factorySettingButtonWithBackViewImageName:@"" buttonTitle:nil tag:i fitImageView:NO];
        button.tintColor = kMainColor;
        button.layer.contents = (id)[UIImage imageNamed:[[functionalManager getReaderBackgroundColorModeArray] objectAtIndex:i]].CGImage;
        button.layer.cornerRadius = 4;
        button.clipsToBounds = YES;
        button.tag = i;
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        button.contentHorizontalAlignment = UIControlContentVerticalAlignmentFill;
        [button setImageEdgeInsets:UIEdgeInsetsMake(factoryButtonHeight * 0.5, factoryButtonHeight * 0.5, 0, 0)];
        [button addTarget:self action:@selector(changeBackgroundImageClick:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundScorll addSubview:button];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(button_X);
            make.centerY.mas_equalTo(backgroundScorll.mas_centerY);
            make.width.mas_equalTo(button_W);
            make.height.mas_equalTo(button_H);
        }];
        
        if (i == WXReaderBackColorWhite) {
            button.layer.borderColor = kColorRGBA(235, 235, 241, 1).CGColor;
            button.layer.borderWidth = 0.8;
        }
        
        if ([functionalManager getReaderBackgroundColorMode] == i) {
            [button setImage:[[UIImage imageNamed:@"book_setting_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        }
        
    }
    backgroundScorll.contentSize = CGSizeMake((button_W + kHalfMargin) * backgroundImageArr.count, 0);
}

#pragma mark - 点击事件
// 改变字号
- (void)fontSizeChangeClick:(UIButton *)sender
{
    sender.backgroundColor = kColorRGBA(235, 235, 241, 1);
    sender.imageView.tintColor = kBlackColor;
    
    CGFloat temp_font = [functionalManager getReaderFontSize];
    if (sender.tag == 0) {
        if (temp_font == [functionalManager getReaderMinFontSize]) {
            sender.imageView.tintColor = kGrayTextColor;
            return;
        }
        [functionalManager setReaderFontSize:temp_font - 1];
        fontSizeLabel.text = [NSString stringWithFormat:@"%.lf",[functionalManager getReaderFontSize]];
    } else {
        if (temp_font == [functionalManager getReaderMaxFontSize]) {
            sender.imageView.tintColor = kGrayTextColor;
            return;
        }
        [functionalManager setReaderFontSize:temp_font + 1];
        fontSizeLabel.text = [NSString stringWithFormat:@"%.lf",[functionalManager getReaderFontSize]];
    }
    
    if ([functionalManager getReaderFontSize] == [functionalManager getReaderMinFontSize]) {
        decreaseFontBtn.imageView.tintColor = kGrayTextColor;
    } else if ([functionalManager getReaderFontSize] == [functionalManager getReaderMaxFontSize]) {
        increaseFontBtn.imageView.tintColor = kGrayTextColor;
    } else {
        decreaseFontBtn.imageView.tintColor = kBlackColor;
        increaseFontBtn.imageView.tintColor = kBlackColor;
    }
}

- (void)fontSizeChangeHighlighted:(UIButton *)sender
{
    if (sender.tag == 0 && [functionalManager getReaderFontSize] == [functionalManager getReaderMinFontSize]) {
        return;
    }
    
    if (sender.tag == 1 && [functionalManager getReaderFontSize] == [functionalManager getReaderMaxFontSize]) {
        return;
    }
    
    sender.backgroundColor = kMainColor;
    sender.imageView.tintColor = kWhiteColor;
}

// 改变背景色
- (void)changeBackgroundImageClick:(UIButton *)sender
{
    [backgroundScorll.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton *t_btn = (UIButton *)obj;
            [t_btn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        }
    }];

    [sender setImage:[[UIImage imageNamed:@"book_setting_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    [functionalManager setNightModeState:WXReaderPatternModeDaytime];
    [functionalManager setReaderBackgroundColor:sender.tag];
}

// 设置翻页类型
- (void)transitionStyleChangeClick:(UIButton *)sender
{
    for (UIView *t_view in self.subviews) {
        if ([t_view isKindOfClass:[UIButton class]] && (t_view.tag == 100 || t_view.tag == 101 || t_view.tag == 102 || t_view.tag == 103)) {
            UIButton *t_button = (UIButton *)t_view;
            t_button.backgroundColor = kColorRGBA(235, 235, 241, 1);
            t_button.selected = NO;
        }
    }
    
    switch (sender.tag) {
        case 100:
            [functionalManager setTransitionStyle:WXReaderTransitionStylePageCurl];
            break;
        case 101:
            [functionalManager setTransitionStyle:WXReaderTransitionStyleScroll];
            break;
        case 102:
            [functionalManager setTransitionStyle:WXReaderTransitionStyleCover];
            break;
        case 103:
            [functionalManager setTransitionStyle:WXReaderTransitionStyleNone];
            break;
            
        default:
            break;
    }
    
    sender.selected = YES;
    sender.backgroundColor = kMainColor;
}

// 设置字间距
- (void)lineSpacingChangeClick:(UIButton *)sender
{
    for (UIView *t_view in self.subviews) {
        if ([t_view isKindOfClass:[UIButton class]] && (t_view.tag == 10 || t_view.tag == 11 || t_view.tag == 12)) {
            UIButton *t_button = (UIButton *)t_view;
            t_button.backgroundColor = kColorRGBA(235, 235, 241, 1);
            t_button.imageView.tintColor = kBlackColor;
        }
    }
    
    switch (sender.tag) {
        case 10:
            [functionalManager setReaderLinesSpacing:line_spacing_small];
            break;
        case 11:
            [functionalManager setReaderLinesSpacing:line_spacing_medium];
            break;
        case 12:
            [functionalManager setReaderLinesSpacing:line_spacing_big];
            break;
            
        default:
            break;
    }
    
    sender.imageView.tintColor = kWhiteColor;
    sender.backgroundColor = kMainColor;
}

- (UIButton *)factorySettingButtonWithBackViewImageName:(NSString *)imageName buttonTitle:(NSString *)title tag:(NSInteger)tag fitImageView:(BOOL)fitImage
{
    UIButton *t_factory = [UIButton buttonWithType:UIButtonTypeCustom];
    t_factory.backgroundColor = kColorRGBA(235, 235, 241, 1);
    t_factory.layer.cornerRadius = 2;
    t_factory.tag = tag;
    [t_factory.titleLabel setTextAlignment:NSTextAlignmentCenter];
    if (title.length > 0) {
        t_factory.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [t_factory setTitle:title forState:0];
        [t_factory.titleLabel setFont:kMainFont];
        [t_factory setTitleColor:kBlackColor forState:UIControlStateNormal];
        [t_factory setTitleColor:kWhiteColor forState:UIControlStateSelected];
    } else {
        if (imageName.length > 0) {
            t_factory.imageView.tintColor = kBlackColor;
            t_factory.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
            t_factory.contentHorizontalAlignment = UIControlContentVerticalAlignmentFill;
            [t_factory setImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            [t_factory setImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
        }
        if (fitImage) {
            t_factory.imageView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            t_factory.imageView.tintColor = kMainColor;
        }
    }
    
    return t_factory;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (!hidden) {
        [backgroundScorll.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[UIButton class]]) {
                UIButton *t_btn = (UIButton *)obj;
                if ([functionalManager getReaderBackgroundColorMode] == t_btn.tag) {
                    [t_btn setImage:[UIImage imageNamed:@"book_setting_select"] forState:UIControlStateNormal];
                } else {
                    [t_btn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                }
            }
        }];
    }
}

@end

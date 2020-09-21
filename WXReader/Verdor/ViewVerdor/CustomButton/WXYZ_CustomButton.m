//
//  WXYZ_CustomButton.m
//  WXReader
//
//  Created by Andrew on 2019/5/31.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_CustomButton.h"

@interface WXYZ_CustomButton ()
{
    BOOL _showMaskView;
    WXYZ_CustomButtonIndicator _buttonIndicatior;
}

@property (nonatomic, strong) UIView *bottomHoldView;

@property (nonatomic, strong) UIImageView *buttonImageView;

@property (nonatomic, strong) UILabel *buttonTitleLabel;

@property (nonatomic, strong) UILabel *buttonSubTitleLabel;

@property (nonatomic, strong) UILabel *cornerMarkLabel;

@property (nonatomic, strong) UIView *maskView;

@end

@implementation WXYZ_CustomButton

- (instancetype)initWithButtonTitle:(NSString *)buttonTitle buttonImageName:(NSString *)buttonImageName buttonIndicator:(WXYZ_CustomButtonIndicator)buttonIndicatior
{
    return [self initWithFrame:CGRectZero buttonTitle:buttonTitle buttonSubTitle:@"" buttonImageName:buttonImageName buttonIndicator:buttonIndicatior showMaskView:NO];
}

- (instancetype)initWithFrame:(CGRect)frame buttonTitle:(NSString *)buttonTitle buttonImageName:(NSString *)buttonImageName buttonIndicator:(WXYZ_CustomButtonIndicator)buttonIndicatior
{
    return [self initWithFrame:frame buttonTitle:buttonTitle buttonSubTitle:@"" buttonImageName:buttonImageName buttonIndicator:buttonIndicatior showMaskView:NO];
}

- (instancetype)initWithFrame:(CGRect)frame buttonTitle:(NSString *)buttonTitle buttonImageName:(NSString *)buttonImageName buttonIndicator:(WXYZ_CustomButtonIndicator)buttonIndicatior showMaskView:(BOOL)showMaskView
{
    return [self initWithFrame:frame buttonTitle:buttonTitle buttonSubTitle:@"" buttonImageName:buttonImageName buttonIndicator:buttonIndicatior showMaskView:showMaskView];
}

- (instancetype)initWithFrame:(CGRect)frame buttonTitle:(NSString *)buttonTitle buttonSubTitle:(NSString *)buttonSubTitle buttonImageName:(NSString *)buttonImageName buttonIndicator:(WXYZ_CustomButtonIndicator)buttonIndicatior showMaskView:(BOOL)showMaskView
{
    if (self = [super initWithFrame:frame]) {
        self.graphicDistance = 10;
        self.buttonImageScale = 0.7;
        self.horizontalMigration = 0;
        self.buttonTitle = buttonTitle;
        self.buttonSubTitle = buttonSubTitle;
        self.buttonImageName = buttonImageName;
        
        _showMaskView = showMaskView;
        _buttonIndicatior = buttonIndicatior;
                
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    [self addSubview:self.bottomHoldView];
    
    self.buttonTitleLabel.text = _buttonTitle;
    [self.bottomHoldView addSubview:self.buttonTitleLabel];
    
    if (_buttonImageName.length > 0) {
        if ([_buttonImageName hasPrefix:@"http"]) {
            [self.buttonImageView setImageWithURL:[NSURL URLWithString:_buttonImageName] placeholder:HoldImage options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
        } else {
            self.buttonImageView.image = [[UIImage imageNamed:_buttonImageName] imageWithRenderingMode:UIImageRenderingModeAutomatic];
        }
        [self.bottomHoldView addSubview:self.buttonImageView];
    }
    
    self.cornerMarkLabel.hidden = YES;
    [self.buttonImageView addSubview:self.cornerMarkLabel];
    [self.cornerMarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.buttonImageView.mas_right);
        make.centerY.mas_equalTo(self.buttonImageView.mas_top);
        make.height.mas_equalTo(CGFLOAT_MIN);
        make.width.mas_equalTo(CGFLOAT_MIN);
    }];
    
    if (_buttonSubTitle.length > 0) {
        self.buttonSubTitleLabel.text = _buttonSubTitle;
        [self.bottomHoldView addSubview:self.buttonSubTitleLabel];
    }
    
    if (_showMaskView) {
        [self addSubview:self.maskView];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    switch (_buttonIndicatior) {
        case WXYZ_CustomButtonIndicatorTitleLeft:// 文字左 图片右
            [self createCustomButtonIndicatorTitleLeft];
            break;
        case WXYZ_CustomButtonIndicatorTitleRight:// 文字右 图片左
            [self createCustomButtonIndicatorTitleRight];
            break;
        case WXYZ_CustomButtonIndicatorTitleTop:// 文字上 图片下
            [self createCustomButtonIndicatorTitleTop];
            break;
        case WXYZ_CustomButtonIndicatorTitleBottom:// 文字下 图片上
            [self createCustomButtonIndicatorTitleBottom];
            break;
        case WXYZ_CustomButtonIndicatorImageLeftBothLeft:// 图片左 文字右 (同时靠左)
            [self createCustomButtonIndicatorImageLeftBothLeft];
            break;
        case WXYZ_CustomButtonIndicatorImageLeftBothRight:// 图片左 文字右 (同时靠右)
            [self createCustomButtonIndicatorImageLeftBothRight];
            break;
        case WXYZ_CustomButtonIndicatorImageRightBothLeft:// 文字左 图片右 (同时靠左)
            [self createCustomButtonIndicatorImageRightBothLeft];
            break;
        case WXYZ_CustomButtonIndicatorImageRightBothRight:// 文字左 图片右 (同时靠右)
            [self createCustomButtonIndicatorImageRightBothRight];
            break;
            
        default:
            break;
    }
}

- (void)undoMaskView
{
    self.maskView.hidden = YES;
    [self.maskView removeAllSubviews];
    [self.maskView removeFromSuperview];
    self.maskView = nil;
}

// 图片边长
- (CGFloat)getButtonImageViewSideLength
{
    if (self.height >= self.width) {
        return self.width * self.buttonImageScale;
    }
    return self.height * self.buttonImageScale;
}

// 控件边距
- (CGFloat)getViewMargin
{
    if (self.height >= self.width) {
        return self.width * (1 - self.buttonImageScale);
    }
    return self.height * (1 - self.buttonImageScale);
}

// 文字左 图片右
- (void)createCustomButtonIndicatorTitleLeft
{
    if (_buttonImageName.length > 0) {
        [self.bottomHoldView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX).with.offset(self.horizontalMigration);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(self.mas_height);
            make.left.mas_equalTo(self.buttonTitleLabel.mas_left);
            make.right.mas_equalTo(self.buttonImageView.mas_right);
        }];
        [self.buttonImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.buttonTitleLabel.mas_right).with.offset(self.graphicDistance);
            make.centerY.mas_equalTo(self.bottomHoldView.mas_centerY);
            make.width.height.mas_equalTo([self getButtonImageViewSideLength]);
        }];
        
        self.buttonTitleLabel.textAlignment = NSTextAlignmentRight;
        [self.buttonTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:self.buttonTitleLabel] > self.width?self.width:[WXYZ_ViewHelper getDynamicWidthWithLabel:self.buttonTitleLabel]);
            make.height.mas_equalTo(self.mas_height);
        }];
    } else {
        [self.bottomHoldView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX).with.offset(self.horizontalMigration);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(self.mas_height);
            make.left.mas_equalTo(self.buttonTitleLabel.mas_left);
            make.right.mas_equalTo(self.buttonTitleLabel.mas_right);
        }];
        [self.buttonTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.centerX.mas_equalTo(self.mas_centerX);
            make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:self.buttonTitleLabel] > self.width?self.width:[WXYZ_ViewHelper getDynamicWidthWithLabel:self.buttonTitleLabel]);
            make.height.mas_equalTo(self.mas_height);
        }];
    }
    
    if (_buttonSubTitle.length > 0) {
        self.buttonSubTitleLabel.text = _buttonSubTitle;
        self.buttonSubTitleLabel.textAlignment = NSTextAlignmentRight;
        
        [self.buttonSubTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.buttonTitleLabel.mas_left);
            make.bottom.mas_equalTo(self.bottomHoldView.mas_bottom);
            make.width.mas_equalTo(self.buttonTitleLabel.mas_width);
            make.height.mas_equalTo(self.mas_height).multipliedBy(0.4);
        }];
        
        [self.buttonTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.mas_height).multipliedBy(0.6);
        }];
    }
}

// 文字右 图片左
- (void)createCustomButtonIndicatorTitleRight
{
    if (_buttonImageName.length > 0) {
        [self.bottomHoldView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX).with.offset(self.horizontalMigration);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(self.mas_height);
            make.left.mas_equalTo(self.buttonImageView.mas_left);
            make.right.mas_equalTo(self.buttonTitleLabel.mas_right);
        }];
        [self.buttonImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.buttonTitleLabel.mas_left).with.offset(- self.graphicDistance);
            make.centerY.mas_equalTo(self.bottomHoldView.mas_centerY);
            make.width.height.mas_equalTo([self getButtonImageViewSideLength]);
        }];
        
        self.buttonTitleLabel.textAlignment = NSTextAlignmentRight;
        [self.buttonTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.right.mas_equalTo(self.bottomHoldView.mas_right);
            make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:self.buttonTitleLabel] > self.width?self.width:[WXYZ_ViewHelper getDynamicWidthWithLabel:self.buttonTitleLabel]);
            make.height.mas_equalTo(self.mas_height).priorityMedium();
        }];
    } else {
        [self.bottomHoldView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX).with.offset(self.horizontalMigration);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(self.mas_height);
            make.left.mas_equalTo(self.buttonTitleLabel.mas_left);
            make.right.mas_equalTo(self.buttonTitleLabel.mas_right);
        }];
        [self.buttonTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.centerX.mas_equalTo(self.mas_centerX);
            make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:self.buttonTitleLabel] > self.width?self.width:[WXYZ_ViewHelper getDynamicWidthWithLabel:self.buttonTitleLabel]);
            make.height.mas_equalTo(self.mas_height).priorityMedium();
        }];
    }
    
    if (_buttonSubTitle.length > 0) {
        self.buttonSubTitleLabel.text = _buttonSubTitle;
        self.buttonSubTitleLabel.textAlignment = NSTextAlignmentRight;
        
        [self.buttonSubTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.buttonTitleLabel.mas_left);
            make.bottom.mas_equalTo(self.bottomHoldView.mas_bottom);
            make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:self.buttonSubTitleLabel]);
            make.height.mas_equalTo(self.mas_height).multipliedBy(0.4);
        }];
        
        [self.buttonTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.mas_height).multipliedBy(0.6);
        }];
    }
}

// 文字上 图片下
- (void)createCustomButtonIndicatorTitleTop
{
    [self.buttonTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(self.mas_right);
        make.left.mas_equalTo(self.mas_left);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
    
    if (_buttonImageName.length > 0) {
        [self.buttonImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.buttonTitleLabel.mas_left);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.width.height.mas_equalTo([self getButtonImageViewSideLength] / 2);
        }];

        [self.buttonTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.buttonImageView.mas_top);
        }];
    }
    
    if (_buttonSubTitle.length > 0) {
        self.buttonSubTitleLabel.text = _buttonSubTitle;
        
        [self.buttonSubTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.buttonTitleLabel.mas_left);
            make.top.mas_equalTo(self.mas_centerY);
            make.width.mas_equalTo(self.buttonTitleLabel.mas_width);
            make.height.mas_equalTo(self.mas_height).multipliedBy(0.5);
        }];
        
        [self.buttonTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.mas_height).multipliedBy(0.5);
        }];
    }
}

// 文字下 图片上
- (void)createCustomButtonIndicatorTitleBottom
{
    [self.bottomHoldView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    if (_buttonImageName.length > 0) {
        [self.buttonImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.buttonMargin);
            make.centerX.mas_equalTo(self.mas_centerX);
            make.width.height.mas_equalTo([self getButtonImageViewSideLength]);
        }];
        
        self.buttonTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self.buttonTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(self.bottomHoldView.mas_right);
            make.top.mas_equalTo(self.buttonImageView.mas_bottom).with.offset(self.graphicDistance);
            make.bottom.mas_equalTo(self.bottomHoldView.mas_bottom).with.offset(- self.buttonMargin);
        }];
    } else {
        [self.buttonTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(self.bottomHoldView.mas_bottom).with.offset(- self.buttonMargin);
            make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:self.buttonTitleLabel] > self.width?self.width:[WXYZ_ViewHelper getDynamicWidthWithLabel:self.buttonTitleLabel]);
            make.height.mas_equalTo(self.mas_height);
        }];
    }
}

// 图片左 文字右 (同时靠左)
- (void)createCustomButtonIndicatorImageLeftBothLeft
{
    self.buttonTitleLabel.textAlignment = NSTextAlignmentLeft;
    
    if (_buttonImageName.length > 0) {
        [self.buttonImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.width.height.mas_equalTo([self getButtonImageViewSideLength]);
        }];
        
        [self.buttonTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.buttonImageView.mas_right).with.offset(self.graphicDistance);
            make.right.mas_equalTo(self.mas_right);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(self.mas_height);
        }];
    } else {
        [self.buttonTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(self.mas_right);
            make.height.mas_equalTo(self.mas_height);
        }];
    }
    
    if (_buttonSubTitle.length > 0) {
        self.buttonSubTitleLabel.text = _buttonSubTitle;
        self.buttonSubTitleLabel.textAlignment = NSTextAlignmentRight;
        
        [self.buttonSubTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.buttonTitleLabel.mas_left);
            make.top.mas_equalTo(self.mas_centerY);
            make.width.mas_equalTo(self.buttonTitleLabel.mas_width);
            make.height.mas_equalTo(self.mas_height).multipliedBy(0.4);
        }];
        
        [self.buttonTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.mas_height).multipliedBy(0.6);
        }];
    }
}

// 图片左 文字右 (同时靠右)
- (void)createCustomButtonIndicatorImageLeftBothRight
{
    [self.buttonTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(self.mas_right);
        make.left.mas_equalTo(self.mas_left);
        make.height.mas_equalTo(self.mas_height);
    }];
    
    if (_buttonImageName.length > 0) {
        [self.buttonImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.width.height.mas_equalTo([self getButtonImageViewSideLength]);
        }];
        
        self.buttonTitleLabel.textAlignment = NSTextAlignmentLeft;
        [self.buttonTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
           make.left.mas_equalTo(self.buttonImageView.mas_right).with.offset(self.graphicDistance);
        }];
    }
    
    if (_buttonSubTitle.length > 0) {
        self.buttonSubTitleLabel.text = _buttonSubTitle;
        self.buttonSubTitleLabel.textAlignment = NSTextAlignmentLeft;
        [self.buttonSubTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.buttonTitleLabel.mas_left);
            make.top.mas_equalTo(self.mas_centerY);
            make.width.mas_equalTo(self.buttonTitleLabel.mas_width);
            make.height.mas_equalTo(self.mas_height).multipliedBy(0.4);
        }];
        
        [self.buttonTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.mas_height).multipliedBy(0.6);
        }];
    }
}

// 文字左 图片右 (同时靠左)
- (void)createCustomButtonIndicatorImageRightBothLeft
{
    [self.buttonTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(self.mas_right);
        make.height.mas_equalTo(self.mas_height);
    }];
    
    if (_buttonImageName.length > 0) {
        [self.buttonImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.buttonTitleLabel.mas_right).with.offset(self.graphicDistance);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.width.height.mas_equalTo([self getButtonImageViewSideLength]);
        }];
        
        self.buttonTitleLabel.textAlignment = NSTextAlignmentRight;
        [self.buttonTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
           make.right.mas_equalTo(self.mas_right).with.offset(- self.width / 2 + self.graphicDistance / 2);
        }];
    }
    
    if (_buttonSubTitle.length > 0) {
        self.buttonSubTitleLabel.text = _buttonSubTitle;
        self.buttonSubTitleLabel.textAlignment = NSTextAlignmentRight;
        
        [self.buttonSubTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.buttonTitleLabel.mas_left);
            make.top.mas_equalTo(self.mas_centerY);
            make.width.mas_equalTo(self.buttonTitleLabel.mas_width);
            make.height.mas_equalTo(self.mas_height).multipliedBy(0.4);
        }];
        
        [self.buttonTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.mas_height).multipliedBy(0.6);
        }];
    }
}

// 文字左 图片右 (同时靠右)
- (void)createCustomButtonIndicatorImageRightBothRight
{
    self.buttonTitleLabel.textAlignment = NSTextAlignmentRight;
    
    if (_buttonImageName.length > 0) {
        [self.buttonImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.mas_right);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.width.height.mas_equalTo([self getButtonImageViewSideLength]);
        }];
        
        [self.buttonTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(self.buttonImageView.mas_left).with.offset(- self.graphicDistance);
            make.height.mas_equalTo(self.mas_height);
        }];
    } else {
        [self.buttonTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(self.mas_right);
            make.height.mas_equalTo(self.mas_height);
        }];
    }
    
    if (_buttonSubTitle.length > 0) {
        self.buttonSubTitleLabel.text = _buttonSubTitle;
        self.buttonSubTitleLabel.textAlignment = NSTextAlignmentRight;
        
        [self.buttonSubTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.buttonTitleLabel.mas_left);
            make.top.mas_equalTo(self.mas_centerY);
            make.width.mas_equalTo(self.buttonTitleLabel.mas_width);
            make.height.mas_equalTo(self.mas_height).multipliedBy(0.4);
        }];
        
        [self.buttonTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.mas_height).multipliedBy(0.6);
        }];
    }
}

#pragma mark - 变量设置
/*
 text
 */
- (void)setButtonTitle:(NSString *)buttonTitle
{
    _buttonTitle = buttonTitle;
    self.buttonTitleLabel.text = buttonTitle;
}

- (void)setButtonSubTitle:(NSString *)buttonSubTitle
{
    _buttonSubTitle = buttonSubTitle;
    self.buttonSubTitleLabel.text = buttonSubTitle;
}

- (void)setButtonTitleFont:(UIFont *)buttonTitleFont
{
    _buttonTitleFont = buttonTitleFont;
    self.buttonTitleLabel.font = buttonTitleFont;
}

- (void)setButtonSubTitleFont:(UIFont *)buttonSubTitleFont
{
    _buttonSubTitleFont = buttonSubTitleFont;
    self.buttonSubTitleLabel.font = buttonSubTitleFont;
}

/*
 color
 */

- (void)setButtonTitleColor:(UIColor *)buttonTitleColor
{
    _buttonTitleColor = buttonTitleColor;
    self.buttonTitleLabel.textColor = buttonTitleColor;
}

- (void)setButtonSubTitleColor:(UIColor *)buttonSubTitleColor
{
    _buttonSubTitleColor = buttonSubTitleColor;
    self.buttonSubTitleLabel.textColor = buttonSubTitleColor;
}

- (void)setButtonTintColor:(UIColor *)buttonTintColor
{
    _buttonTintColor = buttonTintColor;
    self.buttonTitleLabel.textColor = buttonTintColor;
    self.buttonSubTitleLabel.textColor = buttonTintColor;
    _buttonImageView.image = [_buttonImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.buttonImageView.tintColor = buttonTintColor;
}

/*
 image
 */
- (void)setButtonImageName:(NSString *)buttonImageName
{
    _buttonImageName = buttonImageName;
    _buttonImageView.image = [[UIImage imageNamed:buttonImageName] imageWithRenderingMode:UIImageRenderingModeAutomatic];
}

/*
 frame
 */

- (void)setButtonImageViewWidth:(NSInteger)buttonImageViewWidth
{
    _buttonImageViewWidth = buttonImageViewWidth;
    
    [self.buttonImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(buttonImageViewWidth)).priorityHigh();
    }];
}

- (void)setButtonImageViewHeight:(NSInteger)buttonImageViewHeight
{
    _buttonImageViewHeight = buttonImageViewHeight;
    
    [self.buttonImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(buttonImageViewHeight)).with.priorityHigh();
    }];
}

- (void)setHorizontalMigration:(CGFloat)horizontalMigration
{
    _horizontalMigration = horizontalMigration;
}

- (void)setButtonImageScale:(CGFloat)buttonImageScale
{
    if (buttonImageScale > 1) {
        buttonImageScale = 1;
    }
    
    if (buttonImageScale < 0) {
        buttonImageScale = 0;
    }
    
    _buttonImageScale = buttonImageScale;
}

- (void)setGraphicDistance:(NSInteger)graphicDistance
{
    _graphicDistance = graphicDistance;
}

/*
 cornerMark
 */

- (void)setCornerBackColor:(UIColor *)cornerBackColor
{
    _cornerBackColor = cornerBackColor;
    self.cornerMarkLabel.backgroundColor = cornerBackColor;
}

- (void)setCornerTextColor:(UIColor *)cornerTextColor
{
    _cornerTextColor = cornerTextColor;
    self.cornerMarkLabel.textColor = cornerTextColor;
}

- (void)setCornerTitle:(NSString *)cornerTitle
{
    _cornerTitle = cornerTitle;
    self.cornerMarkLabel.hidden = (cornerTitle.length == 0);
    self.cornerMarkLabel.text = cornerTitle;
    self.cornerMarkLabel.layer.cornerRadius = (self.getButtonImageViewSideLength / 2) / 2;
    
    [self.cornerMarkLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.getButtonImageViewSideLength / 2);
        make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:self.cornerMarkLabel]);
    }];
}

- (void)setCornerTextFont:(UIFont *)cornerTextFont
{
    _cornerTextFont = cornerTextFont;
    self.cornerMarkLabel.font = cornerTextFont;
}

/*
 other
 */

// 是否翻转图片
- (void)setTransformImageView:(BOOL)transformImageView
{
    _transformImageView = transformImageView;
    if (transformImageView) {
        self.buttonImageView.transform = CGAffineTransformMakeRotation(M_PI);        
    }
}

- (void)setButtonTitleNumberOfLines:(NSInteger)buttonTitleNumberOfLines
{
    _buttonTitleNumberOfLines = buttonTitleNumberOfLines;
    self.buttonTitleLabel.numberOfLines = buttonTitleNumberOfLines;
}

static CFAbsoluteTime startTime;
- (void)startSpin {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @(0.0f);
    animation.toValue   = @(M_PI * 2.0);
    animation.duration  = 0.8;
    animation.autoreverses = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = MAXFLOAT;
    [self.buttonImageView.layer addAnimation:animation forKey:@"spin"];
    startTime = CFAbsoluteTimeGetCurrent();
}

- (void)stopSpin {
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    /*
        问题：如果网络请求非常快，会造成刚开始转圈就停止了，体验不好。
        解决：记录开始转圈和结束时的时间，计算时间差如果小于1秒，则延迟移除动画。
     */
    CFTimeInterval inteval = currentTime * 1000.0 - startTime * 1000.0;
    if (inteval < 1000.0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.buttonImageView.layer removeAnimationForKey:@"spin"];
        });
    } else {
        [self.buttonImageView.layer removeAnimationForKey:@"spin"];
    }
}

#pragma mark - LazyLoad
- (UIView *)bottomHoldView
{
    if (!_bottomHoldView) {
        _bottomHoldView = [[UIView alloc] init];
        _bottomHoldView.backgroundColor = [UIColor clearColor];
        _bottomHoldView.userInteractionEnabled = NO;
    }
    return _bottomHoldView;
}

- (UIImageView *)buttonImageView
{
    if (!_buttonImageView) {
        _buttonImageView = [[UIImageView alloc] init];
    }
    return _buttonImageView;
}

- (UILabel *)cornerMarkLabel
{
    if (!_cornerMarkLabel) {
        _cornerMarkLabel = [[UILabel alloc] init];
        _cornerMarkLabel.textAlignment = NSTextAlignmentCenter;
        _cornerMarkLabel.backgroundColor = kRedColor;
        _cornerMarkLabel.font = kFont6;
        _cornerMarkLabel.textColor = kWhiteColor;
        _cornerMarkLabel.clipsToBounds = YES;
    }
    return _cornerMarkLabel;
}

- (UILabel *)buttonTitleLabel
{
    if (!_buttonTitleLabel) {
        _buttonTitleLabel = [[UILabel alloc] init];
        _buttonTitleLabel.numberOfLines = 1;
        _buttonTitleLabel.font = kFont12;
        _buttonTitleLabel.textColor = kBlackColor;
        _buttonTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _buttonTitleLabel;
}

- (UILabel *)buttonSubTitleLabel
{
    if (!_buttonSubTitleLabel) {
        _buttonSubTitleLabel = [[UILabel alloc] init];
        _buttonSubTitleLabel.numberOfLines = 1;
        _buttonSubTitleLabel.font = kFont10;
        _buttonSubTitleLabel.textColor = kGrayTextColor;
        _buttonSubTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _buttonSubTitleLabel;
}

- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.frame = self.frame;
        _maskView.backgroundColor = kGrayViewColor;
    }
    return _maskView;
}

@end

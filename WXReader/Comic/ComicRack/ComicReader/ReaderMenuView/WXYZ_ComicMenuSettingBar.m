//
//  WXYZ_ComicMenuSettingBar.m
//  WXReader
//
//  Created by Andrew on 2019/6/5.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicMenuSettingBar.h"
#import "KLSwitch.h"
#import "WXYZ_NightModeView.h"
#import <AudioToolbox/AudioToolbox.h>

#define Menu_Setting_Cell_Height 70
#define Menu_Setting_Bar_Height (3 * Menu_Setting_Cell_Height + PUB_NAVBAR_OFFSET)

@implementation WXYZ_ComicMenuSettingBar
{
    UIView *bottomView;
    
    KLSwitch *clickPageSwitch;
    KLSwitch *nightSwitch;
    
}

- (instancetype)initWithMode:(int)mode
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.backgroundColor = kBlackTransparentColor;
        self.hidden = YES;
        [kMainWindow addSubview:self];
        
        NSUserDefaults *defualt = [NSUserDefaults standardUserDefaults];
        
        // 默认开启
        if (![defualt objectForKey:Enable_Click_Page]) {
            [defualt setObject:@"1" forKey:Enable_Click_Page];
            [defualt synchronize];
        }
        
        // 默认关闭
        if (![defualt objectForKey:Enable_Click_Night]) {
            [defualt setObject:@"0" forKey:Enable_Click_Night];
            [defualt synchronize];
        }
        
        // 默认开启
        if (![defualt objectForKey:Enable_Barrage]) {
            [defualt setObject:@"1" forKey:Enable_Barrage];
            [defualt synchronize];
        }
        
        [self createSubViews:mode];
    }
    return self;
}

- (void)createSubViews:(int)mode
{
    bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:bottomView];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(self.mas_bottom);
        make.width.mas_equalTo(self.mas_width);
        make.height.mas_equalTo(Menu_Setting_Bar_Height);
    }];
    
    NSInteger cellIndex = 0;
    
    {
        UIView *cell = [[UIView alloc] init];
        cell.backgroundColor = [UIColor whiteColor];
        [bottomView addSubview:cell];
        
        [cell mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(cellIndex * Menu_Setting_Cell_Height);
            make.width.mas_equalTo(bottomView.mas_width);
            make.height.mas_equalTo(Menu_Setting_Cell_Height);
        }];
        
        clickPageSwitch = [[KLSwitch alloc] initWithFrame:CGRectMake(1, 1, 51, 31) didChangeHandler:^(BOOL isOn) {
            AudioServicesPlaySystemSound(1519);
            if (isOn) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:Enable_Click_Page];
                [[NSNotificationCenter defaultCenter] postNotificationName:Enable_Click_Page object:@"1"];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:Enable_Click_Page];
                [[NSNotificationCenter defaultCenter] postNotificationName:Enable_Click_Page object:@"0"];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
        clickPageSwitch.onTintColor = kMainColor;
        clickPageSwitch.transform = CGAffineTransformMakeScale(0.7, 0.7);//缩放
        [cell addSubview:clickPageSwitch];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:Enable_Click_Page] isEqualToString:@"1"]) {
            [clickPageSwitch setDefaultOnState:YES];
        } else {
            [clickPageSwitch setDefaultOnState:NO];
        }
        
        [clickPageSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(cell.mas_centerY);
            make.right.mas_equalTo(cell.mas_right).with.offset(- kHalfMargin);
            make.width.mas_equalTo(51);
            make.height.mas_equalTo(31);
        }];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"点击翻页";
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = kBlackColor;
        titleLabel.font = kMainFont;
        [cell addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(cell.mas_centerY);
            make.left.mas_equalTo(kHalfMargin);
            make.width.mas_equalTo(SCREEN_WIDTH / 2);
            make.height.mas_equalTo(20);
        }];
        
        UILabel *subTitleLabel = [[UILabel alloc] init];
        subTitleLabel.text = @"打开后可点击屏幕上下方翻页";
        subTitleLabel.textAlignment = NSTextAlignmentLeft;
        subTitleLabel.textColor = kGrayTextColor;
        subTitleLabel.font = kFont12;
        [cell addSubview:subTitleLabel];
        
        [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(titleLabel.mas_left);
            make.top.mas_equalTo(titleLabel.mas_bottom);
            make.width.mas_equalTo(subTitleLabel.mas_width);
            make.height.mas_equalTo(20);
        }];
        
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = kGrayLineColor;
        [cell addSubview:line];
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kMargin);
            make.height.mas_equalTo(kCellLineHeight);
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.bottom.mas_equalTo(cell.mas_bottom);
        }];
        
        cellIndex ++;
    }
    
    {
        UIView *cell = [[UIView alloc] init];
        cell.backgroundColor = [UIColor whiteColor];
        [bottomView addSubview:cell];
        
        [cell mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(cellIndex * Menu_Setting_Cell_Height);
            make.width.mas_equalTo(bottomView.mas_width);
            make.height.mas_equalTo(Menu_Setting_Cell_Height);
        }];
        
        nightSwitch = [[KLSwitch alloc] initWithFrame:CGRectMake(1, 1, 51, 31) didChangeHandler:^(BOOL isOn) {
            AudioServicesPlaySystemSound(1519);
            if (isOn) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:Enable_Click_Night];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:Enable_Click_Night object:@"1"];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:Enable_Click_Night];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:Enable_Click_Night object:@"0"];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
        nightSwitch.onTintColor = kMainColor;
        nightSwitch.transform = CGAffineTransformMakeScale(0.7, 0.7);//缩放
        [cell addSubview:nightSwitch];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:Enable_Click_Night] isEqualToString:@"1"]) {
            [nightSwitch setDefaultOnState:YES];
        } else {
            [nightSwitch setDefaultOnState:NO];
        }
        
        [nightSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(cell.mas_centerY);
            make.right.mas_equalTo(cell.mas_right).with.offset(- kHalfMargin);
            make.width.mas_equalTo(51);
            make.height.mas_equalTo(31);
        }];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"夜间模式";
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = kBlackColor;
        titleLabel.font = kMainFont;
        [cell addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(cell.mas_centerY);
            make.left.mas_equalTo(kHalfMargin);
            make.width.mas_equalTo(SCREEN_WIDTH / 2);
            make.height.mas_equalTo(30);
        }];
        
        cellIndex ++;
    }
    {
        UIView *cell = [[UIView alloc] init];
        cell.backgroundColor = [UIColor whiteColor];
        [bottomView addSubview:cell];
        
        [cell mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(cellIndex * Menu_Setting_Cell_Height);
            make.width.mas_equalTo(bottomView.mas_width);
            make.height.mas_equalTo(Menu_Setting_Cell_Height);
        }];
        self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.leftButton.layer.masksToBounds = true;
        self.leftButton.layer.cornerRadius = 8;
        [self.leftButton setTitle:@"垂直模式" forState:UIControlStateNormal];
        self.leftButton.titleLabel.font = [UIFont systemFontOfSize:15];
        self.leftButton.layer.borderColor = kMainColor.CGColor;
        self.leftButton.layer.borderWidth = 1;
        [cell addSubview:self.leftButton];
        
        self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.rightButton.layer.masksToBounds = true;
        self.rightButton.layer.cornerRadius = 8;
        [self.rightButton setTitle:@"水平模式" forState:UIControlStateNormal];
        self.rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
        self.rightButton.layer.borderColor = kMainColor.CGColor;
        self.rightButton.layer.borderWidth = 1;
        [cell addSubview:self.rightButton];
        
        [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(35);
            make.centerY.mas_equalTo(cell.mas_centerY);
            make.right.mas_equalTo(cell.mas_right).multipliedBy(0.5).offset(-25);
        }];
        
        [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(35);
            make.centerY.mas_equalTo(cell.mas_centerY);
            make.left.mas_equalTo(cell.mas_right).multipliedBy(0.5).offset(25);
        }];
        
        [self.leftButton addTarget:self action:@selector(leftPress) forControlEvents:UIControlEventTouchUpInside];
        [self.rightButton addTarget:self action:@selector(rightPress) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        [self changeMode:mode];
        
        cellIndex ++;
    }
    
}

- (void)leftPress {
    [self changeMode:1];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(changeMode:)]) {
        [self.delegate changeMode:1];
    }
}

- (void)rightPress {
    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"暂不支持"];
    return;
    [self changeMode:2];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(changeMode:)]) {
        [self.delegate changeMode:2];
    }
}

- (void)changeMode:(int)mode {
    if (mode == 1) {
        self.leftButton.backgroundColor = kMainColor;
        [self.leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.rightButton.backgroundColor = [UIColor clearColor];
        [self.rightButton setTitleColor:kMainColor forState:UIControlStateNormal];
        
    } else {
        self.rightButton.backgroundColor = kMainColor;
        [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.leftButton.backgroundColor = [UIColor clearColor];
        [self.leftButton setTitleColor:kMainColor forState:UIControlStateNormal];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UIView *touchView = [[touches anyObject] view];
    if (![touchView isEqual:bottomView]) {
        [self hiddenSettingBar];
    }
}

- (void)showSettingBar
{
    self.hidden = NO;
    
    [UIView animateWithDuration:kAnimatedDuration animations:^{
        [self->bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_bottom).with.offset(- Menu_Setting_Bar_Height);
        }];
    }];
    
     [UIView animateWithDuration:kAnimatedDuration animations:^{
         [self->bottomView.superview layoutIfNeeded];
     }];
}

- (void)hiddenSettingBar
{
    [bottomView.superview setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:kAnimatedDuration animations:^{
        [self->bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_bottom);
        }];
    }];
    
    [UIView animateWithDuration:kAnimatedDuration animations:^{
        [self->bottomView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if ([clickPageSwitch pointInside:[clickPageSwitch convertPoint:point fromView:self] withEvent:event]) {
        return clickPageSwitch;
    }
    
    if ([nightSwitch pointInside:[nightSwitch convertPoint:point fromView:self] withEvent:event]) {
        return nightSwitch;
    }
    
    if ([self.leftButton pointInside:[self.leftButton convertPoint:point fromView:self] withEvent:event]) {
         return self.leftButton;
     }
     if ([self.rightButton pointInside:[self.rightButton convertPoint:point fromView:self] withEvent:event]) {
         return self.rightButton;
     }
    
    if ([bottomView pointInside:[bottomView convertPoint:point fromView:self] withEvent:event]) {
        return bottomView;
    }
        
    return view;
}

@end

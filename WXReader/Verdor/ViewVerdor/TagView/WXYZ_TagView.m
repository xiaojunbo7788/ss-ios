//
//  DPMoreView.m
//  WXReader
//
//  Created by Andrew on 2018/5/26.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_TagView.h"

@implementation WXYZ_TagView

- (instancetype)init
{
    if (self = [super init]) {
        _tagViewCornerRadius = 0;
        _tagSpacing = 5;
        _tagMergeAllowance = 5;
        _tagViewFont = kFont9;
        _tagBorderStyle = WXYZ_TagBorderStyleFill;
        _tagAlignment = WXYZ_TagAlignmentLeft;
    }
    return self;
}

- (void)setTagArray:(NSArray *)tagArray
{
    if (!tagArray) {
        return;
    }
    
    if ([tagArray isEqual:_tagArray]) {
        return;
    }
    
    NSMutableArray *t_arr = [tagArray mutableCopy];
    for (WXYZ_TagModel *t_model in tagArray) {
        if (!t_model.tab || t_model.tab.length == 0) {
            [t_arr removeObject:t_model];
        }
    }
    tagArray = [t_arr copy];

    _tagArray = tagArray;
    
    [self removeAllSubviews];
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor clearColor];
    [self addSubview:bottomView];
    
    switch (_tagAlignment) {
        case WXYZ_TagAlignmentLeft:
        {
            [bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.mas_left);
                make.width.mas_equalTo(100);
                make.height.mas_equalTo(self.mas_height);
                make.top.mas_equalTo(self.mas_top);
            }];
        }
            break;
        case WXYZ_TagAlignmentRight:
        {
            
            _tagArray = [[[_tagArray reverseObjectEnumerator] allObjects] mutableCopy];
            [bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.mas_right);
                make.width.mas_equalTo(100);
                make.height.mas_equalTo(self.mas_height);
                make.top.mas_equalTo(self.mas_top);
            }];
        }
            break;
        case WXYZ_TagAlignmentCenter:
        {
            [bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.mas_centerX);
                make.width.mas_equalTo(100);
                make.height.mas_equalTo(self.mas_height);
                make.top.mas_equalTo(self.mas_top);
            }];
        }
            break;
    }
    
    CGFloat button_H = self.height;//按钮高
    CGFloat button_W = 0;
    CGFloat button_X = - _tagSpacing;
    CGFloat space_X = _tagSpacing;//按钮间距
    CGFloat levelViewWidth = 0;
    for (int i = 0; i < _tagArray.count; i++) {
        WXYZ_TagModel *tagModel = [_tagArray objectOrNilAtIndex:i];
        button_X = button_X + button_W + space_X;
        button_W = [WXYZ_ViewHelper getDynamicWidthWithLabelFont:_tagViewFont labelHeight:button_H labelText:tagModel.tab?:@""] + _tagMergeAllowance;
        
        if (levelViewWidth > self.width) {
            return;
        }
        levelViewWidth = levelViewWidth + button_W + space_X;
        
        UILabel *levelLabel = [[UILabel alloc] init];
        levelLabel.font = _tagViewFont;
        levelLabel.text = tagModel.tab?:@"";
        levelLabel.textColor = [UIColor colorWithHexString:tagModel.color?:@"#0A0A0A"];
        levelLabel.textAlignment = NSTextAlignmentCenter;
        levelLabel.layer.cornerRadius = _tagViewCornerRadius == 0?(button_H / 2):_tagViewCornerRadius;
        levelLabel.clipsToBounds = YES;
        [bottomView addSubview:levelLabel];
        
        if (tagModel.color.length == 0) {
            levelLabel.backgroundColor = [UIColor colorWithHexString:@"#F9F9F9"];
        } else {
            switch (_tagBorderStyle) {
                case WXYZ_TagBorderStyleBorder:
                    levelLabel.backgroundColor = [UIColor clearColor];
                    levelLabel.layer.borderColor = [UIColor colorWithHexString:tagModel.color?:@""].CGColor;
                    [levelLabel addBorderLineWithBorderWidth:0.5 borderColor:[UIColor colorWithHexString:tagModel.color?:@""] cornerRadius:2];
                    break;
                case WXYZ_TagBorderStyleFill:
                    levelLabel.backgroundColor = [[UIColor colorWithHexString:tagModel.color?:@""] colorWithAlphaComponent:0.2];
                    break;
                case WXYZ_TagBorderStyleNone:
                    levelLabel.backgroundColor = [UIColor clearColor];
                    break;
                    
                default:
                    break;
            }            
        }
        
        
        [levelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if (_tagAlignment == WXYZ_TagAlignmentRight) {
                make.right.mas_equalTo(self.mas_right).with.offset(- button_X);
            } else {
                make.left.mas_equalTo(button_X);
            }
            make.width.mas_equalTo(button_W);
            make.height.mas_equalTo(self.mas_height);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
    }
    
    [bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(levelViewWidth - _tagSpacing);
    }];
    
    if (self.tagViewWidthUpdate) {
        self.tagViewWidthUpdate(levelViewWidth - _tagSpacing);
    }
}

@end

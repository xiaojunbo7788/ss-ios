//
//  WXYZ_GuideView.m
//  WXReader
//
//  Created by Andrew on 2020/5/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_GuideView.h"

@implementation WXYZ_GuideView
{
    WXYZ_GuideType _guideType;
}

- (instancetype)initWithGuideType:(WXYZ_GuideType)guideType
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _guideType = guideType;
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidden)]];
    
    UILabel *leftView = [[UILabel alloc] init];
    leftView.backgroundColor = kColorRGBA(0, 0, 0, 0.4);
    leftView.numberOfLines = 0;
    leftView.text = @"上\n一\n页";
    leftView.textColor = kWhiteColor;
    leftView.textAlignment = NSTextAlignmentCenter;
    leftView.font = [UIFont boldSystemFontOfSize:50];
    [self addSubview:leftView];
    
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH / 3);
        make.height.mas_equalTo(self.mas_height);
    }];
    
    NSMutableAttributedString * attriStr = [[NSMutableAttributedString alloc] initWithString:@"菜单\n"];
    NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
    attchImage.image = [UIImage imageNamed:@"book_guide_tap"];
    attchImage.bounds = CGRectMake(0, 0, 50, 50);
    NSAttributedString *stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
    [attriStr appendAttributedString:stringImage];
    
    UILabel *centerView = [[UILabel alloc] init];
    centerView.backgroundColor = kColorRGBA(0, 0, 0, 0.7);
    centerView.numberOfLines = 2;
    centerView.textColor = kWhiteColor;
    centerView.textAlignment = NSTextAlignmentCenter;
    centerView.font = [UIFont boldSystemFontOfSize:50];
    centerView.attributedText = attriStr;
    [self addSubview:centerView];
    
    [centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftView.mas_right);
        make.top.mas_equalTo(leftView.mas_top);
        make.width.mas_equalTo(leftView.mas_width);
        make.height.mas_equalTo(leftView.mas_height);
    }];
    
    UILabel *rightView = [[UILabel alloc] init];
    rightView.backgroundColor = kColorRGBA(0, 0, 0, 0.4);
    rightView.numberOfLines = 0;
    rightView.text = @"下\n一\n页";
    rightView.textColor = kWhiteColor;
    rightView.textAlignment = NSTextAlignmentCenter;
    rightView.font = [UIFont boldSystemFontOfSize:50];
    [self addSubview:rightView];
    
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(centerView.mas_right);
        make.top.mas_equalTo(leftView.mas_top);
        make.width.mas_equalTo(leftView.mas_width);
        make.height.mas_equalTo(leftView.mas_height);
    }];
    
}

- (void)hidden
{
    [self removeAllSubviews];
    [self removeFromSuperview];
}

@end

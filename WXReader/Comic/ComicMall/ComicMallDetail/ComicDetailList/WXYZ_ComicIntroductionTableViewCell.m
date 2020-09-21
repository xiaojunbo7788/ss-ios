//
//  WXYZ_ComicIntroductionTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/5/30.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicIntroductionTableViewCell.h"

@implementation WXYZ_ComicIntroductionTableViewCell
{
    UILabel *introductionContent;
}

- (void)createSubviews
{
    [super createSubviews];
    
    introductionContent = [[UILabel alloc] init];
    introductionContent.textColor = kGrayTextColor;
    introductionContent.textAlignment = NSTextAlignmentLeft;
    introductionContent.font = kFont12;
    introductionContent.numberOfLines = 0;
    [self.contentView addSubview:introductionContent];
    [introductionContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kHalfMargin);
        make.top.mas_equalTo(self.contentView.mas_top).with.offset(0);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kHalfMargin);
    }];
    
    UIView *splitLine = [[UIView alloc] init];
    splitLine.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:splitLine];
    [splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.1);
        make.right.bottom.left.equalTo(self.contentView);
        make.top.equalTo(introductionContent.mas_bottom).offset(kHalfMargin).priorityLow();
    }];
}

- (void)setComicModel:(WXYZ_ProductionModel *)comicModel
{
    if (_comicModel != comicModel) {
        _comicModel = comicModel;
        
        if (comicModel.production_descirption.length > 0) {
            
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:comicModel.production_descirption?:@""];
            attributedString.lineSpacing = 6;
            attributedString.font = kFont12;
            attributedString.color = kGrayTextColor;
            
            YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(SCREEN_WIDTH - 2 * kMargin, MAXFLOAT) text:attributedString];
            
            if (layout.rowCount < 5) {
                introductionContent.attributedText = attributedString;
            } else {
                // 截取前5行的内容
                YYTextLine *lastLine = layout.lines[4];
                NSMutableAttributedString *t_atr = [[attributedString attributedSubstringFromRange:NSMakeRange(0, lastLine.range.location + lastLine.range.length)] mutableCopy];
                // 截取第5行一半的内容
                CGFloat maxWidth = (SCREEN_WIDTH - 2 * kMargin) / 2.0;
                if (lastLine.lineWidth > maxWidth) {
                    // 获取多出来的距离
                    CGFloat spacing = lastLine.lineWidth - maxWidth;
                    // 获取多余的文字个数(多余的间距 / 单个字的宽度)
                    NSInteger number = spacing / (lastLine.lineWidth / lastLine.range.length);
                    t_atr = [[t_atr attributedSubstringFromRange:NSMakeRange(0, t_atr.length - number - 1)] mutableCopy];
                    [t_atr appendString:@" ..."];
                }
                introductionContent.attributedText = t_atr;
            }
        }
    }
}

@end

//
//  WXYZ_BookMarkCellTableViewCell.m
//  WXReader
//
//  Created by LL on 2020/7/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BookMarkCell.h"

#import "NSObject+Observer.h"
#import "WXYZ_BookMarkModel.h"

@implementation WXYZ_BookMarkCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = kFont14;
    titleLabel.textColor = kBlackColor;
    [self.contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kMargin);
        make.left.equalTo(self.contentView).offset(kMoreHalfMargin);
    }];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.font = kFont11;
    timeLabel.textColor = kGrayTextColor;
    timeLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleLabel);
        make.right.equalTo(self.contentView).offset(-kMoreHalfMargin);
    }];
    [titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(timeLabel.mas_left).offset(-kMargin);
    }];
    
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.numberOfLines = 2;
    descLabel.font = kFont12;
    descLabel.textColor = kGrayTextColor;
    [self.contentView addSubview:descLabel];
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(13);
        make.left.equalTo(titleLabel);
        make.right.equalTo(self.contentView).offset(-25.0);
    }];
    
    UIView *splitLine = [[UIView alloc] init];
    splitLine.backgroundColor = kGrayLineColor;
    [self.contentView addSubview:splitLine];
    [splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kCellLineHeight);
        make.left.right.bottom.equalTo(self.contentView);
        make.top.equalTo(descLabel.mas_bottom).offset(kMoreHalfMargin).priorityLow();
    }];
    
    [self addObserver:KEY_PATH(self, bookMarkModel) complete:^(WXYZ_BookMarkCell * _Nonnull obj, WXYZ_BookMarkModel * _Nullable oldVal, WXYZ_BookMarkModel * _Nullable newVal) {
        titleLabel.text = newVal.chapterTitle ?: @"";
        timeLabel.text = [WXYZ_UtilsHelper dateStringWithTimestamp:newVal.timestamp] ?: @"";
        if ([[newVal.pageContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"\U0000fffc"]) {
            descLabel.text = @"广告页";
        } else {
            descLabel.text = newVal.pageContent ?: @"";
        }
    }];
}
@end

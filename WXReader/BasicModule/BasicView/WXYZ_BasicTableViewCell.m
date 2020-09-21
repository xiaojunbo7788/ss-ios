//
//  WXYZ_BasicTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/12/23.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_BasicTableViewCell.h"

@implementation WXYZ_BasicTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    UIView *cellLine = [[UIView alloc] init];
    self.cellLine = cellLine;
    self.cellLine.backgroundColor = kGrayLineColor;
    self.cellLine.hidden = YES;
    [self.contentView addSubview:self.cellLine];
    
    [self.cellLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.width.mas_equalTo(SCREEN_WIDTH - kMargin);
        make.height.mas_equalTo(kCellLineHeight);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset( - kCellLineHeight);
    }];
}

- (void)setCellIndexPath:(NSIndexPath *)cellIndexPath
{
    _cellIndexPath = cellIndexPath;
}

- (void)setHiddenEndLine:(BOOL)hiddenEndLine
{
    _hiddenEndLine = hiddenEndLine;
    self.cellLine.hidden = hiddenEndLine;
}

- (void)setProductionType:(WXYZ_ProductionType)productionType
{
    _productionType = productionType;
}

@end

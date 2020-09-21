//
//  WXYZ_MemberPrivilegeCellCollectionViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/4/21.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_MemberPrivilegeCellCollectionViewCell.h"

@implementation WXYZ_MemberPrivilegeCellCollectionViewCell
{
    UIImageView *privilegeIcon;
    UILabel *privilegeLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    privilegeIcon = [[UIImageView alloc] init];
    [self addSubview:privilegeIcon];
    
    [privilegeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.mas_top);
        make.width.height.mas_equalTo(self.mas_width).multipliedBy(0.5);
    }];
    
    privilegeLabel = [[UILabel alloc] init];
    privilegeLabel.textAlignment = NSTextAlignmentCenter;
    privilegeLabel.textColor = kBlackColor;
    privilegeLabel.font = kMainFont;
    [self addSubview:privilegeLabel];
    
    [privilegeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).with.offset(kQuarterMargin);
        make.top.mas_equalTo(privilegeIcon.mas_bottom).with.offset(kHalfMargin + kQuarterMargin);
        make.right.mas_equalTo(self.mas_right).with.offset(- kQuarterMargin);
        make.height.mas_equalTo(20);
    }];
}

- (void)setPrivilegeModel:(WXYZ_PrivilegeModel *)privilegeModel
{
    _privilegeModel = privilegeModel;
    
    [privilegeIcon setImageWithURL:[NSURL URLWithString:privilegeModel.icon] placeholder:HoldImage options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
    
    privilegeLabel.text = privilegeModel.label?:@"";
}

@end

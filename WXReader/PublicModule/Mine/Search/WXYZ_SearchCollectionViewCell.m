//
//  WXYZ_SearchCollectionViewCell.m
//  WXReader
//
//  Created by geng on 2020/9/13.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_SearchCollectionViewCell.h"

@interface WXYZ_SearchCollectionViewCell ()

@property (nonatomic, strong) UILabel *titBtn;

@end

@implementation WXYZ_SearchCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *titBtn = [[UILabel alloc] init];
        //设置按的
        titBtn.backgroundColor = [UIColor colorWithHexString:@"#F9F9F9"];
        titBtn.textColor = [UIColor colorWithHexString:@"#0A0A0A"];
        titBtn.font = kFont13;
        titBtn.textAlignment = NSTextAlignmentCenter;
        titBtn.layer.cornerRadius = 30 / 2;
        titBtn.clipsToBounds = YES;
        self.titBtn = titBtn;
        [self addSubview:self.titBtn];
        
        [self.titBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.left.mas_equalTo(self);
        }];
    }
    return self;
}

- (void)showInfo:(NSDictionary *)dic {
    self.titBtn.text = dic[@"title"];
    if ([dic[@"id"] intValue] == -1) {
        self.titBtn.textColor = kMainColor;
    } else {
        self.titBtn.textColor = [UIColor colorWithHexString:@"#0A0A0A"];
    }
}


@end

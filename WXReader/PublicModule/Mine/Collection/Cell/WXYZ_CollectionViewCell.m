//
//  WXYZ_CollectionViewCell.m
//  WXReader
//
//  Created by geng on 2020/9/9.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_CollectionViewCell.h"

@interface WXYZ_CollectionViewCell ()

@property (nonatomic, strong) UIImageView *mImageView;
@property (nonatomic, strong) UILabel *mTitleLabel;
@property (nonatomic, strong) UILabel *mCountLabel;


@end

@implementation WXYZ_CollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.mImageView = [[UIImageView alloc] init];
        self.mImageView.clipsToBounds = true;
        self.mImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.mImageView];
        
        self.mTitleLabel = [[UILabel alloc] init];
        self.mTitleLabel.textColor = [UIColor blackColor];
        self.mTitleLabel.font  =[UIFont systemFontOfSize:15];
        [self addSubview:self.mTitleLabel];
        
        self.mCountLabel = [[UILabel alloc] init];
        self.mCountLabel.textColor = [UIColor lightGrayColor];
        self.mCountLabel.font  =[UIFont systemFontOfSize:13];
        [self addSubview:self.mCountLabel];
        
        [self.mImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.left.mas_equalTo(self);
            make.height.mas_equalTo(150);
        }];
        
        [self.mTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self);
            make.top.mas_equalTo(self.mImageView.mas_bottom).offset(4);
            make.right.mas_equalTo(self);
            make.height.mas_greaterThanOrEqualTo(14);
        }];
        [self.mCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self);
            make.top.mas_equalTo(self.mTitleLabel.mas_bottom).offset(3);
            make.right.mas_equalTo(self);
            make.height.mas_greaterThanOrEqualTo(14);
        }];
        
    }
    return self;
}

- (void)showInfo:(WXYZ_CollectModel *)model {
    switch (model.type) {
           case 1:
            self.mTitleLabel.text = model.author;
               break;
          case  2:
                self.mTitleLabel.text = model.original;
               break;
           case 3:
                self.mTitleLabel.text = model.sinici;
               break;
           default:
               break;
       }
    if (model.count != nil) {
         self.mCountLabel.text = [NSString stringWithFormat:@"合计%@篇",model.count];
    } else {
        self.mCountLabel.text = [NSString stringWithFormat:@"合计%@篇",@"0"];
    }
    [self.mImageView setImageWithURL:[NSURL URLWithString:model.icon?:@""] placeholder:HoldImage options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
   
}

@end

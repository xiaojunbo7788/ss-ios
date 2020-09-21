//
//  WXYZ_DetailHeadContentView.m
//  WXReader
//
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_DetailHeadContentView.h"
#import "HCSStarRatingView.h"
#import "WXYZ_ProductionCollectionManager.h"
@interface WXYZ_DetailHeadContentView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) HCSStarRatingView *ratingView;
@property (nonatomic, strong) UILabel *hotLabel;
@property (nonatomic, strong) UILabel *collectNumLabel;

@end

@implementation WXYZ_DetailHeadContentView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = kWhiteColor;
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = kBoldFont22;
        [self addSubview:self.titleLabel];
        
        self.ratingView = [[HCSStarRatingView alloc] initWithFrame:CGRectMake(50, 200, 200, 50)];
        self.ratingView.backgroundColor = [UIColor clearColor];
        
        self.ratingView.hidden = true;
        self.ratingView.maximumValue = 5;
        self.ratingView.minimumValue = 0;
        self.ratingView.value = 2;
        self.ratingView.emptyStarImage = [UIImage imageNamed:@"us_start"];
        self.ratingView.halfStarImage = [UIImage imageNamed:@"s_start"];
        self.ratingView.filledStarImage = [UIImage imageNamed:@"s_start"];
        [self addSubview:self.ratingView];
        
        self.hotLabel = [[UILabel alloc] init];
        self.hotLabel.backgroundColor = [UIColor clearColor];
        self.hotLabel.textColor = kWhiteColor;
        self.hotLabel.textAlignment = NSTextAlignmentLeft;
        self.hotLabel.font = kMainFont;
          
        [self addSubview:self.hotLabel];
        
        self.collectNumLabel = [[UILabel alloc] init];
        self.collectNumLabel.backgroundColor = [UIColor clearColor];
        self.collectNumLabel.textColor = kWhiteColor;
        self.collectNumLabel.textAlignment = NSTextAlignmentLeft;
        self.collectNumLabel.font = kMainFont;
        [self addSubview:self.collectNumLabel];
         
    
        self.collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.collectButton.backgroundColor = kMainColor;
        self.collectButton.layer.cornerRadius = 12;
        self.collectButton.hidden = YES;
        [self.collectButton setTitle:@"＋收藏" forState:UIControlStateNormal];
        [self.collectButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
        [self.collectButton.titleLabel setFont:kFont12];
        [self.collectButton addTarget:self action:@selector(collectionClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.collectButton];
           

        [self makeConstrants];
    }
    return self;
}

- (void)showInfo:(WXYZ_ProductionModel *)detailModel withType:(int)type {
    if (type == 1) {
        self.ratingView.hidden = true;
        self.titleLabel.attributedText = [self formatAttributedText:detailModel.name];
        self.hotLabel.attributedText = [self formatAttributedText:detailModel.hot_num];
        self.collectNumLabel.attributedText = [self formatAttributedText:detailModel.total_favors];
        self.collectButton.hidden = false;
        if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] isCollectedWithProductionModel:detailModel]) {
            self.collectButton.tag = 1;
            self.collectButton.backgroundColor = [kMainColor colorWithAlphaComponent:0.75];
            [self.collectButton setTitle:@"已收藏" forState:UIControlStateNormal];
        } else {
            self.collectButton.tag = 0;
            self.collectButton.backgroundColor = kMainColor;
            [self.collectButton setTitle:@"＋收藏" forState:UIControlStateNormal];
        }
    } else {
        
    }
}

- (void)collectionClick:(UIButton *)sender {
    [self.delegate onClickCollectionBtn];
}

- (void)makeConstrants {
   
    [self.collectNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-kHalfMargin+3);
        make.height.mas_greaterThanOrEqualTo(13);
        make.right.mas_equalTo(self.collectButton.mas_left).offset(-kQuarterMargin);
    }];
    

    [self.collectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(self.collectNumLabel.mas_centerY);
        make.height.mas_equalTo(24);
        make.width.mas_equalTo(60);
    }];
    
    [self.hotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.bottom.mas_equalTo(self.collectNumLabel.mas_top).offset(- kQuarterMargin);
        make.height.mas_greaterThanOrEqualTo(13);
        make.right.mas_equalTo(self.mas_right).offset(- kHalfMargin);
    }];
    
    
    [self.ratingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.bottom.mas_equalTo(self.hotLabel.mas_top).offset(-5);
        make.height.mas_equalTo(27);
        make.width.mas_equalTo(120);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.bottom.mas_equalTo(self.ratingView.mas_top).offset(-5);
        make.height.mas_greaterThanOrEqualTo(13);
        make.right.mas_equalTo(self.mas_right).offset(-10);
    }];
    
    
    
}


#pragma mark - Private
- (NSAttributedString *)formatAttributedText:(NSString *)normalText {
    NSMutableAttributedString *authorAttString = [[NSMutableAttributedString alloc] initWithString:normalText?:@""];
    return authorAttString;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  WXYZ_SearchView.m
//  WXReader
//
//  Created by Andrew on 2019/5/28.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_SearchView.h"
#import "WXYZ_GCDTimer.h"

@interface WXYZ_SearchView ()
{
    UIImageView *searchIcon;
}

@property (nonatomic, strong) WXYZ_GCDTimer *timer;

@property (nonatomic, weak) UILabel *searchTitle;

@end

@implementation WXYZ_SearchView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = kColorRGBA(255, 255, 255, 0.3);
        self.layer.borderColor = kColorRGBA(235, 235, 241, 1).CGColor;
        self.layer.borderWidth = 0;
        
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    searchIcon = [[UIImageView alloc] init];
    searchIcon.image = [[UIImage imageNamed:@"public_search"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    searchIcon.userInteractionEnabled = YES;
    searchIcon.tintColor = kWhiteColor;
    [self addSubview:searchIcon];
    
    [searchIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).with.offset(- kHalfMargin);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(self.mas_height).with.multipliedBy(0.7);
    }];
    
    UILabel *searchTitle = [[UILabel alloc] init];
    self.searchTitle = searchTitle;
    searchTitle.backgroundColor = [UIColor clearColor];
    searchTitle.textColor = [UIColor whiteColor];
    searchTitle.font = kFont12;
    searchTitle.textAlignment = NSTextAlignmentLeft;
    [self addSubview:searchTitle];
    
    [searchTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).with.offset(kHalfMargin);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.right.mas_equalTo(searchIcon.mas_left).with.offset(- kHalfMargin);
        make.height.mas_equalTo(self.mas_height);
    }];
    
}

- (void)setSearchViewDarkColor:(BOOL)searchViewDarkColor
{
    _searchViewDarkColor = searchViewDarkColor;
    if (searchViewDarkColor) {
        searchIcon.tintColor = kGrayTextLightColor;
        self.backgroundColor = kColorRGBA(255, 255, 255, 0.0);
        self.searchTitle.textColor = kGrayTextLightColor;
        self.layer.borderColor = kColorRGBA(235, 235, 241, 1).CGColor;
        self.layer.borderWidth = 0.6;
        
    } else {
        searchIcon.tintColor = kWhiteColor;
        self.backgroundColor = kColorRGBA(255, 255, 255, 0.3);
        self.searchTitle.textColor = [UIColor whiteColor];
        self.layer.borderColor = kColorRGBA(235, 235, 241, 1).CGColor;
        self.layer.borderWidth = 0;
    }
}

- (void)setPlaceholderArray:(NSArray *)placeholderArray
{
    _placeholderArray = placeholderArray;
    if (placeholderArray.count > 0) {
        
        self.searchTitle.text = [placeholderArray objectOrNilAtIndex:0];
        if (placeholderArray.count > 1) {
            int __block index = 0;
            
            WS(weakSelf)
            [self.timer stopTimer];
            [self.timer startTimer];
            
            self.timer.timerRunningBlock = ^(NSUInteger runTimes, CGFloat currentTime) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.searchTitle.text = [placeholderArray objectOrNilAtIndex:index];
                    
                    if (++ index == placeholderArray.count) {
                        index = 0;
                    }
                });
            };
        }
    }
}

- (NSString *)currentPlaceholder {
    return self.searchTitle.text;
}

- (WXYZ_GCDTimer *)timer
{
    if (!_timer) {
        _timer = [[WXYZ_GCDTimer alloc] initCycleTimerWithInterval:10 immediatelyCallBack:YES];
    }
    return _timer;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.layer.cornerRadius = self.height / 2;
    self.clipsToBounds = YES;
}

@end

//
//  WXYZ_ClassifyHeaderView.m
//  WXReader
//
//  Created by Andrew on 2019/6/17.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ClassifyHeaderView.h"
#import "WXYZ_SearchBoxView.h"

@implementation WXYZ_ClassifyHeaderView
{
    WXYZ_SearchBoxView *searchBoxView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    
    WS(weakSelf)
    
    searchBoxView = [[WXYZ_SearchBoxView alloc] init];
    searchBoxView.searchBoxSelectBlock = ^(NSString * _Nonnull field, NSString * _Nonnull value) {
        if (weakSelf.searchBoxSelectBlock) {
            weakSelf.searchBoxSelectBlock(field, value);
        }
    };
    [self addSubview:searchBoxView];
    
    [searchBoxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

- (void)setSearch_box:(NSArray<WXYZ_SearchBoxModel *> *)search_box
{
    _search_box = search_box;
    
    searchBoxView.search_box = search_box;
    
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40 * search_box.count);
}

@end

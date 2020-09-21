//
//  WXYZ_SearchBoxModel.m
//  WXReader
//
//  Created by Andrew on 2019/6/17.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_SearchBoxView.h"

#define SearchBarHeight 40

@interface WXYZ_SearchBoxView ()

@property (nonatomic, strong) NSMutableArray *boxViewArray;

@end

@implementation WXYZ_SearchBoxView

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)selectSearchBoxAtIndex:(NSIndexPath *)indexPath selectField:(NSString *)field selectValue:(NSString *)value
{
    if (self.searchBoxSelectBlock) {
        self.searchBoxSelectBlock(field, value);
    }
}

- (void)setSearch_box:(NSArray<WXYZ_SearchBoxModel *> *)search_box
{
    _search_box = search_box;
    
    if (!self.boxViewArray) {
        self.boxViewArray = [NSMutableArray array];
        for (NSInteger i = 0; i < self.search_box.count; i ++) {
            WXYZ_SearchBoxCollectionView *boxView = [[WXYZ_SearchBoxCollectionView alloc] initWithFrame:CGRectMake(0, SearchBarHeight * i, SCREEN_WIDTH, SearchBarHeight)];
            boxView.searchModel = [search_box objectOrNilAtIndex:i];
            boxView.delegate = self;
            [self addSubview:boxView];
            
            [self.boxViewArray addObject:boxView];
        }
    } else {
        for (NSInteger i = 0; i < self.boxViewArray.count; i++) {
            WXYZ_SearchBoxCollectionView *boxView = [self.boxViewArray objectOrNilAtIndex:i];
            boxView.searchModel = [search_box objectOrNilAtIndex:i];
        }
    }
    
}

@end

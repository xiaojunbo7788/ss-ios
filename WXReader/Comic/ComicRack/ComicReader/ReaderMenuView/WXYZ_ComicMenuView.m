//
//  WXYZ_ComicMenuView.m
//  WXReader
//
//  Created by Andrew on 2019/6/4.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicMenuView.h"
#import "WXYZ_ComicMenuTopBar.h"
#import "WXYZ_ComicMenuBottomBar.h"

@implementation WXYZ_ComicMenuView
{
    WXYZ_ComicMenuTopBar *topBar;
    WXYZ_ComicMenuBottomBar *bottomBar;
}

implementation_singleton(WXYZ_ComicMenuView)

- (instancetype)init
{
    if (self = [super init]) {
        
        [self initialize];
        
        [self createSubViews];
    }
    return self;
}

- (void)initialize
{
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    
    self.isShowing = NO;
}

- (void)createSubViews
{
    topBar = [[WXYZ_ComicMenuTopBar alloc] init];
    [self addSubview:topBar];
    
    bottomBar = [[WXYZ_ComicMenuBottomBar alloc] init];
    [self addSubview:bottomBar];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hiddenMenuView];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *touchView = [super hitTest:point withEvent:event];
    if (CGRectContainsPoint(topBar.bounds, point)) {
        if ([touchView isKindOfClass:[UIButton class]]) {
            return touchView;
        }
        return nil;
    }
    
    if ([touchView isDescendantOfView:bottomBar]) {
        return touchView;
    }
    
    return nil;
}

- (void)autoShowOrHiddenMenuView
{
    if (!self.isShowing) {
        [self showMenuView];
    } else {
        [self hiddenMenuView];
    }
}

- (void)showMenuView
{
    [bottomBar reloadCollectionState];
    if (self.isShowing) {
        return;
    }
    self.isShowing = YES;
    [topBar showMenuTopBar];
    [bottomBar showMenuBottomBar];
    [WXYZ_ViewHelper setStateBarDefaultStyle];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)hiddenMenuView
{
    if (!self.isShowing) {
        return;
    }
    self.isShowing = NO;
    [topBar hiddenMenuTopBar];
    [bottomBar hiddenMenuBottomBar];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)startLoadingData
{
    [bottomBar startLoadingData];
}

- (void)stopLoadingData
{
    [bottomBar stopLoadingData];
}

- (void)setComicChapterModel:(WXYZ_ProductionChapterModel *)comicChapterModel
{
    _comicChapterModel = comicChapterModel;
    
    if (comicChapterModel) {
        [topBar setNavTitle:comicChapterModel.chapter_title?:self.productionModel.name];
        bottomBar.comicChapterModel = comicChapterModel;
    } else {
        [topBar setNavTitle:@""];
        bottomBar.comicChapterModel = comicChapterModel;
    }
    
}

- (void)setProductionModel:(WXYZ_ProductionModel *)productionModel
{
    if (_productionModel != productionModel) {
        _productionModel = productionModel;
        
        bottomBar.productionModel = productionModel;
    }
}

@end

//
//  UIView+Empty.m
//  LYEmptyViewDemo
//
//  Created by liyang on 2018/5/10.
//  Copyright © 2018年 liyang. All rights reserved.
//

#import "UIView+Empty.h"
#import <objc/runtime.h>
#import "LYEmptyView.h"

#pragma mark - ------------------ UIView ------------------

@implementation UIView (Empty)

+ (void)exchangeInstanceMethod1:(SEL)method1 method2:(SEL)method2
{
    method_exchangeImplementations(class_getInstanceMethod(self, method1), class_getInstanceMethod(self, method2));
}

#pragma mark - Setter/Getter

static char kEmptyViewKey;
- (void)setLy_emptyView:(LYEmptyView *)ly_emptyView{
    if (ly_emptyView != self.ly_emptyView) {
        
        objc_setAssociatedObject(self, &kEmptyViewKey, ly_emptyView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[LYEmptyView class]]) {
                [view removeFromSuperview];
            }
        }
        [self addSubview:self.ly_emptyView];
    }
}
- (LYEmptyView *)ly_emptyView{
    return  objc_getAssociatedObject(self, &kEmptyViewKey);
}

#pragma mark - Private Method (UITableView、UICollectionView有效)
- (NSInteger)totalDataCount
{
    NSInteger totalCount = 0;
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;
        
        for (NSInteger section = 0; section < tableView.numberOfSections; section++) {
            totalCount += [tableView numberOfRowsInSection:section];
        }
    } else if ([self isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        
        for (NSInteger section = 0; section < collectionView.numberOfSections; section++) {
            totalCount += [collectionView numberOfItemsInSection:section];
        }
    }
    return totalCount;
}
- (void)getDataAndSet{
    //没有设置emptyView的，直接返回
    if (!self.ly_emptyView) {
        return;
    }
    
    if ([self totalDataCount] == 0) {
        [self show];
    }else{
        [self hide];
    }
}
- (void)show{
    
    //当不自动显隐时，内部自动调用show方法时也不要去显示，要显示的话只有手动去调用 ly_showEmptyView
    if (!self.ly_emptyView.autoShowEmptyView) {
        self.ly_emptyView.hidden = YES;
        return;
    }
    
    [self ly_showEmptyView];
}
- (void)hide{
    
    if (!self.ly_emptyView.autoShowEmptyView) {
        self.ly_emptyView.hidden = YES;
        return;
    }
    
    [self ly_hideEmptyView];
}

#pragma mark - Public Method
- (void)ly_showEmptyView{
    
    [self.ly_emptyView.superview layoutSubviews];
    
    self.ly_emptyView.hidden = NO;
    
    //让 emptyBGView 始终保持在最上层
    [self bringSubviewToFront:self.ly_emptyView];
    
    UITableView *tableView = (UITableView *)self;
    if ([tableView isKindOfClass:UITableView.class]) {
        tableView.mj_footer.hidden = YES;
    }
}
- (void)ly_hideEmptyView{
    self.ly_emptyView.hidden = YES;
    UITableView *tableView = (UITableView *)self;
    if ([tableView isKindOfClass:UITableView.class]) {
        tableView.mj_footer.hidden = NO;
    }
}

- (void)ly_startLoading{
    self.ly_emptyView.hidden = YES;
}
- (void)ly_endLoading{
    UITableView *tableView = (UITableView *)self;
    if ([tableView isKindOfClass:UITableView.class]) {
        tableView.mj_footer.hidden = ![self totalDataCount];
    }
    self.ly_emptyView.hidden = [self totalDataCount];
}

@end

#pragma mark - ------------------ UITableView ------------------

@implementation UITableView (Empty)
+ (void)load{
    
    [self exchangeInstanceMethod1:@selector(reloadData) method2:@selector(ly_reloadData)];
    
    ///section
    [self exchangeInstanceMethod1:@selector(insertSections:withRowAnimation:) method2:@selector(ly_insertSections:withRowAnimation:)];
    [self exchangeInstanceMethod1:@selector(deleteSections:withRowAnimation:) method2:@selector(ly_deleteSections:withRowAnimation:)];
    [self exchangeInstanceMethod1:@selector(reloadSections:withRowAnimation:) method2:@selector(ly_reloadSections:withRowAnimation:)];
    
    ///row
    [self exchangeInstanceMethod1:@selector(insertRowsAtIndexPaths:withRowAnimation:) method2:@selector(ly_insertRowsAtIndexPaths:withRowAnimation:)];
    [self exchangeInstanceMethod1:@selector(deleteRowsAtIndexPaths:withRowAnimation:) method2:@selector(ly_deleteRowsAtIndexPaths:withRowAnimation:)];
    [self exchangeInstanceMethod1:@selector(reloadRowsAtIndexPaths:withRowAnimation:) method2:@selector(ly_reloadRowsAtIndexPaths:withRowAnimation:)];
}
- (void)ly_reloadData{
    [self ly_reloadData];
    [self getDataAndSet];
}
///section
- (void)ly_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation{
    [self ly_insertSections:sections withRowAnimation:animation];
    [self getDataAndSet];
}
- (void)ly_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation{
    [self ly_deleteSections:sections withRowAnimation:animation];
    [self getDataAndSet];
}
- (void)ly_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation{
    [self ly_reloadSections:sections withRowAnimation:animation];
    [self getDataAndSet];
}

///row
- (void)ly_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation{
    [self ly_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self getDataAndSet];
}
- (void)ly_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation{
    [self ly_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self getDataAndSet];
}
- (void)ly_reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation{
    [self ly_reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self getDataAndSet];
}


@end

#pragma mark - ------------------ UICollectionView ------------------

@implementation UICollectionView (Empty)

+ (void)load{
    
    [self exchangeInstanceMethod1:@selector(reloadData) method2:@selector(ly_reloadData)];
    
    ///section
    [self exchangeInstanceMethod1:@selector(insertSections:) method2:@selector(ly_insertSections:)];
    [self exchangeInstanceMethod1:@selector(deleteSections:) method2:@selector(ly_deleteSections:)];
    [self exchangeInstanceMethod1:@selector(reloadSections:) method2:@selector(ly_reloadSections:)];
    
    ///item
    [self exchangeInstanceMethod1:@selector(insertItemsAtIndexPaths:) method2:@selector(ly_insertItemsAtIndexPaths:)];
    [self exchangeInstanceMethod1:@selector(deleteItemsAtIndexPaths:) method2:@selector(ly_deleteItemsAtIndexPaths:)];
    [self exchangeInstanceMethod1:@selector(reloadItemsAtIndexPaths:) method2:@selector(ly_reloadItemsAtIndexPaths:)];
    
}
- (void)ly_reloadData{
    [self ly_reloadData];
    [self getDataAndSet];
}
///section
- (void)ly_insertSections:(NSIndexSet *)sections{
    [self ly_insertSections:sections];
    [self getDataAndSet];
}
- (void)ly_deleteSections:(NSIndexSet *)sections{
    [self ly_deleteSections:sections];
    [self getDataAndSet];
}
- (void)ly_reloadSections:(NSIndexSet *)sections{
    [self ly_reloadSections:sections];
    [self getDataAndSet];
}

///item
- (void)ly_insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    [self ly_insertItemsAtIndexPaths:indexPaths];
    [self getDataAndSet];
}
- (void)ly_deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    [self ly_deleteItemsAtIndexPaths:indexPaths];
    [self getDataAndSet];
}
- (void)ly_reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    [self ly_reloadItemsAtIndexPaths:indexPaths];
    [self getDataAndSet];
}
@end


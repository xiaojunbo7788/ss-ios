
//
//  WXYZ_ComicDownloadManagementViewController.m
//  WXReader
//
//  Created by Andrew on 2019/6/11.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicDownloadManagementViewController.h"
#import "WXYZ_ComicReaderViewController2.h"
#import "WXYZ_ComicDownloadManagementDetailViewController.h"

#import "WXYZ_ComicDownloadManagementTableViewCell.h"

#import "WXYZ_ComicDownloadManager.h"
#import "WXYZ_ProductionReadRecordManager.h"

#import "UIView+LayoutCallback.h"
#import "WXYZ_ProductionCollectionManager.h"

@interface WXYZ_ComicDownloadManagementViewController () <UITableViewDelegate, UITableViewDataSource>

/// 编辑页面
@property (nonatomic, weak) UIView *edittingView;

@property (nonatomic, weak) UIButton *edittingAll;

@property (nonatomic, weak) UIButton *edittingDelete;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *selectedArray;

@property (nonatomic, weak) CALayer *topLayer;

@property (nonatomic, weak) CALayer *middleLayer;

@end

@implementation WXYZ_ComicDownloadManagementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setStatusBarDefaultStyle];
    
    NSArray *t_sourceArray = [[[[WXYZ_DownloadHelper sharedManager] getDownloadProductionArrayWithProductionType:WXYZ_ProductionTypeComic] reverseObjectEnumerator] allObjects];
    
    self.dataSourceArray = [NSMutableArray array];
    for (WXYZ_ProductionModel *t_model in t_sourceArray) {
        if ([[WXYZ_ComicDownloadManager sharedManager] getDownloadChapterCountWithProduction_id:t_model.production_id] > 0) {
            [self.dataSourceArray addObject:t_model];
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.dataSourceArray.count == 0) {
            [self.mainTableView ly_showEmptyView];
        } else {
            [self.mainTableView ly_hideEmptyView];
        }
    });
    
    [self.mainTableView reloadData];
}

- (void)initialize
{
    self.selectedArray = [NSMutableArray array];
    // 设置编辑状态
    WS(weakSelf)
    _editStateBlock = ^() {
        BOOL isEditting = NO;
        if (weakSelf.mainTableView.visibleCells.count == 0) return NO;
        for (UITableViewCell *cell in weakSelf.mainTableView.visibleCells) {
            if ([cell isMemberOfClass:WXYZ_ComicDownloadManagementTableViewCell.class]) {
                WXYZ_ComicDownloadManagementTableViewCell *celll = (WXYZ_ComicDownloadManagementTableViewCell *)cell;
                isEditting = !celll.isEditting;
                weakSelf.isEditting = isEditting;
                // 隐藏/显示底部编辑区域
                if (isEditting) {
                    [UIView animateWithDuration:kAnimatedDuration animations:^{
                        [weakSelf.edittingView mas_updateConstraints:^(MASConstraintMaker *make) {
                            make.bottom.equalTo(weakSelf.view);
                        }];
                        [weakSelf.edittingView.superview layoutIfNeeded];
                    }];
                } else {
                    [UIView animateWithDuration:kAnimatedDuration animations:^{
                        [weakSelf.edittingView mas_updateConstraints:^(MASConstraintMaker *make) {
                            make.bottom.equalTo(weakSelf.view).offset(CGRectGetHeight(weakSelf.edittingView .bounds));
                        }];
                        [weakSelf.edittingView.superview layoutIfNeeded];
                    }];
                }
                [celll setEditing:!celll.isEditting];
                continue;
            }
        }
        return isEditting;
    };
    
    [self hiddenNavigationBar:YES];
}

- (void)createSubviews
{
    UIView *edittingView = [[UIView alloc] init];
    self.edittingView = edittingView;
    edittingView .backgroundColor = self.view.backgroundColor;
    WS(weakSelf)
    edittingView.frameBlock = ^(UIView * _Nonnull view) {
        if (weakSelf.topLayer) return;
        CALayer *layer = [CALayer layer];
        layer.backgroundColor = kColorRGB(238, 238, 238).CGColor;
        layer.frame = CGRectMake(0, 0, CGRectGetWidth(view.bounds), 0.5);
        [view.layer addSublayer:layer];
        weakSelf.topLayer = layer;
    };
    [self.view addSubview:edittingView ];
    [edittingView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.bottom.equalTo(self.view);
    }];
    
    // 编辑状态下全选按钮
    UIButton *edittingAll = [UIButton buttonWithType:UIButtonTypeCustom];
    self.edittingAll = edittingAll;
    [edittingAll setTitle:@"全选" forState:UIControlStateNormal];
    [edittingAll addTarget:self action:@selector(selectedAllEvent) forControlEvents:UIControlEventTouchUpInside];
    edittingAll.frameBlock = ^(UIButton * _Nonnull button) {
        if (weakSelf.middleLayer) return;
        CALayer *layer = [CALayer layer];
        layer.backgroundColor = kColorRGB(238, 238, 238).CGColor;
        layer.frame = CGRectMake(CGRectGetMaxX(button.frame), 16.0f, 0.5, CGRectGetHeight(button.bounds) - 2 * 16.0f);
        [button.layer addSublayer:layer];
        weakSelf.middleLayer = layer;
    };
    [edittingAll setTitleColor:kBlackColor forState:UIControlStateNormal];
    edittingAll.titleLabel.font = kFont14;
    [edittingView  addSubview:edittingAll];
    [edittingAll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(edittingView ).offset(1.0f);
        make.left.equalTo(edittingView );
        make.width.equalTo(edittingView ).multipliedBy(0.5f);
        make.height.equalTo(edittingAll.mas_width).multipliedBy(60.0f / 187.5f);
        make.bottom.equalTo(edittingView ).offset(-PUB_TABBAR_OFFSET).priorityLow();
    }];
    
    // 编辑状态下删除按钮
    UIButton *edittingDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    self.edittingDelete = edittingDelete;
    [edittingDelete setTitle:@"删除" forState:UIControlStateNormal];
    [edittingDelete addTarget:self action:@selector(deleteEvent) forControlEvents:UIControlEventTouchUpInside];
    [edittingDelete setTitleColor:kGrayTextColor forState:UIControlStateNormal];
    edittingDelete.titleLabel.font = kFont14;
    [edittingView  addSubview:edittingDelete];
    [edittingDelete mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.top.equalTo(edittingAll);
        make.left.equalTo(edittingAll.mas_right);
    }];
    
    [edittingView  setNeedsLayout];
    [edittingView  layoutIfNeeded];
    // 设置编辑区域默认高度
    [edittingView  mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(CGRectGetHeight(edittingView .bounds));
    }];
    
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.contentInset = UIEdgeInsetsMake(0, 0, PUB_TABBAR_OFFSET, 0);
    [self.view addSubview:self.mainTableView];
    
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(edittingView .mas_top);
    }];
    
    [self setEmptyOnView:self.mainTableView title:@"还没有下载记录" tapBlock:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.dataSourceArray.count == 0) {
            [self.mainTableView ly_showEmptyView];
        } else {
            [self.mainTableView ly_hideEmptyView];
        }
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WS(weakSelf)
    WXYZ_ComicDownloadManagementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_ComicDownloadManagementTableViewCell"];
    
    if (!cell) {
        cell = [[WXYZ_ComicDownloadManagementTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_ComicDownloadManagementTableViewCell"];
    }
    WXYZ_ProductionModel *t_model = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    cell.comicModel = t_model;
    [cell set_Editting:self.isEditting];
    cell.cellSelectBlock = ^(WXYZ_ProductionModel *comicModel, NSString *comic_name) {
        WXYZ_ComicDownloadManagementDetailViewController *vc = [[WXYZ_ComicDownloadManagementDetailViewController alloc] init];
        vc.comicModel = comicModel;
        vc.navTitle = comic_name;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    cell.imageViewSelectBlock = ^(NSInteger comic_id) {
        WXYZ_ComicMallDetailViewController *vc = [[WXYZ_ComicMallDetailViewController alloc] init];
        vc.comic_id = comic_id;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    cell.buttonSelectBlock = ^(WXYZ_ProductionModel *comicModel) {
        [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] moveCollectionToTopWithProductionModel:t_model];
        WXYZ_ComicReaderViewController2 *vc = [[WXYZ_ComicReaderViewController2 alloc] init];
        vc.comicProductionModel = comicModel;
        vc.chapter_id = [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] getReadingRecordChapter_idWithProduction_id:comicModel.production_id];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    
    if ([self.selectedArray containsObject:@(t_model.production_id)]) {
        [cell switchSelectedState:YES];
    } else {
        [cell switchSelectedState:NO];
    }
            
    cell.selecteEdittingCellBlock = ^(WXYZ_ProductionModel * _Nonnull productionModel, BOOL isSelected) {
        if (isSelected) {
            [weakSelf.selectedArray addObject:@(productionModel.production_id)];
        } else {
            [weakSelf.selectedArray removeObject:@(productionModel.production_id)];
        }
        [weakSelf updateEdittingView];
    };
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionModel *t_model = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    
    [[WXYZ_ComicDownloadManager sharedManager] removeDownloadProductionWithProduction_id:t_model.production_id];
    
    [self.dataSourceArray removeObject:t_model];
    [self.mainTableView reloadData];
    
    if (self.dataSourceArray.count > 0) {
        [self.mainTableView ly_hideEmptyView];
    } else {
        [self.mainTableView ly_showEmptyView];
    }
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHalfMargin;
}
//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kHalfMargin)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, PUB_TABBAR_OFFSET == 0 ? 10 : PUB_TABBAR_OFFSET)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

// 全选按钮点击事件
- (void)selectedAllEvent {
    if ([self.edittingAll.titleLabel.text isEqualToString:@"全选"]) {
        for (UITableViewCell *cell in self.mainTableView.visibleCells) {
            if ([cell isMemberOfClass:WXYZ_ComicDownloadManagementTableViewCell.class]) {
                WXYZ_ComicDownloadManagementTableViewCell *tempCell = (WXYZ_ComicDownloadManagementTableViewCell *)cell;
                [tempCell switchSelectedState:YES];
            }
        }
        
        for (WXYZ_ProductionModel *t_model in self.dataSourceArray) {
            if (![self.selectedArray containsObject:@(t_model.production_id)]) {
                [self.selectedArray addObject:@(t_model.production_id)];
            }
        }
    } else {
        for (UITableViewCell *cell in self.mainTableView.visibleCells) {
            if ([cell isMemberOfClass:WXYZ_ComicDownloadManagementTableViewCell.class]) {
                WXYZ_ComicDownloadManagementTableViewCell *tempCell = (WXYZ_ComicDownloadManagementTableViewCell *)cell;
                [tempCell switchSelectedState:NO];
            }
        }
        
        [self.selectedArray removeAllObjects];
    }
    
    [self updateEdittingView];
}

// 删除按钮点击事件
- (void)deleteEvent {
    if (self.selectedArray.count == 0) return;
    NSMutableArray *arr = [self.dataSourceArray mutableCopy];
    NSMutableArray<NSIndexPath *> *pathArr = [NSMutableArray array];
    [arr enumerateObjectsUsingBlock:^(WXYZ_ProductionModel * _Nonnull productionModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self.selectedArray containsObject:@(productionModel.production_id)]) {
            [[WXYZ_ComicDownloadManager sharedManager] removeDownloadProductionWithProduction_id:productionModel.production_id];
            [self.dataSourceArray removeObject:productionModel];
            [self.selectedArray removeObject:@(productionModel.production_id)];
            [pathArr addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
        }
    }];
    
    WS(weakSelf)
    if (@available(iOS 11.0, *)) {
        [self.mainTableView performBatchUpdates:^{
            [self.mainTableView deleteRowsAtIndexPaths:pathArr withRowAnimation:UITableViewRowAnimationLeft];
        } completion:^(BOOL finished) {
            if (!finished) return;
            SS(strongSelf)
            BOOL a = !strongSelf->_editStateBlock ?: strongSelf->_editStateBlock();
            NSLog(@"%@", a?@"":@"");
            [UIView animateWithDuration:kAnimatedDuration animations:^{
                [self.edittingView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(self.view).offset(CGRectGetHeight(self.edittingView .bounds));
                }];
                [self.edittingView.superview layoutIfNeeded];
            }];
            !self.changeEditStateBlock ?: self.changeEditStateBlock(YES);
        }];
    } else {
        [self.mainTableView beginUpdates];
        [self.mainTableView deleteRowsAtIndexPaths:pathArr withRowAnimation:UITableViewRowAnimationLeft];
        [self.mainTableView endUpdates];
        dispatch_async(dispatch_get_main_queue(), ^{
            SS(strongSelf)
            BOOL a = !strongSelf->_editStateBlock ?: strongSelf->_editStateBlock();
            NSLog(@"%@", a?@"":@"");
            [UIView animateWithDuration:kAnimatedDuration animations:^{
                [self.edittingView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(self.view).offset(CGRectGetHeight(self.edittingView .bounds));
                }];
                [self.edittingView.superview layoutIfNeeded];
            }];
            !self.changeEditStateBlock ?: self.changeEditStateBlock(YES);
        });
    }
    
    if (self.dataSourceArray.count > 0) {
        [self.mainTableView ly_hideEmptyView];
    } else {
        [self.mainTableView ly_showEmptyView];
    }
    
    self.isEditting = NO;
    [self updateEdittingView];
}

// 更新底部编辑区域
- (void)updateEdittingView {
    if (self.dataSourceArray.count > 0 && self.mainTableView.visibleCells.count == 0) return;
    
    BOOL allSelected = YES;
    for (WXYZ_ProductionModel *t_model in self.dataSourceArray) {
        if (![self.selectedArray containsObject:@(t_model.production_id)]) {
            allSelected = NO;
            break;
        }
    }
    
    if (allSelected) {
        [self.edittingAll setTitle:@"取消全选" forState:UIControlStateNormal];
    } else {
        [self.edittingAll setTitle:@"全选" forState:UIControlStateNormal];
    }
    
    if (self.selectedArray.count == 0) {
        [self.edittingDelete setTitle:@"删除" forState:UIControlStateNormal];
        [self.edittingDelete setTitleColor:kGrayTextColor forState:UIControlStateNormal];
    } else {
        [self.edittingDelete setTitle:[NSString stringWithFormat:@"删除 (%zd)", self.selectedArray.count] forState:UIControlStateNormal];
        [self.edittingDelete setTitleColor:kRedColor forState:UIControlStateNormal];
    }
    
}

@end

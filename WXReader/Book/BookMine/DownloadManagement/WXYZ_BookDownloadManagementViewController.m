//
//  WXYZ_BookDownloadManagementViewController.m
//  WXReader
//
//  Created by Andrew on 2019/4/3.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_BookDownloadManagementViewController.h"
#import "WXYZ_BookDownloadManager.h"

#import "WXYZ_BookDownloadManagementTableViewCell.h"
#import "WXYZ_BookDownloadManagementChapterTableViewCell.h"

#import "WXYZ_BookReaderViewController.h"

#import "UIView+LayoutCallback.h"
#import "WXYZ_ProductionCollectionManager.h"

@interface WXYZ_BookDownloadManagementViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray<NSNumber *> *selectedArray;

// 章节记录
@property (nonatomic, strong) NSMutableDictionary *chapterDownloadDic;

@property (nonatomic, weak) CALayer *topLayer;

@property (nonatomic, weak) CALayer *middleLayer;

/// 编辑页面
@property (nonatomic, weak) UIView *edittingView;

@property (nonatomic, weak) UIButton *edittingAll;

@property (nonatomic, weak) UIButton *edittingDelete;

@end

@implementation WXYZ_BookDownloadManagementViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self netRequest];
    [self initialize];
    [self createSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setStatusBarDefaultStyle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Hidden_Tabbar object:nil];
}

- (void)initialize
{
    self.selectedArray = [NSMutableArray array];
    // 设置编辑状态
    WS(weakSelf)
    _editStateBlock = ^() {
        BOOL isEditting = NO;
        if (weakSelf.mainTableViewGroup.visibleCells.count == 0) return NO;
        for (UITableViewCell *cell in weakSelf.mainTableViewGroup.visibleCells) {
            if ([cell isMemberOfClass:WXYZ_BookDownloadManagementTableViewCell.class]) {
                WXYZ_BookDownloadManagementTableViewCell *celll = (WXYZ_BookDownloadManagementTableViewCell *)cell;
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
            
            if ([cell isMemberOfClass:WXYZ_BookDownloadManagementChapterTableViewCell.class]) {
                WXYZ_BookDownloadManagementChapterTableViewCell *celll = (WXYZ_BookDownloadManagementChapterTableViewCell *)cell;
                [celll setEditing:!celll.isEditting];
                continue;
            }
        }
        return isEditting;
    };
    
    [self hiddenNavigationBar:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netRequest) name:Notification_Reload_Download_State object:nil];
}

- (void)createSubviews
{
    UIView *edittingView = [[UIView alloc] init];
    self.edittingView = edittingView;
    edittingView .backgroundColor = self.view.backgroundColor;
    WS(weakSelf)
    edittingView .frameBlock = ^(UIView * _Nonnull view) {
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
    
    self.mainTableViewGroup.delegate = self;
    self.mainTableViewGroup.dataSource = self;
    [self.view addSubview:self.mainTableViewGroup];
    
    [self.mainTableViewGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(edittingView .mas_top);
    }];
    
    [edittingView  setNeedsLayout];
    [edittingView  layoutIfNeeded];
    // 设置编辑区域默认高度
    [edittingView  mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(CGRectGetHeight(edittingView .bounds));
    }];
    
    [self setEmptyOnView:self.mainTableViewGroup title:@"还没有下载记录" tapBlock:nil];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSourceArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    WXYZ_BookDownloadTaskListModel *listModel = [self.dataSourceArray objectOrNilAtIndex:section];
    return listModel.task_list.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_BookDownloadTaskListModel *listModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.section];
    WS(weakSelf)
    if (indexPath.row == 0) {
        
        WXYZ_BookDownloadManagementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_BookDownloadManagementTableViewCell"];
        
        if (!cell) {
            cell = [[WXYZ_BookDownloadManagementTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_BookDownloadManagementTableViewCell"];
        }
        cell.productionModel = listModel.productionModel;
        [cell set_Editting:self.isEditting];
        cell.openBookBlock = ^(NSString *book_id) {
            WXYZ_BookReaderViewController *vc = [[WXYZ_BookReaderViewController alloc] init];
            [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] moveCollectionToTopWithProductionModel:listModel.productionModel];
            vc.book_id = [book_id integerValue];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        };
        cell.cellSelectBlock = ^(NSInteger production_id) {
            WXYZ_BookMallDetailViewController *vc = [[WXYZ_BookMallDetailViewController alloc] init];
            vc.book_id = production_id;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        };
        
        if ([self.selectedArray containsObject:@(listModel.productionModel.production_id)]) {
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
        
        if (self.pushFromReader) {
            cell.openBook.hidden = YES;
        } else {
            cell.openBook.hidden = NO;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        WXYZ_BookDownloadManagementChapterTableViewCell *chapterCell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_BookDownloadManagementChapterTableViewCell"];
        
        if (!chapterCell) {
            chapterCell = [[WXYZ_BookDownloadManagementChapterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_BookDownloadManagementChapterTableViewCell"];
        }
        chapterCell.downloadTaskModel = [listModel.task_list objectOrNilAtIndex:indexPath.row - 1];
        [chapterCell set_Editing:self.isEditting];
        return chapterCell;
    }
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == self.dataSourceArray.count - 1) {
        return PUB_TABBAR_OFFSET == 0 ? 10 : PUB_TABBAR_OFFSET;
    }
    return 0.01;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, section == self.dataSourceArray.count - 1?(PUB_TABBAR_OFFSET == 0 ? 10 : PUB_TABBAR_OFFSET):0.01)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return YES;
    }
    return NO;
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
    WXYZ_BookDownloadTaskListModel *t_model = [self.dataSourceArray objectOrNilAtIndex:indexPath.section];
    [[WXYZ_BookDownloadManager sharedManager] removeDownloadProductionWithProduction_id:t_model.productionModel.production_id];
    [self.dataSourceArray removeObject:t_model];
    [self.mainTableViewGroup reloadData];
    
    if (self.dataSourceArray.count > 0) {
        [self.mainTableViewGroup ly_hideEmptyView];
    } else {
        [self.mainTableViewGroup ly_showEmptyView];
    }
}

- (void)netRequest
{
    NSArray *downloandArray = [[[[WXYZ_DownloadHelper sharedManager] getDownloadProductionArrayWithProductionType:WXYZ_ProductionTypeBook] reverseObjectEnumerator] allObjects];
    
    for (WXYZ_ProductionModel *productionModel in downloandArray) {
        WXYZ_BookDownloadTaskListModel *downloadTaskListModel = [[WXYZ_BookDownloadManager sharedManager] getDownloadProductionModelWithProduction_id:productionModel.production_id];
        if (downloadTaskListModel.task_list.count > 0) {
            [self.dataSourceArray addObject:downloadTaskListModel];
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainTableViewGroup reloadData];
            
            if (self.dataSourceArray.count > 0) {
                [self.mainTableViewGroup ly_hideEmptyView];
            } else {
                [self.mainTableViewGroup ly_showEmptyView];
            }
        });
    });
}

// 全选按钮点击事件
- (void)selectedAllEvent {
    if ([self.edittingAll.titleLabel.text isEqualToString:@"全选"]) {
        for (UITableViewCell *cell in self.mainTableViewGroup.visibleCells) {
            if ([cell isMemberOfClass:WXYZ_BookDownloadManagementTableViewCell.class]) {
                WXYZ_BookDownloadManagementTableViewCell *tempCell = (WXYZ_BookDownloadManagementTableViewCell *)cell;
                [tempCell switchSelectedState:YES];
            }
        }
        
        for (WXYZ_BookDownloadTaskListModel *t_model in self.dataSourceArray) {
            if (![self.selectedArray containsObject:@(t_model.productionModel.production_id)]) {
                [self.selectedArray addObject:@(t_model.productionModel.production_id)];
            }
        }
    } else {
        for (UITableViewCell *cell in self.mainTableViewGroup.visibleCells) {
            if ([cell isMemberOfClass:WXYZ_BookDownloadManagementTableViewCell.class]) {
                WXYZ_BookDownloadManagementTableViewCell *tempCell = (WXYZ_BookDownloadManagementTableViewCell *)cell;
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
    NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
    NSMutableArray *arr = [self.dataSourceArray mutableCopy];
    [arr enumerateObjectsUsingBlock:^(WXYZ_BookDownloadTaskListModel * _Nonnull downloadModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self.selectedArray containsObject:@(downloadModel.productionModel.production_id)]) {
            [[WXYZ_BookDownloadManager sharedManager] removeDownloadProductionWithProduction_id:downloadModel.productionModel.production_id];
            [self.dataSourceArray removeObject:downloadModel];
            [self.selectedArray removeObject:@(downloadModel.productionModel.production_id)];
            [set addIndex:idx];
        }
    }];
    
    WS(weakSelf)
    if (@available(iOS 11.0, *)) {
        [self.mainTableViewGroup performBatchUpdates:^{
            [self.mainTableViewGroup deleteSections:set withRowAnimation:UITableViewRowAnimationLeft];
        } completion:^(BOOL finished) {
            SS(strongSelf)
            if (!finished) return;
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
        [self.mainTableViewGroup beginUpdates];
        [self.mainTableViewGroup deleteSections:set withRowAnimation:UITableViewRowAnimationLeft];
        [self.mainTableViewGroup endUpdates];
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
        [self.mainTableViewGroup ly_hideEmptyView];
    } else {
        [self.mainTableViewGroup ly_showEmptyView];
    }
    
    self.isEditting = NO;
    [self updateEdittingView];
}

// 更新底部编辑区域
- (void)updateEdittingView {
    if (self.dataSourceArray.count > 0 && self.mainTableViewGroup.visibleCells.count == 0) return;
    
    BOOL allSelected = YES;
    for (WXYZ_BookDownloadTaskListModel *t_model in self.dataSourceArray) {
        if (![self.selectedArray containsObject:@(t_model.productionModel.production_id)]) {
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

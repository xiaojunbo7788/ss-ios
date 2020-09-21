//
//  WXYZ_ComicDownloadManagementDetailViewController.m
//  WXReader
//
//  Created by Andrew on 2020/7/9.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ComicDownloadManagementDetailViewController.h"
#import "WXYZ_ComicReaderDownloadCollectionViewCell.h"
#import "WXYZ_ChapterBottomPayBar.h"

#import "WXYZ_ComicReaderDownloadModel.h"

#import "WXYZ_ComicDownloadManager.h"

@interface WXYZ_ComicDownloadManagementDetailViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    UIView *toolBarView;
    YYLabel *toolBarLeftLabel;
    UILabel *toolBarRightLabel;
    
    UIButton *deleteButton;
    
    UIButton *selectAllButton;
}

@end

@implementation WXYZ_ComicDownloadManagementDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
    [self netRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarDefaultStyle];
}

- (void)initialize
{
    [self setNavigationBarTitle:self.navTitle?:@"选择章节"];
    
    self.view.backgroundColor = kGrayViewColor;
}

- (void)createSubviews
{
    WXYZ_CustomButton *sortButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - kHalfMargin - 60, PUB_NAVBAR_HEIGHT - 30 - kQuarterMargin, 60, 30) buttonTitle:@"正序" buttonImageName:@"comic_positive_order" buttonIndicator:WXYZ_CustomButtonIndicatorImageRightBothRight];
    sortButton.selected = NO;
    sortButton.buttonImageScale = 0.4;
    sortButton.buttonTitleFont = kFont11;
    sortButton.graphicDistance = 5;
    sortButton.buttonTitleColor = kGrayTextColor;
    [sortButton addTarget:self action:@selector(sortClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:sortButton];
    
    self.mainCollectionViewFlowLayout.minimumLineSpacing = kHalfMargin;
    self.mainCollectionViewFlowLayout.minimumInteritemSpacing = kHalfMargin;
    self.mainCollectionViewFlowLayout.itemSize = CGSizeMake((SCREEN_WIDTH - 5 * kHalfMargin) / 4, 40);
    self.mainCollectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(kHalfMargin, kHalfMargin, kHalfMargin, kHalfMargin);
    
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.dataSource = self;
    self.mainCollectionView.alwaysBounceVertical = YES;
    [self.mainCollectionView registerClass:[WXYZ_ComicReaderDownloadCollectionViewCell class] forCellWithReuseIdentifier:@"WXYZ_ComicReaderDownloadCollectionViewCell"];
    [self.view addSubview:self.mainCollectionView];
    
    [self.mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_height).with.offset(- PUB_NAVBAR_HEIGHT - PUB_TABBAR_HEIGHT - 20);
    }];
    
    toolBarView = [[UIView alloc] init];
    toolBarView.backgroundColor = kWhiteColor;
    [self.view addSubview:toolBarView];
    
    [toolBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(self.view.mas_bottom);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT + 20);
    }];
    
    toolBarLeftLabel = [[YYLabel alloc] init];
    toolBarLeftLabel.textColor = kGrayTextColor;
    toolBarLeftLabel.textContainerInset = UIEdgeInsetsMake(3, kHalfMargin, 0, 0);
    toolBarLeftLabel.textAlignment = NSTextAlignmentLeft;
    toolBarLeftLabel.font = kFont10;
    toolBarLeftLabel.backgroundColor = kGrayDeepViewColor;
    [toolBarView addSubview:toolBarLeftLabel];
    
    [toolBarLeftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(toolBarView.mas_width);
        make.height.mas_equalTo(20);
    }];
    
    toolBarRightLabel = [[UILabel alloc] init];
    toolBarRightLabel.text = @"已选0话";
    toolBarRightLabel.textColor = kGrayTextColor;
    toolBarRightLabel.textAlignment = NSTextAlignmentRight;
    toolBarRightLabel.font = kFont10;
    toolBarRightLabel.backgroundColor = [UIColor clearColor];
    [toolBarView addSubview:toolBarRightLabel];
    
    [toolBarRightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(toolBarView.mas_right).with.offset(- kHalfMargin);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(toolBarView.mas_width).with.multipliedBy(0.5);
        make.height.mas_equalTo(20);
    }];
    
    selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectAllButton setTitle:@"全选" forState:UIControlStateNormal];
    [selectAllButton setTitleColor:kBlackColor forState:UIControlStateNormal];
    [selectAllButton.titleLabel setFont:kMainFont];
    [selectAllButton addTarget:self action:@selector(checkallClick:) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:selectAllButton];
    
    [selectAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(toolBarView.mas_left);
        make.top.mas_equalTo(toolBarRightLabel.mas_bottom);
        make.width.mas_equalTo(SCREEN_WIDTH / 2);
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT - PUB_TABBAR_OFFSET);
    }];
    
    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.enabled = NO;
    [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [deleteButton setTitleColor:kGrayTextLightColor forState:UIControlStateNormal];
    [deleteButton.titleLabel setFont:kMainFont];
    [deleteButton addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:deleteButton];
    
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(selectAllButton.mas_right);
        make.top.mas_equalTo(toolBarRightLabel.mas_bottom);
        make.right.mas_equalTo(toolBarView.mas_right);
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT - PUB_TABBAR_OFFSET);
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"WXYZ_ComicReaderDownloadCollectionViewCell";
    WXYZ_ProductionChapterModel *listModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    listModel.can_read = YES;
    
    WXYZ_ComicReaderDownloadCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.chapterModel = listModel;
    cell.cellDownloadState = [[self.selectSourceDictionary objectForKey:[WXYZ_UtilsHelper formatStringWithInteger:listModel.chapter_id]] integerValue];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionChapterModel *listModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    WXYZ_ComicReaderDownloadCollectionViewCell *cell = (WXYZ_ComicReaderDownloadCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    switch (cell.cellDownloadState) {
        case WXYZ_ProductionDownloadStateDownloaded:
            [self setCollectionCellDownloadStateWithChapter_id:listModel.chapter_id downloadState:WXYZ_ProductionDownloadStateSelected];
            [self reloadToolBar];
            break;
        case WXYZ_ProductionDownloadStateSelected:
            [self setCollectionCellDownloadStateWithChapter_id:listModel.chapter_id downloadState:WXYZ_ProductionDownloadStateDownloaded];
            [self reloadToolBar];
            break;
        default:
            break;
    }
}

#pragma mark - 点击事件
- (void)sortClick:(WXYZ_CustomButton *)sender
{
    if (sender.selected) {
        sender.buttonImageName = @"comic_positive_order";
        sender.buttonTitle = @"正序";
    } else {
        sender.buttonImageName = @"comic_reverse_order";
        sender.buttonTitle = @"倒序";
    }
    
    sender.selected = !sender.selected;
    
    self.dataSourceArray = [[[self.dataSourceArray reverseObjectEnumerator] allObjects] mutableCopy];
    [self.mainCollectionView reloadData];
}

- (void)checkallClick:(UIButton *)sender
{
    for (NSString *t_chapter_id in self.selectSourceDictionary.allKeys) {
        
        if (!sender.selected) { // 全选状态
            if ([[self.selectSourceDictionary objectForKey:t_chapter_id] integerValue] == WXYZ_ProductionDownloadStateDownloaded) {
                [self setCollectionCellDownloadStateWithChapter_id:[t_chapter_id integerValue] downloadState:WXYZ_ProductionDownloadStateSelected];
            }
        } else {
            if ([[self.selectSourceDictionary objectForKey:t_chapter_id] integerValue] == WXYZ_ProductionDownloadStateSelected) {
                [self setCollectionCellDownloadStateWithChapter_id:[t_chapter_id integerValue] downloadState:WXYZ_ProductionDownloadStateDownloaded];
            }
        }
    }
    
    sender.selected = !sender.selected;

    [self reloadToolBar];
}

- (void)deleteClick:(UIButton *)sender
{
    NSMutableArray *t_deleteArr = [NSMutableArray array];
    for (NSString *t_chapter_id in self.selectSourceDictionary.allKeys) {
        if ([[self.selectSourceDictionary objectForKey:t_chapter_id] integerValue] == WXYZ_ProductionDownloadStateSelected) {
            [t_deleteArr addObject:t_chapter_id];
        }
    }
    
    WS(weakSelf)
    [[WXYZ_ComicDownloadManager sharedManager] removeDownloadChaptersWithProduction_id:self.comicModel.production_id chapter_ids:t_deleteArr];
    [WXYZ_ComicDownloadManager sharedManager].downloadDeleteFinishBlock = ^(NSArray * _Nonnull success_chapter_ids, NSArray * _Nonnull fail_chapter) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"删除成功"];
        [weakSelf netRequest];
    };
}

- (void)reloadToolBar
{
    NSInteger selectIndex = 0;
    NSInteger downloadedIndex = 0;
    
    for (NSString *t_key in self.selectSourceDictionary) {
        switch ([[self.selectSourceDictionary objectForKey:t_key] integerValue]) {
            case WXYZ_ProductionDownloadStateDownloaded:
                downloadedIndex ++;
                break;
            case WXYZ_ProductionDownloadStateSelected:
                selectIndex ++;
                break;
                
            default:
                break;
        }
    }

    toolBarLeftLabel.text = [NSString stringWithFormat:@"已下载%@话", [WXYZ_UtilsHelper formatStringWithInteger:self.dataSourceArray.count]];
    toolBarRightLabel.text = [NSString stringWithFormat:@"已选%@话", [WXYZ_UtilsHelper formatStringWithInteger:selectIndex]];
    
    deleteButton.enabled = NO;
    [deleteButton setTitleColor:kGrayTextLightColor forState:UIControlStateNormal];
    
    selectAllButton.enabled = YES;
    selectAllButton.selected = NO;
    [selectAllButton setTitle:@"全选" forState:UIControlStateNormal];
    [selectAllButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH / 2);
    }];
    
    
    if (selectIndex > 0 && downloadedIndex == 0) { // 有选中的文件并且没有未选中的文件
        
        deleteButton.enabled = YES;
        [deleteButton setTitleColor:kBlackColor forState:UIControlStateNormal];
        
        selectAllButton.selected = YES;
        [selectAllButton setTitle:@"取消全选" forState:UIControlStateNormal];
        [selectAllButton setTitleColor:kBlackColor forState:UIControlStateNormal];
    } else if (downloadedIndex > 0 && selectIndex > 0) { // 有未选中的文件
        
        deleteButton.enabled = YES;
        [deleteButton setTitleColor:kBlackColor forState:UIControlStateNormal];
    }
}

- (void)setCollectionCellDownloadStateWithChapter_id:(NSInteger)chapter_id downloadState:(WXYZ_ProductionDownloadState)downloadState
{
    WXYZ_ComicReaderDownloadCollectionViewCell *cell = (WXYZ_ComicReaderDownloadCollectionViewCell *)[self.mainCollectionView cellForItemAtIndexPath:(NSIndexPath *)[self.cellIndexDictionary objectForKey:[WXYZ_UtilsHelper formatStringWithInteger:chapter_id]]];
    cell.cellDownloadState = downloadState;
    [self.selectSourceDictionary setObject:[WXYZ_UtilsHelper formatStringWithInteger:downloadState] forKey:[WXYZ_UtilsHelper formatStringWithInteger:chapter_id]];
}

- (void)netRequest
{
    self.dataSourceArray = [[[WXYZ_ComicDownloadManager sharedManager] getDownloadChapterModelArrayWithProduction_id:self.comicModel.production_id] mutableCopy];
    
    // 章节名称序号排序
    NSString *tmp = @"";
    NSInteger m = self.dataSourceArray.count;
    for (NSInteger i = 0; i < m - 1; i++) {
        for (NSInteger j = 0; j < m- i - 1; j++) {
            if ([[self.dataSourceArray[j] display_label] integerValue] > [[self.dataSourceArray[j + 1] display_label] integerValue]) {
                tmp = self.dataSourceArray[j + 1];
                self.dataSourceArray[j+1] = self.dataSourceArray[j];
                self.dataSourceArray[j] = tmp;
            }
        }
    }
    
    if (self.dataSourceArray.count == 0) {
        [self.navigationController popViewControllerAnimated:NO];
        return;
    }
    
    [self resetSelectSourceDicWithDataSourceArray:[self.dataSourceArray copy] productionType:WXYZ_ProductionTypeComic];
    
    [self reloadToolBar];
    [self.mainCollectionView reloadData];
}

@end

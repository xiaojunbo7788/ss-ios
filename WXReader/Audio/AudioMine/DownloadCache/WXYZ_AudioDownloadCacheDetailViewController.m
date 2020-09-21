//
//  WXYZ_AudioDownloadCacheDetailViewController.m
//  WXReader
//
//  Created by Andrew on 2020/4/1.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AudioDownloadCacheDetailViewController.h"

#import "WXYZ_AudioDownloadTableViewCell.h"

#import "WXYZ_AudioDownloadManager.h"

@interface WXYZ_AudioDownloadCacheDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation WXYZ_AudioDownloadCacheDetailViewController
{
    UIButton *deleteButton;
    WXYZ_CustomButton *selectAllButton;
}

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
}

- (void)createSubviews
{
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.contentInset = UIEdgeInsetsMake(0, 0, PUB_TABBAR_OFFSET, 0);
    [self.view addSubview:self.mainTableView];
    
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_height).with.offset(- PUB_NAVBAR_HEIGHT - PUB_TABBAR_HEIGHT);
    }];
    
    selectAllButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"全选" buttonImageName:@"audio_download_unselect" buttonIndicator:WXYZ_CustomButtonIndicatorImageLeftBothLeft];
    selectAllButton.buttonTitleColor = kBlackColor;
    selectAllButton.buttonTitleFont = kMainFont;
    selectAllButton.graphicDistance = 10;
    selectAllButton.buttonImageScale = 0.4;
    selectAllButton.tag = 0;
    selectAllButton.backgroundColor = [UIColor whiteColor];
    [selectAllButton addTarget:self action:@selector(checkallClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectAllButton];
    
    [selectAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.top.mas_equalTo(self.mainTableView.mas_bottom);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT - PUB_TABBAR_OFFSET);
    }];
    
    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.backgroundColor = kGrayTextLightColor;
    deleteButton.enabled = NO;
    [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [deleteButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [deleteButton.titleLabel setFont:kMainFont];
    [deleteButton addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteButton];
    
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right);
        make.top.mas_equalTo(selectAllButton.mas_top);
        make.width.mas_equalTo(SCREEN_WIDTH / 3);
        make.height.mas_equalTo(selectAllButton.mas_height);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionChapterModel *chapterModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    static NSString *cellName = @"WXYZ_AudioDownloadTableViewCell";
    WXYZ_AudioDownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_AudioDownloadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.isCacheState = YES;
    cell.chapterModel = chapterModel;
    cell.cellDownloadState = [[self.selectSourceDictionary objectForKey:[WXYZ_UtilsHelper formatStringWithInteger:chapterModel.chapter_id]] integerValue];
    cell.hiddenEndLine = self.dataSourceArray.count - 1 == indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//section头间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
//section头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    view.backgroundColor = kGrayViewColor;
    
    UILabel *headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMargin, 0, SCREEN_WIDTH / 2, 30)];
    headerTitleLabel.backgroundColor = [UIColor clearColor];
    headerTitleLabel.font = kFont12;
    headerTitleLabel.text = [NSString stringWithFormat:@"共%@章", [WXYZ_UtilsHelper formatStringWithInteger:self.dataSourceArray.count]];
    headerTitleLabel.textColor = kGrayTextColor;
    [view addSubview:headerTitleLabel];
    
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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionChapterModel *chapterModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    WXYZ_AudioDownloadTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    switch (cell.cellDownloadState) {
        case WXYZ_ProductionDownloadStateDownloaded:
        case WXYZ_ProductionDownloadStateNormal:
            [self setCollectionCellDownloadStateWithChapter_id:chapterModel.chapter_id downloadState:WXYZ_ProductionDownloadStateSelected];
            [self reloadToolBar];
            break;
        case WXYZ_ProductionDownloadStateSelected:
            [self setCollectionCellDownloadStateWithChapter_id:chapterModel.chapter_id downloadState:WXYZ_ProductionDownloadStateNormal];
            [self reloadToolBar];
            break;
        default:
            break;
    }
}

- (void)checkallClick:(WXYZ_CustomButton *)sender
{
    for (NSString *t_chapter_id in self.selectSourceDictionary.allKeys) {
        
        if (!sender.selected) { // 全选状态
            if ([[self.selectSourceDictionary objectForKey:t_chapter_id] integerValue] == WXYZ_ProductionDownloadStateDownloaded || [[self.selectSourceDictionary objectForKey:t_chapter_id] integerValue] == WXYZ_ProductionDownloadStateNormal) {
                [self setCollectionCellDownloadStateWithChapter_id:[t_chapter_id integerValue] downloadState:WXYZ_ProductionDownloadStateSelected];
            }
        } else {
            if ([[self.selectSourceDictionary objectForKey:t_chapter_id] integerValue] == WXYZ_ProductionDownloadStateSelected) {
                [self setCollectionCellDownloadStateWithChapter_id:[t_chapter_id integerValue] downloadState:WXYZ_ProductionDownloadStateNormal];
            }
        }
    }
    
    sender.selected = !sender.selected;

    [self reloadToolBar];
}

- (void)deleteClick
{
    NSMutableArray *t_deleteArr = [NSMutableArray array];
    for (NSString *t_chapter_id in self.selectSourceDictionary.allKeys) {
        if ([[self.selectSourceDictionary objectForKey:t_chapter_id] integerValue] == WXYZ_ProductionDownloadStateSelected) {
            [t_deleteArr addObject:t_chapter_id];
        }
    }
    
    WS(weakSelf)
    [[WXYZ_AudioDownloadManager sharedManager] removeDownloadChaptersWithProduction_id:self.audioModel.production_id chapter_ids:t_deleteArr];
    [WXYZ_AudioDownloadManager sharedManager].downloadDeleteFinishBlock = ^(NSArray * _Nonnull success_chapter_ids, NSArray * _Nonnull fail_chapter) {
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
            case WXYZ_ProductionDownloadStateNormal:
                downloadedIndex ++;
                break;
            case WXYZ_ProductionDownloadStateSelected:
                selectIndex ++;
                break;
                
            default:
                break;
        }
    }
    
    deleteButton.enabled = NO;
    deleteButton.backgroundColor = kGrayTextLightColor;
    
    selectAllButton.selected = NO;
    selectAllButton.enabled = YES;
    selectAllButton.buttonTitle = @"全选";
    selectAllButton.buttonImageName = @"audio_download_unselect";
    
    if (selectIndex > 0 && downloadedIndex == 0) { // 有选中的文件并且没有未选中的文件
        
        deleteButton.enabled = YES;
        deleteButton.backgroundColor = kMainColor;
        
        selectAllButton.selected = YES;
        selectAllButton.buttonTitle = @"取消全选";
        selectAllButton.buttonImageName = @"audio_download_select";

    } else if (downloadedIndex > 0 && selectIndex > 0) { // 有未选中的文件
        deleteButton.enabled = YES;
        deleteButton.backgroundColor = kMainColor;
    }
}

- (void)setCollectionCellDownloadStateWithChapter_id:(NSInteger)chapter_id downloadState:(WXYZ_ProductionDownloadState)downloadState
{
    WXYZ_AudioDownloadTableViewCell *cell = (WXYZ_AudioDownloadTableViewCell *)[self.mainTableView cellForRowAtIndexPath:(NSIndexPath *)[self.cellIndexDictionary objectForKey:[WXYZ_UtilsHelper formatStringWithInteger:chapter_id]]];
    cell.cellDownloadState = downloadState;
    [self.selectSourceDictionary setObject:[WXYZ_UtilsHelper formatStringWithInteger:downloadState] forKey:[WXYZ_UtilsHelper formatStringWithInteger:chapter_id]];
}

- (void)netRequest
{
    self.dataSourceArray = [[[WXYZ_AudioDownloadManager sharedManager] getDownloadChapterModelArrayWithProduction_id:self.audioModel.production_id] mutableCopy];
    
    if (self.dataSourceArray.count == 0) {
        [self.navigationController popViewControllerAnimated:NO];
        return;
    }
    [self resetSelectSourceDicWithDataSourceArray:[self.dataSourceArray copy] productionType:WXYZ_ProductionTypeAudio];
    
    [self reloadToolBar];
    [self.mainTableView reloadData];
}

@end

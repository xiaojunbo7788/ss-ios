//
//  WXYZ_ComicReaderDirectoryViewController.m
//  WXReader
//
//  Created by Andrew on 2019/6/7.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicReaderDirectoryViewController.h"
#import "WXYZ_ComicDirectoryListTableViewCell.h"

#import "WXYZ_ComicDirectoryListModel.h"

#import "WXYZ_ProductionReadRecordManager.h"
#import "WXYZ_ComicDownloadManager.h"

#define MenuButtonHeight 50

@interface WXYZ_ComicReaderDirectoryViewController () <UITableViewDelegate, UITableViewDataSource>
{
    WXYZ_CustomButton *gotoCurrent;
    WXYZ_CustomButton *gotoEnd;
    
    CGFloat beginOffSetY;
}

@property (nonatomic, strong) WXYZ_CustomButton *sortButton;

@property (nonatomic, strong) WXYZ_ComicDirectoryListModel *directoryListModel;

/// 已阅读章节索引
@property (nonatomic, assign) NSInteger readIndex;

/// 按钮触发的滚动事件
@property (nonatomic, assign) BOOL btnTrigger;

@end

@implementation WXYZ_ComicReaderDirectoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
    [self networkRequest];
}

- (void)initialize
{
    self.readIndex = -1;
    [self setNavigationBarTitle:@"目录"];
    
    [self.navigationBar addSubview:self.sortButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequest) name:Notification_Production_Pay_Success object:nil];
    
    [self setEmptyOnView:self.mainTableView title:@"暂无目录列表" buttonTitle:@"" tapBlock:^{
        
    }];
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
        make.height.mas_equalTo(self.view.mas_height).with.offset(- PUB_NAVBAR_HEIGHT);
    }];
    
    gotoCurrent = [[WXYZ_CustomButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - MenuButtonHeight - kHalfMargin, SCREEN_HEIGHT - PUB_TABBAR_HEIGHT - 44 - MenuButtonHeight - kMargin - kHalfMargin, MenuButtonHeight, MenuButtonHeight) buttonTitle:@"当前" buttonImageName:@"comic_goto_current" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
    gotoCurrent.layer.cornerRadius = 25;
    gotoCurrent.layer.borderWidth = 1;
    gotoCurrent.layer.borderColor = kGrayViewColor.CGColor;
    gotoCurrent.clipsToBounds = YES;
    gotoCurrent.backgroundColor = kWhiteColor;
    gotoCurrent.buttonMargin = 8;
    gotoCurrent.buttonTitleFont = kFont11;
    gotoCurrent.graphicDistance = 0;
    gotoCurrent.buttonImageScale = 0.4;
    [gotoCurrent addTarget:self action:@selector(gotoCurrentClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gotoCurrent];
    
    gotoEnd = [[WXYZ_CustomButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - MenuButtonHeight - kHalfMargin, SCREEN_HEIGHT - PUB_TABBAR_HEIGHT - 44 - kMargin, MenuButtonHeight, MenuButtonHeight) buttonTitle:@"到底" buttonImageName:@"comic_goto_bottom" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
    gotoEnd.layer.cornerRadius = 25;
    gotoEnd.layer.borderWidth = 1;
    gotoEnd.layer.borderColor = kGrayViewColor.CGColor;
    gotoEnd.clipsToBounds = YES;
    gotoEnd.tag = 0;
    gotoEnd.backgroundColor = kWhiteColor;
    gotoEnd.buttonMargin = 8;
    gotoEnd.buttonTitleFont = kFont11;
    gotoEnd.graphicDistance = 0;
    gotoEnd.buttonImageScale = 0.4;
    [gotoEnd addTarget:self action:@selector(gotoEndClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gotoEnd];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    beginOffSetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView.contentSize.height - scrollView.contentOffset.y <= CGRectGetHeight(scrollView.bounds)) {// 滑到了底部
        gotoEnd.buttonImageName = @"comic_goto_top";
        gotoEnd.buttonTitle = @"到顶";
        gotoEnd.tag = 1;
    } else if (scrollView.contentOffset.y == 0) {// 滑到了顶部
        gotoEnd.buttonImageName = @"comic_goto_bottom";
        gotoEnd.buttonTitle = @"到底";
        gotoEnd.tag = 0;
    }
    self.btnTrigger = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.btnTrigger) {
        if (scrollView.contentOffset.y > beginOffSetY) {
            gotoEnd.buttonImageName = @"comic_goto_bottom";
            gotoEnd.buttonTitle = @"到底";
            gotoEnd.tag = 0;
        } else if (scrollView.contentOffset.y < beginOffSetY) {
            gotoEnd.buttonImageName = @"comic_goto_top";
            gotoEnd.buttonTitle = @"到顶";
            gotoEnd.tag = 1;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.directoryListModel.chapter_list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionChapterModel *t_chapterList = [self.directoryListModel.chapter_list objectOrNilAtIndex:indexPath.row];
    WXYZ_ComicDirectoryListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_ComicDirectoryListTableViewCell"];
    
    if (!cell) {
        cell = [[WXYZ_ComicDirectoryListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_ComicDirectoryListTableViewCell"];
    }
    cell.chapterModel = t_chapterList;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN)];
    view.backgroundColor = [UIColor whiteColor];
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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, PUB_TABBAR_OFFSET == 0?10:PUB_TABBAR_OFFSET)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    WXYZ_ProductionChapterModel *t_chapterModel = [self.directoryListModel.chapter_list objectOrNilAtIndex:indexPath.row];
    [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] addReadingRecordWithProduction_id:self.comic_id chapter_id:t_chapterModel.chapter_id chapterTitle:t_chapterModel.chapter_title];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Switch_Chapter object:[WXYZ_UtilsHelper formatStringWithInteger:t_chapterModel.chapter_id]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentSize.height - scrollView.contentOffset.y <= CGRectGetHeight(scrollView.bounds)) {// 滑到了底部
        gotoEnd.buttonImageName = @"comic_goto_top";
        gotoEnd.buttonTitle = @"到顶";
        gotoEnd.tag = 1;
    } else if (scrollView.contentOffset.y == 0) {// 滑到了顶部
        gotoEnd.buttonImageName = @"comic_goto_bottom";
        gotoEnd.buttonTitle = @"到底";
        gotoEnd.tag = 0;
    }
    self.btnTrigger = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        if (scrollView.contentSize.height - scrollView.contentOffset.y <= CGRectGetHeight(scrollView.bounds)) {// 滑到了底部
            gotoEnd.buttonImageName = @"comic_goto_top";
            gotoEnd.buttonTitle = @"到顶";
            gotoEnd.tag = 1;
        } else if (scrollView.contentOffset.y == 0) {// 滑到了顶部
            gotoEnd.buttonImageName = @"comic_goto_bottom";
            gotoEnd.buttonTitle = @"到底";
            gotoEnd.tag = 0;
        }
    }
    self.btnTrigger = NO;
}

#pragma mark - 点击事件
- (void)changeDirectorySort:(WXYZ_CustomButton *)sender
{
    if (self.directoryListModel.chapter_list.count == 0) return;
    if (sender.tag == 0) {
        sender.tag = 1;
        sender.buttonImageName = @"comic_reverse_order";
        sender.buttonTitle = @"倒序";
    } else {
        sender.tag = 0;
        sender.buttonImageName = @"comic_positive_order";
        sender.buttonTitle = @"正序";
    }

    self.directoryListModel.chapter_list = [[self.directoryListModel.chapter_list reverseObjectEnumerator] allObjects];
    self.directoryListModel = self.directoryListModel;// 更新阅读章节下标索引
    
    [self.mainTableView reloadData];
}

- (void)gotoCurrentClick:(UIButton *)sender
{
    if (self.directoryListModel.chapter_list.count == 0) return;
    if (self.readIndex) {
        [self.mainTableView scrollToRow:self.readIndex inSection:0 atScrollPosition:UITableViewScrollPositionTop animated:NO];
    } else {
        [self.mainTableView setContentOffset:CGPointMake(0,0) animated:NO];
    }
}

- (void)gotoEndClick:(UIButton *)sender
{
    self.btnTrigger = YES;
    if (self.directoryListModel.chapter_list.count == 0) return;
    if (sender.tag == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Directory_Move object:@"bottom"];
        [self.mainTableView scrollToBottomAnimated:YES];
        gotoEnd.buttonImageName = @"comic_goto_top";
        gotoEnd.buttonTitle = @"到顶";
        gotoEnd.tag = 1;
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Directory_Move object:@"top"];
        [self.mainTableView scrollToTopAnimated:YES];
        gotoEnd.buttonImageName = @"comic_goto_bottom";
        gotoEnd.buttonTitle = @"到底";
        gotoEnd.tag = 0;
    }
}

#pragma mark - 懒加载
- (WXYZ_CustomButton *)sortButton
{
    if (!_sortButton) {
        _sortButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - kHalfMargin - 60, PUB_NAVBAR_HEIGHT - 30 - kQuarterMargin, 60, 30) buttonTitle:@"正序" buttonSubTitle:@"" buttonImageName:@"comic_positive_order" buttonIndicator:WXYZ_CustomButtonIndicatorImageRightBothRight showMaskView:NO];
        _sortButton.buttonImageScale = 0.4;
        _sortButton.buttonTitleFont = kFont11;
        _sortButton.graphicDistance = 5;
        _sortButton.buttonTitleColor = kGrayTextColor;
        _sortButton.tag = 0;
        [_sortButton addTarget:self action:@selector(changeDirectorySort:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sortButton;
}

- (void)setDirectoryListModel:(WXYZ_ComicDirectoryListModel *)directoryListModel {
    _directoryListModel = directoryListModel;
    
    // 计算已读章节的位置
    NSInteger readIndex = [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] getReadingRecordChapter_idWithProduction_id:self.comic_id];
    NSArray<NSNumber *> *t_arr = [self.directoryListModel.chapter_list valueForKeyPath:@"chapter_id"];
    self.readIndex = [t_arr indexOfObject:@(readIndex)];
    if (self.readIndex == NSNotFound) {
        self.readIndex = -1;
    }
}

- (void)networkRequest
{
    if ([WXYZ_NetworkReachabilityManager networkingStatus] == NO) {
        WXYZ_ProductionModel *comicModel = [[WXYZ_DownloadHelper sharedManager] getDownloadProductionModelWithProduction_id:self.comic_id productionType:WXYZ_ProductionTypeComic];
        
        self.directoryListModel = [[WXYZ_ComicDirectoryListModel alloc] init];
        self.directoryListModel.chapter_list = comicModel.chapter_list;
        [self.mainTableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [gotoCurrent sendActionsForControlEvents:UIControlEventTouchUpInside];
        });
        
        if (self.directoryListModel.chapter_list.count == 0) {
            self.mainTableView.scrollEnabled = NO;
        } else {
            self.mainTableView.scrollEnabled = YES;
        }
        [self.mainTableView ly_endLoading];
        return;
    }
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POSTQuick:Comic_Catalog parameters:@{@"comic_id":[WXYZ_UtilsHelper formatStringWithInteger:self.comic_id]} model:WXYZ_ComicDirectoryListModel.class success:^(BOOL isSuccess, WXYZ_ComicDirectoryListModel *_Nullable t_model, BOOL isCache, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            weakSelf.directoryListModel = t_model;
            [weakSelf.mainTableView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [gotoCurrent sendActionsForControlEvents:UIControlEventTouchUpInside];
            });
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg ?: @"请求失败"];
        }
        if (weakSelf.directoryListModel.chapter_list.count == 0) {
            weakSelf.mainTableView.scrollEnabled = NO;
        } else {
            weakSelf.mainTableView.scrollEnabled = YES;
        }
        [weakSelf.mainTableView ly_endLoading];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (weakSelf.directoryListModel.chapter_list.count == 0) {
            weakSelf.mainTableView.scrollEnabled = NO;
        } else {
            weakSelf.mainTableView.scrollEnabled = YES;
        }
        [weakSelf.mainTableView ly_endLoading];
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:@"请求失败"];
    }];
}

@end

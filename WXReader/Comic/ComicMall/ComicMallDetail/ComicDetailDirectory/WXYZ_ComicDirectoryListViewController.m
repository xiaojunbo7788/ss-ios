//
//  WXYZ_ComicDirectoryListViewController.m
//  WXReader
//
//  Created by Andrew on 2019/5/29.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicDirectoryListViewController.h"
#import "WXYZ_ComicDirectoryListTableViewCell.h"

#import "WXYZ_ComicReaderViewController.h"

#import "WXYZ_ProductionReadRecordManager.h"

#define MenuButtonHeight 50

@interface WXYZ_ComicDirectoryListViewController () <UITableViewDelegate, UITableViewDataSource>
{
    WXYZ_CustomButton *gotoCurrent;
    WXYZ_CustomButton *gotoEnd;
    
    CGFloat beginOffSetY;
    
    BOOL clickGotoButton;
}

@property (nonatomic, strong) UILabel *headTitleLabel;

@property (nonatomic, strong) WXYZ_CustomButton *sortButton;

/// 已阅读章节索引
@property (nonatomic, assign) NSInteger readIndex;

@end

@implementation WXYZ_ComicDirectoryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
}

- (void)initialize
{
    // 计算已读章节的位置
    NSInteger readIndex = [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] getReadingRecordChapter_idWithProduction_id:self.comicModel.production_id];
    NSArray<NSNumber *> *t_arr = [self.comicModel.chapter_list valueForKeyPath:@"chapter_id"];
    self.readIndex = [t_arr indexOfObject:@(readIndex)];
    if (self.readIndex == NSNotFound) {
        self.readIndex = -1;
    }
    [self hiddenNavigationBar:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRecordData) name:NSNotification_Updata_Read_Record object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.mainTableView reloadData];
}

- (void)createSubviews
{
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    [self.view addSubview:self.mainTableView];
    
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    gotoCurrent = [[WXYZ_CustomButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - MenuButtonHeight - kHalfMargin, SCREEN_HEIGHT - Comic_Detail_HeaderView_Height - PUB_TABBAR_HEIGHT - 44 - 44 - MenuButtonHeight - kMargin - kHalfMargin, MenuButtonHeight, MenuButtonHeight) buttonTitle:@"当前" buttonImageName:@"comic_goto_current" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
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
    
    gotoEnd = [[WXYZ_CustomButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - MenuButtonHeight - kHalfMargin, SCREEN_HEIGHT - Comic_Detail_HeaderView_Height - PUB_TABBAR_HEIGHT - 44 - 44 - kMargin, MenuButtonHeight, MenuButtonHeight) buttonTitle:@"到底" buttonImageName:@"comic_goto_bottom" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom];
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
    
    [self setEmptyOnView:self.mainTableView title:@"暂无目录列表" buttonTitle:@"" tapBlock:^{}];
    if (self.comicModel.chapter_list.count == 0) {
        gotoCurrent.hidden = YES;
        gotoEnd.hidden = YES;
        self.sortButton.hidden = YES;
        self.headTitleLabel.hidden = YES;
    } else {
        gotoCurrent.hidden = NO;
        gotoEnd.hidden = NO;
        self.sortButton.hidden = NO;
        self.headTitleLabel.hidden = NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mainTableView ly_endLoading];
    });
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    beginOffSetY = scrollView.contentOffset.y;
    clickGotoButton = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!clickGotoButton) {
        if ([scrollView isEqual:self.mainTableView]) {
            if (!self.canScroll) {
                scrollView.contentOffset = CGPointZero;
            }
            if (scrollView.contentOffset.y <= 0) {
                self.canScroll = NO;
                scrollView.contentOffset = CGPointZero;
                //到顶通知父视图改变状态
                [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Can_Leave_Top object:@YES];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Can_Leave_Top object:@NO];
            }
        }
        
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
}

- (void)setContentOffSetY:(CGFloat)contentOffSetY
{
    gotoCurrent.frame = CGRectMake(SCREEN_WIDTH - MenuButtonHeight - kHalfMargin, SCREEN_HEIGHT - Comic_Detail_HeaderView_Height - PUB_TABBAR_HEIGHT - 44 - 44 - MenuButtonHeight - kMargin - kHalfMargin + contentOffSetY, MenuButtonHeight, MenuButtonHeight);
    gotoEnd.frame = CGRectMake(SCREEN_WIDTH - MenuButtonHeight - kHalfMargin, SCREEN_HEIGHT - Comic_Detail_HeaderView_Height - PUB_TABBAR_HEIGHT - 44 - 44 - kMargin + contentOffSetY, MenuButtonHeight, MenuButtonHeight);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.comicModel.chapter_list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionChapterModel *t_chapterList = [self.comicModel.chapter_list objectOrNilAtIndex:indexPath.row];
    WXYZ_ComicDirectoryListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_ComicDirectoryListTableViewCell"];
    
    if (!cell) {
        cell = [[WXYZ_ComicDirectoryListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_ComicDirectoryListTableViewCell"];
    }
    cell.chapterModel = t_chapterList;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    view.backgroundColor = [UIColor whiteColor];
    
    [view addSubview:self.headTitleLabel];
    
    [view addSubview:self.sortButton];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.readIndex = indexPath.row;
    WXYZ_ProductionChapterModel *t_chapterModel = [self.comicModel.chapter_list objectOrNilAtIndex:indexPath.row];
    [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] addReadingRecordWithProduction_id:t_chapterModel.production_id chapter_id:t_chapterModel.chapter_id chapterTitle:t_chapterModel.chapter_title];
    
    WXYZ_ComicReaderViewController *vc = [[WXYZ_ComicReaderViewController alloc] init];
    vc.comicProductionModel = self.comicModel;
    vc.chapter_id = t_chapterModel.chapter_id;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 点击事件
- (void)changeDirectorySort:(WXYZ_CustomButton *)sender
{
    if (self.comicModel.chapter_list.count == 0) return;
    if (sender.tag == 0) {
        sender.tag = 1;
        sender.buttonImageName = @"comic_reverse_order";
        sender.buttonTitle = @"倒序";
    } else {
        sender.tag = 0;
        sender.buttonImageName = @"comic_positive_order";
        sender.buttonTitle = @"正序";
    }
    self.comicModel.chapter_list = [[self.comicModel.chapter_list reverseObjectEnumerator] allObjects];
    // 计算已读章节的位置
    NSInteger readIndex = [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] getReadingRecordChapter_idWithProduction_id:self.comicModel.production_id];
    NSArray<NSNumber *> *t_arr = [self.comicModel.chapter_list valueForKeyPath:@"chapter_id"];
    self.readIndex = [t_arr indexOfObject:@(readIndex)];
    if (self.readIndex == NSNotFound) {
        self.readIndex = -1;
    }
    [self.mainTableView reloadData];
}

- (void)gotoCurrentClick:(UIButton *)sender
{
    if (self.comicModel.chapter_list.count == 0) return;
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Directory_Move object:@"bottom"];
    if (self.readIndex != -1) {
        [self.mainTableView scrollToRow:self.readIndex inSection:0 atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)gotoEndClick:(UIButton *)sender
{
    if (self.comicModel.chapter_list.count == 0) return;
    clickGotoButton = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Can_Leave_Top object:@NO];
    if (sender.tag == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Directory_Move object:@"bottom"];
        [self.mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.comicModel.chapter_list.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        gotoEnd.buttonImageName = @"comic_goto_top";
        gotoEnd.buttonTitle = @"到顶";
        gotoEnd.tag = 1;
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Directory_Move object:@"top"];
        [self.mainTableView setContentOffset:CGPointMake(0,0) animated:YES];
        gotoEnd.buttonImageName = @"comic_goto_bottom";
        gotoEnd.buttonTitle = @"到底";
        gotoEnd.tag = 0;
    }
}

#pragma mark - 懒加载
- (UILabel *)headTitleLabel
{
    if (!_headTitleLabel) {
        _headTitleLabel = [[UILabel alloc] init];
        _headTitleLabel.text = self.comicModel.flag?:@"";
        _headTitleLabel.frame = CGRectMake(kHalfMargin, 0, SCREEN_WIDTH - kMargin, 44);
        _headTitleLabel.font = kFont11;
        _headTitleLabel.textColor = kGrayTextColor;
        _headTitleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _headTitleLabel;
}

- (WXYZ_CustomButton *)sortButton
{
    if (!_sortButton) {
        _sortButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - kHalfMargin - 60, 7, 60, 30) buttonTitle:@"正序" buttonSubTitle:@"" buttonImageName:@"comic_positive_order" buttonIndicator:WXYZ_CustomButtonIndicatorImageRightBothRight showMaskView:NO];
        _sortButton.buttonImageScale = 0.4;
        _sortButton.buttonTitleFont = kFont11;
        _sortButton.graphicDistance = 5;
        _sortButton.buttonTitleColor = kGrayTextColor;
        _sortButton.tag = 0;
        [_sortButton addTarget:self action:@selector(changeDirectorySort:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sortButton;
}

- (void)setComicModel:(WXYZ_ProductionModel *)comicModel
{
    _comicModel = comicModel;
    
    if (self.sortButton.tag == 1) {
        self.comicModel.chapter_list = [[comicModel.chapter_list reverseObjectEnumerator] allObjects];
    }
    [self reloadRecordData];
}

- (void)reloadRecordData
{
    [self.mainTableView reloadData];
}

@end

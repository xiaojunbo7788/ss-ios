//
//  WXYZ_BookMallDetailViewController.m
//  WXReader
//
//  Created by Andrew on 2018/5/23.
//  Copyright © 2018年 Andrew. All rights reserved.
// 小说详情
//


#import "WXYZ_CommentsViewController.h"
#import "WXYZ_TaskViewController.h"
#import "WXYZ_DirectoryViewController.h"

#import "WXYZ_BookMallDetailHeaderViewTableViewCell.h"
#import "WXYZ_BookMallStyleSingleTableViewCell.h"
#import "WXYZ_BookMallStyleDoubleTableViewCell.h"
#import "WXYZ_BookMallStyleMixtureTableViewCell.h"
#import "WXYZ_BookMallStyleMixtureMoreTableViewCell.h"
#import "WXYZ_CommentsTableViewCell.h"
#import "WXYZ_PublicADStyleTableViewCell.h"
#import "WXYZ_BookMallDetailDirectoryTableViewCell.h"
#import "WXYZ_ComicInfoListTableViewCell.h"
#import "WXYZ_ComicInfoListStringTableViewCell.h"
#import "WXYZ_BookMallDetailIntroductionTableViewCell.h"

#import "WXYZ_BookReaderViewController.h"

#import "WXYZ_ProductionCollectionManager.h"
#import "WXYZ_ProductionReadRecordManager.h"
#import "WXYZ_BookDownloadManager.h"
#import "WXYZ_ReaderBookManager.h"

#import "WXYZ_BookDetailModel.h"

#import "WXYZ_ReaderSettingHelper.h"

#import "WXYZ_CatalogModel.h"

#if WX_W_Share_Mode || WX_Q_Share_Mode
    #import "WXYZ_ShareManager.h"
#endif

#if WX_Enable_Third_Party_Ad
    #import "AppDelegate.h"

    #import <BUAdSDK/BUBannerAdView.h>
#endif

#if WX_Download_Mode
    #import "WXYZ_BookDownloadMenuBar.h"
    #import "WXYZ_DownloadCacheViewController.h"
#endif

#if WX_Enable_Ai
    #import "WXYZ_BookAiPlayPageViewController.h"
#endif

@interface WXYZ_BookMallDetailViewController () <UITableViewDelegate, UITableViewDataSource
#if WX_Enable_Third_Party_Ad
,BUBannerAdViewDelegate>
#else
>
#endif

@property (nonatomic, strong) WXYZ_BookDetailModel *bookModel;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UIButton *sectionBottomCommentButton;

#if WX_W_Share_Mode || WX_Q_Share_Mode
@property (nonatomic, weak) UIButton *shareButton;
#endif

@property (nonatomic, strong) UIButton *readBookButton;

@property (nonatomic, weak) UIButton *addBookRack;

@property (nonatomic, strong) NSArray *sectionTagArray;

@property (nonatomic, strong) NSMutableArray *detailListArray;

#if WX_Download_Mode
@property (nonatomic, weak) UIButton *downloadButton;
#endif

#if WX_Enable_Third_Party_Ad
@property (nonatomic, weak) BUBannerAdView *bannerView;
#endif

@property (nonatomic, assign) BOOL needRefresh;

@end

@implementation WXYZ_BookMallDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
    [self netRequest];
}

- (void)initialize
{
    self.needRefresh = YES;
    [self hiddenSeparator];
    
    [self setStatusBarLightContentStyle];
    self.navigationBar.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    self.navigationBar.navTitleLabel.textColor = kBlackColor;
    self.navigationBar.navTitleLabel.alpha = 0.0;
    [self.navigationBar setLightLeftButton];
    
#if WX_Enable_Ai
    [WXYZ_BookAiPlayPageViewController sharedManager];
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self changeNavBarColorState:self.mainTableViewGroup.contentOffset.y withAnimate:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Hidden_Tabbar object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToDownloadController) name:Notification_Push_To_Download object:nil];
    
    if (self.addBookRack) {
        if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] isCollectedWithProductionModel:self.bookModel.book]) {
            self.addBookRack.enabled = NO;
            [self.addBookRack setTitle:@"已收藏" forState:UIControlStateNormal];
            [self.addBookRack setTitleColor:kMainColorAlpha(0.5) forState:UIControlStateNormal];
            self.addBookRack.userInteractionEnabled = NO;
        } else {
            self.addBookRack.enabled = YES;
            [self.addBookRack setTitle:@"收藏" forState:UIControlStateNormal];
            [self.addBookRack setTitleColor:kMainColor forState:UIControlStateNormal];
            [self.addBookRack addTarget:self action:@selector(addBookRackClick:) forControlEvents:UIControlEventTouchUpInside];
            self.addBookRack.userInteractionEnabled = YES;
        }
        
        if ([[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] productionHasReadedWithProduction_id:self.bookModel.book.production_id]) {
            [self.readBookButton setTitle:@"继续阅读" forState:UIControlStateNormal];
        } else {
            [self.readBookButton setTitle:@"开始阅读" forState:UIControlStateNormal];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Notification_Reload_BookDetail object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Notification_Push_To_Download object:nil];
}

- (void)createSubviews
{
#if WX_W_Share_Mode || WX_Q_Share_Mode
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.shareButton = shareButton;
    shareButton.hidden = YES;
    shareButton.adjustsImageWhenHighlighted = NO;
    shareButton.tintColor = kWhiteColor;
    [shareButton setImage:[[UIImage imageNamed:@"public_share"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [shareButton setImageEdgeInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
    [shareButton addTarget:self action:@selector(UMShareClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:shareButton];
    
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.navigationBar.mas_right).with.offset(- kHalfMargin);
        make.bottom.mas_equalTo(self.navigationBar.mas_bottom).with.offset(- 7);
        make.width.height.mas_equalTo(30);
    }];
#endif
    
#if WX_Download_Mode
    if ([WXYZ_UtilsHelper getAiReadSwitchState]) {
        UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.downloadButton = downloadButton;
        downloadButton.hidden = YES;
        downloadButton.adjustsImageWhenHighlighted = NO;
        downloadButton.tintColor = kWhiteColor;
        [downloadButton setImage:[[UIImage imageNamed:@"public_download"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [downloadButton setImageEdgeInsets:UIEdgeInsetsMake(6, 6, 5.5, 5.5)];
        [downloadButton addTarget:self action:@selector(downloadClick) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationBar addSubview:downloadButton];
        
        [downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
#if WX_W_Share_Mode || WX_Q_Share_Mode
            make.right.mas_equalTo(shareButton.mas_left).with.offset(- kHalfMargin);
#else
            make.right.mas_equalTo(self.navigationBar.mas_right).with.offset(- kHalfMargin);
#endif
            make.bottom.mas_equalTo(self.navigationBar.mas_bottom).with.offset(- 7);
            make.width.height.mas_equalTo(30);
        }];
    }
#endif
    
    self.mainTableViewGroup.delegate = self;
    self.mainTableViewGroup.dataSource = self;
    [self.view addSubview:self.mainTableViewGroup];
    
    [self.mainTableViewGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_height);
    }];
    
    WS(weakSelf)
    [self.mainTableViewGroup addHeaderRefreshWithRefreshingBlock:^{
        [weakSelf netRequest];
    }];
}

- (void)createToolBar
{
    [self.mainTableViewGroup mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.view.mas_height).with.offset(- PUB_TABBAR_HEIGHT);
    }];
    
    UIView *toolBarView = [[UIView alloc] init];
    toolBarView.backgroundColor = kGrayViewColor;
    [self.view addSubview:toolBarView];
    
    [toolBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(self.view.mas_bottom);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT);
    }];
    
    // 加入书架
    UIButton *addBookRack = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addBookRack = addBookRack;
    if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] isCollectedWithProductionModel:self.bookModel.book]) {
        self.addBookRack.enabled = NO;
        [addBookRack setTitle:@"已收藏" forState:UIControlStateNormal];
        [addBookRack setTitleColor:kMainColorAlpha(0.5) forState:UIControlStateNormal];
    } else {
        self.addBookRack.enabled = YES;
        [addBookRack setTitle:@"收藏" forState:UIControlStateNormal];
        [addBookRack setTitleColor:kMainColor forState:UIControlStateNormal];
        [addBookRack addTarget:self action:@selector(addBookRackClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    addBookRack.backgroundColor = kGrayViewColor;
    [addBookRack.titleLabel setFont:kMainFont];
    [addBookRack addBorderLineWithBorderWidth:0.5 borderColor:kGrayViewColor cornerRadius:0 borderType:UIBorderSideTypeRight];
    [toolBarView addSubview:addBookRack];
    
    // 开始阅读
    self.readBookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] productionHasReadedWithProduction_id:self.bookModel.book.production_id]) {
        [self.readBookButton setTitle:@"继续阅读" forState:UIControlStateNormal];
    } else {
        [self.readBookButton setTitle:@"开始阅读" forState:UIControlStateNormal];
    }
    self.readBookButton.backgroundColor = kMainColor;
    [self.readBookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.readBookButton.titleLabel setFont:[UIFont boldSystemFontOfSize:kFontSize13]];
    [self.readBookButton addTarget:self action:@selector(readBookClick) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:self.readBookButton];
    
    // 听书
    UIButton *audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    audioButton.backgroundColor = kGrayViewColor;
    [audioButton setTitleColor:kMainColor forState:UIControlStateNormal];
    [audioButton.titleLabel setFont:kMainFont];
    [audioButton addTarget:self action:@selector(audioButtonClick:) forControlEvents:UIControlEventTouchUpInside];
#if WX_Enable_Ai
    if ([WXYZ_UtilsHelper getAiReadSwitchState]) {
        [audioButton setTitle:@"听书" forState:UIControlStateNormal];
    } else {
        [audioButton setTitle:@"下载书籍" forState:UIControlStateNormal];
    }
#else
    [audioButton setTitle:@"下载书籍" forState:UIControlStateNormal];
#endif
    
    [toolBarView addSubview:audioButton];
    
    NSArray *viewArray = @[audioButton, self.readBookButton, addBookRack];
    
    [viewArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
    [viewArray mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.mas_equalTo(0);
       make.height.mas_equalTo(toolBarView.mas_height).with.offset(- PUB_TABBAR_OFFSET);
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSMutableArray *t_sectionTagArray = [NSMutableArray array];
    
    // 简介
    if (self.bookModel.book.production_descirption.length > 0 || self.bookModel.book.name.length > 0) {
        [t_sectionTagArray addObject:@"descirption"];
    }
    
    // 广告
    if (self.bookModel.advert.ad_type != 0) {
        [t_sectionTagArray addObject:@"ad"];
    }
    
    // 评论
#if WX_Comments_Mode
    [t_sectionTagArray addObject:@"comment"];
#endif
    
    // 猜你喜欢
    if (self.bookModel.label.count > 0) {
        [t_sectionTagArray addObject:@"label"];
    }
    
    self.sectionTagArray = [t_sectionTagArray copy];
    
    return t_sectionTagArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if ([[self.sectionTagArray objectAtIndex:section] isEqualToString:@"descirption"]) {
        
        return self.detailListArray.count + 2;
    }
    
#if WX_Comments_Mode
    if ([[self.sectionTagArray objectAtIndex:section] isEqualToString:@"ad"]) {
        return 1;
    }
#endif
    
    if ([[self.sectionTagArray objectAtIndex:section] isEqualToString:@"comment"]) {
        return self.bookModel.comment.count;
    }
    
    if ([[self.sectionTagArray objectAtIndex:section] isEqualToString:@"label"]) {
        return self.bookModel.label.count;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.sectionTagArray objectAtIndex:indexPath.section] isEqualToString:@"descirption"]) {
        
        if (indexPath.row == 0) {
            return [self createHeaderViewCellWithTableView:tableView atIndexPath:indexPath labelModel:self.bookModel.book];
        }
        
        if (indexPath.row < self.detailListArray.count) {
            return [self createInfoListStyleCellWithTableView:tableView atIndexPath:indexPath];
        }
        
        if (indexPath.row - self.detailListArray.count == 1) {
            return [self createDirectoryCellWithTableView:tableView atIndexPath:indexPath labelModel:self.bookModel.book];
        }
        return [self createIntroductionCellWithTableView:tableView atIndexPath:indexPath labelModel:self.bookModel.book];
        
    }
    
    if ([[self.sectionTagArray objectAtIndex:indexPath.section] isEqualToString:@"ad"]) {
        return [self createADCellWithTableView:tableView atIndexPath:indexPath];
    }
    
#if WX_Comments_Mode
    if ([[self.sectionTagArray objectAtIndex:indexPath.section] isEqualToString:@"comment"]) {
        WXYZ_CommentsDetailModel *commentModel = [self.bookModel.comment objectOrNilAtIndex:indexPath.row];
        return [self createCommentCellWithTableView:tableView atIndexPath:indexPath labelModel:commentModel];
    }
#endif
    
    if ([[self.sectionTagArray objectAtIndex:indexPath.section] isEqualToString:@"label"]) {
        WXYZ_MallCenterLabelModel *labelModel = [self.bookModel.label objectOrNilAtIndex:indexPath.row];
        return [self createCellWithTabelView:tableView indexPath:indexPath labelModel:labelModel];
    }
    
    return [[UITableViewCell alloc] init];
}

- (UITableViewCell *)createHeaderViewCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath labelModel:(WXYZ_ProductionModel *)bookModel
{
    static NSString *cellName = @"WXYZ_BookMallDetailHeaderViewTableViewCell";
    WXYZ_BookMallDetailHeaderViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_BookMallDetailHeaderViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.bookModel = bookModel;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)createIntroductionCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath labelModel:(WXYZ_ProductionModel *)bookModel
{
    static NSString *cellName = @"WXYZ_BookMallDetailIntroductionTableViewCell";
    WXYZ_BookMallDetailIntroductionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_BookMallDetailIntroductionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.bookModel = bookModel;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)createDirectoryCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath labelModel:(WXYZ_ProductionModel *)bookModel
{
    WS(weakSelf)
    static NSString *cellName = @"WXYZ_BookMallDetailDirectoryTableViewCell";
    WXYZ_BookMallDetailDirectoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_BookMallDetailDirectoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.bookModel = bookModel;
    cell.catalogueButtonClickBlock = ^{
        if (!weakSelf.bookModel.book) return;
        WXYZ_DirectoryViewController *vc = [[WXYZ_DirectoryViewController alloc] init];
        vc.isReader = weakSelf.isReader;
        vc.bookModel = weakSelf.bookModel.book;
        vc.isBookDetailPush = YES;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)createInfoListStyleCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *t_listDic = [self.detailListArray objectAtIndex:indexPath.row];
    NSString *key = [[t_listDic allKeys] firstObject];
    id value = [t_listDic objectForKey:key];
    
    if ([value isKindOfClass:[NSArray class]]) {
        static NSString *cellName = @"WXYZ_ComicInfoListTableViewCell";
        WXYZ_ComicInfoListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (!cell) {
            cell = [[WXYZ_ComicInfoListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        cell.leftTitleString = key;
        cell.detailArray = value;
        cell.hiddenEndLine = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        static NSString *cellName = @"WXYZ_ComicInfoListStringTableViewCell";
        WXYZ_ComicInfoListStringTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (!cell) {
            cell = [[WXYZ_ComicInfoListStringTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        cell.leftTitleString = key;
        cell.rightTitleString = value;
        cell.hiddenEndLine = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (UITableViewCell *)createCellWithTabelView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath labelModel:(WXYZ_MallCenterLabelModel *)labelModel
{
    Class cellClass = WXYZ_BookMallStyleSingleTableViewCell.class;
    switch (labelModel.style) {
        case 1:
             cellClass = WXYZ_BookMallStyleSingleTableViewCell.class;
            break;
        case 2:
            cellClass = WXYZ_BookMallStyleDoubleTableViewCell.class;
            break;
        case 3:
            cellClass = WXYZ_BookMallStyleMixtureTableViewCell.class;
            break;
        case 4:
            cellClass = WXYZ_BookMallStyleMixtureMoreTableViewCell.class;
            break;
            
        default:
            cellClass = WXYZ_BookMallStyleSingleTableViewCell.class;
            break;
    }
    
    WS(weakSelf)
    WXYZ_BookMallBasicStyleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(cellClass)];
    if (!cell) {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(cellClass)];
    }
    
    cell.labelModel = labelModel;
    cell.cellDidSelectItemBlock = ^(NSInteger production_id) {
        WXYZ_BookMallDetailViewController *vc = [[WXYZ_BookMallDetailViewController alloc] init];
        vc.book_id = production_id;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)createCommentCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath labelModel:(WXYZ_CommentsDetailModel *)commentModel
{
    static NSString *cellName = @"WXYZ_CommentsTableViewCell";
    WXYZ_CommentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_CommentsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.commentModel = commentModel;
    cell.hiddenEndLine = NO;
    [cell setIsPreview:YES lastRow:(self.bookModel.comment.count - 1 == indexPath.row)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)createADCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"WXYZ_PublicADStyleTableViewCell";
    WXYZ_PublicADStyleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_PublicADStyleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    [cell setAdModel:self.bookModel.advert refresh:self.needRefresh];
    cell.mainTableView = tableView;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == (self.bookModel.advert.ad_type == 0?1:2)) {
        WXYZ_CommentsDetailModel *t_model = [self.bookModel.comment objectOrNilAtIndex:indexPath.row];
        [self commentWithComment_id:t_model.comment_id];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pointY = scrollView.contentOffset.y;
    [self changeNavBarColorState:pointY withAnimate:YES];
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!self.bookModel) {
        return CGFLOAT_MIN;
    }
    
#if WX_Comments_Mode
    if ([[self.sectionTagArray objectAtIndex:section] isEqualToString:@"comment"]) {
        return 54;
    }
#endif
    
    return CGFLOAT_MIN;
}

//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN)];
        view.backgroundColor = kWhiteColor;
        
        if ([[self.sectionTagArray objectAtIndex:section] isEqualToString:@"comment"]) {
            view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 54);
            
            if (self.bookModel.advert.ad_type == 0) {
                UIView *grayLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
                grayLine.backgroundColor = kGrayViewColor;
                [view addSubview:grayLine];
            }
            
            UIImageView *mainTitleHoldView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comic_label_hold"]];
            mainTitleHoldView.frame = CGRectMake(kHalfMargin, 10 + 22 - kMargin / 2, kMargin, kMargin);
            [view addSubview:mainTitleHoldView];

            UILabel *t_title = [[UILabel alloc] initWithFrame:CGRectMake(kMargin + kHalfMargin + kQuarterMargin, 10, SCREEN_WIDTH - kMargin, 44)];
            t_title.textAlignment = NSTextAlignmentLeft;
            t_title.textColor = kBlackColor;
            t_title.backgroundColor = [UIColor whiteColor];
            t_title.font = kBoldFont16;
            t_title.text = @"最新书评";
            [t_title addBorderLineWithBorderWidth:0.5 borderColor:kGrayLineColor cornerRadius:0 borderType:UIBorderSideTypeBottom];
            [view addSubview:t_title];
            
            UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            commentButton.frame = CGRectMake(SCREEN_WIDTH - 50 - kHalfMargin, 10, 50, 43);
            commentButton.backgroundColor = [UIColor whiteColor];
            [commentButton setTitle:@"写评论" forState:UIControlStateNormal];
            [commentButton setTitleColor:kMainColor forState:UIControlStateNormal];
            [commentButton.titleLabel setFont:kFont12];
            [commentButton addTarget:self action:@selector(commentClick) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:commentButton];
        }
        
        return view;
    }

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (!self.bookModel) {
        return CGFLOAT_MIN;
    }
    
#if WX_Comments_Mode
    if ([[self.sectionTagArray objectAtIndex:section] isEqualToString:@"comment"]) {
        return 64;
    }
#endif
    return CGFLOAT_MIN;
}

//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN)];
    view.backgroundColor = kWhiteColor;
    
    if ([[self.sectionTagArray objectAtIndex:section] isEqualToString:@"comment"]) {
        if (self.bookModel.book.total_comment == 0) {
            [self.sectionBottomCommentButton setTitle:@"暂无评论，点击抢沙发" forState:UIControlStateNormal];
        } else {
            [self.sectionBottomCommentButton setTitle:[NSString stringWithFormat:@"查看全部评论(%@条)", [WXYZ_UtilsHelper formatStringWithInteger:self.bookModel.book.total_comment]] forState:UIControlStateNormal];
        }
        
        [view addSubview:self.sectionBottomCommentButton];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.sectionBottomCommentButton.frame) + kHalfMargin, SCREEN_WIDTH, 10)];
        lineView.backgroundColor = kGrayViewColor;
        [view addSubview:lineView];
    }
    return view;
}

- (UIButton *)sectionBottomCommentButton
{
    if (!_sectionBottomCommentButton) {
        
        _sectionBottomCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sectionBottomCommentButton.frame = CGRectMake(SCREEN_WIDTH / 4, kHalfMargin, SCREEN_WIDTH / 2, 36);
        _sectionBottomCommentButton.backgroundColor = [UIColor whiteColor];
        _sectionBottomCommentButton.layer.cornerRadius = 18;
        _sectionBottomCommentButton.layer.borderColor = kMainColor.CGColor;
        _sectionBottomCommentButton.layer.borderWidth = 0.4f;
        [_sectionBottomCommentButton setTitleColor:kMainColor forState:UIControlStateNormal];
        [_sectionBottomCommentButton.titleLabel setFont:kFont12];
        [_sectionBottomCommentButton addTarget:self action:@selector(commentClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sectionBottomCommentButton;
}


- (void)pushToDownloadController
{
#if WX_Download_Mode
    WXYZ_DownloadCacheViewController *vc = [[WXYZ_DownloadCacheViewController alloc] init];
    vc.onlyBookMode = YES;
    [self.navigationController pushViewController:vc animated:YES];
#endif
}

- (void)commentClick
{
    [self commentWithComment_id:0];
}

- (void)commentWithComment_id:(NSInteger)comment_id
{
    WS(weakSelf)
    WXYZ_CommentsViewController *vc = [[WXYZ_CommentsViewController alloc] init];
    vc.production_id = self.book_id;
    vc.comment_id = comment_id;
    vc.productionType = WXYZ_ProductionTypeBook;
    vc.commentsSuccessBlock = ^(WXYZ_CommentsDetailModel *commentModel) {
        
        WXYZ_BookDetailModel *t_model = weakSelf.bookModel;
        
        // 评论数++
        t_model.book.total_comment ++;
        
        // 评论数组model添加
        NSMutableArray *t_array = [NSMutableArray arrayWithArray:t_model.comment];
        [t_array insertObject:commentModel atIndex:0];
        t_model.comment = [t_array copy];
        
        weakSelf.bookModel = t_model;
        
        [weakSelf.mainTableViewGroup reloadData];
        
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)audioButtonClick:(UIButton *)sender
{
    if ([WXYZ_NetworkReachabilityManager networkingStatus] == NO) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"听书功能仅支持在线使用"];
        return;
    }
    
    if (self.bookModel.book.chapter_list.count == 0) {
        [sender setTitleColor:kGrayViewColor forState:UIControlStateNormal];
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.frame = CGRectMake(0, 0, 30, 30);
        indicatorView.center = sender.center;
        [indicatorView startAnimating];
        [sender addSubview:indicatorView];
        WS(weakSelf)
        [WXYZ_NetworkRequestManger POST:Book_Catalog parameters:@{@"book_id" : [WXYZ_UtilsHelper formatStringWithInteger:self.book_id]} model:WXYZ_ProductionModel.class success:^(BOOL isSuccess, WXYZ_ProductionModel *  _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
            [indicatorView removeFromSuperview];
            [sender setTitleColor:kMainColor forState:UIControlStateNormal];
            if (isSuccess) {
                weakSelf.bookModel.book.chapter_list = t_model.chapter_list;
                [weakSelf saveCatalog:requestModel.data];
                [weakSelf audioButtonClick:sender];
            } else {
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg ?: @"书籍获取失败"];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [indicatorView removeFromSuperview];
            [sender setTitleColor:kMainColor forState:UIControlStateNormal];
            [WXYZ_TopAlertManager showAlertWithError:error defaultText:@"书籍获取失败"];
        }];
        return;
    }
    
#if WX_Enable_Ai
    if ([WXYZ_UtilsHelper getAiReadSwitchState]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Reset_Player_Inof object:nil];
        
        WXYZ_BookAiPlayPageViewController *vc = [WXYZ_BookAiPlayPageViewController sharedManager];
        [vc loadDataWithBookModel:self.bookModel.book chapterModel:nil];
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[WXYZ_BookAiPlayPageViewController class]]) {
                [self popViewController];
                return;
            }
        }
        
        WXYZ_NavigationController *nav = [[WXYZ_NavigationController alloc] initWithRootViewController:vc];
        [[WXYZ_ViewHelper getWindowRootController] presentViewController:nav animated:YES completion:nil];
    }
#endif
    
#if WX_Download_Mode
    if (![WXYZ_UtilsHelper getAiReadSwitchState]) {
        [self downloadClick];
    }
#endif
}

#if WX_Download_Mode
- (void)downloadClick
{
    if (!self.book_id) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"书籍获取失败"];
        return;
    }
    
    if (self.bookModel.book.list.count == 0) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"书籍获取失败"];
        return;
    }
    
    self.downloadButton.enabled = NO;

    WXYZ_BookDownloadMenuBar *downloadBar = [[WXYZ_BookDownloadMenuBar alloc] init];
    downloadBar.book_id = [WXYZ_UtilsHelper formatStringWithInteger:self.book_id];
    downloadBar.chapter_id = [WXYZ_UtilsHelper formatStringWithInteger:[[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] getReadingRecordChapter_idWithProduction_id:self.book_id]];
    WS(weakSelf)
    downloadBar.menuBarDidHiddenBlock = ^{
        weakSelf.downloadButton.enabled = YES;
    };
    [kMainWindow addSubview:downloadBar];
    
    [downloadBar showDownloadPayView];
}
#endif

#if WX_W_Share_Mode || WX_Q_Share_Mode
- (void)UMShareClick
{
    [[WXYZ_ShareManager sharedManager] shareProductionInController:self shareTitle:self.bookModel.book.name shareDescribe:self.bookModel.book.production_descirption shareImageURL:self.bookModel.book.cover productionType:WXYZ_ShareProductionBook production_id:self.bookModel.book.production_id shareState:WXYZ_ShareStateAll];
}
#endif

- (void)addBookRackClick:(UIButton *)sender
{
    [WXYZ_UtilsHelper synchronizationRackProductionWithProduction_id:self.book_id productionType:WXYZ_ProductionTypeBook complete:nil];
    
    if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] addCollectionWithProductionModel:self.bookModel.book atIndex:0]) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"已收藏"];
        [sender setTitle:@"已收藏" forState:UIControlStateNormal];
        [sender setTitleColor:kMainColorAlpha(0.5) forState:UIControlStateNormal];
        sender.enabled = NO;
    } else {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"添加失败"];
    }
}

- (void)readBookClick
{
    if (self.isReader) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (!self.bookModel.book) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"书籍获取失败"];
        return;
    }
    
    [WXYZ_TaskViewController taskReadRequestWithProduction_id:self.book_id];
    
    // 删除多余的阅读器和书籍详情页
    NSArray<UIViewController *> *t_arr = self.navigationController.viewControllers;
    NSMutableArray<UIViewController *> *tt_arr = [t_arr mutableCopy];
    for (UIViewController *obj in t_arr) {
        if ([obj isKindOfClass:WXYZ_BookReaderViewController.class] ||
            ([obj isKindOfClass:WXYZ_BookMallDetailViewController.class] && obj != self)) {
            [tt_arr removeObject:obj];
        }
    }
    
    if (tt_arr.count != self.navigationController.viewControllers.count) {
        self.navigationController.viewControllers = tt_arr;
    }
    
    WXYZ_BookReaderViewController *vc = [[WXYZ_BookReaderViewController alloc] init];
    vc.book_id = self.book_id;
    vc.bookModel = self.bookModel.book;
    [self.navigationController pushViewController:vc animated:YES];
    [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] moveCollectionToTopWithProductionModel:self.bookModel.book];
}

- (void)jumpToReader:(NSNotification *)noti
{
    if ([noti.object isEqualToString:@"WXYZ_BookMallDetailViewController"]) {
        
        WXYZ_ProductionModel *t_model = [noti.userInfo objectForKey:@"bookModel"];
        
        WXYZ_BookReaderViewController *vc = [[WXYZ_BookReaderViewController alloc] init];
        vc.book_id = t_model.production_id;
        vc.bookModel = t_model;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)netRequest
{
    if ([WXYZ_NetworkReachabilityManager networkingStatus] == NO) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"当前无网络连接"];
        return;
    }
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Book_Mall_Detail parameters:@{@"book_id":[WXYZ_UtilsHelper formatStringWithInteger:self.book_id]} model:WXYZ_BookDetailModel.class success:^(BOOL isSuccess, WXYZ_BookDetailModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            weakSelf.bookModel = t_model;
            
            self.detailListArray = [NSMutableArray array];
            // 作者
            if (self.bookModel.book.author.length > 0) {
                [self.detailListArray addObject:@{@"作者":[self.bookModel.book.author componentsSeparatedByString:@","]}];
            }
            // 标签
            if (self.bookModel.book.tag.count > 0) {
                
                NSMutableArray *t_tagArr = [NSMutableArray array];
                for (WXYZ_TagModel *t_tag in self.bookModel.book.tag) {
                    [t_tagArr addObject:t_tag.tab];
                }
                
                [self.detailListArray addObject:@{@"标签":t_tagArr}];
            }
            
            // 分类
            if (self.bookModel.book.tags.count > 0) {
                [self.detailListArray addObject:@{@"分类":self.bookModel.book.tags}];
            }
            
            // 原著
            if (self.bookModel.book.original.length > 0) {
                [self.detailListArray addObject:@{@"原著":@[self.bookModel.book.original]}];
            }
            
            // 汉化组
            if (self.bookModel.book.sinici.length > 0) {
                [self.detailListArray addObject:@{@"汉化组":@[self.bookModel.book.sinici]}];
            }
            
            // 创建日期
            if (self.bookModel.book.created_at.length > 0) {
                [self.detailListArray addObject:@{@"创建日期":self.bookModel.book.created_at}];
            }
            
            // 最后修改
            if (self.bookModel.book.last_chapter_time.length > 0) {
                [self.detailListArray addObject:@{@"最后修改":self.bookModel.book.last_chapter_time}];
            }
            
            // 作品简介
            if (self.bookModel.book.last_chapter_time.length > 0) {
                [self.detailListArray addObject:@{@"作品简介":@""}];
            }
            
            [weakSelf.mainTableViewGroup reloadData];
            
            [weakSelf createToolBar];
            [weakSelf requestCatalog];
            
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg ?: @"书籍获取失败"];
        }
#if WX_W_Share_Mode || WX_Q_Share_Mode
        weakSelf.shareButton.hidden = NO;
#endif
        weakSelf.downloadButton.hidden = isMagicState?YES:NO;
        
        [weakSelf.mainTableViewGroup endRefreshing];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:@"书籍获取失败"];
        [weakSelf.mainTableViewGroup endRefreshing];
    }];
}

// 获取目录信息
- (void)requestCatalog {
    NSInteger chapter_id = [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] getReadingRecordChapter_idWithProduction_id:self.book_id];
    
    NSDictionary *params = @{
        @"book_id" : [WXYZ_UtilsHelper formatStringWithInteger:self.book_id],
        @"chapter_id" : @(chapter_id),
        @"scroll_type": @(1), // 1：向下加载；2：向上加载
    };
    WXYZ_CatalogModel * __block catalogModel = nil;
    NSDictionary * __block catalogDict = nil;
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Book_New_Catalog parameters:params model:WXYZ_CatalogModel.class success:^(BOOL isSuccess, WXYZ_CatalogModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            catalogModel = t_model;
            weakSelf.bookModel.book.list = t_model.list;
            weakSelf.bookModel.book.author_name = t_model.author.author_name;
            weakSelf.bookModel.book.author_id = t_model.author.author_id;
            weakSelf.bookModel.book.author_note = t_model.author.author_note;
            weakSelf.bookModel.book.author_avatar = t_model.author.author_avatar;
                        
            // 预下载第一章
            if (t_model.list.count > 0) {
                [[WXYZ_ReaderBookManager sharedManager] downloadPrestrainChapterWithProductionModel:weakSelf.bookModel.book production_id:weakSelf.book_id chapter_id:[[t_model.list firstObject].chapter_id integerValue] completionHandler:nil];
            }
            if (catalogDict) {
                NSString *str = [t_model.author modelToJSONString];
                NSDictionary *t_dict = [WXYZ_UtilsHelper dictionaryWithJsonString:str];
                NSMutableDictionary *tt_dict = [NSMutableDictionary dictionaryWithDictionary:catalogDict];
                [tt_dict setObject:t_dict forKey:@"author"];
                [weakSelf saveCatalog:tt_dict];
            }
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg ?: @"书籍获取失败"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:@"书籍获取失败"];
    }];
    
    [WXYZ_NetworkRequestManger POST:Book_Catalog parameters:@{@"book_id" : [WXYZ_UtilsHelper formatStringWithInteger:self.book_id]} model:WXYZ_ProductionModel.class success:^(BOOL isSuccess, WXYZ_ProductionModel *  _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            weakSelf.bookModel.book.chapter_list = t_model.chapter_list;
            if (catalogModel) {
                NSString *str = [catalogModel.author modelToJSONString];
                NSDictionary *t_dict = [WXYZ_UtilsHelper dictionaryWithJsonString:str];
                NSMutableDictionary *tt_dict = [NSMutableDictionary dictionaryWithDictionary:requestModel.data];
                [tt_dict setObject:t_dict forKey:@"author"];
                [weakSelf saveCatalog:tt_dict];
            } else {
                catalogDict = requestModel.data;
            }
        }
    } failure:nil];
}

- (void)setBookModel:(WXYZ_BookDetailModel *)bookModel {
    _bookModel = bookModel;
    [self.navigationBar setNavigationBarTitle:bookModel.book.name?:@""];
    self.needRefresh = YES;
    [self.mainTableViewGroup reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.needRefresh = NO;
    });
}

- (void)changeNavBarColorState:(CGFloat)contentOffsetY withAnimate:(BOOL)animate
{
    CGFloat alpha = [WXYZ_ColorHelper getAlphaWithContentOffsetY:contentOffsetY];
    CGFloat rbgColor = [WXYZ_ColorHelper getColorWithContentOffsetY:contentOffsetY];
    
    self.navigationBar.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:alpha];
    self.navigationBar.navTitleLabel.backgroundColor = [UIColor clearColor];
    self.navigationBar.navTitleLabel.alpha = alpha;
    self.navigationBar.navTitleLabel.textColor = kColorRGBA(rbgColor, rbgColor, rbgColor, 1);
    [self.navigationBar setLeftButtonTintColor:kColorRGBA(rbgColor, rbgColor, rbgColor, 1)];
    
#if WX_W_Share_Mode || WX_Q_Share_Mode
    self.shareButton.tintColor = kColorRGBA(rbgColor, rbgColor, rbgColor, 1);
#endif
    
#if WX_Download_Mode
    self.downloadButton.tintColor = kColorRGBA(rbgColor, rbgColor, rbgColor, 1);
#endif
    
    if (contentOffsetY > 60) {
        [self setStatusBarDefaultStyle];
    } else {
        [self setStatusBarLightContentStyle];
    }
}

/// 保存目录列表到本地
- (void)saveCatalog:(NSDictionary *)catalog {
    NSString *path =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    
    path = [path stringByAppendingPathComponent:[WXYZ_UtilsHelper stringToMD5:@"book_catalog"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:@{} error:nil];
    }
    NSString *catalogName = [NSString stringWithFormat:@"%zd_%@", self.book_id, @"catalog"];
    NSString *fullPath = [path stringByAppendingFormat:@"/%@.plist", [WXYZ_UtilsHelper stringToMD5:catalogName]];
    [catalog writeToFile:fullPath atomically:YES];
}

@end

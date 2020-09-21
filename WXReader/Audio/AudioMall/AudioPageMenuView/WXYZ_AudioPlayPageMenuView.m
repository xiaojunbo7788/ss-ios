//
//  WXYZ_AudioPlayPageMenuView.m
//  WXReader
//
//  Created by Andrew on 2020/3/18.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AudioPlayPageMenuView.h"

#import "WXYZ_AudioPlayPageMenuTableViewCell.h"
#import "WXYZ_AudioPlayPageMenuDirectoryTableViewCell.h"

#import "WXYZ_CustomButton.h"
#import "WXYZ_AudioSettingHelper.h"
#import "WXYZ_ProductionReadRecordManager.h"

#define Menu_Cell_Height 44
#define Menu_Header_Height 40
#define Menu_Footer_Height (40 + PUB_TABBAR_OFFSET)

@interface WXYZ_AudioPlayPageMenuView ()

/// 是倒序
@property (nonatomic, assign) BOOL isInvert;

@end

@implementation WXYZ_AudioPlayPageMenuView
{
    WXYZ_MenuType _menuType;
    
    UITapGestureRecognizer *tap;
    
    UIView *backView;
    UITableView *mainTableView;
    UIButton *closeButton;
    UILabel *headerTitleLabel;
    UIView *sectionHeaderView;
    UILabel *sectionHeaderTitle;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        [self initialize];
        [self createSubviews];
    }
    return self;
}

- (void)initialize
{
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.backgroundColor = kBlackTransparentColor;
    self.tag = 111;
    [kMainWindow addSubview:self];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

- (void)createSubviews
{
    backView = [[UIView alloc] init];
    backView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT / 2);
    backView.backgroundColor = kWhiteColor;
    [backView addRoundingCornersWithRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
    [self addSubview:backView];
    
    mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    mainTableView.backgroundColor = [UIColor whiteColor];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.showsVerticalScrollIndicator = NO;
    mainTableView.showsHorizontalScrollIndicator = NO;
    mainTableView.estimatedRowHeight = 100;
    mainTableView.sectionFooterHeight = 10;
    mainTableView.rowHeight = UITableViewAutomaticDimension;
    mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0, *)) {
        mainTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [backView addSubview:mainTableView];
    
    [mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backView.mas_left);
        make.top.mas_equalTo(backView.mas_top);
        make.width.mas_equalTo(backView.mas_width);
        make.height.mas_equalTo(backView.mas_height).offset(-Menu_Footer_Height);
    }];
    
    headerTitleLabel = [[UILabel alloc] init];
    headerTitleLabel.textAlignment = NSTextAlignmentCenter;
    headerTitleLabel.textColor = kBlackColor;
    headerTitleLabel.font = kBoldFont15;
    headerTitleLabel.backgroundColor = [UIColor whiteColor];
    [backView addSubview:headerTitleLabel];
    
    [headerTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backView.mas_left);
        make.top.mas_equalTo(backView.mas_top);
        make.width.mas_equalTo(backView.mas_width);
        make.height.mas_equalTo(Menu_Header_Height);
    }];
    
    {
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = kGrayLineColor;
        [backView addSubview:line];
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(headerTitleLabel.mas_bottom);
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.height.mas_equalTo(kCellLineHeight);
        }];
    }
    
    closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, Menu_Footer_Height);
    closeButton.backgroundColor = kWhiteColor;
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [closeButton setTitleColor:kBlackColor forState:UIControlStateNormal];
    [closeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, PUB_TABBAR_OFFSET, 0)];
    [closeButton.titleLabel setFont:kMainFont];
    [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:closeButton];
    
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
       make.left.mas_equalTo(backView.mas_left);
       make.bottom.mas_equalTo(backView.mas_bottom);
       make.width.mas_equalTo(backView.mas_width);
       make.height.mas_equalTo(Menu_Footer_Height);
    }];
    
    {
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = kGrayLineColor;
        [backView addSubview:line];
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(closeButton.mas_top);
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.height.mas_equalTo(kCellLineHeight);
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_menuType == WXYZ_MenuTypeAudioDirectory || _menuType == WXYZ_MenuTypeAiDirectory) {
        static NSString *cellName = @"WXYZ_AudioPlayPageMenuDirectoryTableViewCell";
        WXYZ_AudioPlayPageMenuDirectoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (!cell) {
            cell = [[WXYZ_AudioPlayPageMenuDirectoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        cell.productionType = _menuType == WXYZ_MenuTypeAiDirectory?WXYZ_ProductionTypeAi:WXYZ_ProductionTypeAudio;
        cell.chapterListModel = [self.menuListArray objectAtIndex:indexPath.row];
        cell.hiddenEndLine = indexPath.row == self.menuListArray.count - 1;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        static NSString *cellName = @"WXYZ_AudioPlayPageMenuTableViewCell";
        WXYZ_AudioPlayPageMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (!cell) {
            cell = [[WXYZ_AudioPlayPageMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        cell.cellTitleString = [self.menuListArray objectAtIndex:indexPath.row];
        cell.hiddenEndLine = indexPath.row == self.menuListArray.count - 1;
        switch (_menuType) {
            case WXYZ_MenuTypeTiming:
                cell.cellSelected = [[WXYZ_AudioSettingHelper sharedManager] getReadTiming] == indexPath.row;
                break;
            case WXYZ_MenuTypeAudioSpeed:
                cell.cellSelected = [[WXYZ_AudioSettingHelper sharedManager] getReadSpeedWithProducitionType:WXYZ_ProductionTypeAudio] == indexPath.row;
                break;
            case WXYZ_MenuTypeAiSpeed:
                cell.cellSelected = [[WXYZ_AudioSettingHelper sharedManager] getReadSpeedWithProducitionType:WXYZ_ProductionTypeAi] == indexPath.row;
                break;
            case WXYZ_MenuTypeAiVoice:
                cell.cellSelected = [[WXYZ_AudioSettingHelper sharedManager] getReadVoiceWithProducitionType:WXYZ_ProductionTypeAi] == indexPath.row;
                break;
            default:
                break;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Menu_Cell_Height;
}

//section头间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_menuType == WXYZ_MenuTypeAudioDirectory || _menuType == WXYZ_MenuTypeAiDirectory) {
        return Menu_Header_Height + 40;
    }
    return Menu_Header_Height;
}
//section头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!sectionHeaderView) {
        sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, Menu_Header_Height)];
        sectionHeaderView.backgroundColor = [UIColor clearColor];
        
        if (_menuType == WXYZ_MenuTypeAudioDirectory || _menuType == WXYZ_MenuTypeAiDirectory) {
            sectionHeaderView.backgroundColor = [UIColor whiteColor];
            
            sectionHeaderTitle = [[UILabel alloc] initWithFrame:CGRectMake(kMargin, Menu_Header_Height, SCREEN_WIDTH / 2, 40)];
            sectionHeaderTitle.text = [NSString stringWithFormat:@"共%@章", [WXYZ_UtilsHelper formatStringWithInteger:self.totalChapter]];
            sectionHeaderTitle.textColor = kGrayTextColor;
            sectionHeaderTitle.textAlignment = NSTextAlignmentLeft;
            sectionHeaderTitle.font = kFont12;
            [sectionHeaderView addSubview:sectionHeaderTitle];
            
            WXYZ_CustomButton *sortButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - kHalfMargin - 60, Menu_Header_Height, 60, 40) buttonTitle:@"正序" buttonImageName:@"comic_positive_order" buttonIndicator:WXYZ_CustomButtonIndicatorImageRightBothRight];
            sortButton.buttonImageScale = 0.3;
            sortButton.buttonTitleFont = kFont12;
            sortButton.graphicDistance = 5;
            sortButton.buttonTitleColor = kGrayTextColor;
            sortButton.tag = 0;
            [sortButton addTarget:self action:@selector(changeDirectorySort:) forControlEvents:UIControlEventTouchUpInside];
            [sectionHeaderView addSubview:sortButton];
        }
    }
    
    if (sectionHeaderTitle) {
        sectionHeaderTitle.text = [NSString stringWithFormat:@"共%@章", [WXYZ_UtilsHelper formatStringWithInteger:self.totalChapter]];
    }
    return sectionHeaderView;
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
    switch (_menuType) {
        case WXYZ_MenuTypeTiming:
            [[WXYZ_AudioSettingHelper sharedManager] setReadTimingWithIndex:indexPath.row];
            break;
        case WXYZ_MenuTypeAudioSpeed:
            [[WXYZ_AudioSettingHelper sharedManager] setReadSpeedWithIndex:indexPath.row producitionType:WXYZ_ProductionTypeAudio];
            break;
        case WXYZ_MenuTypeAiSpeed:
            [[WXYZ_AudioSettingHelper sharedManager] setReadSpeedWithIndex:indexPath.row producitionType:WXYZ_ProductionTypeAi];
            break;
        case WXYZ_MenuTypeAiVoice:
            [[WXYZ_AudioSettingHelper sharedManager] setReadVoiceWithIndex:indexPath.row producitionType:WXYZ_ProductionTypeAi];
            break;
        default:
            break;
    }
    
    if (_menuType == WXYZ_MenuTypeAudioDirectory || _menuType == WXYZ_MenuTypeAiDirectory) {
        WXYZ_ProductionChapterModel *listModel = [self.menuListArray objectAtIndex:indexPath.row];
        if (listModel.chapter_id > 0) {
            if (self.chooseDirectoryMenuBlock) {
                self.chooseDirectoryMenuBlock(listModel.chapter_id, indexPath.row);
            }
        }
    } else {
        if (self.chooseMenuBlock) {
            self.chooseMenuBlock(_menuType, indexPath.row);
        }
    }
    
    [tableView reloadData];
    
    [self close];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view.tag != 111) {
        return NO;
    } else {
        return YES;
    }
}

- (void)changeDirectorySort:(WXYZ_CustomButton *)sender
{
    if (sender.tag == 0) {
        sender.tag = 1;
        sender.buttonImageName = @"comic_reverse_order";
        sender.buttonTitle = @"倒序";
        self.isInvert = YES;
    } else {
        sender.tag = 0;
        sender.buttonImageName = @"comic_positive_order";
        sender.buttonTitle = @"正序";
        self.isInvert = NO;
    }
    
    if (_menuType == WXYZ_MenuTypeAiDirectory) {
        
        WXYZ_ProductionChapterModel *t_model = self.menuListArray.firstObject;
        NSDictionary *params = @{
            @"book_id" : @(t_model.production_id),
            @"order_by" : sender.tag ? @(2) : @(1)
        };
        
        WS(weakSelf)
        [WXYZ_NetworkRequestManger POST:Book_New_Catalog parameters:params model:WXYZ_CatalogModel.class success:^(BOOL isSuccess, WXYZ_CatalogModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
            if (isSuccess) {
                weakSelf.totalChapter = t_model.total_chapter;
                NSMutableArray<WXYZ_ProductionChapterModel *> *t_arr = [NSMutableArray array];
                for (WXYZ_CatalogListModel *list in t_model.list) {
                    WXYZ_ProductionChapterModel *model = [[WXYZ_ProductionChapterModel alloc] init];
                    
                    model.production_id = [list.book_id integerValue];
                    model.chapter_id = [list.chapter_id integerValue];
                    model.next_chapter = [list.next_chapter integerValue];
                    model.last_chapter = [list.previou_chapter integerValue];
                    model.chapter_title = list.title;
                    model.total_words = [list.words integerValue];
                    model.is_vip = list.vip;
                    model.update_time = list.update_time;
                    model.display_order = [NSString stringWithFormat:@"%zd", list.display_order];
                    model.can_read = list.can_read;
                    model.is_preview = list.preview;
                    
                    [t_arr addObject:model];
                }
                weakSelf.menuListArray = t_arr;
                
                [mainTableView reloadData];
                
                [mainTableView hideRefreshHeader];
                [mainTableView showRefreshFooter];
            }
        } failure:nil];
    } else {
        self.menuListArray = [[self.menuListArray reverseObjectEnumerator] allObjects];
        
        [mainTableView reloadData];
        
        [mainTableView hideRefreshHeader];
        [mainTableView showRefreshFooter];
    }
}

- (void)showWithMenuType:(WXYZ_MenuType)menuType
{
    _menuType = menuType;
    
    switch (menuType) {
        case WXYZ_MenuTypeTiming:
            self.menuListArray = [[WXYZ_AudioSettingHelper sharedManager] getReadTimingKeys];
            headerTitleLabel.text = @"定时";
            break;
        case WXYZ_MenuTypeAudioSpeed:
            self.menuListArray = [[WXYZ_AudioSettingHelper sharedManager] getReadSpeedKeysWithProducitionType:WXYZ_ProductionTypeAudio];
            headerTitleLabel.text = @"语速";
            break;
        case WXYZ_MenuTypeAiSpeed:
            self.menuListArray = [[WXYZ_AudioSettingHelper sharedManager] getReadSpeedKeysWithProducitionType:WXYZ_ProductionTypeAi];
            headerTitleLabel.text = @"语速";
            break;
        case WXYZ_MenuTypeAiVoice:
            self.menuListArray = [[WXYZ_AudioSettingHelper sharedManager] getReadVoiceKeysWithProducitionType:WXYZ_ProductionTypeAi];
            headerTitleLabel.text = @"声音";
            break;
        case WXYZ_MenuTypeAudioDirectory:
        case WXYZ_MenuTypeAiDirectory:
        {
            headerTitleLabel.text = @"章节目录";
            WS(weakSelf)
            [mainTableView addFooterRefreshWithRefreshingBlock:^{
                if (weakSelf.isInvert) {
                    [weakSelf requestCatalogWithScrollType:@"2"];
                } else {
                    [weakSelf requestCatalogWithScrollType:@"1"];
                }
            }];
        }
            break;
        case WXYZ_MenuTypeAudioSelection:
        {
            if (self.menuListArray.count > 0) {
                NSMutableArray *t_array = [NSMutableArray array];
                for (int i = 0; i < (self.menuListArray.count / 30) + (self.menuListArray.count % 30 == 0?0:1); i ++) {
                    [t_array addObject:[NSString stringWithFormat:@"%@-%@", [WXYZ_UtilsHelper formatStringWithInteger:(i * 30 + 1)], [WXYZ_UtilsHelper formatStringWithInteger:((i + 1) * 30) <= self.menuListArray.count?((i + 1) * 30):self.menuListArray.count]]];
                }
                self.menuListArray = [t_array copy];
            }
            
            headerTitleLabel.text = @"选章";
        }
            break;
        default:
            break;
    }
    
    // 计算tableview高度
    CGFloat tableViewHeight = self.menuListArray.count * Menu_Cell_Height + Menu_Header_Height + Menu_Footer_Height + ((_menuType == WXYZ_MenuTypeAudioDirectory || _menuType == WXYZ_MenuTypeAiDirectory)?80:0);
    if (tableViewHeight > SCREEN_HEIGHT / 2) {
        tableViewHeight = SCREEN_HEIGHT / 2;
    }
    
    [UIView animateWithDuration:kAnimatedDuration animations:^{
        backView.frame = CGRectMake(0, SCREEN_HEIGHT - tableViewHeight, SCREEN_WIDTH, tableViewHeight);
    }];
    
    [mainTableView reloadData];
    [mainTableView layoutIfNeeded];
    
    if (menuType == WXYZ_MenuTypeAiDirectory) {
        // 移动到当前播放位置
        for (int i = 0; i < self.menuListArray.count; i ++) {
            WXYZ_ProductionChapterModel *chapter_model = [self.menuListArray objectAtIndex:i];
            if (chapter_model.chapter_id == [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAi] getReadingRecordChapter_idWithProduction_id:chapter_model.production_id]) {
                [mainTableView scrollToRow:i inSection:0 atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }
    } else if (menuType == WXYZ_MenuTypeAudioDirectory) {
        // 移动到当前播放位置
        for (int i = 0; i < self.menuListArray.count; i ++) {
            WXYZ_ProductionChapterModel *chapter_model = [self.menuListArray objectAtIndex:i];
            if (chapter_model.chapter_id == [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] getReadingRecordChapter_idWithProduction_id:chapter_model.production_id]) {
                [mainTableView scrollToRow:i inSection:0 atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }
    }   
}

- (void)close
{
    [UIView animateWithDuration:kAnimatedDuration animations:^{
        backView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, backView.height);
    } completion:^(BOOL finished) {
        for (UIView *v in [self subviews]) {
            [v removeFromSuperview];
        }
        [self removeFromSuperview];
    }];
    
}

// scrollType 1：向下加载；2：向上加载
- (void)requestCatalogWithScrollType:(NSString *)scrollType {
    BOOL loadDown = [scrollType isEqualToString:@"1"];
        
    NSString *chapterID = @"";
    WXYZ_ProductionChapterModel *t_model = nil;
    if (loadDown) {
        t_model = self.menuListArray.lastObject;
        chapterID = [NSString stringWithFormat:@"%zd", t_model.next_chapter];
    } else {
        t_model = self.menuListArray.lastObject;
        chapterID = [NSString stringWithFormat:@"%zd", t_model.last_chapter];
    }
    
    if ([chapterID isEqualToString:@"0"]) {
        [mainTableView endRefreshing];
        if (loadDown) {
            [mainTableView hideRefreshFooter];
        } else {
            [mainTableView hideRefreshHeader];
        }
        return;
    }
    
    NSDictionary *params = @{
        @"book_id" : @(t_model.production_id),
        @"chapter_id" : chapterID,
        @"scroll_type" : scrollType,
    };
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Book_New_Catalog parameters:params model:WXYZ_CatalogModel.class success:^(BOOL isSuccess, WXYZ_CatalogModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        [mainTableView endRefreshing];
        if (isSuccess) {
            weakSelf.totalChapter = t_model.total_chapter;
            NSMutableArray<WXYZ_ProductionChapterModel *> *t_arr = [NSMutableArray array];
            for (WXYZ_CatalogListModel *list in t_model.list) {
                WXYZ_ProductionChapterModel *model = [[WXYZ_ProductionChapterModel alloc] init];

                model.production_id = [list.book_id integerValue];
                model.chapter_id = [list.chapter_id integerValue];
                model.next_chapter = [list.next_chapter integerValue];
                model.last_chapter = [list.previou_chapter integerValue];
                model.chapter_title = list.title;
                model.total_words = [list.words integerValue];
                model.is_vip = list.vip;
                model.update_time = list.update_time;
                model.display_order = [NSString stringWithFormat:@"%zd", list.display_order];
                model.can_read = list.can_read;
                model.is_preview = list.preview;

                [t_arr addObject:model];
            }
            if ([scrollType isEqualToString:@"2"]) {
                t_arr = [[[t_arr reverseObjectEnumerator] allObjects] mutableCopy];
            }
            weakSelf.menuListArray = [weakSelf.menuListArray arrayByAddingObjectsFromArray:t_arr];
            [mainTableView reloadData];
            [mainTableView endRefreshing];
            if ([scrollType isEqualToString:@"1"]) {
                if (t_arr.lastObject.next_chapter == 0) {
                    [mainTableView hideRefreshFooter];
                }
                if (t_arr.firstObject.last_chapter == 0) {
                    [mainTableView hideRefreshHeader];
                }
            } else {
                if (t_arr.lastObject.last_chapter == 0) {
                    [mainTableView hideRefreshFooter];
                }
                if (t_arr.firstObject.next_chapter == 0) {
                    [mainTableView hideRefreshHeader];
                }
            }
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
        [mainTableView endRefreshing];
    }];
    
}

@end

//
//  WXYZ_BookDownloadMenuBar.m
//  WXReader
//
//  Created by Andrew on 2019/4/3.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_BookDownloadMenuBar.h"
#import "WXYZ_BookDownloadManager.h"
#import "WXYZ_BookDownloadTaskListModel.h"

#import "WXYZ_BookDownloadMenuBarTableViewCell.h"

#import "WXYZ_ChapterBottomPayBar.h"

#define DefaultBar_H 6 * Cell_Height + PUB_NAVBAR_OFFSET + 10

#define Cell_Height 40

#define animateDuration 0.4f

@interface WXYZ_BookDownloadMenuBar () <UITableViewDelegate, UITableViewDataSource>
{
    UIView *menuView;
}

@property (nonatomic, strong) WXYZ_BookDownloadTaskListModel *downloadModel;

@property (nonatomic, strong) WXYZ_BookDownloadManager *bookDownloadManager;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, weak) UITableView *mainTableView;

@end

@implementation WXYZ_BookDownloadMenuBar

- (instancetype)init
{
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.backgroundColor = kColorRGBA(0, 0, 0, 0.0);
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    self.bookDownloadManager = [WXYZ_BookDownloadManager sharedManager];
}

- (void)showDownloadPayView
{
    [self.activityIndicator startAnimating];
    [self netRequest];
}

- (void)hiddenDownloadPayView
{
    if (self.menuBarDidHiddenBlock) {
        self.menuBarDidHiddenBlock();
    }
    [self removeAllSubviews];
    [self removeFromSuperview];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UIView *touchView = [[touches anyObject] view];
    if (![touchView isEqual:menuView] && ![touchView isEqual:self.mainTableView] && ![touchView isKindOfClass:[NSClassFromString(@"UITableViewCellContentView") class]]) {
        [self hiddenDownloadPayView];
    }
}

- (void)createSubViews
{
    self.backgroundColor = kBlackTransparentColor;
    
    menuView = [[UIView alloc] init];
    menuView.backgroundColor = [UIColor whiteColor];
    [self addSubview:menuView];
    
    [menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(self.mas_bottom);
        make.width.mas_equalTo(self.mas_width);
        make.height.mas_equalTo(DefaultBar_H);
    }];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    self.activityIndicator.hidesWhenStopped = YES;
    [menuView addSubview:self.activityIndicator];
    //设置小菊花的frame
    [self.activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(menuView.mas_centerX);
        make.centerY.mas_equalTo(menuView.mas_centerY);
        make.height.width.mas_equalTo(20);
    }];
}

- (void)reloadViewData
{
    [UIView animateWithDuration:animateDuration animations:^{
        [self->menuView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.width.mas_equalTo(self.mas_width);
            make.height.mas_equalTo(DefaultBar_H);
        }];
    }];
    
    UITableView *mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.mainTableView = mainTableView;
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.scrollEnabled = NO;
    mainTableView.backgroundColor = [UIColor whiteColor];
    mainTableView.showsVerticalScrollIndicator = NO;
    mainTableView.showsHorizontalScrollIndicator = NO;
    mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:mainTableView];
    
    [mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.width.mas_equalTo(self.mas_width);
        make.height.mas_equalTo(Cell_Height * (1 + self.downloadModel.task_list.count) + Cell_Height + PUB_TABBAR_OFFSET + 10);
    }];
    
    if (@available(iOS 11.0, *)) {
        mainTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    
    [menuView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(Cell_Height * (1 + self.downloadModel.task_list.count) + Cell_Height + PUB_TABBAR_OFFSET + 10);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.downloadModel.task_list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_BookDownloadMenuBarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_BookDownloadMenuBarTableViewCell"];
    
    if (!cell) {
        cell = [[WXYZ_BookDownloadMenuBarTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_BookDownloadMenuBarTableViewCell"];
    }
    cell.book_id = [self.book_id integerValue];
    cell.optionModel = [self.downloadModel.task_list objectOrNilAtIndex:indexPath.row];
    cell.hiddenEndLine = (self.downloadModel.task_list.count - 1 == indexPath.row);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.mainTableView.userInteractionEnabled = NO;
    WXYZ_BookDownloadMenuBarTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell startDownloadLoading];
    
    NSString *path =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    path = [path stringByAppendingPathComponent:[WXYZ_UtilsHelper stringToMD5:@"book_catalog"]];
    NSString *catalogName = [NSString stringWithFormat:@"%@_%@", self.book_id, @"catalog"];
    NSString *fullPath = [path stringByAppendingFormat:@"/%@.plist", [WXYZ_UtilsHelper stringToMD5:catalogName]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:fullPath];
        WXYZ_ProductionModel *t_model = [WXYZ_ProductionModel modelWithDictionary:dict];
        self.downloadModel.productionModel = t_model;
        [self downloadChapterWithTaskModel:[self.downloadModel.task_list objectAtIndex:indexPath.row]];
    } else {
        WS(weakSelf)
        [WXYZ_NetworkRequestManger POST:Book_Catalog parameters:@{@"book_id":self.book_id} model:WXYZ_ProductionModel.class success:^(BOOL isSuccess, WXYZ_ProductionModel *  _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
            if (isSuccess) {
                weakSelf.downloadModel.productionModel = t_model;
                [weakSelf downloadChapterWithTaskModel:[self.downloadModel.task_list objectAtIndex:indexPath.row]];
                [weakSelf hiddenDownloadPayView];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
    }    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Cell_Height;
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return Cell_Height;
}
//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.frame = CGRectMake(0, 0, SCREEN_WIDTH, Cell_Height);
    titleLabel.text = @"选择需要下载的章节";
    titleLabel.textColor = kBlackColor;
    titleLabel.font = kMainFont;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    return titleLabel;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return Cell_Height + PUB_TABBAR_OFFSET + 10;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, Cell_Height + PUB_TABBAR_OFFSET + 10);
    view.backgroundColor = kColorRGBA(235, 235, 241, 1);
    
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    downloadButton.frame = CGRectMake(0, 10, SCREEN_WIDTH, Cell_Height + PUB_TABBAR_OFFSET);
    downloadButton.backgroundColor = [UIColor whiteColor];
    [downloadButton setTitle:@"下载缓存" forState:UIControlStateNormal];
    [downloadButton setTitleColor:kBlackColor forState:UIControlStateNormal];
    [downloadButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, PUB_TABBAR_OFFSET / 2, 0)];
    [downloadButton.titleLabel setFont:kMainFont];
    [downloadButton addTarget:self action:@selector(downloadClick) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:downloadButton];
    
    return view;
}

- (void)downloadClick
{
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Push_To_Download object:nil];
    [self hiddenDownloadPayView];
}

- (void)netRequest
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Book_Chapter_Download_Option parameters:@{@"book_id":self.book_id, @"chapter_id":self.chapter_id} model:nil success:^(BOOL isSuccess, NSDictionary * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            WXYZ_BookDownloadTaskListModel *t_downloadModel = [WXYZ_BookDownloadTaskListModel modelWithDictionary:[t_model objectForKey:@"data"]];
            
            weakSelf.downloadModel = t_downloadModel;
            
            [weakSelf.activityIndicator stopAnimating];
            [weakSelf createSubViews];
            [weakSelf reloadViewData];
        } else if (Compare_Json_isEqualTo(requestModel.code, 703)) {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
            [weakSelf hiddenDownloadPayView];
        }
    } failure:nil];
}

- (void)downloadChapterWithTaskModel:(WXYZ_DownloadTaskModel *)taskModel
{
    WS(weakSelf)
    taskModel.dateString = [WXYZ_UtilsHelper currentDateStringWithFormat:@"yyyy-MM-dd"];
    taskModel.download_title = [NSString stringWithFormat:@"%@ — %@章", [WXYZ_UtilsHelper formatStringWithInteger:taskModel.start_order], [WXYZ_UtilsHelper formatStringWithInteger:taskModel.end_order]];
    
    [self.bookDownloadManager downloadChaptersWithProductionModel:self.downloadModel.productionModel downloadTaskModel:taskModel production_id:[self.book_id integerValue] start_chapter_id:[taskModel.start_chapter_id integerValue] downloadNum:taskModel.down_num];
    self.bookDownloadManager.downloadMissionStateChangeBlock = ^(WXYZ_DownloadMissionState state, NSInteger production_id, WXYZ_DownloadTaskModel * _Nonnull downloadTaskModel, NSArray<NSNumber *> * _Nullable chapterIDArray) {
        switch (state) {
            case WXYZ_DownloadStateMissionStart:
            {
                for (UIView *view in weakSelf.mainTableView.subviews) {
                    if ([view isKindOfClass:[WXYZ_BookDownloadMenuBarTableViewCell class]]) {
                        WXYZ_BookDownloadMenuBarTableViewCell *cell = (WXYZ_BookDownloadMenuBarTableViewCell *)view;
                        if (cell.optionModel.label == downloadTaskModel.label) {
                            cell.missionState = state;
                            [weakSelf hiddenDownloadPayView];
                        }
                    }
                }
            }
                break;
            case WXYZ_DownloadStateMissionFinished:
            {
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"下载完成"];
                // 更新本地目录
                [WXYZ_BookDownloadMenuBar updateLocalCatalog:chapterIDArray];
                for (UIView *view in weakSelf.mainTableView.subviews) {
                    if ([view isKindOfClass:[WXYZ_BookDownloadMenuBarTableViewCell class]]) {
                        WXYZ_BookDownloadMenuBarTableViewCell *cell = (WXYZ_BookDownloadMenuBarTableViewCell *)view;
                        cell.optionModel = cell.optionModel;
                    }
                }
            }
                break;
            case WXYZ_DownloadStateMissionShouldPay:
            {
                SS(strongSelf)
                
                [weakSelf hiddenDownloadPayView];
                
                WXYZ_ProductionChapterModel *t_model = [[WXYZ_ProductionChapterModel alloc] init];
                t_model.production_id = production_id;
                t_model.chapter_id = [downloadTaskModel.start_chapter_id integerValue];
                
                WXYZ_ChapterBottomPayBar *payBar = [[WXYZ_ChapterBottomPayBar alloc] initWithChapterModel:t_model barType:WXYZ_BottomPayBarTypeDownload productionType:WXYZ_ProductionTypeBook buyChapterNum:[[WXYZ_UtilsHelper formatStringWithInteger:taskModel.down_num] integerValue]];
                payBar.paySuccessChaptersBlock = ^(NSArray<NSString *> * _Nonnull success_chapter_ids) {
                    [strongSelf downloadChapterWithTaskModel:taskModel];
                };
                [payBar showBottomPayBar];
            }
                break;
            default:
                break;
        }
        weakSelf.mainTableView.userInteractionEnabled = YES;
    };
}

static NSString *_bookID;
- (void)setBook_id:(NSString *)book_id {
    _book_id = book_id;
    _bookID = book_id;
}

// 下载成功后请求目录并更新本地目录
+ (void)updateLocalCatalog:(NSArray<NSNumber *> *)catalogArr {
    [WXYZ_NetworkRequestManger POST:Book_Catalog parameters:@{@"book_id" : _bookID} model:WXYZ_ProductionModel.class success:^(BOOL isSuccess, WXYZ_ProductionModel *  _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            NSString *path =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
            
            path = [path stringByAppendingPathComponent:[WXYZ_UtilsHelper stringToMD5:@"book_catalog"]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:@{} error:nil];
            }
            NSString *catalogName = [NSString stringWithFormat:@"%@_%@", _bookID, @"catalog"];
            NSString *fullPath = [path stringByAppendingFormat:@"/%@.plist", [WXYZ_UtilsHelper stringToMD5:catalogName]];
            [requestModel.data writeToFile:fullPath atomically:YES];
        }
    } failure:nil];
}

@end

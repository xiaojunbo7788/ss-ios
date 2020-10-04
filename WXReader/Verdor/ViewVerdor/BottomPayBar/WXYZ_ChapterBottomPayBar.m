//
//  WXYZ_ChapterBottomPayBar.m
//  WXReader
//
//  Created by Andrew on 2020/7/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ChapterBottomPayBar.h"

#import "WXYZ_RechargeViewController.h"
#import "WXYZ_MemberViewController.h"
#import "WXYZ_ChapterBottomPayBarTitleTableViewCell.h"
#import "WXYZ_ChapterBottomPayBarOptionTableViewCell.h"
#import "WXYZ_ChapterBottomPayBarBalanceTableViewCell.h"
#import "WXYZ_ChapterBottomPayBarAutoBuyTableViewCell.h"
#import "WXYZ_ChapterBottomPayBarCostTableViewCell.h"
#import "WXZY_CommonPayAlertView.h"
#import "WXYZ_ReaderBookManager.h"
#import "WXYZ_ShareManager.h"
@interface WXYZ_ChapterBottomPayBar ()  <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;

@end

@implementation WXYZ_ChapterBottomPayBar
{
    // 选项卡选择下标
    NSInteger _optionSelectIndex;
    
    NSInteger _buyChapterNum;
    
    WXYZ_BottomPayBarType _barType;
    WXYZ_ProductionType _productionType;
    
    WXYZ_ProductionChapterModel *_chapterModel;
    WXYZ_ChapterPayBarModel *_payBarModel;
}

- (instancetype)initWithChapterModel:(WXYZ_ProductionChapterModel *)chapterModel barType:(WXYZ_BottomPayBarType)barType productionType:(WXYZ_ProductionType)productionType
{
    if (self = [self initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) chapterModel:chapterModel barType:barType productionType:productionType buyChapterNum:1]) {
        [[WXYZ_ViewHelper getWindowRootController].view addSubview:self];
    }
    return self;
}

- (instancetype)initWithChapterModel:(WXYZ_ProductionChapterModel *)chapterModel barType:(WXYZ_BottomPayBarType)barType productionType:(WXYZ_ProductionType)productionType buyChapterNum:(NSInteger)buyChapterNum
{
    if (self = [self initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) chapterModel:chapterModel barType:barType productionType:productionType buyChapterNum:buyChapterNum]) {
        [[WXYZ_ViewHelper getWindowRootController].view addSubview:self];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame chapterModel:(WXYZ_ProductionChapterModel *)chapterModel barType:(WXYZ_BottomPayBarType)barType productionType:(WXYZ_ProductionType)productionType
{
    if (self = [self initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) chapterModel:chapterModel barType:barType productionType:productionType buyChapterNum:1]) {
        [[WXYZ_ViewHelper getWindowRootController].view addSubview:self];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame chapterModel:(WXYZ_ProductionChapterModel *)chapterModel barType:(WXYZ_BottomPayBarType)barType productionType:(WXYZ_ProductionType)productionType buyChapterNum:(NSInteger)buyChapterNum
{
    if (self = [super initWithFrame:frame]) {
        _barType = barType;
        _productionType = productionType;
        
        _chapterModel = chapterModel;
        
        _optionSelectIndex = 0;
        _buyChapterNum = buyChapterNum;
        
        _canTouchHiddenView = YES;
        
        self.backgroundColor = kBlackTransparentColor;
        [self initialize];
        [self createSubViews];
        [self netRequest];
    }
    return self;
}

- (void)initialize
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netRequest) name:Notification_Login_Success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netRequest) name:Notification_Recharge_Success object:nil];
}

- (void)createSubViews
{
    self.mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.mainTableView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, CGFLOAT_MIN);
    self.mainTableView.backgroundColor = [UIColor clearColor];
    self.mainTableView.showsVerticalScrollIndicator = NO;
    self.mainTableView.showsHorizontalScrollIndicator = NO;
    self.mainTableView.estimatedRowHeight = 100;
    self.mainTableView.sectionFooterHeight = 10;
    self.mainTableView.rowHeight = UITableViewAutomaticDimension;
    self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.scrollEnabled = NO;
    if (@available(iOS 11.0, *)) {
        self.mainTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [self addSubview:self.mainTableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_barType == WXYZ_BottomPayBarTypeDownload) {
        return 3;
    }
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            return [self createPayBarTitleTabelViewCellWithTabelView:tableView];
        }
            break;
        case 1:
        {
            if (_barType == WXYZ_BottomPayBarTypeDownload) {
                return [self createPayBarBalanceTabelViewCellWithTabelView:tableView];
            } else {
                WS(weakSelf)
                static NSString *cellName = @"WXYZ_ChapterBottomPayBarOptionTableViewCell";
                WXYZ_ChapterBottomPayBarOptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
                if (!cell) {
                    cell = [[WXYZ_ChapterBottomPayBarOptionTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
                }
                cell.hiddenEndLine = NO;
                cell.pay_options = _payBarModel.pay_options;
                cell.payOptionClickBlock = ^(WXYZ_ChapterPayBarOptionModel * _Nonnull chapterOptionModel, NSInteger selectIndex) {
                    _optionSelectIndex = selectIndex;
                    _buyChapterNum = chapterOptionModel.buy_num;
                    [weakSelf.mainTableView reloadData];
                };
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
        }
            break;
        case 2:
        {
            if (_barType == WXYZ_BottomPayBarTypeDownload) {
                return [self createPayBarCostTableViewCellWithTableView:tableView];
            } else {
                return [self createPayBarBalanceTabelViewCellWithTabelView:tableView];
            }
        }
            break;
        case 3:
        {
            static NSString *cellName = @"WXYZ_ChapterBottomPayBarAutoBuyTableViewCell";
            WXYZ_ChapterBottomPayBarAutoBuyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (!cell) {
                cell = [[WXYZ_ChapterBottomPayBarAutoBuyTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            }
            cell.hiddenEndLine = NO;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
        case 4:
        {
            return [self createPayBarCostTableViewCellWithTableView:tableView];
        }
            break;
            
        default:
            break;
    }
    
    return [[UITableViewCell alloc] init];
}

- (UITableViewCell *)createPayBarTitleTabelViewCellWithTabelView:(UITableView *)tableView
{
    static NSString *cellName = @"WXYZ_ChapterBottomPayBarTitleTableViewCell";
    WXYZ_ChapterBottomPayBarTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_ChapterBottomPayBarTitleTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.hiddenEndLine = NO;
    cell.buyOptionModel = [_payBarModel.pay_options objectOrNilAtIndex:_optionSelectIndex];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)createPayBarBalanceTabelViewCellWithTabelView:(UITableView *)tableView
{
    static NSString *cellName = @"WXYZ_ChapterBottomPayBarBalanceTableViewCell";
    WXYZ_ChapterBottomPayBarBalanceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_ChapterBottomPayBarBalanceTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.hiddenEndLine = NO;
    cell.base_info = _payBarModel.base_info;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)createPayBarCostTableViewCellWithTableView:(UITableView *)tableView
{
//    WS(weakSelf)
    static NSString *cellName = @"WXYZ_ChapterBottomPayBarCostTableViewCell";
    WXYZ_ChapterBottomPayBarCostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_ChapterBottomPayBarCostTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.base_info = _payBarModel.base_info;
    cell.buyOptionModel = [_payBarModel.pay_options objectOrNilAtIndex:_optionSelectIndex];
    cell.buyChapterClickBlock = ^(BOOL needRecharge) {
        if (!WXYZ_UserInfoManager.isLogin) {
            [WXYZ_LoginViewController presentLoginView];
//            [kMainWindow sendSubviewToBack:weakSelf];
        } else {
            if (needRecharge) {
                //TODO:弹窗
                 WXZY_CommonPayAlertView *payAlertView = [[WXZY_CommonPayAlertView alloc]initWithFrame:CGRectZero];
                payAlertView.msg = _chapterModel.recharge_content;
                [payAlertView showInView:[UIApplication sharedApplication].keyWindow];
                WS(weakSelf)
                payAlertView.onClick = ^(int type) {
                    if (type == 1) {
                        //分享
                         [[WXYZ_ShareManager sharedManager] shareApplicationInController:weakSelf shareState:WXYZ_ShareStateAll];
                    } else if (type == 2) {
                        //vip
                        WXYZ_MemberViewController *vc = [[WXYZ_MemberViewController alloc] init];
                        vc.productionType = _productionType;
                        WXYZ_NavigationController *t_nav = [[WXYZ_NavigationController alloc] initWithRootViewController:vc];
                        [[WXYZ_ViewHelper getWindowRootController] presentViewController:t_nav animated:YES completion:nil];
                        [kMainWindow sendSubviewToBack:weakSelf];
                        
                    } else if (type == 3) {
                        //充值
                        WXYZ_RechargeViewController *vc = [[WXYZ_RechargeViewController alloc] init];
                        vc.production_id = _chapterModel.production_id;
                        vc.productionType = _productionType;
                        WXYZ_NavigationController *t_nav = [[WXYZ_NavigationController alloc] initWithRootViewController:vc];
                        [[WXYZ_ViewHelper getWindowRootController] presentViewController:t_nav animated:YES completion:nil];
                        [kMainWindow sendSubviewToBack:weakSelf];
                    }
                };
                

            } else {
                WS(weakSelf)
                [weakSelf hiddenBottomPayBar];
                [weakSelf chapterPayRequest];
            }
        }
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((_barType == WXYZ_BottomPayBarTypeDownload && indexPath.row == 2) || indexPath.row == 4) {
        return 60;
    }
    return 50;
}

//section头间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
//section头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return PUB_TABBAR_OFFSET;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, PUB_TABBAR_OFFSET)];
    view.backgroundColor = kColorRGBA(247, 248, 250, 1);
    return view;
}

- (void)showBottomPayBar
{
    [UIView animateWithDuration:kAnimatedDurationFast animations:^{
        self.mainTableView.frame = CGRectMake(0, SCREEN_HEIGHT - (_barType == WXYZ_BottomPayBarTypeDownload?(2 * 50 + 60):(4 * 50 + 60)) - PUB_TABBAR_OFFSET, SCREEN_WIDTH, (_barType == WXYZ_BottomPayBarTypeDownload?(2 * 50 + 60):(4 * 50 + 60)) + PUB_TABBAR_OFFSET);
    }];
}

- (void)hiddenBottomPayBar
{
    if (!self.hidden) {
        
        [UIView animateWithDuration:kAnimatedDurationFast animations:^{
            self.mainTableView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, (_barType == WXYZ_BottomPayBarTypeDownload?(2 * 50 + 60):(4 * 50 + 60)) + PUB_TABBAR_OFFSET);
        } completion:^(BOOL finished) {
            [self removeAllSubviews];
            [self removeFromSuperview];
            self.hidden = YES;
            if (self.bottomPayBarHiddenBlock) {
                self.bottomPayBarHiddenBlock();
            }
        }];
    }
}

#pragma mark - 系统方法
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.canTouchHiddenView) {
        UIView *touchView = [[touches anyObject] view];
        if (![touchView isDescendantOfView:self.mainTableView]) {
            [self hiddenBottomPayBar];
            
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"您已取消购买"];
            
            if (self.payCancleChapterBlock) {
                self.payCancleChapterBlock(_chapterModel.chapter_ids);
            }
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(CGRectMake(0, 0, SCREEN_WIDTH, PUB_NAVBAR_HEIGHT), point) && !self.canTouchHiddenView) {
        return nil;
    }
    return [super hitTest:point withEvent:event];
}

- (void)netRequest
{
    NSString *url = @"";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    switch (_productionType) {
        case WXYZ_ProductionTypeBook:
        case WXYZ_ProductionTypeAi:
        {
            url = Book_Buy_Index;
            [parameters setObject:[WXYZ_UtilsHelper formatStringWithInteger:_chapterModel.production_id] forKey:@"book_id"];
            [parameters setObject:[WXYZ_UtilsHelper formatStringWithInteger:_chapterModel.chapter_id] forKey:@"chapter_id"];
            
            if (_barType == WXYZ_BottomPayBarTypeDownload) {
                [parameters setObject:@"down" forKey:@"page_from"];
                [parameters setObject:[WXYZ_UtilsHelper formatStringWithInteger:_buyChapterNum] forKey:@"num"];
            } else {
                [parameters setObject:@"read" forKey:@"page_from"];
            }
        }
            break;
        case WXYZ_ProductionTypeComic:
        {
            url = Comic_Buy_Index;
            
            [parameters setObject:[WXYZ_UtilsHelper formatStringWithInteger:_chapterModel.production_id] forKey:@"comic_id"];
            if (_barType == WXYZ_BottomPayBarTypeDownload) {
                [parameters setObject:[_chapterModel.chapter_ids componentsJoinedByString:@","] forKey:@"chapter_id"];
                [parameters setObject:@"down" forKey:@"page_from"];
            } else {
                [parameters setObject:[WXYZ_UtilsHelper formatStringWithInteger:_chapterModel.chapter_id] forKey:@"chapter_id"];
                [parameters setObject:@"read" forKey:@"page_from"];
            }
        }
            break;
        case WXYZ_ProductionTypeAudio:
        {
            url = Audio_Buy_Index;
            
            [parameters setObject:[WXYZ_UtilsHelper formatStringWithInteger:_chapterModel.production_id] forKey:@"audio_id"];
            if (_barType == WXYZ_BottomPayBarTypeDownload) {
                [parameters setObject:[_chapterModel.chapter_ids componentsJoinedByString:@","] forKey:@"chapter_id"];
                [parameters setObject:@"down" forKey:@"page_from"];
            } else {
                [parameters setObject:[WXYZ_UtilsHelper formatStringWithInteger:_chapterModel.chapter_id] forKey:@"chapter_id"];
                [parameters setObject:@"read" forKey:@"page_from"];
            }
        }
            break;
            
        default:
            break;
    }
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:url parameters:[parameters copy] model:nil success:^(BOOL isSuccess, NSDictionary * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            SS(strongSelf)
            [WXYZ_UserInfoManager shareInstance].totalRemain = [[[t_model objectForKey:@"data"] objectForKey:@"remain"] integerValue];
            if (strongSelf) {
                strongSelf->_payBarModel = [WXYZ_ChapterPayBarModel modelWithDictionary:[t_model objectForKey:@"data"]];
            }
            [weakSelf.mainTableView reloadData];
        }
    } failure:nil];
}

- (void)chapterPayRequest
{
    NSString *url = @"";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    switch (_productionType) {
        case WXYZ_ProductionTypeBook:
        case WXYZ_ProductionTypeAi:
        {
            url = Book_Buy_Chapter;
            [parameters setObject:[WXYZ_UtilsHelper formatStringWithInteger:_chapterModel.production_id] forKey:@"book_id"];
            [parameters setObject:[WXYZ_UtilsHelper formatStringWithInteger:_chapterModel.chapter_id] forKey:@"chapter_id"];
            [parameters setObject:[WXYZ_UtilsHelper formatStringWithInteger:_buyChapterNum] forKey:@"num"];
        }
            break;
        case WXYZ_ProductionTypeComic:
        {
            url = Comic_Buy_Chapter;
            [parameters setObject:[WXYZ_UtilsHelper formatStringWithInteger:_chapterModel.production_id] forKey:@"comic_id"];
            
            if (_barType == WXYZ_BottomPayBarTypeDownload) {
                [parameters setObject:[_chapterModel.chapter_ids componentsJoinedByString:@","] forKey:@"chapter_id"];
                
            } else {
                [parameters setObject:[WXYZ_UtilsHelper formatStringWithInteger:_chapterModel.chapter_id] forKey:@"chapter_id"];
                [parameters setObject:[WXYZ_UtilsHelper formatStringWithInteger:_buyChapterNum] forKey:@"num"];
            }
        }
            break;
        case WXYZ_ProductionTypeAudio:
        {
            url = Audio_Buy_Chapter;
            [parameters setObject:[WXYZ_UtilsHelper formatStringWithInteger:_chapterModel.production_id] forKey:@"audio_id"];
            [parameters setObject:[WXYZ_UtilsHelper formatStringWithInteger:_buyChapterNum] forKey:@"num"];
            
            if (_barType == WXYZ_BottomPayBarTypeDownload) {
                [parameters setObject:[_chapterModel.chapter_ids componentsJoinedByString:@","] forKey:@"chapter_id"];
            } else {
                [parameters setObject:[WXYZ_UtilsHelper formatStringWithInteger:_chapterModel.chapter_id] forKey:@"chapter_id"];
            }
        }
            break;
            
        default:
            break;
    }
    
    [WXYZ_NetworkRequestManger POST:url parameters:parameters model:nil success:^(BOOL isSuccess, id  _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {

            NSArray<NSString *> *t_arr = [requestModel.data objectForKey:@"chapter_ids"];
            if (self.paySuccessChaptersBlock) {
                self.paySuccessChaptersBlock(t_arr);
            }
            
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"购买成功"];
            NSInteger index = [WXYZ_ReaderBookManager sharedManager].currentChapterIndex;
            for (NSInteger i = index; i < index + t_arr.count; i++) {
                [WXYZ_ReaderBookManager sharedManager].bookModel.chapter_list[index].is_preview = NO;
            }
            if (_productionType == WXYZ_ProductionTypeBook || _productionType == WXYZ_ProductionTypeAi) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Retry_Chapter object:nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Production_Pay_Success object:t_arr];
            
        } else {
            !self.payFailChaptersBlock ?: self.payFailChaptersBlock(_chapterModel.chapter_ids);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
    }];
}

@end

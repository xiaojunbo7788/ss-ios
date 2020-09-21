//
//  WXYZ_ComicListDetailViewController.m
//  WXReader
//
//  Created by Andrew on 2019/5/29.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicListDetailViewController.h"
#import "WXYZ_CommentsViewController.h"

#import "WXYZ_ComicIntroductionTableViewCell.h"
#import "WXYZ_CommentsTableViewCell.h"
#import "WXYZ_ComicNormalStyleTableViewCell.h"
#import "WXYZ_PublicADStyleTableViewCell.h"
#import "WXYZ_ComicInfoListTableViewCell.h"
#import "WXYZ_ComicInfoListStringTableViewCell.h"
#import "WXYZ_TagBookViewController.h"
@interface WXYZ_ComicListDetailViewController () <UITableViewDelegate, UITableViewDataSource,WXYZ_ComicInfoListTableViewCellDelegate>

@property (nonatomic, strong) UIButton *sectionBottomCommentButton;

@property (nonatomic, strong) NSArray *sectionTagArray;

@property (nonatomic, strong) NSMutableArray *detailListArray;

@end

@implementation WXYZ_ComicListDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
}

- (void)initialize
{
    [self hiddenNavigationBar:YES];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)createSubviews
{
    self.mainTableViewGroup.delegate = self;
    self.mainTableViewGroup.dataSource = self;
    [self.view addSubview:self.mainTableViewGroup];
    
    [self.mainTableViewGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSMutableArray *t_sectionTagArray = [NSMutableArray array];
    
    // 简介
    if (self.detailModel.productionModel.production_descirption.length > 0) {
        [t_sectionTagArray addObject:@"descirption"];
    } else {
        [t_sectionTagArray addObject:@"descirption"];
    }
    
    // 广告
    if (self.detailModel.advert.ad_type != 0) {
        [t_sectionTagArray addObject:@"ad"];
    }
    
    // 评论
#if WX_Comments_Mode
    [t_sectionTagArray addObject:@"comment"];
#endif
    
    // 猜你喜欢
    if (self.detailModel.label.count > 0) {
        [t_sectionTagArray addObject:@"label"];
    }
    
    self.sectionTagArray = [t_sectionTagArray copy];
    
    return t_sectionTagArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[self.sectionTagArray objectAtIndex:section] isEqualToString:@"descirption"]) {
        
        return self.detailListArray.count + 1;
    }
    
    if ([[self.sectionTagArray objectAtIndex:section] isEqualToString:@"ad"]) {
        return 1;
    }
    
#if WX_Comments_Mode
    if ([[self.sectionTagArray objectAtIndex:section] isEqualToString:@"comment"]) {
        return self.detailModel.comment.count;
    }
#endif
    
    if ([[self.sectionTagArray objectAtIndex:section] isEqualToString:@"label"]) {
        return self.detailModel.label.count;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.sectionTagArray objectAtIndex:indexPath.section] isEqualToString:@"descirption"]) {
        
        if (indexPath.row < self.detailListArray.count) {
            return [self createInfoListStyleCellWithTableView:tableView atIndexPath:indexPath];
        }
        
        return [self createIntroductionStyleCellWithTableView:tableView atIndexPath:indexPath labelModel:self.detailModel.productionModel];
    }
    
    if ([[self.sectionTagArray objectAtIndex:indexPath.section] isEqualToString:@"ad"]) {
        return [self createADCellWithTableView:tableView atIndexPath:indexPath];
    }
    
#if WX_Comments_Mode
    if ([[self.sectionTagArray objectAtIndex:indexPath.section] isEqualToString:@"comment"]) {
        WXYZ_CommentsDetailModel *commentModel = [self.detailModel.comment objectOrNilAtIndex:indexPath.row];
        return [self createCommentCellWithTableView:tableView atIndexPath:indexPath labelModel:commentModel];
    }
#endif
    
    if ([[self.sectionTagArray objectAtIndex:indexPath.section] isEqualToString:@"label"]) {
        WXYZ_MallCenterLabelModel *labelModel = [self.detailModel.label objectOrNilAtIndex:indexPath.row];
        return [self createNormalStyleComicCellWithTableView:tableView atIndexPath:indexPath labelModel:labelModel];
    }
    
    return [[UITableViewCell alloc] init];
}

- (UITableViewCell *)createIntroductionStyleCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath labelModel:(WXYZ_ProductionModel *)comicModel
{
    static NSString *cellName = @"WXYZ_ComicIntroductionTableViewCell";
    WXYZ_ComicIntroductionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_ComicIntroductionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.comicModel = comicModel;
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
            cell.delegate = self;
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

- (UITableViewCell *)createNormalStyleComicCellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath labelModel:(WXYZ_MallCenterLabelModel *)labelModel
{
    WS(weakSelf)
    static NSString *cellName = @"WXYZ_ComicNormalStyleTableViewCell";
    WXYZ_ComicNormalStyleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_ComicNormalStyleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.labelModel = labelModel;
    cell.cellDidSelectItemBlock = ^(NSInteger production_id) {
        if (weakSelf.pushToComicDetailBlock) {
            weakSelf.pushToComicDetailBlock(production_id);
        }
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
    [cell setIsPreview:YES lastRow:(self.detailModel.comment.count - 1 == indexPath.row)];
    cell.hiddenEndLine = NO;
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
    [cell setAdModel:self.detailModel.advert refresh:NO];
    cell.mainTableView = tableView;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
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
        
        if (self.detailModel.advert.ad_type == 0) {
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
        if (self.detailModel.productionModel.total_comment == 0) {
            [self.sectionBottomCommentButton setTitle:@"暂无评论，点击抢沙发" forState:UIControlStateNormal];
        } else {
            [self.sectionBottomCommentButton setTitle:[NSString stringWithFormat:@"查看全部评论(%@条)", [WXYZ_UtilsHelper formatStringWithInteger:self.detailModel.productionModel.total_comment]] forState:UIControlStateNormal];
        }
        
        [view addSubview:self.sectionBottomCommentButton];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.sectionBottomCommentButton.frame) + kHalfMargin, SCREEN_WIDTH, 10)];
        lineView.backgroundColor = kGrayViewColor;
        [view addSubview:lineView];
    }
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.sectionTagArray objectAtIndex:indexPath.section] isEqualToString:@"comment"]) {
        [self commentWithComment_id:[[self.detailModel.comment objectOrNilAtIndex:indexPath.row] comment_id]];
    }
}

- (void)commentClick
{
    [self commentWithComment_id:0];
}

- (void)commentWithComment_id:(NSInteger)comment_id
{
    WS(weakSelf)
    WXYZ_CommentsViewController *vc = [[WXYZ_CommentsViewController alloc] init];
    vc.production_id = self.detailModel.productionModel.production_id;
    vc.comment_id = comment_id;
    vc.productionType = WXYZ_ProductionTypeComic;
    vc.commentsSuccessBlock = ^(WXYZ_CommentsDetailModel *commentModel) {
        NSMutableArray *array = [weakSelf.detailModel.comment mutableCopy];
        [array insertObject:commentModel atIndex:0];
        weakSelf.detailModel.comment = [array copy];
        weakSelf.detailModel.productionModel.total_comment ++;
        [weakSelf.mainTableViewGroup reloadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
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

- (void)setDetailModel:(WXYZ_ComicMallDetailModel *)detailModel
{
    _detailModel = detailModel;
    
    self.detailListArray = [NSMutableArray array];
    // 作者
    if (self.detailModel.productionModel.author.length > 0) {
        NSMutableArray *t_authorArr = [NSMutableArray array];
        for (WXYZ_AuthorModel *t_author in self.detailModel.productionModel.author2) {
            [t_authorArr addObject:t_author];
        }
         [self.detailListArray addObject:@{@"作者":t_authorArr}];
//        [self.detailListArray addObject:@{@"作者":[self.detailModel.productionModel.author componentsSeparatedByString:@","]}];
    }
    // 标签
    if (self.detailModel.productionModel.tag.count > 0) {
        
        NSMutableArray *t_tagArr = [NSMutableArray array];
        for (WXYZ_TagModel *t_tag in self.detailModel.productionModel.tag) {
            [t_tagArr addObject:t_tag.tab];
        }
        
        [self.detailListArray addObject:@{@"标签":t_tagArr}];
    }
    
    // 分类
    if (self.detailModel.productionModel.tags.count > 0) {
        [self.detailListArray addObject:@{@"分类":self.detailModel.productionModel.tags}];
    }
    
    // 原著
    if (self.detailModel.productionModel.original.length > 0) {
        NSMutableArray *t_originalArr = [[NSMutableArray alloc] init];
        for (WXYZ_OriginalModel *t_original in self.detailModel.productionModel.original2) {
                [t_originalArr addObject:t_original];
        }
        [self.detailListArray addObject:@{@"原著":t_originalArr}];
//        [self.detailListArray addObject:@{@"原著":@[self.detailModel.productionModel.original]}];
    }
    
    // 汉化组
    if (self.detailModel.productionModel.sinici.length > 0) {
        NSMutableArray *t_siniciArr = [[NSMutableArray alloc] init];
        for (WXYZ_AuthorSiniciModel *t_sinici in self.detailModel.productionModel.sinici2) {
                [t_siniciArr addObject:t_sinici];
        }
        [self.detailListArray addObject:@{@"汉化组":t_siniciArr}];
//        [self.detailListArray addObject:@{@"汉化组":@[self.detailModel.productionModel.sinici]}];
    }
    
    // 创建日期
    if (self.detailModel.productionModel.created_at.length > 0) {
        [self.detailListArray addObject:@{@"创建日期":self.detailModel.productionModel.created_at}];
    }
    
    // 最后修改
    if (self.detailModel.productionModel.last_chapter_time.length > 0) {
        [self.detailListArray addObject:@{@"最后修改":self.detailModel.productionModel.last_chapter_time}];
    }
    
    // 作品简介
    if (self.detailModel.productionModel.last_chapter_time.length > 0) {
        [self.detailListArray addObject:@{@"作品简介":@""}];
    }
    
    [self.mainTableViewGroup reloadData];
}


- (void)gotoTagList:(int)classType withTitle:(NSString *)title {
    WXYZ_TagBookViewController *vc = [[WXYZ_TagBookViewController alloc] init];
    vc.classType = classType;
    vc.tagTitle = title;
//    vc._id = dic[@"id"];
    [self.navigationController pushViewController:vc animated:true];
}

@end

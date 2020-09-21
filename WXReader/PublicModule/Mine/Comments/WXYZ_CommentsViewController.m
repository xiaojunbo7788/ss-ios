//
//  WXYZ_CommentsViewController.m
//  WXReader
//
//  Created by Andrew on 2018/6/26.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_CommentsViewController.h"
#import "WXYZ_CommentsTableViewCell.h"

#import "CXTextView.h"

#import "WXYZ_CommentsViewController.h"

@interface WXYZ_CommentsViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextViewDelegate>
{
    CGFloat keyboardHeight;     //键盘高度
    CGFloat commentViewHeight;
}

@property (nonatomic, strong) CXTextView *commentTextView;

@property (nonatomic, strong) UIView *commentBottomView;

@property (nonatomic, strong) WXYZ_CommentsModel *commentModel;

@end

@implementation WXYZ_CommentsViewController

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
    if (self.chapter_id > 0) {
        if (self.productionType == WXYZ_ProductionTypeComic) {
            [self setNavigationBarTitle:@"评论"];
        } else {
            [self setNavigationBarTitle:@"本章评论（0）"];
        }
    } else {
        [self setNavigationBarTitle:@"书评（0）"];
    }
    commentViewHeight = 30;
    
    NSArray *viewcontrollers = self.navigationController.viewControllers;
    if (viewcontrollers.count <= 1) {
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(kHalfMargin, PUB_NAVBAR_OFFSET + 20, 44, 44);
        closeButton.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12);
        [closeButton setImage:[UIImage imageNamed:@"public_close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
        
        [self setNavigationBarLeftButton:closeButton];
    }
    
    if (self.pushFromReader) {
        id target = self.navigationController.interactivePopGestureRecognizer.delegate;
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:target action:NSSelectorFromString(@"handleNavigationTransition:")];
        panGesture.delegate = self; // 设置手势代理，拦截手势触发
        [self.view addGestureRecognizer:panGesture];
        
        // 一定要禁止系统自带的滑动手势
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netRequest) name:Notification_Reload_BookDetail object:nil];
    
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)name:UIKeyboardWillHideNotification object:nil];
}

- (void)createSubviews
{
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    [self.view addSubview:self.mainTableView];
    
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_height).with.offset(- PUB_NAVBAR_HEIGHT - PUB_TABBAR_HEIGHT);
    }];
    
    self.commentBottomView = [[UIView alloc] init];
    self.commentBottomView.backgroundColor = kGrayViewColor;
    [self.view addSubview:self.commentBottomView];
    
    [self.commentBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(self.view.mas_bottom);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT);
    }];
    
    
    WS(weakSelf)
    self.commentTextView = [[CXTextView alloc] initWithFrame:CGRectMake(kHalfMargin, kQuarterMargin, SCREEN_WIDTH - kMargin, 30)];
    self.commentTextView.placeholder = @"说点什么吧";
    self.commentTextView.maxLine = 5;
    self.commentTextView.maxLength = 200;
    self.commentTextView.font = kMainFont;
    self.commentTextView.backgroundColor = [UIColor whiteColor];
    self.commentTextView.layer.cornerRadius = 15;
    self.commentTextView.textHeightChangeBlock = ^(CGFloat height) {
        SS(strongSelf)
        strongSelf->commentViewHeight = height;
        
        [weakSelf.commentBottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(strongSelf->keyboardHeight + height + kHalfMargin);
        }];
    };
    self.commentTextView.returnHandlerBlock = ^{
        [weakSelf sendCommentNetRequest];
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    };
    [self.commentBottomView addSubview:self.commentTextView];
    
    
    [self.mainTableView addHeaderRefreshWithRefreshingBlock:^{
        weakSelf.currentPageNumber = 1;
        [weakSelf netRequest];
    }];
    
    [self.mainTableView addFooterRefreshWithRefreshingBlock:^{
        weakSelf.currentPageNumber ++;
        [weakSelf netRequest];
    }];
    
    [self setEmptyOnView:self.mainTableView title:@"暂无评论内容" tapBlock:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"WXYZ_CommentsTableViewCell";
    WXYZ_CommentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[WXYZ_CommentsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.commentModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.hiddenEndLine = indexPath.row == self.dataSourceArray.count - 1;
    
    if (self.chapter_id > 0) {
        if (self.productionType == WXYZ_ProductionTypeComic) {
            [self setNavigationBarTitle:[NSString stringWithFormat:@"评论"]];
        } else {
            [self setNavigationBarTitle:[NSString stringWithFormat:@"本章评论（%@）",[WXYZ_UtilsHelper formatStringWithInteger:self.commentModel.total_count]]];
        }
    } else {
        [self setNavigationBarTitle:[NSString stringWithFormat:@"书评（%@）",[WXYZ_UtilsHelper formatStringWithInteger:self.commentModel.total_count]]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_CommentsDetailModel *t_model = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    [self.commentTextView textViewBecomeFirstResponder];
    self.comment_id = t_model.comment_id;
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
    return CGFLOAT_MIN;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.mainTableView) {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
}

- (void)setComment_id:(NSInteger)comment_id
{
    _comment_id = comment_id;
    
    [self resetCommentTextViewPlaceHolder];
}

- (void)resetCommentTextViewPlaceHolder
{
    if (!self.dataSourceArray || self.dataSourceArray.count == 0) {
        return;
    }
    for (WXYZ_CommentsDetailModel *t_model in self.dataSourceArray) {
        if (t_model.comment_id == self.comment_id) {
            self.commentTextView.placeholder = [NSString stringWithFormat:@"回复 ＠%@", [WXYZ_UtilsHelper formatStringWithObject:t_model.nickname]];
            break;
        }
    }
}


//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)noti
{
    //获取键盘的高度
    keyboardHeight = [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    [self.commentBottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(keyboardHeight + commentViewHeight + kHalfMargin + kQuarterMargin);
    }];
    [self.commentBottomView.superview layoutIfNeeded];
}

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)noti
{
    keyboardHeight = PUB_TABBAR_OFFSET;
    [self.commentBottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(commentViewHeight + PUB_TABBAR_OFFSET + (PUB_TABBAR_HEIGHT - PUB_TABBAR_OFFSET - 30));
    }];
    [self.commentBottomView.superview layoutIfNeeded];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (![self.commentBottomView pointInside:[self.commentBottomView convertPoint:[[touches anyObject] locationInView:self.view] fromView:self.view] withEvent:event]) {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
}

- (void)netRequest
{
    NSString *url = @"";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    switch (self.productionType) {
        case WXYZ_ProductionTypeBook:
            url = Book_Comment_List;
            parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"book_id":[WXYZ_UtilsHelper formatStringWithInteger:self.production_id]?:@"", @"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber]}];
            break;
        case WXYZ_ProductionTypeComic:
            url = Comic_Comment_List;
            parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"comic_id":[WXYZ_UtilsHelper formatStringWithInteger:self.production_id]?:@"", @"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber]}];
            break;
        case WXYZ_ProductionTypeAudio:
            url = Audio_Comment_List;
            parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"audio_id":[WXYZ_UtilsHelper formatStringWithInteger:self.production_id]?:@"", @"page_num":[WXYZ_UtilsHelper formatStringWithInteger:self.currentPageNumber]}];
            break;
            
        default:
            break;
    }
    
    if (self.chapter_id > 0) {
        [parameters setObject:[WXYZ_UtilsHelper formatStringWithInteger:self.chapter_id]?:@"" forKey:@"chapter_id"];
    }
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:url parameters:parameters model:WXYZ_CommentsModel.class success:^(BOOL isSuccess, WXYZ_CommentsModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            if (weakSelf.currentPageNumber == 1) {
                [weakSelf.mainTableView showRefreshFooter];
                [weakSelf.dataSourceArray removeAllObjects];
                weakSelf.dataSourceArray = [NSMutableArray arrayWithArray:t_model.list];
            } else {
                [weakSelf.dataSourceArray addObjectsFromArray:t_model.list];
            }
            if (t_model.total_page <= t_model.current_page) {
                [weakSelf.mainTableView hideRefreshFooter];
            }
            
            [weakSelf resetCommentTextViewPlaceHolder];
            
            weakSelf.commentModel = t_model;
        } else {
            [weakSelf.mainTableView hideRefreshFooter];
        }
        [weakSelf.mainTableView endRefreshing];
        [weakSelf.mainTableView reloadData];
        [weakSelf.mainTableView ly_endLoading];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf.mainTableView endRefreshing];
        [weakSelf.mainTableView ly_endLoading];
        [weakSelf.mainTableView hideRefreshFooter];
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
    }];
}

- (void)sendCommentNetRequest
{
    if (!WXYZ_UserInfoManager.isLogin) {
        WXYZ_AlertView *alert = [[WXYZ_AlertView alloc] init];
        alert.alertViewDetailContent = @"登录后才可以进行评论";
        alert.alertViewConfirmTitle = @"去登录";
        alert.alertViewCancelTitle = @"暂不";
        alert.confirmButtonClickBlock = ^{
            [WXYZ_LoginViewController presentLoginView];
        };
        [alert showAlertView];
        return;
    }
    
    if ([self.commentTextView.text isEqualToString:@""]) {
        return;
    }
    
    NSString *t_text = self.commentTextView.text;
    self.commentTextView.text = @"";
    
    NSString *url = @"";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    switch (self.productionType) {
        case WXYZ_ProductionTypeBook:
            url = Book_Comment_Post;
            parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"book_id":[WXYZ_UtilsHelper formatStringWithInteger:self.production_id]?:@"", @"content":t_text}];
            break;
        case WXYZ_ProductionTypeComic:
            url = Comic_Comment_Post;
            parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"comic_id":[WXYZ_UtilsHelper formatStringWithInteger:self.production_id]?:@"", @"content":t_text}];
            break;
        case WXYZ_ProductionTypeAudio:
            url = Audio_Comment_Post;
            parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"audio_id":[WXYZ_UtilsHelper formatStringWithInteger:self.production_id]?:@"", @"content":t_text}];
            break;
            
        default:
            break;
    }
    
    if (self.chapter_id > 0) {
        [parameters setObject:[WXYZ_UtilsHelper formatStringWithInteger:self.chapter_id] forKey:@"chapter_id"];
    }
    
    if (self.comment_id && self.comment_id != 0) {
        [parameters setObject:[WXYZ_UtilsHelper formatStringWithInteger:self.comment_id] forKey:@"comment_id"];
    }
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:url parameters:parameters model:WXYZ_CommentsDetailModel.class success:^(BOOL isSuccess, WXYZ_CommentsDetailModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            weakSelf.comment_id = 0;
            
            weakSelf.commentTextView.placeholder = @"说点什么吧";
            
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"评论成功"];
            
            !weakSelf.commentsSuccessBlock ?: weakSelf.commentsSuccessBlock(t_model);
            
            if (t_model) {
                [weakSelf.dataSourceArray insertObject:t_model atIndex:0];
            }
            
            weakSelf.commentModel.total_count++;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeComment" object:[NSString stringWithFormat:@"%zd", weakSelf.commentModel.total_count]];
            
            [weakSelf.mainTableView reloadData];
            [weakSelf.mainTableView ly_endLoading];
            
        } else if (Compare_Json_isEqualTo(requestModel.code, 315)) {
            weakSelf.comment_id = 0;
            weakSelf.commentTextView.placeholder = @"说点什么吧";
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:requestModel.msg];
        }  else if (Compare_Json_isEqualTo(requestModel.code, 318)) {
            weakSelf.commentTextView.text = @"";
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        } else {
            weakSelf.commentTextView.text = t_text;
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:@"评论失败"];
    }];
}

- (void)popViewController
{
    [super popViewController];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

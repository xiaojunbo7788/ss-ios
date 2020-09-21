//
//  WXYZ_InsterestBooksViewController.m
//  WXReader
//
//  Created by Andrew on 2018/11/16.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "WXYZ_InsterestBooksViewController.h"
#import "WXYZ_InsterestBookModel.h"

#import "WXYZ_ProductionCollectionManager.h"

#import "NSMutableArray+KVO.h"

@interface WXYZ_InsterestBooksViewController ()
{
    UIScrollView *scrollView;
    UIButton *nextStepButton;
    NSMutableArray *addBookArray;
}

@end

@implementation WXYZ_InsterestBooksViewController

- (instancetype)init
{
    if (self = [super init]) {
        [self initialize];
        [self createSubviews];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self hiddenNavigationBar:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarDefaultStyle];
}

- (void)initialize
{
    addBookArray = [NSMutableArray array];
    self.view.backgroundColor = kWhiteColor;
}

- (void)createSubviews
{
    YYLabel *titleTop = [[YYLabel alloc] init];
    titleTop.text = @"独特的你";
    titleTop.textColor = kBlackColor;
    titleTop.textAlignment = NSTextAlignmentCenter;
    titleTop.textVerticalAlignment = YYTextVerticalAlignmentBottom;
    titleTop.font = kFont18;
    [self.view addSubview:titleTop];
    
    [titleTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(PUB_NAVBAR_OFFSET);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(65);
    }];
    
    YYLabel *titleBottom = [[YYLabel alloc] init];
    titleBottom.text = @"请选择你感兴趣的书籍";
    titleBottom.textColor = kGrayTextColor;
    titleBottom.textAlignment = NSTextAlignmentCenter;
    titleBottom.textVerticalAlignment = YYTextVerticalAlignmentTop;
    titleBottom.font = kMainFont;
    [self.view addSubview:titleBottom];
    
    [titleBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleTop.mas_bottom).with.offset(kHalfMargin);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(titleTop.mas_height);
    }];
    
    nextStepButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextStepButton.backgroundColor = kColorRGBA(218, 218, 218, 1);
    nextStepButton.layer.cornerRadius = 20;
    nextStepButton.userInteractionEnabled = NO;
    [nextStepButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [nextStepButton setTitle:@"完成" forState:UIControlStateNormal];
    [nextStepButton addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextStepButton];
    WS(weakSelf)
    addBookArray.changeBlock = ^(NSMutableArray * _Nonnull newVal) {
        SS(strongSelf)
        if (newVal.count <= 0) {
            strongSelf->nextStepButton.backgroundColor = kColorRGBA(218, 218, 218, 1);
            strongSelf->nextStepButton.userInteractionEnabled = NO;
        } else {
            strongSelf->nextStepButton.backgroundColor = kMainColor;
            strongSelf->nextStepButton.userInteractionEnabled = YES;
        }
    };
    
    [nextStepButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).with.offset(- PUB_NAVBAR_OFFSET - kMargin);
        make.left.mas_equalTo(2 * kMargin);
        make.width.mas_equalTo(self.view.mas_width).with.offset(- 4 * kMargin);
        make.height.mas_equalTo(40);
    }];
    
    scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:scrollView];
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.top.mas_equalTo(titleBottom.mas_bottom);
        make.bottom.mas_equalTo(nextStepButton.mas_top).with.offset(- kMargin);
    }];
}

- (void)setProductionArray:(NSArray *)productionArray
{
    _productionArray = productionArray;
    
    if (productionArray.count == 0) {
        return;
    }
    
    int buttonNum = 3;                  // 每行多少按钮
    CGFloat button_W = BOOK_WIDTH;      // 按钮宽
    CGFloat button_H = BOOK_HEIGHT + BOOK_CELL_TITLE_HEIGHT + kQuarterMargin;   // 按钮高
    CGFloat margin_X = kHalfMargin; // 第一个按钮的X坐标
    CGFloat margin_Y = 0;               // 第一个按钮的Y坐标
    CGFloat space_X = kHalfMargin;  // 按钮间距
    CGFloat space_Y = kMargin;  // 行间距
    
    [scrollView setContentSize:CGSizeMake(0, productionArray.count < 4?(button_H + space_Y):2 * (button_H + space_Y))];
    
    for (int i = 0; i < (productionArray.count <= 6?productionArray.count:6); i++) {
        int row = i / buttonNum;//行号
        int loc = i % buttonNum;//列号
        CGFloat button_X = margin_X + (space_X + button_W) * loc;
        CGFloat button_Y = margin_Y + (space_Y + button_H) * row;
        
        WXYZ_ProductionModel *t_model = [productionArray objectOrNilAtIndex:i];
        
        UIButton *bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        bottomButton.frame = CGRectMake(button_X, button_Y, button_W, button_H);
        bottomButton.tag = i;
        bottomButton.backgroundColor = [UIColor clearColor];
        [bottomButton addTarget:self action:@selector(bookButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        bottomButton.selected = YES;
        [scrollView addSubview:bottomButton];
        
        WXYZ_ProductionCoverView *bookImageView = [[WXYZ_ProductionCoverView alloc] initWithProductionType:t_model.productionType productionCoverDirection:WXYZ_ProductionCoverDirectionVertical];
        bookImageView.coverImageURL = t_model.cover;
        bookImageView.userInteractionEnabled = NO;
        [bottomButton addSubview:bookImageView];
        
        [bookImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(bottomButton.mas_centerX);
            make.top.mas_equalTo(bottomButton.mas_top);
            make.width.mas_equalTo(BOOK_WIDTH);
            make.height.mas_equalTo(BOOK_HEIGHT);
        }];
        
        UILabel *connerLabel = [[UILabel alloc] init];
        connerLabel.font = kFont10;
        connerLabel.layer.cornerRadius = 4.0f;
        connerLabel.textAlignment = NSTextAlignmentCenter;
        connerLabel.textColor = kWhiteColor;
        connerLabel.clipsToBounds = YES;
        [bookImageView addSubview:connerLabel];
        
        [connerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(bookImageView.mas_right).with.offset(- kQuarterMargin);
            make.top.mas_equalTo(bookImageView.mas_top).with.offset(kQuarterMargin);
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(20);
        }];
        
        if (t_model.productionType == WXYZ_ProductionTypeBook) {
            connerLabel.backgroundColor = kMainColor;
            connerLabel.text = @"小说";
        }
        
        if (t_model.productionType == WXYZ_ProductionTypeComic) {
            connerLabel.backgroundColor = kRedColor;
            connerLabel.text = @"漫画";
        }
        
        if (t_model.productionType == WXYZ_ProductionTypeAudio) {
            connerLabel.backgroundColor = [UIColor colorWithHexString:@"#56a0ef"];
            connerLabel.text = @"听书";
        }

        UILabel *bookTitleLabel = [[UILabel alloc] init];
        bookTitleLabel.numberOfLines = 2;
        bookTitleLabel.text = t_model.name;
        bookTitleLabel.backgroundColor = kWhiteColor;
        bookTitleLabel.font = kMainFont;
        bookTitleLabel.textAlignment = NSTextAlignmentLeft;
        bookTitleLabel.textColor = kBlackColor;
        [bottomButton addSubview:bookTitleLabel];
        
        [bookTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(bookImageView.mas_left);
            make.top.mas_equalTo(bookImageView.mas_bottom).with.offset(kQuarterMargin);
            make.width.mas_equalTo(bookImageView.mas_width);
            make.height.mas_equalTo(BOOK_CELL_TITLE_HEIGHT);
        }];
        
        UIImageView *selectView = [[UIImageView alloc] init];
        selectView.userInteractionEnabled = YES;
        selectView.image = [UIImage imageNamed:@"audio_download_select"];
        [bottomButton addSubview:selectView];
        
        [selectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(bookImageView.mas_right).with.offset(- 5);
            make.bottom.mas_equalTo(bookImageView.mas_bottom).with.offset(- 5);
            make.height.width.mas_equalTo(18);
        }];
    }
    
    [addBookArray KVO_addObjectsFromArray:productionArray];
}

- (void)bookButtonClick:(UIButton *)sender
{
    WXYZ_ProductionModel *t_books = [self.productionArray objectOrNilAtIndex:sender.tag];
    if (sender.selected) {
        [sender.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[WXYZ_ProductionCoverView class]]) {
                obj.alpha = 0.5;
            }
            
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *t_obj = (UIImageView *)obj;
                t_obj.image = [UIImage imageNamed:@"audio_download_unselect"];
                *stop = YES;
            }
        }];
        [addBookArray KVO_removeObject:t_books];
    } else {
        [sender.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[WXYZ_ProductionCoverView class]]) {
                obj.alpha = 1;
            }
            
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *t_obj = (UIImageView *)obj;
                t_obj.image = [UIImage imageNamed:@"audio_download_select"];
                *stop = YES;
            }
        }];
        [addBookArray KVO_addObject:t_books];
    }
    sender.selected = !sender.selected;
}

- (void)nextStep
{
    for (WXYZ_ProductionModel *t_model in addBookArray) {
        switch (t_model.productionType) {
            case WXYZ_ProductionTypeBook:
                [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] addCollectionWithProductionModel:t_model atIndex:0];
                break;
            case WXYZ_ProductionTypeComic:
                [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] addCollectionWithProductionModel:t_model];
                break;
            case WXYZ_ProductionTypeAudio:
                [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] addCollectionWithProductionModel:t_model];
                break;
                
            default:
                break;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Insterest_Change object:@"step_two"];
}

@end

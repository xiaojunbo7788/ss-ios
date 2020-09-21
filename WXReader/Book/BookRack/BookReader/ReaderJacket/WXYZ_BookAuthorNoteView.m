//
//  WXYZ_BookAuthorNoteView.m
//  WXReader
//
//  Created by LL on 2020/6/2.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BookAuthorNoteView.h"

#import "WXYZ_ReaderSettingHelper.h"
#import "WXYZ_ReaderBookManager.h"
#import "WXYZ_GiftView.h"
#import "AppDelegate.h"

#import "WXYZ_CommentsViewController.h"

@interface WXYZ_BookAuthorNoteView ()

@property (nonatomic, strong) WXYZ_BookAuthorNoteModel *noteModel;

@property (nonatomic, weak) UIButton *firstBtn;

@property (nonatomic, strong) NSArray<UIButton *> *btnArr;

@property (nonatomic, weak) UIView *mainView;

@property (nonatomic, weak) UIButton *commentBtn;

@property (nonatomic, weak) UIButton *rewardBtn;

@property (nonatomic, weak) UIButton *ticketBtn;

@end

@implementation WXYZ_BookAuthorNoteView

- (instancetype)initWithFrame:(CGRect)frame notoModel:(WXYZ_BookAuthorNoteModel *)noteModel {
    if (self = [super initWithFrame:frame]) {
        self.noteModel = noteModel;
        [self netRequest];
        [self initialize];
        [self createSubviews];
    }
    return self;
}

- (void)initialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeComment:) name:@"changeComment" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rewardEvent:) name:@"changeReward" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ticketEvent:) name:@"changeTicket" object:nil];
}

- (void)netRequest {
    
    NSDictionary *params = @{
        @"book_id" : @([WXYZ_ReaderBookManager sharedManager].book_id),
        @"chapter_id" : @([WXYZ_ReaderBookManager sharedManager].chapter_id),
        @"scroll_type" : @"1",
    };
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Book_New_Catalog parameters:params model:WXYZ_CatalogModel.class success:^(BOOL isSuccess, WXYZ_CatalogModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        weakSelf.noteModel.reward_num = [NSString stringWithFormat:@"%zd", t_model.list.firstObject.reward_num];
        weakSelf.noteModel.ticket_num = [NSString stringWithFormat:@"%zd", t_model.list.firstObject.ticket_num];
        weakSelf.noteModel.comment_num = [NSString stringWithFormat:@"%zd", t_model.list.firstObject.comment_num];
        
        [weakSelf.rewardBtn setAttributedTitle:[self atrbuteStringWithDict:@{@"打赏" : @"reward_num"}] forState:UIControlStateNormal];
        [weakSelf.ticketBtn setAttributedTitle:[self atrbuteStringWithDict:@{@"月票" : @"ticket_num"}] forState:UIControlStateNormal];
        [weakSelf.commentBtn setAttributedTitle:[self atrbuteStringWithDict:@{@"评论" : @"comment_num"}] forState:UIControlStateNormal];
    } failure:nil];
}

- (void)createSubviews {
    self.backgroundColor = [UIColor clearColor];
    
    UIView *mainView = nil;
    if (self.noteModel.author_note.length > 0) {
        mainView = [[UIView alloc] init];
        self.mainView = mainView;
        mainView.backgroundColor = [[[WXYZ_ReaderSettingHelper sharedManager] getReaderTextColor] colorWithAlphaComponent:0.2];
        mainView.layer.cornerRadius = 5.0f;
        mainView.layer.masksToBounds = YES;
        [self addSubview:mainView];
        [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(self);
        }];
        
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = kColorRGB(83, 59, 37);
        [mainView addSubview:backView];
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(mainView);
            make.top.equalTo(mainView).offset(11);
            make.size.mas_equalTo(CGSizeMake(3.0, 19.0));
        }];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = [[WXYZ_ReaderSettingHelper sharedManager] getReaderTextColor];
        titleLabel.font = kFont14;
        titleLabel.text = @"作家的话";
        [mainView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(backView);
            make.left.equalTo(backView.mas_right).offset(kHalfMargin);
            make.right.equalTo(mainView);
        }];
        
        UIImageView *coverImageView = [[UIImageView alloc] init];
        [coverImageView setImageWithURL:[NSURL URLWithString:self.noteModel.author_avatar] placeholder:HoldImage];
        coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        coverImageView.clipsToBounds = YES;
        coverImageView.layer.cornerRadius = 12.0;
        coverImageView.layer.masksToBounds = YES;
        [mainView addSubview:coverImageView];
        [coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLabel);
            make.top.equalTo(titleLabel.mas_bottom).offset(14.0);
            make.size.mas_equalTo(CGSizeMake(24.0, 24.0));
        }];
        
        UILabel *authorLabel = [[UILabel alloc] init];
        authorLabel.textColor = [[WXYZ_ReaderSettingHelper sharedManager] getReaderTextColor];
        authorLabel.font = kFont14;
        authorLabel.text = self.noteModel.author_name;
        [mainView addSubview:authorLabel];
        [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(coverImageView);
            make.left.equalTo(coverImageView.mas_right).offset(kHalfMargin);
            make.right.equalTo(mainView);
        }];
        
        UILabel *descLabel = [[UILabel alloc] init];
        descLabel.textColor = [[WXYZ_ReaderSettingHelper sharedManager] getReaderTextColor];
        descLabel.font = kFont10;
        descLabel.numberOfLines = 0;
        descLabel.text = self.noteModel.author_note;
        [mainView addSubview:descLabel];
        [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(coverImageView.mas_bottom).offset(11.0);
            make.left.equalTo(coverImageView);
            make.right.equalTo(mainView).offset(-kHalfMargin);
            make.bottom.equalTo(mainView).offset(-kMoreHalfMargin);
        }];
    }
    
    NSMutableArray<NSDictionary *> *textArr = [NSMutableArray array];
    AppDelegate *delegate = (AppDelegate *)kRCodeSync([UIApplication sharedApplication].delegate);
    if (self.noteModel.reward_num.length > 0 && delegate.checkSettingModel.system_setting.novel_reward_switch == 1) {
        [textArr addObject:@{@"打赏" : @"reward_num"}];
    }
    if (self.noteModel.ticket_num.length > 0 && delegate.checkSettingModel.system_setting.monthly_ticket_switch == 1) {
        [textArr addObject:@{@"月票" : @"ticket_num"}];
    }
    if (self.noteModel.comment_num.length > 0) {
        [textArr addObject:@{@"评论" : @"comment_num"}];
    }
    
    if (textArr.count == 0) return;
    
    WS(weakSelf)
    NSMutableArray<UIButton *> *btnArr = [NSMutableArray array];
    [textArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setAttributedTitle:[self atrbuteStringWithDict:obj] forState:UIControlStateNormal];
        button.titleLabel.numberOfLines = 0;
        if ([obj.allKeys.firstObject isEqualToString:@"评论"]) {
            weakSelf.commentBtn = button;
        }
        if ([obj.allKeys.firstObject isEqualToString:@"打赏"]) {
            weakSelf.rewardBtn = button;
        }
        if ([obj.allKeys.firstObject isEqualToString:@"月票"]) {
            weakSelf.ticketBtn = button;
        }
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            if ([obj.allValues.firstObject isEqualToString:@"reward_num"]) {
                WXYZ_GiftView *mainView = [[WXYZ_GiftView alloc] initWithFrame:CGRectZero bookModel:[WXYZ_ReaderBookManager sharedManager].bookModel];
                mainView.giftNumBlock = ^(NSInteger giftNumber) {
                    weakSelf.noteModel.reward_num = [WXYZ_UtilsHelper formatStringWithInteger:giftNumber];
                    [button setAttributedTitle:[weakSelf atrbuteStringWithDict:obj] forState:UIControlStateNormal];
                };
                [mainView show];
            } else if ([obj.allValues.firstObject isEqualToString:@"ticket_num"]) {
                WXYZ_GiftView *mainView = [[WXYZ_GiftView alloc] initWithFrame:CGRectZero bookModel:[WXYZ_ReaderBookManager sharedManager].bookModel];
                mainView.ticketNumBlock = ^(NSInteger ticketNumber) {
                    weakSelf.noteModel.ticket_num = [WXYZ_UtilsHelper formatStringWithInteger:ticketNumber];
                    [button setAttributedTitle:[weakSelf atrbuteStringWithDict:obj] forState:UIControlStateNormal];
                };
                mainView.isTicket = YES;
                [mainView show];
            } else if ([obj.allValues.firstObject isEqualToString:@"comment_num"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Reader_Push object:@"WXYZ_CommentsViewController"];
            }
        }]];
        [self addSubview:button];
        [btnArr addObject:button];
    }];
    self.btnArr = btnArr;
    
    if (btnArr.count == 1 || btnArr.count == 0) {
        if (btnArr.count == 1) {
            [btnArr.firstObject mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self);
                make.centerX.equalTo(self);
            }];
        }
    } else {
        [btnArr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
        [btnArr mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
        }];
        
        [btnArr enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (btnArr.count == idx + 1) {
                *stop = YES;
            }
            UIView *splitLine = [[UIView alloc] init];
            splitLine.backgroundColor = kColorRGBA(83, 59, 37, 0.8);
            splitLine.hidden = btnArr.count == idx + 1;
            [obj addSubview:splitLine];
            [splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(22.0f);
                make.width.mas_equalTo(0.5f);
                make.right.equalTo(obj);
                make.centerY.equalTo(obj);
            }];
        }];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    self.firstBtn = btnArr.firstObject;
}

- (void)changeComment:(NSNotification *)noti {
    self.noteModel.comment_num = noti.object;
    [self.commentBtn setAttributedTitle:[self atrbuteStringWithDict:@{@"评论" : @"comment_num"}] forState:UIControlStateNormal];
}

- (void)rewardEvent:(NSNotification *)noti {
    self.noteModel.reward_num = noti.object;
    [self.rewardBtn setAttributedTitle:[self atrbuteStringWithDict:@{@"打赏" : @"reward_num"}] forState:UIControlStateNormal];
}

- (void)ticketEvent:(NSNotification *)noti {
    self.noteModel.ticket_num = noti.object;
    [self.ticketBtn setAttributedTitle:[self atrbuteStringWithDict:@{@"月票" : @"ticket_num"}] forState:UIControlStateNormal];
}

- (NSAttributedString *)atrbuteStringWithDict:(NSDictionary *)dict {
    NSString *text = dict.allKeys.firstObject;
    
    NSString *num = [self.noteModel performSelectorWithArgs:NSSelectorFromString(dict.allValues.firstObject)];
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", text, num] attributes:@{NSFontAttributeName : kFont10, NSForegroundColorAttributeName : [[WXYZ_ReaderSettingHelper sharedManager] getReaderTextColor]}];
    [atr addAttribute:NSFontAttributeName value:kFont14 range:NSMakeRange(0, text.length)];
    return atr;
}

- (void)setSpacing:(CGFloat)spacing {
    _spacing = spacing;
    if (spacing == -1) {
        CGFloat t_spacing = CGRectGetHeight(self.bounds);
        t_spacing = t_spacing - self.noteHeight + kHalfMargin;
        [self.btnArr mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mainView.mas_bottom).offset(t_spacing);
        }];
    }
}

- (CGFloat)noteHeight {
    CGFloat __block height = 0;
    if ([NSThread isMainThread]) {
        if (self.mainView) {
            height = CGRectGetHeight(self.mainView.bounds) + CGRectGetHeight(self.firstBtn.bounds) + kHalfMargin;
        } else {
            height = CGRectGetHeight(self.firstBtn.bounds);
        }
    } else {
        dispatch_semaphore_t signal = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.mainView) {
                height = CGRectGetHeight(self.mainView.bounds) + CGRectGetHeight(self.firstBtn.bounds) + kHalfMargin;
            } else {
                height = CGRectGetHeight(self.firstBtn.bounds);
            }
            dispatch_semaphore_signal(signal);
        });
        dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);
    }
    return height;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


@implementation WXYZ_BookAuthorNoteModel

@end

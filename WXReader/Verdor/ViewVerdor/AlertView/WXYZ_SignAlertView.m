//
//  DPSignAlertView.m
//  WXReader
//
//  Created by Andrew on 2018/11/8.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "WXYZ_SignAlertView.h"
#import "WXYZ_ProductionCollectionManager.h"

@implementation WXYZ_SignAlertView
{
    UIView *bookBackView;
}

- (void)createSubviews
{
    [super createSubviews];
    
    bookBackView = [[UIView alloc] init];
    bookBackView.backgroundColor = [UIColor clearColor];
    [self.alertBackView addSubview:bookBackView];
    
    self.alertViewCancelTitle = @"不用了";
    
    self.alertViewConfirmTitle = @"全部收藏";
    
    WS(weakSelf)
    self.confirmButtonClickBlock = ^{
        [weakSelf addBooks];
    };
    
}

- (void)showAlertView
{
    if (_bookList.count == 0) {
        [self closeAlertView];
        return;
    }
    
    [super showAlertView];
    
    CGFloat bookWidth = (self.alertViewWidth - 2 * kMargin - 2 * kHalfMargin) / 3;
    CGFloat bookHeigh = kGeometricHeight(bookWidth, 3, 4);
    
    [self.alertViewContentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
    }];
    
    [bookBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.top.mas_equalTo(self.alertViewContentLabel.mas_bottom).with.offset(kMargin);
        make.width.mas_equalTo(self.alertBackView.mas_width).with.offset(- 2 * kMargin);
        make.height.mas_equalTo(bookHeigh + 40);
    }];
    
    [self.cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.alertBackView.mas_left).with.offset(0);
        make.top.mas_equalTo(bookBackView.mas_bottom).with.offset(kMargin);
        make.height.mas_equalTo(self.alertViewButtonHeight);
        make.width.mas_equalTo(self.alertViewWidth / 2);
    }];
    
    [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.alertBackView.mas_right).with.offset(0);
        make.top.mas_equalTo(bookBackView.mas_bottom).with.offset(kMargin);
        make.height.mas_equalTo(self.alertViewButtonHeight);
        make.width.mas_equalTo(self.alertViewWidth / 2);
    }];
}

- (void)setBookList:(NSArray *)bookList
{
    _bookList = bookList;
    if (kObjectIsEmpty(bookList)) return;
    
    CGFloat bookWidth = (self.alertViewWidth - (2 * kMargin) - (2 * kHalfMargin)) / 3.0;
    CGFloat bookHeigh = kGeometricHeight(bookWidth, 3, 4);
    
    int buttonNum = 3;//每行多少按钮
    CGFloat button_W = bookWidth;//按钮宽
    CGFloat space_X = kHalfMargin;//按钮间距
    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = [UIColor clearColor];
    [bookBackView addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(bookBackView);
    }];
    
    int max = (int)(bookList.count < 3 ? bookList.count : 3);
    
    for (int i = 0; i < max; i ++) {
        int loc = i % buttonNum;//列号
        CGFloat button_X = (space_X + button_W) * loc;
        
        WXYZ_ProductionModel *t_model = [bookList objectOrNilAtIndex:i];

        // 图片
        WXYZ_ProductionCoverView *bookImageView = [[WXYZ_ProductionCoverView alloc] initWithProductionType:t_model.productionType productionCoverDirection:WXYZ_ProductionCoverDirectionVertical];
        bookImageView.userInteractionEnabled = YES;
        bookImageView.coverImageURL = t_model.cover;
        [backView addSubview:bookImageView];
        
        [bookImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(button_X);
            make.width.mas_equalTo(bookWidth);
            make.height.mas_equalTo(bookHeigh);
            if (i == max - 1) {
                make.right.equalTo(backView);
            }
        }];
        
        // 书名
        UILabel *bookTitleLabel = [[UILabel alloc] init];
        bookTitleLabel.numberOfLines = 1;
        bookTitleLabel.text = [NSString stringWithFormat:@"%@\n", t_model.name];
        bookTitleLabel.backgroundColor = kWhiteColor;
        bookTitleLabel.font = kFont12;
        bookTitleLabel.textAlignment = NSTextAlignmentLeft;
        [backView addSubview:bookTitleLabel];
        
        [bookTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(bookImageView.mas_centerX);
            make.top.mas_equalTo(bookImageView.mas_bottom);
            make.width.mas_equalTo(bookImageView.mas_width);
            make.height.mas_equalTo(20);
            make.bottom.equalTo(backView);
        }];
        
        UILabel *connerLabel = [[UILabel alloc] init];
        connerLabel.font = kFont8;
        connerLabel.layer.cornerRadius = 4.0f;
        connerLabel.textAlignment = NSTextAlignmentCenter;
        connerLabel.textColor = kWhiteColor;
        connerLabel.clipsToBounds = YES;
        [bookImageView addSubview:connerLabel];
        
        [connerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(bookImageView.mas_right).with.offset(- kQuarterMargin);
            make.top.mas_equalTo(bookImageView.mas_top).with.offset(kQuarterMargin);
            make.width.mas_equalTo(30);
            make.height.mas_equalTo(15);
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
    }
}

- (void)addBooks
{
    for (WXYZ_ProductionModel *t_model in self.bookList) {
        
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
    
    if (self.bookList) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Reload_Rack_Production object:nil];
    }
}


@end

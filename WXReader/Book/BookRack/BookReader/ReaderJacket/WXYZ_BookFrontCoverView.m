//
//  WXYZ_BookFrontCoverView.m
//  WXReader
//
//  Created by LL on 2020/5/23.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BookFrontCoverView.h"

#import "WXYZ_ReaderSettingHelper.h"
#import "WXYZ_ReaderBookManager.h"

@interface WXYZ_BookFrontCoverView ()

@property (nonatomic, strong) WXYZ_ProductionModel *bookModel;

@property (nonatomic, strong) WXYZ_ReaderSettingHelper *readerSetting;

@end

@implementation WXYZ_BookFrontCoverView

- (instancetype)initWithFrame:(CGRect)frame
                bookModel:(WXYZ_ProductionModel *)bookModel
                readerSetting:(WXYZ_ReaderSettingHelper *)readerSetting {
    if (self = [super initWithFrame:frame]) {
        self.bookModel = bookModel;
        self.readerSetting = readerSetting;
        if ([WXYZ_NetworkReachabilityManager networkingStatus]) {
            [self netRquest];
        } else {
            NSString *path =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
            path = [path stringByAppendingPathComponent:[WXYZ_UtilsHelper stringToMD5:@"book_catalog"]];
            NSString *catalogName = [NSString stringWithFormat:@"%zd_%@", bookModel.production_id, @"catalog"];
            NSString *fullPath = [path stringByAppendingFormat:@"/%@.plist", [WXYZ_UtilsHelper stringToMD5:catalogName]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
                NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:fullPath];
                WXYZ_CatalogModel *catalog = [WXYZ_CatalogModel modelWithDictionary:dict];
                if (catalog.author) {
                    self.bookModel.author = self.bookModel.author ? self.bookModel.author : catalog.author.author_name;
                    self.bookModel.author_name = self.bookModel.author_name ? self.bookModel.author_name : catalog.author.author_name;
                    self.bookModel.author_id = self.bookModel.author_id ? self.bookModel.author_id : catalog.author.author_id;
                    self.bookModel.author_note = self.bookModel.author_note ? self.bookModel.author_note : catalog.author.author_note;
                    self.bookModel.author_avatar = self.bookModel.author_avatar ? self.bookModel.author_avatar : catalog.author.author_avatar;
                } else {
                    WXYZ_ProductionModel *t_catalog = [WXYZ_ProductionModel modelWithDictionary:dict];
                    self.bookModel.author = self.bookModel.author ? self.bookModel.author : t_catalog.name;
                    self.bookModel.author_name = self.bookModel.author_name ? self.bookModel.author_name : t_catalog.name;
                }
            }
            [self createSubviews];
        }
    }
    return self;
}

- (void)netRquest {
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Book_New_Catalog parameters:@{@"book_id" : @([WXYZ_ReaderBookManager sharedManager].book_id)} model:WXYZ_CatalogModel.class success:^(BOOL isSuccess, WXYZ_CatalogModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        weakSelf.bookModel.author_note = t_model.author.author_note;
        weakSelf.bookModel.author = t_model.author.author_name;
        weakSelf.bookModel.author_name = t_model.author.author_name;
        [weakSelf createSubviews];
    } failure:nil];
}

- (void)createSubviews {
    UIImageView *coverImageView = [[UIImageView alloc] init];
    coverImageView.backgroundColor = [UIColor clearColor];
    coverImageView.image = [YYImage imageNamed:@"book_reader_cover"];
    [self addSubview:coverImageView];
    [coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = self.bookModel.name ?: @"";
    nameLabel.font = kBoldFont18;
    nameLabel.textColor = [self.readerSetting getReaderTitleTextColor];
    [coverImageView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(coverImageView);
        make.bottom.equalTo(coverImageView.mas_centerY);
    }];
    
    WXYZ_ProductionCoverView *bookCoverView = [[WXYZ_ProductionCoverView alloc] initWithProductionType:WXYZ_ProductionTypeBook productionCoverDirection:WXYZ_ProductionCoverDirectionVertical];
    bookCoverView.coverImageURL = self.bookModel.cover;
    [coverImageView addSubview:bookCoverView];
    [bookCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(nameLabel.mas_top).offset(-kMargin -kQuarterMargin);
        make.centerX.equalTo(nameLabel);
        make.height.equalTo(coverImageView.mas_height).multipliedBy(1.0 / 3.0);
        make.width.equalTo(bookCoverView.mas_height).multipliedBy(150.0 / 200.0);
    }];
    
    self.bookModel.author_note = [self.bookModel.author_note stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (self.bookModel.author_note.length == 0) {
        UILabel *authorLabel = [[UILabel alloc] init];
        authorLabel.text = [NSString stringWithFormat:@"%@/%@", [[self.bookModel.author componentsSeparatedByString:@","] componentsJoinedByString:@" "]?: @"", @"作品"];
        authorLabel.font = kFont14;
        authorLabel.textColor = [self.readerSetting getReaderTextColor];
        [coverImageView addSubview:authorLabel];
        [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(nameLabel.mas_bottom).offset(12.0f);
            make.centerX.equalTo(bookCoverView);
        }];
    } else {
        UILabel *descLabel = [[UILabel alloc] init];
        descLabel.numberOfLines = 5;
        descLabel.font = kFont14;
        descLabel.textColor = [self.readerSetting getReaderTextColor];
        descLabel.text = self.bookModel.author_note;
        [coverImageView addSubview:descLabel];
        [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(nameLabel.mas_bottom).offset(SCREEN_HEIGHT * 65.0 / 896.0);
            make.left.equalTo(coverImageView).offset(63.0);
            make.right.equalTo(coverImageView).offset(-63.0);
        }];
        
        UILabel *authorLabel = [[UILabel alloc] init];
        authorLabel.font = kFont14;
        authorLabel.textColor = [self.readerSetting getReaderTextColor];
        authorLabel.text = [NSString stringWithFormat:@"%@%@", @"—— ", self.bookModel.author_name ?: @""];
        [coverImageView addSubview:authorLabel];
        [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(descLabel.mas_bottom).offset(kMoreHalfMargin);
            make.right.equalTo(descLabel);
        }];
    }
}

@end

//
//  WXReaderMamager.m
//  WXReader
//
//  Created by Andrew on 2018/6/3.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_ReaderBookManager.h"
#import "WXYZ_BookDownloadManager.h"
#import "WXYZ_ProductionReadRecordManager.h"
#import "WXYZ_ReaderSettingHelper.h"

#import "NSAttributedString+TReaderPage.h"
#import "NSString+WXYZ_NSString.h"

#import "TYTextContainer.h"
#import "WXYZ_ADManager.h"

#if WX_Enable_Third_Party_Ad
    #import <BUAdSDK/BUBannerAdView.h>
#endif

#import "AppDelegate.h"
#import "WXYZ_BookFrontCoverView.h"
#import "WXYZ_BookReaderTextViewController.h"

#import "WXYZ_BookAuthorNoteView.h"

#import "TYAttributedLabel.h"
#import "NSString+WXYZ_NSString.h"
#import "UIImage+Color.h"

#import "WXYZ_BookDownloadManager.h"

@interface WXYZ_ReaderBookManager ()
{
    NSInteger _chapter_id;
}

@property (nonatomic, strong) NSAttributedString *chapterAttributedString;

@property (nonatomic, strong) NSMutableArray<NSValue *> *chapterRangeArray;

@property (nonatomic, assign) NSInteger currentChapterPagerCount;

@property (nonatomic, assign) NSInteger totalChapterCount;

@property (nonatomic, assign) NSInteger totalChapterPagerCount;

@property (nonatomic, strong) WXYZ_ReaderSettingHelper *functionalManager;

@property (nonatomic, strong) WXYZ_ADManager *adView;

@property (nonatomic, weak) UIView *alertView;

@end

@implementation WXYZ_ReaderBookManager

implementation_singleton(WXYZ_ReaderBookManager)

- (instancetype)init
{
    if (self = [super init]) {
        _functionalManager = [WXYZ_ReaderSettingHelper sharedManager]; 
    }
    return self;
}

- (void)setBook_id:(NSInteger)book_id
{
    _book_id = book_id;
    [self requestBookModelWithBookId:book_id completionHandler:nil];
}

- (NSInteger)chapter_id
{
    WXYZ_ProductionChapterModel *chapterModel = [self.bookModel.chapter_list objectOrNilAtIndex:_currentChapterIndex];
    _chapter_id = chapterModel.chapter_id;
    return _chapter_id;
}

- (WXYZ_ProductionChapterModel *)chapterModel
{
    return [self.bookModel.chapter_list objectOrNilAtIndex:_currentChapterIndex];
}

- (NSString *)getBookName
{
    return self.bookModel.name?:@"";
}

- (NSString *)getChapterTitle
{
    WXYZ_ProductionChapterModel *t_model = [_bookModel.chapter_list objectOrNilAtIndex:_currentChapterIndex];
    for (WXYZ_ProductionChapterModel *tt_model in _bookModel.chapter_list) {
        if (tt_model.chapter_id == t_model.chapter_id) {
            return tt_model.chapter_title;
        }
    }
    return @"";
}

- (BOOL)isPreviewChapter
{
    if (self.bookModel.total_chapters == 0) {
        return NO;
    }
    WXYZ_ProductionChapterModel *chapterModel = [self.bookModel.chapter_list objectOrNilAtIndex:_currentChapterIndex];
    if (chapterModel.is_preview == 1) {
        if (_chapterRangeArray.count > 1) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

- (BOOL)haveNextCache {
    if (!self.bookModel || self.bookModel.production_id != self.book_id) {
        return NO;
    }
    if (self.currentPagerIndex + 1 >= _currentChapterPagerCount) {
        WXYZ_ProductionChapterModel *t_cmodel = [self getChapterModelWithChapterIndex:self.currentChapterIndex + 1];
        NSString *fullPath = [[WXYZ_BookDownloadManager sharedManager] getChapterFilePathWithChapterModel:t_cmodel];
        return [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
    } else {
        return YES;
    }
}

- (BOOL)havePreCache {
    if (!self.bookModel || self.bookModel.production_id != self.book_id) {
        return NO;
    }
    if (_currentPagerIndex == 0) {
        WXYZ_ProductionChapterModel *t_cmodel = [self getChapterModelWithChapterIndex:self.currentChapterIndex - 1];
        NSString *fullPath = [[WXYZ_BookDownloadManager sharedManager] getChapterFilePathWithChapterModel:t_cmodel];
        return [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
    } else {
        return YES;
    }
}

// 是否有下章节
- (BOOL)haveNextChapter
{
    return _totalChapterCount > _currentChapterIndex + 1;
}

// 是否有上章节
- (BOOL)havePreChapter
{
    return _currentChapterIndex > 0;
}

- (NSInteger)nextPagerIndex
{
    if (![self isTheLastPager]) {
        return _currentPagerIndex + 1;
    }
    return _currentPagerIndex;
}

- (NSInteger)previousPagerIndex
{
    if (![self isTheFormerPager]) {
        return _currentPagerIndex - 1;
    }
    return _currentPagerIndex;
}

// 是否是最后一章最后一页
- (BOOL)isTheLastPager
{
    if (![self haveNextChapter] && (_currentChapterPagerCount == _currentPagerIndex + 1)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Reader_Push object:@"WXYZ_BookBackSideViewController"];
        });
        return YES;
    }
    return NO;
}

// 是否是第一章第一页
- (BOOL)isTheFormerPager
{
    if (_currentChapterIndex == 0 && _currentPagerIndex == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"已经是第一页"];
        });
        return YES;
    }
    return NO;
}

// 是否有下一页
- (BOOL)haveNextPager
{
    if ([self haveNextChapter]) {
        return YES;
    }
    
    if (_currentChapterPagerCount == _currentPagerIndex + 1) {
        return NO;
    }
    
    return YES;
}

// 获取下一页
- (void)getNextPagerAttributedText:(void(^)(NSAttributedString *content))complete {
    NSInteger nextPagerIndex = _currentPagerIndex + 1;
    
    // 获取下一页
    if (nextPagerIndex >= _currentChapterPagerCount) {//需要跳转下一章
        WS(weakSelf)
        [self getPagerAttributedTextWithBookId:_book_id chapterIndex:_currentChapterIndex + 1 pagerIndex:0 completionHandler:^(NSString *content) {
            if (kObjectIsEmpty(content)) {
                content = k_Chapter_RequstFail;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (![WXYZ_NetworkReachabilityManager networkingStatus]) {
                        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"当前为离线状态，只可查看缓存内容哦"];
                    }
                    !complete ?: complete(nil);
                });
                return;
            }
            [weakSelf parseChapterWithChapterContent:content atChapterIndex:weakSelf.currentChapterIndex + 1];
            weakSelf.currentPagerIndex = 0;
            dispatch_async(dispatch_get_main_queue(), ^{
                !complete ?: complete([weakSelf getChapterAttributedStringWithPagerIndex:weakSelf.currentPagerIndex]);
            });
        }];
    } else {
        _currentPagerIndex = nextPagerIndex;
        dispatch_async(dispatch_get_main_queue(), ^{
            !complete ?: complete([self getChapterAttributedStringWithPagerIndex:self.currentPagerIndex]);
        });
    }
}

// 获取上一页
- (void)getPrePagerAttributedText:(void(^ _Nullable)(NSAttributedString *content))complete {
    if (_currentPagerIndex == 0) { // 不存在上一页
        if ([self havePreChapter]) { // 存在上一章
            WS(weakSelf)
            [self getPagerAttributedTextWithBookId:_book_id chapterIndex:_currentChapterIndex - 1 pagerIndex:0 completionHandler:^(NSString *content) {
                if (kObjectIsEmpty(content)) {
                    content = k_Chapter_RequstFail;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (![WXYZ_NetworkReachabilityManager networkingStatus]) {
                            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"当前为离线状态，只可查看缓存内容哦"];
                        }
                        !complete ?: complete(nil);
                    });
                    return;
                }
                [weakSelf parseChapterWithChapterContent:content atChapterIndex:weakSelf.currentChapterIndex - 1];
                weakSelf.currentPagerIndex = weakSelf.currentChapterPagerCount - 1;
                dispatch_async(dispatch_get_main_queue(), ^{
                    !complete ?: complete([weakSelf getChapterAttributedStringWithPagerIndex:weakSelf.currentPagerIndex]);
                });
            }];
        } else {
            !complete ?: complete(nil);
        }
    } else {
        // 存在上一页
        dispatch_async(dispatch_get_main_queue(), ^{        
            !complete ?: complete([self getChapterAttributedStringWithPagerIndex:self.currentPagerIndex - 1]);
        });
    }
}

- (void)setBookModel:(WXYZ_ProductionModel *)bookModel
{
    _bookModel = bookModel;
}

// 获取某一章节某一页
- (void)getPagerAttributedTextWithChapterIndex:(NSInteger)chapterIndex pagerIndex:(NSInteger)pageIndex completionHandler:(void(^)(NSAttributedString *content))completionHandler
{
    if (chapterIndex != _currentChapterIndex && chapterIndex >= 0) {
        self.currentChapterIndex = chapterIndex;
    }
    
    if (pageIndex != _currentPagerIndex && pageIndex >= 0) {
        self.currentPagerIndex = pageIndex;
    }
    
    WS(weakSelf)
    [self getPagerAttributedTextWithBookId:_book_id chapterIndex:chapterIndex pagerIndex:pageIndex completionHandler:^(NSString *content) {
        if (!content) {
            return;
        }
        [weakSelf parseChapterWithChapterContent:content atChapterIndex:chapterIndex];
        NSInteger _pageIndex = pageIndex;
        if (completionHandler) {
            if (weakSelf.markIndex != -1) {
                NSInteger index = 0;
                for (NSValue *obj in weakSelf.chapterRangeArray) {
                    NSRange range = [obj rangeValue];
                    if (weakSelf.markIndex >= range.location && weakSelf.markIndex < range.location + range.length) {
                        break;
                    }
                    index += 1;
                }
                _pageIndex = index;
                weakSelf.currentPagerIndex = pageIndex;
            }
            completionHandler([weakSelf getChapterAttributedStringWithPagerIndex:_pageIndex]);
        }
    }];
}

// 获取某一章节全部内容
- (void)getChapterTextWithBook_id:(NSInteger)book_id chapter_index:(NSInteger)chapter_index completionHandler:(void(^)(NSString *content))completionHandler
{
    [self getPagerAttributedTextWithBookId:book_id chapterIndex:chapter_index pagerIndex:0 completionHandler:^(NSString *content) {
        if (completionHandler) {
            completionHandler(content);
        }
    }];
}

// 获取某一章节某一页
- (void)getPagerAttributedTextWithBookId:(NSUInteger)book_id chapterIndex:(NSInteger)chapterIndex pagerIndex:(NSInteger)pageIndex completionHandler:(void(^)(NSString *content))completionHandler
{
    WS(weakSelf)
    // 如果当前书籍目录存在
    if (_bookModel && _bookModel.production_id == book_id) {
        if (_bookModel.total_chapters == 0) {
            // 如果没有章节数据，请求
            [self requestBookModelWithBookId:book_id completionHandler:^{
                if (weakSelf.bookModel.total_chapters > 0) {
                    // 等待model返回
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf getPagerAttributedTextWithBookId:book_id chapterIndex:chapterIndex pagerIndex:pageIndex completionHandler:^(NSString *content) {
                            !completionHandler ?: completionHandler(content);
                        }];
                    });
                } else {
                    !completionHandler ?: completionHandler(k_Chapter_RequstFail);
                }
            }];
            return;
        }
        WXYZ_ProductionChapterModel *t_model = [self getChapterModelWithChapterIndex:chapterIndex];
        
        // 预加载下一章
        [self downloadPrestrainChaptersWithProductionModel:self.bookModel production_id:self.book_id chapter_id:t_model.next_chapter prestrainNumber:1];
        
        if (!t_model) {
            if (completionHandler) {
                completionHandler(k_Chapter_RequstFail);
            }
            return;
        }
        
        // 如果是 开启自动订阅 && 此章节是预览状态 && 已登录 && 有网络连接的情况下,首先请求网络
        if (WXYZ_UserInfoManager.isLogin && (t_model.is_preview == 1) && [WXYZ_NetworkReachabilityManager networkingStatus] && [WXYZ_UserInfoManager shareInstance].auto_sub) {
            // txt不存在本地，需要下载
            [self downloadPrestrainChapterWithProductionModel:_bookModel production_id:book_id chapter_id:t_model.chapter_id completionHandler:^(NSString * _Nonnull chapterContentString, NSInteger production_id, NSInteger chapter_id) {
                if (chapterContentString.length > 150) {
                    t_model.is_preview = NO;
                    t_model.can_read = YES;
                }
                
                if (completionHandler) {
                    completionHandler(chapterContentString);
                }
                for (WXYZ_CatalogListModel *tt_model in weakSelf.bookModel.list) {
                    if ([tt_model.chapter_id integerValue] == chapter_id) {
                        tt_model.preview = t_model.is_preview;
                        tt_model.can_read = t_model.can_read;
                        break;
                    }
                }
            }];
        } else {
            NSString *t_bookChapterFilePath = [[WXYZ_BookDownloadManager sharedManager] getChapterFilePathWithChapterModel:t_model];
            // txt本地存在
            if ([[NSFileManager defaultManager] fileExistsAtPath:t_bookChapterFilePath]) {
                
                if (completionHandler) {
                    completionHandler([[WXYZ_BookDownloadManager sharedManager] getFileContentsWithChapterModel:t_model]);
                }
            } else {
                // txt不存在本地，需要下载
                if (![WXYZ_NetworkReachabilityManager networkingStatus]) {
                    !completionHandler ?: completionHandler(nil);
                    return;
                }
                [self downloadPrestrainChapterWithProductionModel:_bookModel production_id:book_id chapter_id:t_model.chapter_id completionHandler:^(NSString * _Nonnull chapterContentString, NSInteger production_id, NSInteger chapter_id) {
                    if (chapterContentString.length > 150) {
                        t_model.is_preview = NO;
                        t_model.can_read = YES;
                    }
                    
                    if (completionHandler) {
                        completionHandler(chapterContentString);
                    }
                }];
            }
        }
        
    } else {
        // 获取书籍model
        WXYZ_ProductionModel *t_model = [[WXYZ_DownloadHelper sharedManager] getDownloadProductionModelWithProduction_id:book_id productionType:WXYZ_ProductionTypeBook];
        // 更新书籍章节列表
        NSString *path =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        path = [path stringByAppendingPathComponent:[WXYZ_UtilsHelper stringToMD5:@"book_catalog"]];
        NSString *catalogName = [NSString stringWithFormat:@"%zd_%@", self.book_id, @"catalog"];
        NSString *fullPath = [path stringByAppendingFormat:@"/%@.plist", [WXYZ_UtilsHelper stringToMD5:catalogName]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
            NSDictionary *t_dict = [NSDictionary dictionaryWithContentsOfFile:fullPath];
            WXYZ_ProductionModel *tt_model = [WXYZ_ProductionModel modelWithDictionary:t_dict];
            t_model.chapter_list = tt_model.chapter_list;
        }
        
        // 获取本地书籍Model
        if (t_model) {
            weakSelf.bookModel = t_model;
            // 等待model返回
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getPagerAttributedTextWithBookId:book_id chapterIndex:chapterIndex pagerIndex:pageIndex completionHandler:^(NSString *content) {
                    if (completionHandler) {
                        completionHandler(content);
                    }
                }];
            });
        } else {// 当前书籍信息不存在
            [self requestBookModelWithBookId:book_id completionHandler:^{
                if (weakSelf.bookModel) {
                    // 等待model返回
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf getPagerAttributedTextWithBookId:book_id chapterIndex:chapterIndex pagerIndex:pageIndex completionHandler:^(NSString *content) {
                            !completionHandler ?: completionHandler(content);
                        }];
                    });
                } else {
                    !completionHandler ?: completionHandler(k_Chapter_RequstFail);
                }
            }];
        }
    }
}

- (WXYZ_ProductionChapterModel *)getChapterModelWithChapterIndex:(NSInteger)chapter_index
{
    WXYZ_ProductionChapterModel *t_model = [_bookModel.chapter_list objectOrNilAtIndex:chapter_index];
    return [self getChapterModelWithChapter_id:t_model.chapter_id];
}

- (WXYZ_ProductionChapterModel *)getChapterModelWithChapter_id:(NSInteger)chapter_id
{
    if (!_bookModel) {
        return nil;
    }
    
    if (_bookModel.total_chapters == 0) {
        return nil;
    }
    
    for (WXYZ_ProductionChapterModel *t_model in _bookModel.chapter_list) {
        if (t_model.chapter_id == chapter_id) {
            return t_model;
        }
    }

    return nil;
}

// 书籍model请求
- (void)requestBookModelWithBookId:(NSUInteger)book_id completionHandler:(void(^)(void))completionHandler
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Book_Catalog parameters:@{@"book_id":[WXYZ_UtilsHelper formatStringWithInteger:book_id]} model:nil success:^(BOOL isSuccess, NSDictionary *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            WXYZ_ProductionModel *tt_model = [WXYZ_ProductionModel modelWithDictionary:t_model[@"data"]];
            [[WXYZ_DownloadHelper sharedManager] recordDownloadProductionWithProductionModel:tt_model productionType:WXYZ_ProductionTypeBook];
            
            weakSelf.bookModel = tt_model;
            
            [WXYZ_NetworkRequestManger POST:Book_New_Catalog parameters:@{@"book_id":[WXYZ_UtilsHelper formatStringWithInteger:book_id]} model:WXYZ_CatalogModel.class success:^(BOOL isSuccess, WXYZ_CatalogModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
                if (isSuccess) {
                    weakSelf.bookModel.author_name = t_model.author.author_name;
                    weakSelf.bookModel.author_note = t_model.author.author_note;
                    weakSelf.bookModel.author_id = t_model.author.author_id;
                    weakSelf.bookModel.author_avatar = t_model.author.author_avatar;
                    !completionHandler ?: completionHandler();
                }
            } failure:nil];
            
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !completionHandler ?: completionHandler();
    }];
}

// 预加载章节(支持自动订阅 && 仅支持单章下载)
- (void)downloadPrestrainChapterWithProductionModel:(WXYZ_ProductionModel *)productionModel production_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id completionHandler:(void(^)(NSString *chapterContentString, NSInteger production_id, NSInteger chapter_id))completionHandler
{
    [WXYZ_NetworkRequestManger POST:Book_Chapter_Text parameters:@{@"book_id":[WXYZ_UtilsHelper formatStringWithInteger:production_id], @"chapter_id":[WXYZ_UtilsHelper formatStringWithInteger:chapter_id]} model:WXYZ_ProductionChapterModel.class completionQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) success:^(BOOL isSuccess, WXYZ_ProductionChapterModel * _Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            
            // 解析标题
            NSString *chapter_title_string = @"";
            if (t_model.chapter_title && t_model.chapter_title.length > 0) {
                chapter_title_string = [NSString stringWithFormat:@"W$$X%@W$$X", t_model.chapter_title];
                chapter_title_string = [chapter_title_string stringByAppendingString:@"\n\n"];
            }
            
            // 解析内容
            NSString *chapter_content_string = @"";
            if (t_model.content && t_model.content.length > 0) {
                chapter_content_string = t_model.content;
            }
            
            // 文件内容
            NSString *chapter_file_content = [NSString stringWithFormat:@"%@%@",chapter_title_string, chapter_content_string];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                !completionHandler ?: completionHandler(chapter_file_content, production_id, chapter_id);                
            });
            
            [[WXYZ_BookDownloadManager sharedManager] storingFilesWithChapterModel:t_model storingCompletionHandler:^(BOOL finishStoring) {
                
            }];
        } else {
            !completionHandler ?: completionHandler(k_Chapter_RequstFail, production_id, chapter_id);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !completionHandler ?: completionHandler(k_Chapter_RequstFail, production_id, chapter_id);
    }];
}

// 预加载多个章节(不支持自动订阅 && 支持多章下载)
- (void)downloadPrestrainChaptersWithProductionModel:(WXYZ_ProductionModel *)productionModel production_id:(NSInteger)production_id chapter_id:(NSInteger)chapter_id prestrainNumber:(NSInteger)prestrainNumber
{
    if (chapter_id == 0) return;
    [WXYZ_NetworkRequestManger POST:Chapter_Download parameters:@{@"book_id":[WXYZ_UtilsHelper formatStringWithInteger:production_id], @"chapter_id":[WXYZ_UtilsHelper formatStringWithInteger:chapter_id], @"num":[WXYZ_UtilsHelper formatStringWithInteger:prestrainNumber]} model:nil success:^(BOOL isSuccess, NSDictionary *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            NSArray *chapterArray = [NSArray modelArrayWithClass:[WXYZ_ProductionChapterModel class] json:requestModel.data];
            if (chapterArray.count > 0) {
                for (WXYZ_ProductionChapterModel *chapterModel in chapterArray) {
                    [[WXYZ_BookDownloadManager sharedManager] storingFilesWithChapterModel:chapterModel storingCompletionHandler:^(BOOL finishStoring) {
                        
                    }];
                }
            }
        } else {
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

#pragma mark - private

// 解析章节内容
- (void)parseChapterWithChapterContent:(NSString *)content atChapterIndex:(NSInteger)chapterIndex
{
    _currentChapterIndex = chapterIndex;
    
    if ([content isEqualToString:k_Chapter_RequstFail]) {
        _chapterAttributedString = nil;
        [_chapterRangeArray removeAllObjects];
        return;
    }
    
    [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] addReadingRecordWithProduction_id:self.book_id chapter_id:self.chapter_id chapterTitle:[self getChapterTitle]];
    
    [self addReadLogRequest];
    
    // 章节内容
    NSMutableAttributedString *contentAttribute = [[NSMutableAttributedString alloc] init];
    
    // 标题属性设置
    UIFont *bookTitleFont = [UIFont boldSystemFontOfSize:[_functionalManager getReaderFontSize] + 6];
    CGFloat bookTitleSpacing = [_functionalManager getReaderLinesSpacing];
    
    // 内容属性设置
    UIFont *bookContentFont = [UIFont systemFontOfSize:[_functionalManager getReaderFontSize]];
    CGFloat bookContentSpacing = [_functionalManager getReaderLinesSpacing];
    
    // 书籍标题
    NSString *bookTitle = [[content safe_substringWithRange:[content rangeOfString:@"W\\$\\$X.*W\\$\\$X" options:NSRegularExpressionSearch]] stringByReplacingOccurrencesOfString:@"W$$X" withString:@""];
    NSMutableAttributedString *bookTitleAttribute = [[NSMutableAttributedString alloc] initWithString:bookTitle attributes:@{NSForegroundColorAttributeName : [_functionalManager getReaderTextColor]}];
    bookTitleAttribute.font = bookTitleFont;
    bookTitleAttribute.lineSpacing = bookTitleSpacing;
    [contentAttribute appendAttributedString:bookTitleAttribute];
    
    // 书籍内容
    NSString *bookContent = [content stringByReplacingOccurrencesOfString:[content safe_substringWithRange:[content rangeOfString:@"W\\$\\$X.*W\\$\\$X" options:NSRegularExpressionSearch]] withString:@""];
    NSInteger index = -1;
    for (NSInteger i = 0; i < bookContent.length; i++) {
        NSString *t_text = [bookContent substringWithRange:NSMakeRange(i, 1)];
        if ([t_text isChinese]) {
            index = i;
            break;
        }
    }
    NSString *spaceStr = @"";
    if (index != -1) {
        spaceStr = [bookContent substringToIndex:index];
    }
    bookContent = [bookContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    bookContent = [NSString stringWithFormat:@"%@%@", spaceStr, bookContent];
    NSMutableAttributedString *bookContentAttribute = [[NSMutableAttributedString alloc] initWithString:bookContent attributes:@{NSForegroundColorAttributeName : [_functionalManager getReaderTextColor]}];
    bookContentAttribute.font = bookContentFont;
    bookContentAttribute.lineSpacing = bookContentSpacing;
    [contentAttribute appendAttributedString:bookContentAttribute];
    
    TYTextContainer *textContainer = [[TYTextContainer alloc] createTextContainerWithContentSize:[_functionalManager getReaderViewSize]];
    textContainer.font = [UIFont systemFontOfSize:[_functionalManager getReaderFontSize]];
    textContainer.linesSpacing = [_functionalManager getReaderLinesSpacing];
    textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    
    // 判断是不是第一章
    if (_currentChapterIndex == 0) {
        [self addBookCover:textContainer];
    }
    
    NSInteger random = 3;
    NSMutableArray<NSValue *> *t_arr = [[contentAttribute pageRangeArrayWithConstrainedToSize:[_functionalManager getReaderViewSize]] mutableCopy];
    NSRange lastRange = NSMakeRange(0, 0);
    NSInteger count = t_arr.count / random;
    for (NSInteger i = 0; i < count; i++) {
        NSRange startRange = NSMakeRange(0, 0);
        if (i == 0) {
            startRange = [t_arr[i] rangeValue];
        } else {
            startRange = [t_arr[i * random] rangeValue];
        }
        NSInteger location = startRange.location;
        NSRange endRange = NSMakeRange(0, 0);
        if (random * count == t_arr.count && i == count - 1) {// 如果最后一个是广告位，最把广告往前挪一页
            endRange = [t_arr[t_arr.count - 2] rangeValue];
        } else {
            endRange = [t_arr[i * random + random - 1] rangeValue];
        }
        NSInteger length = endRange.location + endRange.length - location;
        NSRange range = NSMakeRange(location, length);
        lastRange = range;
        NSAttributedString *t_atr = [contentAttribute attributedSubstringFromRange:range];

        [textContainer appendTextAttributedString:t_atr];
        
        [self appendAdViewWithContainer:textContainer];
    }
    
    _chapterRangeArray = [NSMutableArray array];
    
    if ([self isShowADView]) {
        // 计算新的分页数组
        if (random * count == t_arr.count) {// 如果最后一个位置是广告，则把计算位置往前挪
            [t_arr enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx == t_arr.count - 2) {
                    NSRange lastRange = _chapterRangeArray.lastObject.rangeValue;
                    lastRange = NSMakeRange(NSMaxRange(lastRange), obj.rangeValue.length);
                    [_chapterRangeArray addObject:[NSValue valueWithRange:lastRange]];
                    NSRange t_range = NSMakeRange(NSMaxRange(lastRange), 1);
                    [_chapterRangeArray addObject:[NSValue valueWithRange:t_range]];
                } else if ((idx + 1) % random == 0 && idx != t_arr.count - 1) {
                    NSRange lastRange = _chapterRangeArray.lastObject.rangeValue;
                    lastRange = NSMakeRange(NSMaxRange(lastRange), obj.rangeValue.length);
                    [_chapterRangeArray addObject:[NSValue valueWithRange:lastRange]];
                    NSRange t_range = NSMakeRange(NSMaxRange(lastRange), 1);
                    [_chapterRangeArray addObject:[NSValue valueWithRange:t_range]];
                } else {
                    NSInteger offset = (idx + 1) / random;
                    NSRange t_range = obj.rangeValue;
                    t_range.location += offset;
                    [_chapterRangeArray addObject:[NSValue valueWithRange:t_range]];
                }
            }];
        } else {
            [t_arr enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ((idx + 1) % random == 0) {
                    NSRange lastRange = _chapterRangeArray.lastObject.rangeValue;
                    lastRange = NSMakeRange(NSMaxRange(lastRange), obj.rangeValue.length);
                    [_chapterRangeArray addObject:[NSValue valueWithRange:lastRange]];
                    NSRange t_range = NSMakeRange(NSMaxRange(lastRange), 1);
                    [_chapterRangeArray addObject:[NSValue valueWithRange:t_range]];
                } else {
                    NSInteger offset = (idx + 1) / random;
                    NSRange t_range = obj.rangeValue;
                    t_range.location += offset;
                    [_chapterRangeArray addObject:[NSValue valueWithRange:t_range]];
                }
            }];
        }
    } else {
        _chapterRangeArray = t_arr;
    }
    
    if (_currentChapterIndex == 0) {// 如果是第一章，则在前面插入一个分页
        [_chapterRangeArray insertObject:[NSValue valueWithRange:NSMakeRange(0, 1)] atIndex:0];
        for (NSInteger i = 1; i < _chapterRangeArray.count; i++) {
            NSRange t_range = _chapterRangeArray[i].rangeValue;
            t_range.location += 1;
            [_chapterRangeArray replaceObjectAtIndex:i withObject:[NSValue valueWithRange:t_range]];
        }
    }
    
    // 将广告后面的文字都追加过来
    NSRange t_range = NSMakeRange(NSMaxRange(lastRange), contentAttribute.length - NSMaxRange(lastRange));
    NSAttributedString *atr = [contentAttribute attributedSubstringFromRange:t_range];
    [textContainer appendTextAttributedString:atr];
    
    [self formatAttributedString:textContainer atChapterIndex:chapterIndex];
    
    if (self.bookModel.chapter_list[_currentChapterIndex].is_preview == 0) {
        [self appendAuthorNoteWithContainer:textContainer];
    }
}

// 添加书籍封面
- (void)addBookCover:(TYTextContainer *)textContainer {
    WXYZ_BookFrontCoverView * __block coverView = nil;
    kCodeSync({
        coverView = [[WXYZ_BookFrontCoverView alloc] initWithFrame:CGRectMake(0, 0, [self.functionalManager getReaderViewFrame].size.width - 1, [self.functionalManager getReaderViewFrame].size.height - 1) bookModel:self.bookModel readerSetting:self.functionalManager];
        coverView.backgroundColor = [UIColor clearColor];
    });
    [textContainer appendView:coverView];
}

- (void)appendAuthorNoteWithContainer:(TYTextContainer *)textContainer {
    NSAttributedString *atr = [textContainer attributedText];
    NSAttributedString *str = [atr attributedSubstringFromRange:[_chapterRangeArray.lastObject rangeValue]];
    
    CGFloat __block textHeight = 0;
    kCodeSync({
        TYAttributedLabel *chapterContentLabel = [[TYAttributedLabel alloc] init];
        chapterContentLabel.frame = [[WXYZ_ReaderSettingHelper sharedManager] getReaderViewFrame];
        chapterContentLabel.font = [UIFont systemFontOfSize:[[WXYZ_ReaderSettingHelper sharedManager] getReaderFontSize]];
        chapterContentLabel.backgroundColor = [UIColor clearColor];
        chapterContentLabel.linesSpacing = [[WXYZ_ReaderSettingHelper sharedManager] getReaderLinesSpacing];
        chapterContentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        chapterContentLabel.attributedText = str;
        textHeight = [chapterContentLabel getHeightWithWidth:[[WXYZ_ReaderSettingHelper sharedManager] getReaderViewFrame].size.width];
    });
    
    // 获取页面高度
    CGFloat pageHeight = CGRectGetHeight([[WXYZ_ReaderSettingHelper sharedManager] getReaderViewFrame]);
    WXYZ_ProductionChapterModel *tt_model = [[WXYZ_ProductionChapterModel alloc] init];
    if (self.bookModel.chapter_list.count > 0) {
        tt_model = self.bookModel.chapter_list[self.currentChapterIndex];
    } else {
        for (WXYZ_CatalogListModel *obj in self.bookModel.list) {
            if (obj.display_order == self.currentChapterIndex) {
                tt_model = [[WXYZ_ProductionChapterModel alloc] init];
                tt_model.ticket_num = [NSString stringWithFormat:@"%zd", obj.ticket_num];
                tt_model.comment_num = [NSString stringWithFormat:@"%zd", obj.comment_num];
                tt_model.reward_num = [NSString stringWithFormat:@"%zd", obj.reward_num];
                break;
            }
        }
    }
    
    WXYZ_BookAuthorNoteModel *t_model = [[WXYZ_BookAuthorNoteModel alloc] init];
    t_model.author_note = tt_model.author_note;
    t_model.comment_num = tt_model.comment_num;
    if (self.reward_num) {
        t_model.reward_num = self.reward_num;
    } else {
        self.reward_num = tt_model.reward_num;
        t_model.reward_num = tt_model.reward_num;
    }
    if (self.ticket_num) {
        t_model.ticket_num = self.ticket_num;
    } else {
        self.ticket_num = tt_model.ticket_num;
        t_model.ticket_num = tt_model.ticket_num;
    }
    t_model.author_id = self.bookModel.author_id;
    t_model.author_name = self.bookModel.author_name;
    t_model.author_avatar = self.bookModel.author_avatar;
    
    CGFloat height = 0;
       if (pageHeight - textHeight > 46) {
           height = pageHeight - textHeight;
       } else {
           height = [[WXYZ_ReaderSettingHelper sharedManager] getReaderViewFrame].size.height - 1;
       }
    // 获取“作家的话”页面高度
    WXYZ_BookAuthorNoteView * __block noteView = nil;
    kCodeSync({
        noteView = [[WXYZ_BookAuthorNoteView alloc] initWithFrame:CGRectMake(0, 0, [[WXYZ_ReaderSettingHelper sharedManager] getReaderViewFrame].size.width - 1.0, height) notoModel:t_model];
    });
    
    [textContainer appendView:noteView];
    if (pageHeight - textHeight > 46) {
        _chapterAttributedString = [textContainer attributedText];
        NSValue *value = _chapterRangeArray.lastObject;
        NSRange range = [value rangeValue];
        range.length += 1;
        value = [NSValue valueWithRange:range];
        [_chapterRangeArray removeLastObject];
        [_chapterRangeArray addObject:value];
    } else {
        _chapterAttributedString = [textContainer attributedText];
        NSValue *value = _chapterRangeArray.lastObject;
        NSRange range = NSMakeRange(_chapterAttributedString.length - 1, 1);
        value = [NSValue valueWithRange:range];
        [_chapterRangeArray addObject:value];
    }
    // 当前章节总页数
    _currentChapterPagerCount = _chapterRangeArray.count;
    
    // 整书页数 = 总章节数 * 当前章节页数
    _totalChapterPagerCount = _totalChapterCount * _currentChapterPagerCount;
}

- (void)appendAdViewWithContainer:(TYTextContainer *)textContainer {
    if (![self isShowADView]) return;
    
    if ([WXYZ_ADManager canLoadAd:WXYZ_ADViewTypeBook adPosition:WXYZ_ADViewPositionEnd]) {
        WXYZ_ADManager * __block adView = nil;
        kCodeSync({
            adView = [[WXYZ_ADManager alloc] initWithFrame:CGRectMake(0, 0, [self.functionalManager getReaderViewFrame].size.width - 1, [self.functionalManager getReaderViewFrame].size.height - 1) adType:WXYZ_ADViewTypeBook adPosition:WXYZ_ADViewPositionEnd];
            adView.backgroundColor = [UIColor clearColor];
        });
        [textContainer appendView:adView];
    }
}

// 是否应该展示广告
- (BOOL)isShowADView {
    if (![WXYZ_NetworkReachabilityManager networkingStatus]) return NO;
    // 判断是不是在免广告时间内
    AppDelegate *delegate = (AppDelegate *)kRCodeSync([UIApplication sharedApplication].delegate);
    NSInteger totalTime = delegate.checkSettingModel.ad_status_setting.ad_free_time;
    NSString *currentTime = [NSString stringWithFormat:@"%zd", WXYZ_ADManager.adTimestamp];
    NSString *startTime = [[NSUserDefaults standardUserDefaults] objectForKey:WX_Reader_Ad_Start_Timestamp];
    if (currentTime && startTime && ([currentTime integerValue] - [startTime integerValue] <= totalTime * 60) && totalTime != 0) return NO;
    
    return YES;
}

- (void)formatAttributedString:(TYTextContainer *)textContainer atChapterIndex:(NSInteger)chapterIndex
{
    _chapterAttributedString = [textContainer attributedText];
    
    WXYZ_ProductionChapterModel *t_model = [self getChapterModelWithChapterIndex:chapterIndex];
    if (t_model.is_preview == YES && _chapterRangeArray.count > 1) {
        NSValue *value = [_chapterRangeArray.firstObject copy];
        [_chapterRangeArray removeAllObjects];
        [_chapterRangeArray addObject:value];
    }
    
    // 当前章节总页数
    _currentChapterPagerCount = _chapterRangeArray.count;
    
    // 总章节数
    _totalChapterCount = self.bookModel.total_chapters;
    
    // 整书页数 = 总章节数 * 当前章节页数
    _totalChapterPagerCount = _totalChapterCount * _currentChapterPagerCount;
}

// 增加阅读记录
- (void)addReadLogRequest
{
    [WXYZ_NetworkRequestManger POST:Book_Add_Read_log parameters:@{@"book_id":[WXYZ_UtilsHelper formatStringWithInteger:_book_id], @"chapter_id":[WXYZ_UtilsHelper formatStringWithInteger:self.chapter_id]} model:nil success:nil failure:nil];
}

// 获取章节某页内容
- (NSAttributedString *)getChapterAttributedStringWithPagerIndex:(NSInteger)pagerIndex
{
    NSAttributedString *attributeRangString = [[NSAttributedString alloc] initWithString:k_Chapter_RequstFail];
    
    if (pagerIndex > (_chapterRangeArray.count - 1) && pagerIndex > 0) {
        pagerIndex = (_chapterRangeArray.count - 1);
    }
    
    NSRange range = [self chapterPagerRangeWithIndex:pagerIndex];
    if (range.location == NSNotFound) {
        pagerIndex = 0;
        range = [self chapterPagerRangeWithIndex:0];
    }
    
    if ((range.location + range.length) > _chapterAttributedString.length) {
        attributeRangString = _chapterAttributedString;
    } else {
        attributeRangString = [_chapterAttributedString attributedSubstringFromRange:range];
    }
    
    _currentPagerIndex = pagerIndex;
        
    [_functionalManager setLocationMemoryOfChapterIndex:_currentChapterIndex pagerIndex:_currentPagerIndex book_id:_book_id];
    
    return attributeRangString;
}

- (NSRange)chapterPagerRangeWithIndex:(NSInteger)pagerIndex
{
    if (pagerIndex >= 0 && pagerIndex < _chapterRangeArray.count) {
        NSRange range = [_chapterRangeArray[pagerIndex] rangeValue];
        return range;
    }
    return NSMakeRange(NSNotFound, 0);
}

- (NSString *)getChapterContent {
    NSString *text = _chapterAttributedString.string;
    return text;
}

- (NSString *)getChapterDetailContent {
    if (self.currentPagerIndex >= 0 && self.currentPagerIndex < self.chapterRangeArray.count) {
        NSRange range = [self.chapterRangeArray[self.currentPagerIndex] rangeValue];
        NSString *text = [self.chapterAttributedString attributedSubstringFromRange:range].string;
        return text;
    }
    return @"";
}

- (NSMutableArray *)chapterRangeArray {
    return _chapterRangeArray;
}

@end

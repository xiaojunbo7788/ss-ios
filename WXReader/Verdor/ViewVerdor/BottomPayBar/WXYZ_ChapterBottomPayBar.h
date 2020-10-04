//
//  WXYZ_ChapterBottomPayBar.h
//  WXReader
//
//  Created by Andrew on 2020/7/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WXYZ_ChapterBottomPayBarDelegate <NSObject>

- (void)showAlertView;

@end

typedef NS_ENUM(NSUInteger, WXYZ_BottomPayBarType) {
    WXYZ_BottomPayBarTypeDownload,
    WXYZ_BottomPayBarTypeBuyChapter
};

typedef void(^PaySuccessChaptersBlock)(NSArray <NSString *>*success_chapter_ids);

typedef void(^PayCancleChapterBlock)(NSArray <NSString *>*fail_chapter_ids);

typedef void(^PayFailChaptersBlock)(NSArray <NSString *>*fail_chapter_ids);

typedef void(^BottomPayBarHiddenBlock)(void);

@interface WXYZ_ChapterBottomPayBar : UIView

@property (nonatomic, weak) id<WXYZ_ChapterBottomPayBarDelegate>delegate;

@property (nonatomic, copy) PaySuccessChaptersBlock paySuccessChaptersBlock;

@property (nonatomic, copy) PayCancleChapterBlock payCancleChapterBlock;

@property (nonatomic, copy) PayFailChaptersBlock payFailChaptersBlock;

@property (nonatomic, copy) BottomPayBarHiddenBlock bottomPayBarHiddenBlock;

@property (nonatomic, assign) BOOL canTouchHiddenView;

- (instancetype)initWithChapterModel:(WXYZ_ProductionChapterModel *)chapterModel barType:(WXYZ_BottomPayBarType)barType productionType:(WXYZ_ProductionType)productionType;

- (instancetype)initWithChapterModel:(WXYZ_ProductionChapterModel *)chapterModel barType:(WXYZ_BottomPayBarType)barType productionType:(WXYZ_ProductionType)productionType buyChapterNum:(NSInteger)buyChapterNum;

- (instancetype)initWithFrame:(CGRect)frame chapterModel:(WXYZ_ProductionChapterModel *)chapterModel barType:(WXYZ_BottomPayBarType)barType productionType:(WXYZ_ProductionType)productionType;

- (void)showBottomPayBar;

- (void)hiddenBottomPayBar;

@end

NS_ASSUME_NONNULL_END

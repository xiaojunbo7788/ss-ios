//
//  WXYZ_DetailHeadContentView.h
//  WXReader
//
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_ComicMallDetailModel.h"
NS_ASSUME_NONNULL_BEGIN

@protocol WXYZ_DetailHeadContentViewDelegate <NSObject>

- (void)onClickCollectionBtn;

@end

@interface WXYZ_DetailHeadContentView : UIView

@property (nonatomic, weak) id<WXYZ_DetailHeadContentViewDelegate>delegate;

@property (nonatomic, strong) UIButton *collectButton;
//type 1.漫画 2.书籍
- (void)showInfo:(WXYZ_ProductionModel *)detailModel withType:(int)type;

@end


NS_ASSUME_NONNULL_END

//
//  WXYZ_ComicMallDetailHeaderView.h
//  WXReader
//
//  Created by Andrew on 2019/5/29.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_ComicMallDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ComicMallDetailHeaderView : UIView

@property (nonatomic, strong) WXYZ_ProductionModel *comicProductionModel;

@property (nonatomic, assign) CGFloat headerViewAlpha;

- (void)reloadHeaderView;

@end

NS_ASSUME_NONNULL_END

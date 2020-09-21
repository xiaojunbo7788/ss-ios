//
//  WXYZ_ComicListDetailViewController.h
//  WXReader
//
//  Created by Andrew on 2019/5/29.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicMallDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^PushToComicDetailBlock)(NSInteger production_id);

@interface WXYZ_ComicListDetailViewController : WXYZ_BasicViewController

@property (nonatomic, assign) BOOL canScroll;

@property (nonatomic, strong) WXYZ_ComicMallDetailModel *detailModel;

@property (nonatomic, copy) PushToComicDetailBlock pushToComicDetailBlock;

@end

NS_ASSUME_NONNULL_END

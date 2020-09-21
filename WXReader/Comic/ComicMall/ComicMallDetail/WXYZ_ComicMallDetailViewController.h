//
//  WXYZ_ComicMallDetailViewController.h
//  WXReader
//
//  Created by Andrew on 2019/5/28.
//  Copyright © 2019 Andrew. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

#define Comic_Detail_HeaderView_Height (round(SCREEN_WIDTH * 0.8) - 50.0)

@interface WXYZ_ComicMallDetailViewController : WXYZ_BasicViewController

@property (nonatomic, assign) NSInteger comic_id;

@end

NS_ASSUME_NONNULL_END

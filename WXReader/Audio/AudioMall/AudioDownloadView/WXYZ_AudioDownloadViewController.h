//
//  WXYZ_AudioDownloadViewController.h
//  WXReader
//
//  Created by Andrew on 2020/3/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_DownloadViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_AudioDownloadViewController : WXYZ_DownloadViewController

// 预防作品model为空的情况
@property (nonatomic, assign) NSInteger production_id;

@end

NS_ASSUME_NONNULL_END

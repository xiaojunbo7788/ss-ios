//
//  WXYZ_ComicReaderDownloadModel.h
//  WXReader
//
//  Created by Andrew on 2019/6/8.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ComicReaderDownloadModel : NSObject

@property (nonatomic, assign) NSInteger total_chapters;

@property (nonatomic, copy) NSString *display_label;

@property (nonatomic, strong) NSArray <WXYZ_ProductionChapterModel *>*down_list;

@end

NS_ASSUME_NONNULL_END

//
//  WXYZ_ComicDirectoryListModel.h
//  WXReader
//
//  Created by Andrew on 2019/5/30.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ComicDirectoryListModel : NSObject

@property (nonatomic, strong) NSArray <WXYZ_ProductionChapterModel *>*chapter_list;

@end

NS_ASSUME_NONNULL_END

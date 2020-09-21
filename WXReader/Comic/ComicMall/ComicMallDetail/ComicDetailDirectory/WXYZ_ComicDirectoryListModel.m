//
//  WXYZ_ComicDirectoryListModel.m
//  WXReader
//
//  Created by Andrew on 2019/5/30.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicDirectoryListModel.h"

@implementation WXYZ_ComicDirectoryListModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"chapter_list" : [WXYZ_ProductionChapterModel class]};
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"production_id"       :@[@"book_id", @"comic_id", @"audio_id"]
             };
}

@end

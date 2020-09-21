//
//  WXYZ_ComicReaderDownloadModel.m
//  WXReader
//
//  Created by Andrew on 2019/6/8.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicReaderDownloadModel.h"

@implementation WXYZ_ComicReaderDownloadModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"total_chapters" : @"base_info.total_chapters",
             @"display_label" : @"base_info.display_label"
             };
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"down_list" : [WXYZ_ProductionChapterModel class]};
}

@end

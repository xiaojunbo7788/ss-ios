//
//  WXBookModel.m
//  WXReader
//
//  Created by Andrew on 2018/5/27.
//  Copyright © 2018年 Andrew. All rights reserved.
//
#import "WXYZ_AuthorModel.h"
#import "WXYZ_AuthorSiniciModel.h"
#import "WXYZ_OriginalModel.h"
@implementation WXYZ_ProductionModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{
             @"tag" : [WXYZ_TagModel class],
             @"chapter_list" : [WXYZ_ProductionChapterModel class],
             @"list" : [WXYZ_CatalogListModel class],
             @"author2" : [WXYZ_AuthorModel class],
             @"sinici2": [WXYZ_AuthorSiniciModel class],
             @"original2":[WXYZ_OriginalModel class]
             };
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"production_descirption"  :@"description",
             @"visited"             :@"view",
             @"record_title"        :@"chapter_title",
             @"production_id"       :@[@"book_id", @"comic_id", @"audio_id"],
             @"name"                :@[@"name", @"title", @"book_name", @"comic_name", @"audio_name"],
             @"total_chapters"      :@[@"total_chapters", @"total_chapter"]
             };
}

- (id)copyWithZone:(NSZone *)zone {
    return [self modelCopy];
}

- (NSString *)production_descirption
{
    _production_descirption = [_production_descirption stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    return _production_descirption;
}

@end

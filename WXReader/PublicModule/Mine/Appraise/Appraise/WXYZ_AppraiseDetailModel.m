//
//  WXYZ_AppraiseDetailModel.m
//  WXReader
//
//  Created by Andrew on 2020/4/13.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AppraiseDetailModel.h"

@implementation WXYZ_AppraiseDetailModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"production_id"       :@[@"book_id", @"comic_id", @"audio_id"],
             @"name"                :@[@"name", @"title", @"book_name", @"comic_name", @"audio_name"]
             };
}

@end

//
//  WXYZ_PlayPageModel.m
//  WXReader
//
//  Created by Andrew on 2020/3/10.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_PlayPageModel.h"

@implementation WXYZ_PlayPageModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"comment" : [WXYZ_CommentsModel class],
             @"list" : [WXYZ_ProductionModel class],
             @"advert" : [WXYZ_ADModel class],
             @"relation" : [WXYZ_RelationModel class]
    };
}

@end

@implementation WXYZ_RelationModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"production_id"       :@[@"book_id", @"comic_id", @"audio_id"]
             };
}

@end

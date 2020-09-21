//
//  WXYZ_CatalogModel.m
//  WXReader
//
//  Created by LL on 2020/5/8.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_CatalogModel.h"

@implementation WXYZ_CatalogModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{
        @"list" : WXYZ_CatalogListModel.class,
        @"author" : WXYZ_CatalogAuthorModel.class
    };
}

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"list" : @"chapter_list"
    };
}

@end


@implementation WXYZ_CatalogAuthorModel

@end


@implementation WXYZ_CatalogListModel

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"title" : @"chapter_title",
        @"vip"   : @"is_vip",
        @"preview":@"is_preview",
        @"previou_chapter":@"last_chapter"
    };
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:self.class]) return NO;
    return [self hash] == [object hash];
}

- (NSUInteger)hash {
    return [self.chapter_id hash];
}

@end

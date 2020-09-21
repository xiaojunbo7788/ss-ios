//
//  WXYZ_BannerModel.m
//  WXReader
//
//  Created by Andrew on 2019/6/14.
//  Copyright © 2019 Andrew. All rights reserved.
//


@implementation WXYZ_BannerModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"content"  :@[@"book_id", @"content"]
             };
}

- (NSString *)color
{
    if ([_color hasPrefix:@"#"]) {
        if (_color.length >= 7) {
            return [_color substringWithRange:NSMakeRange(0, 7)];
        }
    }
    return @"#000000";
}

@end

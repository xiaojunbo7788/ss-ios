//
//  WXYZ_BookDownloadTaskListModel.m
//  WXReader
//
//  Created by Andrew on 2019/4/3.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_BookDownloadTaskListModel.h"

@implementation WXYZ_BookDownloadTaskListModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"task_list" : [WXYZ_DownloadTaskModel class]};
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"task_list"    :@"down_option"
             };
}

@end

@implementation WXYZ_DownloadTaskModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"start_chapter_id"  :@"s_chapter"
    };
}

- (NSString *)file_size_title
{
    return [NSString stringWithFormat:@"%.1lfM", self.file_size / 1024.0 / 1024.0];
}

@end

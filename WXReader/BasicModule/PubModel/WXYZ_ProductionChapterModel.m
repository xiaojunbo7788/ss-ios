//
//  WXYZ_ProductionChapterModel.m
//  WXReader
//
//  Created by Andrew on 2020/3/21.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ProductionChapterModel.h"

@implementation WXYZ_ProductionChapterModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"tag" : [WXYZ_TagModel class],
             @"advert" : [WXYZ_ADModel class],
             @"image_list" : [WXYZ_ImageListModel class]
             };
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
            @"production_id":@[@"book_id", @"comic_id", @"audio_id"],
            @"relation_production_id":@"relation_book_id",
            @"total_words":@"words",
            @"name" :@[@"name", @"title", @"book_name", @"comic_name", @"audio_name"],
            @"cover":@[@"cover", @"small_cover"]
             };
}

- (void)setAuthor_note:(NSString *)author_note {
    _author_note = author_note;
}


@end

@implementation WXYZ_ImageListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"image_update_time":@"update_time"
             };
}

- (void)setWidth:(NSInteger)width {
    
    _width = width/[UIScreen mainScreen].scale;
    
}

- (void)setHeight:(NSInteger)height {
    _height = height/[UIScreen mainScreen].scale;
}


- (NSString *)image {
    if (_isUpdateImage) {
        return _image;
    }
    if ([WXYZ_UserInfoManager shareInstance].clearData == 0) {
        if (_image != nil && _image.length > 0) {
            NSArray *imgs = [_image componentsSeparatedByString:@"/"];
            NSString *newImg = @"";
            for (int i = 0; i < imgs.count; i++) {
                if (i == imgs.count -1) {
                    newImg = [NSString stringWithFormat:@"%@%@",newImg,@"900/"];
                    newImg = [NSString stringWithFormat:@"%@%@",newImg,imgs[i]];
                } else {
                    newImg = [NSString stringWithFormat:@"%@%@/",newImg,imgs[i]];
                }
            }
            _isUpdateImage = true;
            _image = newImg;
            return _image;
        } else {
            _isUpdateImage = true;
            return @"";
        }
    } else {
        _isUpdateImage = true;
        return _image;
    }
}

@end

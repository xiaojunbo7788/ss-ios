//
//  WXYZ_ComicReaderTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/6/3.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicReaderTableViewCell.h"
#import "WXYZ_ComicDownloadManager.h"

@implementation WXYZ_ComicReaderTableViewCell
{
    UIImageView *chapterImageView;
}

- (void)createSubviews
{
    [super createSubviews];
    
    chapterImageView = [[UIImageView alloc] init];
    chapterImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:chapterImageView];
    
    [chapterImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.width.mas_equalTo(self.contentView.mas_width);
        make.height.mas_equalTo(SCREEN_HEIGHT);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).priorityLow();
    }];   
}

- (void)setImageModel:(WXYZ_ImageListModel *)imageModel
{
    _imageModel = imageModel;
    
    [chapterImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kGeometricHeight(SCREEN_WIDTH, imageModel.width <= 0?SCREEN_WIDTH:imageModel.width, imageModel.height <= 0?SCREEN_HEIGHT:imageModel.height));
    }];
    
    // 查找内存中的图片缓存
    UIImage *cacheImage = [[YYImageCache sharedCache] getImageForKey:imageModel.image withType:YYImageCacheTypeMemory];
    
    // 如果有则使用缓存加载图片
    if (cacheImage) {
        chapterImageView.image = cacheImage;
    } else { // 缓存中不存在,则从本地查找图片,获取本地图片后,也放置内存中,提高运行速度
        
        // 查找沙盒中的文件
        UIImage *localImage = [[WXYZ_ComicDownloadManager sharedManager] getDownloadLocalImageWithProduction_id:self.comic_id chapter_id:self.chapter_id image_id:imageModel.image_id image_update_time:imageModel.image_update_time];
        if (localImage) {
            chapterImageView.image = localImage;
            
            // 将沙盒中的文件存储到内存中
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[YYImageCache sharedCache] setImage:localImage imageData:nil forKey:imageModel.image withType:YYImageCacheTypeMemory];
            });
            
        } else { // 沙盒中没有缓存图片
            
            // 加载网络图片
            [chapterImageView setImageWithURL:[NSURL URLWithString:imageModel.image] placeholder:HoldImage options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
        }
    }
}

@end

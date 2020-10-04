//
//  WXYZ_ComicReaderTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/6/3.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicReaderCollectionCell.h"
#import "WXYZ_ComicDownloadManager.h"

@interface WXYZ_ComicReaderCollectionCell ()

@property (nonatomic, strong) UIImageView *chapterImageView;

@end
@implementation WXYZ_ComicReaderCollectionCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.chapterImageView = [[UIImageView alloc] init];
           self.chapterImageView.contentMode = UIViewContentModeScaleAspectFit;
           [self.contentView addSubview:self.chapterImageView];
           
           [self.chapterImageView mas_makeConstraints:^(MASConstraintMaker *make) {
               make.centerY.mas_equalTo(self.contentView).offset(-PUB_NAVBAR_HEIGHT);
               make.width.mas_equalTo(SCREEN_WIDTH);
               make.centerX.mas_equalTo(self.contentView.mas_centerX);
               make.height.mas_equalTo(self.contentView.mas_height);
//               make.bottom.mas_equalTo(self.contentView.mas_bottom).priorityLow();
           }];
    }
    return self;
}

- (void)setSelModel:(int)selModel {
    _selModel = selModel;

}

- (void)setImageModel:(WXYZ_ImageListModel *)imageModel
{
    _imageModel = imageModel;

    if (imageModel.width !=0 && imageModel.height!=0) {    
//        [self.chapterImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//
//             if (imageModel.width <= SCREEN_WIDTH) {
//                make.height.mas_equalTo((float)(SCREEN_WIDTH/(imageModel.width*1.0)) * imageModel.height);
//             } else {
//                make.height.mas_equalTo((float)(imageModel.width*1.0/SCREEN_WIDTH) * imageModel.height);
//             }
//        }];
    }
    
    // 查找内存中的图片缓存
    UIImage *cacheImage = [[YYImageCache sharedCache] getImageForKey:imageModel.image withType:YYImageCacheTypeMemory];
    
    // 如果有则使用缓存加载图片
    if (cacheImage) {
        self.chapterImageView.image = cacheImage;
        imageModel.width =cacheImage.size.width/[UIScreen mainScreen].scale;
         imageModel.height =cacheImage.size.height/[UIScreen mainScreen].scale;
//        [self.chapterImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//
//               if (imageModel.width == 0 || imageModel.height == 0) {
//                   make.height.mas_equalTo(kGeometricHeight(SCREEN_WIDTH, imageModel.width <= 0?SCREEN_WIDTH:imageModel.width, imageModel.height <= 0?SCREEN_HEIGHT:imageModel.height));
//               } else {
//                   if (imageModel.width <= SCREEN_WIDTH) {
//                       make.height.mas_equalTo((float)(SCREEN_WIDTH/(imageModel.width*1.0)) * imageModel.height);
//                   } else {
//                       make.height.mas_equalTo((float)(imageModel.width*1.0/SCREEN_WIDTH) * imageModel.height);
//                   }
//               }
//           }];
        
    } else { // 缓存中不存在,则从本地查找图片,获取本地图片后,也放置内存中,提高运行速度
        
        // 查找沙盒中的文件
        UIImage *localImage = [[WXYZ_ComicDownloadManager sharedManager] getDownloadLocalImageWithProduction_id:self.comic_id chapter_id:self.chapter_id image_id:imageModel.image_id image_update_time:imageModel.image_update_time];
        if (localImage) {
            self.chapterImageView.image = localImage;
            
            // 将沙盒中的文件存储到内存中
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[YYImageCache sharedCache] setImage:localImage imageData:nil forKey:imageModel.image withType:YYImageCacheTypeMemory];
            });
            
        } else { // 沙盒中没有缓存图片
            // 加载网络图片
            @weakify(self);
            [self.chapterImageView setImageWithURL:[NSURL URLWithString:imageModel.image] placeholder:HoldImage options:YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                @strongify(self);
                if (error==nil && image != nil) {
                    if (imageModel.width !=0 && imageModel.height!=0) {
                        return;
                    }
                    imageModel.width =image.size.width/[UIScreen mainScreen].scale;
                    imageModel.height =image.size.height/[UIScreen mainScreen].scale;
                
//                    [self.chapterImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//
//                        if (imageModel.width == 0 || imageModel.height == 0) {
//                            make.height.mas_equalTo(kGeometricHeight(SCREEN_WIDTH, imageModel.width <= 0?SCREEN_WIDTH:imageModel.width, imageModel.height <= 0?SCREEN_HEIGHT:imageModel.height));
//                        } else {
//                            if (imageModel.width <= SCREEN_WIDTH) {
//                                make.height.mas_equalTo((float)(SCREEN_WIDTH/(imageModel.width*1.0)) * imageModel.height);
//                            } else {
//                                make.height.mas_equalTo((float)(imageModel.width*1.0/SCREEN_WIDTH) * imageModel.height);
//                            }
//                        }
//                    }];
                
                    if (self.delegate != nil) {
                        [self.delegate refreshCurrentCell:self.localRow];
                    }
                }
            }];
        }
    }
}


@end

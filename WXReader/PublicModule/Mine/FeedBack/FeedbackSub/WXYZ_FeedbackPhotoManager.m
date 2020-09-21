//
//  WXYZ_FeedbackPhotoManager.m
//  WXReader
//
//  Created by Andrew on 2019/12/28.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_FeedbackPhotoManager.h"

@interface WXYZ_FeedbackPhotoManager ()

@property (nonatomic, strong) NSMutableSet *uploadSet;

@end

@implementation WXYZ_FeedbackPhotoManager

implementation_singleton(WXYZ_FeedbackPhotoManager)

- (instancetype)init
{
    if (self = [super init]) {
        self.uploadSet = [NSMutableSet set];
    }
    return self;
}

- (void)addPhotoImage:(UIImage *)image complete:(void(^)(WXYZ_FeedbackPhotoModel *photoModel))completeBlock
{
    NSString *imageBase64 = [WXYZ_ViewHelper getBase64StringWithImageData:UIImagePNGRepresentation(image)];
    if (imageBase64.length == 0 || !imageBase64) {
        if (completeBlock) {
            completeBlock(nil);
        }
        return;
    }
    
    [self.uploadSet addObject:@"upload"];
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Upload_Image parameters:@{@"image":imageBase64} model:WXYZ_FeedbackPhotoModel.class success:^(BOOL isSuccess, id _Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            !completeBlock ?: completeBlock(t_model);
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"图片上传失败"];
            !completeBlock ?: completeBlock(nil);
        }
        
        [weakSelf.uploadSet removeObject:[weakSelf.uploadSet anyObject]];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
        [weakSelf.uploadSet removeObject:[weakSelf.uploadSet anyObject]];
        !completeBlock ?: completeBlock(nil);
    }];
}

- (BOOL)isUploading
{
    return self.uploadSet.count > 0;
}

- (void)deletePhotoWithPhotoModel:(WXYZ_FeedbackPhotoModel *)photoModel
{
    if (photoModel.show_img.length <= 0) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"图片删除失败"];
        return;
    }
   
    [self removeAllPhotoImageWithPhotoArray:@[photoModel]];
    
    if (photoModel) {
        if (self.deletePhotoBlock) {
            self.deletePhotoBlock(photoModel);
        }
    }
}

- (void)removeAllPhotoImageWithPhotoArray:(NSArray *)dataSources
{
    [self.uploadSet removeAllObjects];
    
    if (dataSources.count <= 0) {
        return;
    }
    
    NSMutableArray *imgs = [NSMutableArray arrayWithCapacity:3];
    for (WXYZ_FeedbackPhotoModel *t_model in dataSources) {
        if (t_model.img) {
            [imgs addObject:t_model.img];            
        }
    }
    
    [WXYZ_NetworkRequestManger POST:Delete_Upload_Image parameters:@{@"image":[imgs componentsJoinedByString:@"||"]} model:nil success:nil failure:nil];
}

@end

//
//  DPImagePicker.m
//
//  Created by Andrew on 2017/9/11.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "WXYZ_ImagePicker.h"
#import <CoreServices/CoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <Photos/Photos.h>

@class UIActionSheetDelegateImpl;
static UIActionSheetDelegateImpl * delegateImpl;

@implementation WXYZ_ImagePicker
{
    UIViewController *_showController;
}

implementation_singleton(WXYZ_ImagePicker)

- (instancetype)init
{
    if (self = [super init]) {
        _cameraFlashMode = DPCameraFlashModeAuto;
        _cameraDevice = DPCameraDeviceFront;
    }
    return self;
}

- (void)showInController:(UIViewController *)showController
{
    _showController = showController;
    
    WS(weakSelf)
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (is_iPad) {
        UIPopoverPresentationController *popover = actionSheet.popoverPresentationController;
        
        if (popover) {
            popover.sourceView = self;
            popover.sourceRect = self.bounds;
            
            popover.permittedArrowDirections = UIPopoverArrowDirectionDown;
        }        
    }
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        if (weakSelf.chooseImageStyleBlock) {
            weakSelf.chooseImageStyleBlock(DPChooseImageTypeCamera);
        }
        //相机
        [weakSelf turnOnCamera];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"从相册中选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (weakSelf.chooseImageStyleBlock) {
            weakSelf.chooseImageStyleBlock(DPChooseImageTypeLibrary);
        }
        //相册
        [weakSelf turnOnLibrary];
    }]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }]];

    [[WXYZ_ViewHelper getWindowRootController] presentViewController:actionSheet animated:YES completion:nil];
}

- (void)showCameraInController:(UIViewController *)showController
{
    _showController = showController;
    [self turnOnCamera];
}

- (void)showLibraryInController:(UIViewController *)showController
{
    _showController = showController;
    [self turnOnLibrary];
}

- (void)turnOnCamera
{
    //当前设备没有摄像头
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"提示" message:@"当前设备没有摄像头" preferredStyle:UIAlertControllerStyleAlert];
        [alertView addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }]];
        [[WXYZ_ViewHelper getWindowRootController] presentViewController:alertView animated:YES completion:nil];
        return;
    }
    
    //无法获取相机权限
    if([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == kCLAuthorizationStatusDenied){
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"提示" message:@"请前往设置->隐私->相机授权应用拍照权限" preferredStyle:UIAlertControllerStyleAlert];
        [alertView addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }]];
        [[WXYZ_ViewHelper getWindowRootController] presentViewController:alertView animated:YES completion:nil];
        return;
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = _editPhoto;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.cameraDevice = _cameraDevice == DPCameraDeviceFront?UIImagePickerControllerCameraDeviceFront:UIImagePickerControllerCameraDeviceRear;
    switch (_cameraFlashMode) {
        case DPCameraFlashModeAuto:
            imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
            break;
        case DPCameraFlashModeOn:
            imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
            break;
        case DPCameraFlashModeOff:
            imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
            break;
            
        default:
            break;
    }
    imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    [_showController presentViewController:imagePickerController animated:YES completion:nil];
    
}

- (void)turnOnLibrary
{
    //当前设备没有相册
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"提示" message:@"当前设备没有相册" preferredStyle:UIAlertControllerStyleAlert];
        [alertView addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }]];
        [[WXYZ_ViewHelper getWindowRootController] presentViewController:alertView animated:YES completion:nil];
        return;
    }
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                break;
            case PHAuthorizationStatusDenied:
                break;
            case PHAuthorizationStatusNotDetermined:
                break;
            case PHAuthorizationStatusRestricted:
                break;
        }
    }];
    //无法访问相册
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied) {
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"提示" message:@"请前往设置->隐私->相册授权应用访问相册权限" preferredStyle:UIAlertControllerStyleAlert];
        [alertView addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }]];
        [[WXYZ_ViewHelper getWindowRootController] presentViewController:alertView animated:YES completion:nil];
        return;
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.allowsEditing = _editPhoto;
    imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    [_showController presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark -  UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    picker.delegate = nil;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    if ([self.delegate respondsToSelector:@selector(imagePickerDidFinishPickingWithOriginalImage:editedImage:)]) {
        [self.delegate imagePickerDidFinishPickingWithOriginalImage:originalImage editedImage:editedImage];
    }
    
    //如果是拍摄的照片，将自动保存到相册
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage] && picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(originalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

//点击Cancel按钮后执行方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_showController dismissViewControllerAnimated:YES completion:nil];
    if ([self.delegate respondsToSelector:@selector(imagePickerDidCancel)]) {
        [self.delegate imagePickerDidCancel];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([UIDevice currentDevice].systemVersion.floatValue < 11) {
        return;
    }
    if ([viewController isKindOfClass:NSClassFromString(@"PUPhotoPickerHostViewController")]) {
        [viewController.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.bounds.size.width < SCREEN_WIDTH / 9 && !obj.isHidden) {
                obj.hidden = YES;
                *stop = YES;
            }
        }];
    }
}

//保存照片成功后的回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{

}

@end

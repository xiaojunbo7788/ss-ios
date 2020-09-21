//
//  DPImagePicker.h
//
//  Created by Andrew on 2017/9/11.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    DPCameraDeviceFront,    //前置摄像头
    DPCameraDeviceRear,     //后置摄像头
} DPCameraDevice;

typedef enum : NSUInteger {
    DPCameraFlashModeOff,   //关闭闪光灯
    DPCameraFlashModeAuto,  //自动闪光灯
    DPCameraFlashModeOn,    //开启闪光灯
} DPCameraFlashMode;

typedef enum : NSUInteger {
    DPChooseImageTypeCamera,
    DPChooseImageTypeLibrary,
    DPChooseImageTypeUnknow
} DPChooseImageType;

typedef void(^ChooseImageStyleBlock)(DPChooseImageType type);

@protocol DPImagePickerDelegate <NSObject>

@optional

/**
 图片选择完毕

 @param originalImage   未编辑原图
 @param editedImage     编辑后图片
 */
- (void)imagePickerDidFinishPickingWithOriginalImage:(UIImage *)originalImage editedImage:(UIImage *)editedImage;

- (void)imagePickerDidCancel;

@end

@interface WXYZ_ImagePicker : UIView <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) id <DPImagePickerDelegate> delegate;

@property (nonatomic, copy) ChooseImageStyleBlock chooseImageStyleBlock;
/**
 是否可以编辑图片
 default is NO
 */
@property (nonatomic, assign) BOOL editPhoto;

/**
 前置/后置摄像头
 default is Rear
 */
@property (nonatomic, assign) DPCameraDevice cameraDevice;

/**
 闪光灯类型
 default is Auto
 */
@property (nonatomic, assign) DPCameraFlashMode cameraFlashMode;

interface_singleton

/**
 显示图片选择器

 @param showController 承载的Controller
 */
- (void)showInController:(UIViewController *)showController;

/**
 只显示相机

 @param showController 承载Controller
 */
- (void)showCameraInController:(UIViewController *)showController;

/**
 只显示相册

 @param showController 承载Controller
 */
- (void)showLibraryInController:(UIViewController *)showController;

@end

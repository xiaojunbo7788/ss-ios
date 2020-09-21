//
//  WXYZ_BookReaderBackViewController.m
//  WXReader
//
//  Created by Andrew on 2018/5/30.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BookReaderBackViewController.h"
#import "WXYZ_ReaderSettingHelper.h"
#import "WXYZ_ADManager.h"

@interface WXYZ_BookReaderBackViewController ()

@property (nonatomic, weak) UIImageView *backgroundImageView;

@end

@implementation WXYZ_BookReaderBackViewController

- (instancetype)init {
    if (self = [super init]) {
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews {
    self.view.backgroundColor = [[WXYZ_ReaderSettingHelper sharedManager] getReaderBackgroundColor];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    backgroundImageView.backgroundColor = self.view.backgroundColor;
    self.backgroundImageView = backgroundImageView;
    [self.view addSubview:backgroundImageView];
}

- (void)updateWithViewController:(UIViewController *)viewController {
    self.backgroundImageView.frame = viewController.view.bounds;
    self.backgroundImageView.image = [self captureView:viewController.view];
    self.backgroundImageView.alpha = 0.6;
}

- (UIImage *)captureView:(UIView *)view {
    UIImage * __block image = nil;
    kCodeSync({
        CGRect rect = view.bounds;
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGAffineTransform transform = CGAffineTransformMake(-1.0, 0.0, 0.0, 1.0, rect.size.width, 0.0);
        CGContextConcatCTM(context,transform);
        [view.layer renderInContext:context];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}


@end

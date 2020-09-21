//
//  WXYZ_ViewHelper.m
//  WXReader
//
//  Created by Andrew on 2019/7/9.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ViewHelper.h"

@implementation WXYZ_ViewHelper

#pragma mark -  上传图片处理

+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(SCREEN_WIDTH, PUB_TABBAR_HEIGHT));
    [image drawInRect:CGRectMake(0, 0, SCREEN_WIDTH, PUB_TABBAR_HEIGHT)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (NSString *)getBase64StringWithImageData:(NSData *)imageData
{
    return [self image2DataURL:[self imageWithImage:[self fixOrientation:[UIImage imageWithData:imageData]]]];
}

+ (UIImage *)fixOrientation:(UIImage *)aImage
{
    if (aImage.imageOrientation == UIImageOrientationUp) return aImage;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
}

+ (UIImage *)imageWithImage:(UIImage *)image
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height));
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (NSString *)image2DataURL: (UIImage *) image
{
    NSData *imageData = nil;
    NSString *mimeType = nil;
    
    imageData = UIImageJPEGRepresentation(image, 0.7f);
    mimeType = @"image/jpeg";
    
    return [NSString stringWithFormat:@"data:%@;base64,%@", mimeType,
            [imageData base64EncodedStringWithOptions: 0]];
    
}

+ (NSMutableAttributedString *)getSubContentWithOriginalContent:(NSMutableAttributedString *)originalContent labelWidth:(CGFloat)labelWidth labelMaxLine:(NSInteger)labelMaxLine
{
    if (originalContent.length == 0 || labelWidth == 0 || labelMaxLine == 0) {
        return nil;
    }
    
    // 计算总字符长度
    CGFloat totalStringLength = 0;
    
    for (int i = 0; i < [originalContent length]; i ++) {
        
        // 找出每个字符
        NSAttributedString *characterString = [originalContent attributedSubstringFromRange:NSMakeRange(i, 1)];
        
        // 处理换行符
        if ([characterString.string isEqualToString:@"\n"]) {
            
            // 换行符再当前行的位置(类似于取余)
            CGFloat currentDistanceToTop = totalStringLength - (int)(totalStringLength / labelWidth) * labelWidth;
            
            // 换行符到末尾的距离
            CGFloat distanceToEnd = labelWidth - currentDistanceToTop;
            
            totalStringLength = totalStringLength + distanceToEnd;
            
        } else {
            // 计算字符宽度
            CGFloat characterWidth = [characterString boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine context:nil].size.width;
            
            totalStringLength = totalStringLength + characterWidth;
        }
    }
    
    // 计算总字符有几行
    NSInteger characterTotalLine = (int)(totalStringLength / labelWidth);
    
    // 计算总字符最后一行宽度
    CGFloat endLineWidth = totalStringLength / labelWidth - characterTotalLine;
    
    
    // 是否需要截取
    BOOL needSeparated = NO;
    
    // 最后一行宽度大于限宽一半
    if (endLineWidth > 0.5) {
        needSeparated = YES;
    }
    
    // 总字符行数大于限制行数
    if (characterTotalLine > labelMaxLine) {
        needSeparated = YES;
        characterTotalLine = labelMaxLine;
    }
    
    // 进行截取
    if (needSeparated) {
        
        CGFloat finalCharacterLength = 0;
        for (int i = 0; i < [originalContent length]; i ++) {
            NSAttributedString *characterString = [originalContent attributedSubstringFromRange:NSMakeRange(i, 1)];
            
            if ([characterString.string isEqualToString:@"\n"]) {
                
                // 换行符再当前行的位置(类似于取余)
                CGFloat currentDistanceToTop = finalCharacterLength - (int)(finalCharacterLength / labelWidth) * labelWidth;
                
                // 换行符到末尾的距离
                CGFloat distanceToEnd = labelWidth - currentDistanceToTop;
                
                finalCharacterLength = finalCharacterLength + distanceToEnd;
                
            } else {
                // 计算字符宽度
                CGFloat characterWidth = [characterString boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine context:nil].size.width;
                
                finalCharacterLength = finalCharacterLength + characterWidth;
            }
            
            //此处截取maxLength,根据需求设置
            if (finalCharacterLength >= labelWidth * (characterTotalLine + 0.5)) {
                NSMutableAttributedString *resultString = [[NSMutableAttributedString alloc] initWithAttributedString:[originalContent attributedSubstringFromRange:NSMakeRange(0, i)]];
                [resultString appendAttributedString:[[NSAttributedString alloc] initWithString:@"..."]];
                return resultString;
            }
        }
    }
    
    
    // 换行符再当前行的位置(类似于取余)
    CGFloat currentDistanceToTop = totalStringLength - (int)(totalStringLength / labelWidth) * labelWidth;
    
    // 如果当前行总字符长度不足一字符长度,则处理当前行的上一行内容
    if (currentDistanceToTop < 15) {
        
        if (characterTotalLine == 1) {
            [originalContent replaceCharactersInRange:NSMakeRange(originalContent.length / 2, originalContent.length - NSMakeRange(0, originalContent.length / 2).length) withString:@"..."];
        } else {
            return [self getSubContentWithOriginalContent:originalContent labelWidth:labelWidth labelMaxLine:labelMaxLine - 1];
        }
    }
    
    return originalContent;
}

+ (CGFloat)boundsWithFont:(UIFont *)font attributedText:(NSAttributedString *)attributedText needWidth:(CGFloat)needWidth lineSpacing:(CGFloat)lineSpacing
{
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    
    style.lineSpacing = lineSpacing;
    
    [attributeString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributedText.length)];
    
    [attributeString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attributedText.length)];
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine;
    
    CGRect rect = [attributeString boundingRectWithSize:CGSizeMake(needWidth, CGFLOAT_MAX) options:options context:nil];
    
    return rect.size.height;
    
}

+ (NSString *)imageExtensionWithFormatString:(NSString *)formatString
{
    if ([formatString isEqualToString:@"image/jpeg"]) {
        return @"jpeg";
    }
    
    if ([formatString isEqualToString:@"image/png"]) {
        return @"png";
    }
    
    if ([formatString isEqualToString:@"image/gif"]) {
        return @"gif";
    }
    
    if ([formatString isEqualToString:@"image/tiff"]) {
        return @"tiff";
    }
    
    if ([formatString isEqualToString:@"image/webp"]) {
        return @"webp";
    }
    
    return @"";
}

+ (NSString *)audioExtensionWithFormatString:(NSString *)formatString
{
    if ([formatString isEqualToString:@"audio/mpeg"] || [formatString isEqualToString:@"audio/x-mpeg-3"] || [formatString isEqualToString:@"audio/mpeg3"]) {
        return @"mp3";
    }

    if ([formatString isEqualToString:@"audio/wav"]) {
        return @"wav";
    }
    
    if ([formatString isEqualToString:@"audio/x-ma-wma"]) {
        return @"wma";
    }
    
    return @"";
}

#pragma mark - 自适应frame
// width
+ (CGFloat)getDynamicWidthWithLabel:(UILabel *)label
{
    return [self getDynamicWidthWithLabelFont:label.font labelHeight:label.bounds.size.height labelText:label.text maxWidth:MAXFLOAT];
}

+ (CGFloat)getDynamicWidthWithLabel:(UILabel *)label maxWidth:(CGFloat)maxWidth
{
    return [self getDynamicWidthWithLabelFont:label.font labelHeight:label.bounds.size.height labelText:label.text maxWidth:maxWidth];
}

+ (CGFloat)getDynamicWidthWithLabelFont:(UIFont *)labelFont labelHeight:(CGFloat)labelHeight labelText:(NSString *)labelText
{
    return [self getDynamicWidthWithLabelFont:labelFont labelHeight:labelHeight labelText:labelText maxWidth:MAXFLOAT];
}

+ (CGFloat)getDynamicWidthWithLabelFont:(UIFont *)labelFont labelHeight:(CGFloat)labelHeight labelText:(NSString *)labelText maxWidth:(CGFloat)maxWidth
{
    CGSize retSize = [self getDynamicSizeWithLabelFont:labelFont labelText:labelText rectWidth:maxWidth rectHeight:labelHeight];
    
    if (retSize.width + kMargin > maxWidth) {
        return maxWidth;
    }
    return retSize.width + 5;
}

// height
+ (CGFloat)getDynamicHeightWithLabel:(UILabel *)label
{
    return [self getDynamicHeightWithLabelFont:label.font labelWidth:label.bounds.size.width labelText:label.text maxHeight:MAXFLOAT];
}

+ (CGFloat)getDynamicHeightWithLabel:(UILabel *)label maxHeight:(CGFloat)maxHeight
{
    return [self getDynamicHeightWithLabelFont:label.font labelWidth:label.bounds.size.width labelText:label.text maxHeight:maxHeight];
}

+ (CGFloat)getDynamicHeightWithLabelFont:(UIFont *)labelFont labelWidth:(CGFloat)labelWidth labelText:(NSString *)labelText
{
    return [self getDynamicHeightWithLabelFont:labelFont labelWidth:labelWidth labelText:labelText maxHeight:MAXFLOAT];
}

+ (CGFloat)getDynamicHeightWithLabelFont:(UIFont *)labelFont labelWidth:(CGFloat)labelWidth labelText:(NSString *)labelText maxHeight:(CGFloat)maxHeight
{
    CGSize retSize = [self getDynamicSizeWithLabelFont:labelFont labelText:labelText rectWidth:labelWidth rectHeight:maxHeight];
    
    if (retSize.height + kMargin > maxHeight) {
        return maxHeight;
    }
    return retSize.height + kMargin;
}

+ (CGSize)getDynamicSizeWithLabelFont:(UIFont *)labelFont labelText:(NSString *)labelText rectWidth:(CGFloat)rectWidth rectHeight:(CGFloat)rectHeight
{
    NSDictionary *attribute = @{NSFontAttributeName:labelFont};
    
    CGSize retSize = [labelText boundingRectWithSize:CGSizeMake(rectWidth, rectHeight)
                                             options:
                      NSStringDrawingTruncatesLastVisibleLine |
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                          attributes:attribute
                                             context:nil].size;
    return retSize;
}

#pragma mark - window
+ (UIViewController *)getWindowRootController
{
    UIViewController *rootController = kMainWindow.rootViewController;
    while (rootController.presentedViewController) {
      rootController = rootController.presentedViewController;
    }
    return rootController;
}

+ (UIViewController *)getCurrentViewController
{
    UIViewController *result = nil;
    // 获取默认的window
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    // app默认windowLevel是UIWindowLevelNormal，如果不是，找到它。
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    
    // 获取window的rootViewController
    result = window.rootViewController;
    while (result.presentedViewController) {
        result = result.presentedViewController;
    }
    if ([result isKindOfClass:[UITabBarController class]]) {
        result = [(UITabBarController *)result selectedViewController];
    }
    if ([result isKindOfClass:[UINavigationController class]]) {
        result = [(UINavigationController *)result visibleViewController];
    }
    return result;
}

+ (UINavigationController *)getCurrentNavigationController {
    UIWindow *window = __IPHONE_13_0 ? [UIApplication sharedApplication].windows.firstObject : [UIApplication sharedApplication].keyWindow;
    id rootViewController = window.rootViewController;
    if ([rootViewController isKindOfClass:UINavigationController.class]) {
        return (UINavigationController *)rootViewController;
    } else if ([rootViewController isKindOfClass:UITabBarController.class]) {
        UITabBarController *tabBarController = rootViewController;
        if (![tabBarController.selectedViewController isKindOfClass:UINavigationController.class]) return nil;
        return tabBarController.selectedViewController;
    }
    return nil;
}

+ (void)setStateBarLightStyle
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

+ (void)setStateBarDefaultStyle
{
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
}

#pragma mark - 特殊字体

// 删除线
+ (NSMutableAttributedString *)addPartionLineWithString:(NSString *)string range:(NSRange)range
{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedStr addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
    return attributedStr;
}
// 下划线
+ (NSMutableAttributedString *)addUnderLineWithString:(NSString *)string range:(NSRange)range
{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
    return attributedStr;
}

// 字体变大
+ (NSMutableAttributedString *)resetFontWithFont:(UIFont *)font string:(NSString *)string range:(NSRange)range
{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedStr addAttribute:NSFontAttributeName value:font range:range];
    return attributedStr;
}

// 字体变色
+ (NSMutableAttributedString *)resetColorWithColor:(UIColor *)color string:(NSString *)string range:(NSRange)range
{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedStr addAttribute:NSForegroundColorAttributeName value:color range:range];
    return attributedStr;
}

// 字体加粗
+ (NSMutableAttributedString *)resetBoldFontWithString:(NSString *)string range:(NSRange)range
{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedStr addAttribute:NSExpansionAttributeName value:[NSNumber numberWithInt:1] range:range];
    return attributedStr;
}


@end

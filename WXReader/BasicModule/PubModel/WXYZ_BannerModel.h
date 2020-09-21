//
//  WXYZ_BannerModel.h
//  WXReader
//
//  Created by Andrew on 2019/6/14.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_BannerModel : NSObject

@property (nonatomic, copy) NSString *content;  // 根据动作类型对于的漫画则为漫画id

@property (nonatomic, copy) NSString *name;     //作品名

@property (nonatomic, copy) NSString *image;    // 封面

@property (nonatomic, copy) NSString *color;    // 封面的背景色

@property (nonatomic, assign) NSInteger action; // 动作类型，1：跳漫画，2：scheme跳转，3：外部链接

@end

NS_ASSUME_NONNULL_END

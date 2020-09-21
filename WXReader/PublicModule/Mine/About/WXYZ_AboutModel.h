//
//  WXYZ_AboutModel.h
//  WXReader
//
//  Created by Andrew on 2018/10/15.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXYZ_ContactInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_AboutModel : NSObject

@property (nonatomic, strong) NSArray <WXYZ_ContactInfoModel *> *about;

@property (nonatomic, copy) NSString *company;  // 公司

@end

@interface WXYZ_ContactInfoModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *action;

@end

NS_ASSUME_NONNULL_END

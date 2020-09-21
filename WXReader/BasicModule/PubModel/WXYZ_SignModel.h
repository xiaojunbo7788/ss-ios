//
//  WXYZ_SignModel.h
//  WXReader
//
//  Created by Andrew on 2019/7/1.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WXYZ_ProductionModel;

@interface WXYZ_SignModel : NSObject

@property (nonatomic, copy) NSString *award;

@property (nonatomic, copy) NSString *sign_days;

@property (nonatomic, copy) NSString *tomorrow_award;

@property (nonatomic, strong) NSArray <WXYZ_ProductionModel *> *book;

@property (nonatomic, strong) NSArray <WXYZ_ProductionModel *> *comic;

@property (nonatomic, strong) NSArray <WXYZ_ProductionModel *> *audio;

@end

NS_ASSUME_NONNULL_END

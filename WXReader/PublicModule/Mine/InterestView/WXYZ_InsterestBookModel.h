//
//  WXYZ_InsterestBookModel.h
//  WXReader
//
//  Created by Andrew on 2018/11/21.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_InsterestBookModel : NSObject

@property (nonatomic, strong) NSArray <WXYZ_ProductionModel *>*book;

@property (nonatomic, strong) NSArray <WXYZ_ProductionModel *>*comic;

@property (nonatomic, strong) NSArray <WXYZ_ProductionModel *>*audio;

@end

NS_ASSUME_NONNULL_END

//
//  WXYZ_SearchModel.h
//  WXReader
//
//  Created by Andrew on 2018/7/5.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXYZ_ProductionModel;

@interface WXYZ_SearchModel : NSObject

@property (nonatomic, strong) NSArray<WXYZ_ProductionModel *> *list;

@property (nonatomic, strong) NSArray<NSString *> *hot_word;

@end

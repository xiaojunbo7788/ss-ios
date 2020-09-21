//
//  WXYZ_PagingModel.h
//  WXReader
//
//  Created by Andrew on 2020/7/30.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_PagingModel : NSObject

// 总页数
@property (nonatomic, assign) NSInteger current_page;

// 当前页数
@property (nonatomic, assign) NSInteger total_page;

// 全部页总数量
@property (nonatomic, assign) NSInteger total_count;

// 当前页总数量
@property (nonatomic, assign) NSInteger page_size;

@end

NS_ASSUME_NONNULL_END

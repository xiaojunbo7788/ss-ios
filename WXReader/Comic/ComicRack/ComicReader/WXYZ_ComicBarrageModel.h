//
//  WXYZ_ComicBarrageModel.h
//  WXReader
//
//  Created by LL on 2020/5/11.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXYZ_ComicBarrageList, WXYZ_PagingModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ComicBarrageModel : WXYZ_PagingModel

@property (nonatomic, copy) NSArray<WXYZ_ComicBarrageList *> *list;

@end


@interface WXYZ_ComicBarrageList : NSObject

/// 弹幕内容
@property (nonatomic, copy) NSString *content;

// 弹幕颜色，16进制
@property (nonatomic, copy) NSString *color;

@property (nonatomic, assign) NSInteger uid;

@end

NS_ASSUME_NONNULL_END

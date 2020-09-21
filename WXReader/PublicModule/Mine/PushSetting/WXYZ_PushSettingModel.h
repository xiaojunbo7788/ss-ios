//
//  WXYZ_PushSettingModel.h
//  WXReader
//
//  Created by Andrew on 2019/12/21.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_PushSettingModel : NSObject

@property (nonatomic, copy) NSString *label;    // 名称
@property (nonatomic, copy) NSString *push_key;      // 开关对应key
@property (nonatomic, assign) NSInteger status; // 状态 1-开启 0-关闭(后端默认开启)

@end

NS_ASSUME_NONNULL_END

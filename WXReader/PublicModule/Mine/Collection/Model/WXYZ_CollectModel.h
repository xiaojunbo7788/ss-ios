//
//  WXYZ_CollectModel.h
//  WXReader
//
//  Created by geng on 2020/9/13.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_CollectModel : NSObject

@property (nonatomic, assign) int type;
@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *from_channel;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, assign) long created_at;
@property (nonatomic, copy) NSString *original;
@property (nonatomic, copy) NSString *sinici;

@property (nonatomic, copy) NSString *count;
@property (nonatomic, copy) NSString *icon;


@end

NS_ASSUME_NONNULL_END

//
//  WXYZ_NetworkRequestManger.h
//  WXDating
//
//  Created by Andrew on 2017/8/13.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@class WXYZ_NetworkRequestModel;

NS_ASSUME_NONNULL_BEGIN

typedef void(^ _Nullable requestSuccessBlock) (BOOL isSuccess, id _Nullable t_model, WXYZ_NetworkRequestModel *requestModel);
typedef void(^ _Nullable quickRequestSuccessBlock) (BOOL isSuccess, id _Nullable t_model, BOOL isCache, WXYZ_NetworkRequestModel *requestModel);
typedef void(^ _Nullable requestFailedBlock) (NSURLSessionDataTask * _Nullable task, NSError *error);

@interface WXYZ_NetworkRequestManger : NSObject

/// POST request
/// @param url 请求地址
/// @param parameters 请求参数
/// @param model 数据类型，设置为nil时返回的t_model将是原始字典
/// @param success 成功回调
/// @param failure 失败回调
+ (void)POST:(NSString *)url parameters:(NSDictionary * _Nullable)parameters model:(Class _Nullable)model success:(requestSuccessBlock)success failure:(requestFailedBlock)failure;


/// POST request，带缓存
/// @param url 请求地址
/// @param parameters 请求参数
/// @param model 数据类型，设置为nil时返回的t_model将是原始字典
/// @param success 成功回调
/// @param failure 失败回调
+ (void)POSTQuick:(NSString *)url parameters:(NSDictionary * _Nullable)parameters model:(Class _Nullable)model success:(quickRequestSuccessBlock)success failure:(requestFailedBlock)failure;


/// POST request，可以设置回调队列
/// @param url 请求地址
/// @param parameters 请求参数
/// @param model 数据类型，设置为nil时返回的t_model将是原始字典
/// @param completionQueue 回调队列
/// @param success 成功回调
/// @param failure 失败回调
+ (void)POST:(NSString *)url parameters:(NSDictionary * _Nullable)parameters model:(Class _Nullable)model completionQueue:(dispatch_queue_t)completionQueue success:(requestSuccessBlock)success failure:(requestFailedBlock)failure;

@end


@interface WXYZ_NetworkRequestModel : NSObject

@property (nonatomic, strong, nullable) NSURLSessionDataTask *task;

@property (nonatomic, strong, nullable) NSDictionary *data;

@property (nonatomic, strong, nullable) NSString *msg;

@property (nonatomic, assign) NSInteger code;

@end

NS_ASSUME_NONNULL_END


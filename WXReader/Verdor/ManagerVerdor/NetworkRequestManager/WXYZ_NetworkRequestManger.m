//
//  WXYZ_NetworkRequestManger.m
//  WXDating
//
//  Created by Andrew on 2017/8/13.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "WXYZ_NetworkRequestManger.h"
#import <XHNetworkCache.h>
#import "CommonCrypto/CommonDigest.h"


// 请求成功
#define Request_Success_From(x) [[NSString stringWithFormat:@"%@",[x objectForKey:@"code"]] isEqualToString:@"0"]

static NSString * const kCode = @"code";

static NSString * const kMsg = @"msg";

static NSString * const kData = @"data";


@implementation WXYZ_NetworkRequestManger

+ (void)POST:(NSString *)url parameters:(NSDictionary * _Nullable)parameters model:(Class _Nullable)model success:(requestSuccessBlock)success failure:(requestFailedBlock)failure {
    [self POST:url parameters:parameters model:model completionQueue:dispatch_get_main_queue() success:success failure:failure];
}

+ (void)POSTQuick:(NSString *)url parameters:(NSDictionary * _Nullable)parameters model:(Class _Nullable)model success:(quickRequestSuccessBlock)success failure:(requestFailedBlock)failure {
    // 读取缓存数据，若存在则返回缓存数据
    if ([XHNetworkCache checkCacheWithURL:url params:parameters]) {
        id cacheData = [XHNetworkCache cacheJsonWithURL:url params:parameters];
        if ([cacheData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary:cacheData];
            WXYZ_NetworkRequestModel *requestModel = [[WXYZ_NetworkRequestModel alloc] init];
            requestModel.data = dic;
            dispatch_async(dispatch_get_main_queue(), ^{
                !success ?: success(YES, model ? [model modelWithDictionary:dic] : dic, YES, requestModel);
            });
        }
    }
    
    [self POST:url parameters:parameters model:model completionQueue:dispatch_get_main_queue() success:^(BOOL isSuccess, id  _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            [XHNetworkCache save_asyncJsonResponseToCacheFile:model ? [t_model modelToJSONObject] : t_model[kData] andURL:url params:parameters completed:nil];
        }
        !success ?: success(isSuccess, t_model, NO, requestModel);
    } failure:failure];
}

+ (void)POST:(NSString *)url parameters:(NSDictionary *)parameters model:(Class _Nullable)model completionQueue:(dispatch_queue_t)completionQueue success:(requestSuccessBlock)success failure:(requestFailedBlock)failure {
    if (![WXYZ_NetworkReachabilityManager networkingStatus]) return;// 没有网络则直接返回
    
    url = [APIURL stringByAppendingString:url];
    parameters = [self integrationRequestWithParameters:parameters ?: @{}];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy = securityPolicy;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setTimeoutInterval:kOvertime];
    manager.completionQueue = completionQueue;
    
    [manager POST:url parameters:parameters headers:@{@"Content-Type":@"application/json", @"Accept":@"application/json"} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSDictionary dictionaryWithDictionary:responseObject];
#if defined(DEBUG) && DEBUG
        NSLog(@"========== %@",dic);
        #endif
        WXYZ_NetworkRequestModel *requestModel = [[WXYZ_NetworkRequestModel alloc] init];
        requestModel.task = task;
        requestModel.data = dic[kData];
        requestModel.msg = [NSString stringWithFormat:@"%@", dic[kMsg]];
        requestModel.code = [dic[kCode] integerValue];
        
        if (requestModel.code != 704) { // 704 请求重复排除
            !success ?: success(Request_Success_From(dic), model ? [model modelWithDictionary:dic[kData]] : dic, requestModel);
        }
        
        [manager.session finishTasksAndInvalidate];
        if (requestModel.code == 301 || requestModel.code == 302) {
            [kNotification postNotificationName:Notification_Logout object:nil];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(task, error);
        [manager.session finishTasksAndInvalidate];
    }];
}

+ (NSString *)authString:(NSDictionary *)params {
    NSArray *allKeys = params.allKeys;
    allKeys = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    NSMutableArray *signArray = [NSMutableArray array];
    for (NSString *key in allKeys) {
        NSString *keyValue = [NSString stringWithFormat:@"%@=%@", key, params[key]];
        [signArray addObject:keyValue];
    }
    
    NSString *signString = [signArray componentsJoinedByString:@"&"];
    signString = [NSString stringWithFormat:@"%@%@%@", app_key, signString, secret_key];
    
    return [self stringToMD5:signString];
}

+ (NSDictionary *)integrationRequestWithParameters:(NSDictionary *)parameters {
    NSMutableDictionary *integrationParament = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [integrationParament setObject:App_Ver forKey:@"ver"];
    [integrationParament setObject:@"1" forKey:@"osType"];
    [integrationParament setObject:@"1" forKey:@"appId"];
    [integrationParament setObject:@"1" forKey:@"product"];
    [integrationParament setObject:@"AppStore" forKey:@"marketChannel"];
    [integrationParament setObject:[[NSBundle mainBundle] bundleIdentifier] forKey:@"packageName"];
    [integrationParament setObject:[WXYZ_UtilsHelper getTimeStamp] ?: @"" forKey:@"time"];
    [integrationParament setObject:[WXYZ_UtilsHelper getUDID] ?: @"" forKey:@"udid"];
    [integrationParament setObject:[WXYZ_UtilsHelper getSystemVersion] ?: @"" forKey:@"sysVer"];
    [integrationParament setObject:[WXYZ_UtilsHelper getCurrentDeviceModel] ?: @"" forKey:@"phoneModel"];
    [integrationParament setObject:[WXYZ_UserInfoManager shareInstance].token forKey:@"token"];
    [integrationParament setObject:[self authString:integrationParament] ?: @"" forKey:@"sign"];
    
    return integrationParament;
}

+ (NSString *)stringToMD5:(NSString *)inputStr
{
    const char *cStr = [inputStr UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr,(CC_LONG)strlen(cStr), result);
    NSString *resultStr = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    return [resultStr lowercaseString];
}

@end

@implementation WXYZ_NetworkRequestModel
@end

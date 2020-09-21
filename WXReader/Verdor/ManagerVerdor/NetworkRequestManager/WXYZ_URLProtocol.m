//
//  WXYZ_URLProtocol.m
//  WXReader
//
//  Created by Chair on 2020/3/21.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_URLProtocol.h"

#import "AppDelegate.h"
#import <objc/runtime.h>

// 拦截标识符,避免无限循环
static NSString * const kProtocolIdentifier = @"kProtocolIdentifier";

// 默认微信Token请求接口前缀
static NSString * const kDefaultTokenURL = @"https://api.weixin.qq.com/sns/oauth2/access_token?";

@interface WXYZ_URLProtocol () <NSURLConnectionDelegate,NSURLConnectionDataDelegate, NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSOperationQueue     *sessionDelegateQueue;
@property (nonatomic, strong) NSURLResponse        *response;
@property (nonatomic, weak) AppDelegate *delegate;

@end

@implementation WXYZ_URLProtocol

#pragma mark - Public
+ (void)startMonitor {
    [NSURLProtocol registerClass:self];
    [self sharedInstance];
    [_instance load];
}

+ (void)stopMonitor {
    [NSURLProtocol unregisterClass:self];
    [self sharedInstance];
    [_instance unload];
}

static WXYZ_URLProtocol *_instance;
+ (instancetype)sharedInstance {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    
    return _instance;
}


#pragma mark - Override
/// 拦截网络请求
/// @param request 需要拦截的请求
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([NSURLProtocol propertyForKey:kProtocolIdentifier inRequest:request]){
         return NO;
    }
    
    // 拦截微信获取Token的网络请求。
    dispatch_semaphore_t signal = dispatch_semaphore_create(0);
    AppDelegate * __block delegate;
    dispatch_async(dispatch_get_main_queue(), ^{
        delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _instance.delegate = delegate;
        dispatch_semaphore_signal(signal);
    });
    dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);
    NSString *prefix = delegate.checkSettingModel.wechatTokenURL ?: kDefaultTokenURL;
    if ([request.URL.absoluteString hasPrefix:prefix]) {
        NSURLComponents *components = [[NSURLComponents alloc] initWithString:request.URL.absoluteString];
        [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *name = obj.name;
            NSString *value = obj.value;
            if ([name isEqualToString:@"code"]) {
                delegate.wechatCode = value;
            }
        }];
        return YES;
    }
    return NO;
}

/// 返回自定义的网络请求
/// @param request 网络请求
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return [[NSURLRequest alloc] init];
}

// 重写父类的开始加载方法
- (void)startLoading {
    NSURLSessionConfiguration *configuration =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    self.sessionDelegateQueue = [[NSOperationQueue alloc] init];
    self.sessionDelegateQueue.maxConcurrentOperationCount = 1;
    self.sessionDelegateQueue.name = @"com.beiwo.queue";
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:configuration
                                  delegate:self
                             delegateQueue:self.sessionDelegateQueue];
    
    self.dataTask = [session dataTaskWithRequest:self.request];
    [self.dataTask resume];
}

// 结束加载
- (void)stopLoading {
    [self.dataTask cancel];
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!error) {
        [self.client URLProtocolDidFinishLoading:self];
    } else if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
    } else {
        [self.client URLProtocol:self didFailWithError:error];
    }
    self.dataTask = nil;
}

#pragma mark - NSURLSessionDataDelegate
// 当服务端返回信息时，这个回调函数会被ULS调用，在这里实现http返回信息的截取
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    // 返回给URL Loading System接收到的数据，这个很重要，不然光截取不返回，就瞎了。
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    completionHandler(NSURLSessionResponseAllow);
    self.response = response;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    if (response != nil){
        self.response = response;
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
}


#pragma mark - Private
- (void)load {
    if (_isSwizzle == YES) return ;
    _isSwizzle = YES;
    [WXYZ_SessionConfig swizzleSelector];
}

- (void)unload {
    if (_isSwizzle == NO) return ;
    _isSwizzle = NO;
    [WXYZ_SessionConfig swizzleSelector];
}

@end


@implementation WXYZ_SessionConfig

+ (void)swizzleSelector {
    Class originCls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
    Method fromMethod = class_getInstanceMethod(originCls, @selector(protocolClasses));
    Method toMethed = class_getInstanceMethod(self.class, @selector(protocolClasses));
    if (!fromMethod || !toMethed) {
        [NSException raise:NSInternalInconsistencyException format:@"无法加载NEURLSessionConfiguration。"];
    }
    method_exchangeImplementations(fromMethod, toMethed);
}

- (NSArray *)protocolClasses {
    // 在这里添加其他的自定义URLProtocol。
    return @[[WXYZ_URLProtocol class]];
}

@end

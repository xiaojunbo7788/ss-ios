//
//  IAPManager.m
//  IAPDemo
//
//  Created by Charles.Yao on 2016/10/31.
//  Copyright © 2016年 com.pico. All rights reserved.
//

#import "IAPManager.h"
#import "SandBoxHelper.h"
#import "NSDate+category.h"

static NSString * const receiptKey = @"receipt_key";
static NSString * const dateKey = @"date_key";
static NSString * const userIdKey = @"userId_key";

dispatch_queue_t iap_queue() {
    static dispatch_queue_t as_iap_queue;
    static dispatch_once_t onceToken_iap_queue;
    dispatch_once(&onceToken_iap_queue, ^{
        as_iap_queue = dispatch_queue_create([[NSString stringWithFormat:@"com.%@.queue", app_key] cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_CONCURRENT);
    });
    
    return as_iap_queue;
}

@interface IAPManager ()<SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (nonatomic, assign) BOOL goodsRequestFinished; //判断一次请求是否完成

@property (nonatomic, copy) NSString *receipt; //交易成功后拿到的一个64编码字符串

@property (nonatomic, copy) NSString *date; //交易时间

@property (nonatomic, copy) NSString *userId; //交易人

@end

@implementation IAPManager

implementation_singleton(IAPManager)

/***
 内购支付两个阶段：
 1.app直接向苹果服务器请求商品，支付阶段；
 2.苹果服务器返回凭证，app向公司服务器发送验证，公司再向苹果服务器验证阶段；
 */

/**
 阶段一正在进中,app退出。
 在程序启动时，设置监听，监听是否有未完成订单，有的话恢复订单。
 */

//开启监听
- (void)startManager
{

    dispatch_async(iap_queue(), ^{
       
        self.goodsRequestFinished = YES;
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

        [self checkIAPFiles];
    });
}

- (void)stopManager
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    });
}

#pragma mark - 开始请求苹果商品
- (void)requestProductWithId:(NSString *)productId
{
    if (!WXYZ_UserInfoManager.isLogin) {
        [WXYZ_LoginViewController presentLoginView];
        [self filedWithErrorCode:IAP_FILEDCOED_NOTLOGGEDIN error:nil];
        self.goodsRequestFinished = YES; // 商品信息错误
        return;
    }
    
    if (self.goodsRequestFinished) {
        
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeLoading alertTitle:@"正在连接App Store"];
       
        if ([SKPaymentQueue canMakePayments]) { //用户允许app内购
            
            if (productId.length) {
               
                self.goodsRequestFinished = NO;
               
                NSArray *product = [[NSArray alloc] initWithObjects:productId, nil];
                NSSet *set = [NSSet setWithArray:product];
                SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
                productRequest.delegate = self;
                [productRequest start];
            
            } else {
                [self filedWithErrorCode:IAP_FILEDCOED_EMPTYGOODS error:nil];
                self.goodsRequestFinished = YES; // 商品信息错误
            }
        
        } else { //用户未允许app内购
            [self filedWithErrorCode:IAP_FILEDCOED_NORIGHT error:nil];
            self.goodsRequestFinished = YES; //
        }
    
    } else { // 正在进行其他交易
        
    }
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *product = response.products;
    if (product.count == 0) {
        
        [self filedWithErrorCode:IAP_FILEDCOED_CANNOTGETINFORMATION error:nil];
        self.goodsRequestFinished = YES; //失败，请求完成

    } else {
        //发起购买请求
        SKPayment *payment = [SKPayment paymentWithProduct:product[0]];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    self.goodsRequestFinished = YES; //成功，请求完成
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [self filedWithErrorCode:IAP_FILEDCOED_APPLECODE error:[error localizedDescription]];
    self.goodsRequestFinished = YES; //失败，请求完成
}

#pragma mark - 购买操作后的回调
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
       
        switch (transaction.transactionState) {
                
                // 正在交易
            case SKPaymentTransactionStatePurchasing:
                
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeLoading alertTitle:@"商品正在请求中"];
                break;
                
                // 交易完成
            case SKPaymentTransactionStatePurchased: {
                [self getReceipt];      // 获取交易成功后的购买凭证
                [self saveReceipt];     // 存储交易凭证
                [self checkIAPFiles];   // 发送凭证服务器验证是否有效
                [self completeTransaction:transaction];
            }
                break;

                // 交易失败
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;

                // 已经购买过该商品
            case SKPaymentTransactionStateRestored:
                
                [self restoreTransaction:transaction];
                
                break;
           
            default:
               
                break;
        }
    }
}

// 获取交易成功后的购买凭证
- (void)getReceipt
{
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    self.receipt = [receiptData base64EncodedStringWithOptions:0];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if(transaction.error.code != SKErrorPaymentCancelled) {
        // 交易失败
        [self filedWithErrorCode:IAP_FILEDCOED_BUYFILED error:nil];
    } else {
        // 取消交易
        [self filedWithErrorCode:IAP_FILEDCOED_USERCANCEL error:nil];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    self.goodsRequestFinished = YES; //失败，请求完成
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    self.goodsRequestFinished = YES; //恢复购买，请求完成
}

#pragma mark 将购买凭证存储到本地，验证凭证失败时，App再次启动后会重新验证购买凭证
- (void)saveReceipt
{
    self.date = [NSDate chindDateFormate:[NSDate date]];
    NSString *fileName = [WXYZ_UtilsHelper getUDID];
    self.userId = @"UserID";
    NSString *savedPath = [NSString stringWithFormat:@"%@/%@.plist", [SandBoxHelper iapReceiptPath], fileName];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         self.receipt,   receiptKey,
                         self.date,      dateKey,
                         self.userId,    userIdKey,
                         nil];
    [dic writeToFile:savedPath atomically:YES];
}

- (void)checkIAPFiles
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
   
    // 搜索该目录下的所有文件和目录
    NSArray *cacheFileNameArray = [fileManager contentsOfDirectoryAtPath:[SandBoxHelper iapReceiptPath] error:&error];
    if (error == nil) {
        for (NSString *name in cacheFileNameArray) {
            if ([name hasSuffix:@".plist"]){
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", [SandBoxHelper iapReceiptPath], name];
                [self sendAppStoreRequestBuyPlist:filePath];
            }
        }
    } else {
        // 获取本地存储的购买凭证失败
        [self.delegate filedWithErrorCode:IAP_FILEDCOED_APPLECODE andError:error.description];
    }
}

// 验证支付凭证
- (void)sendAppStoreRequestBuyPlist:(NSString *)plistPath
{
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    //这里的参数请根据自己公司后台服务器接口定制，但是必须发送的是持久化保存购买凭证
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [dic objectForKey:receiptKey],          receiptKey,
                                   [dic objectForKey:dateKey],             dateKey,
                                   [dic objectForKey:userIdKey],           userIdKey,
                                   nil];

    // 发送购买凭证至服务器
    if ([params objectForKey:@"receipt_key"]) {
        [self applePayBackRequest:[params objectForKey:@"receipt_key"]];
    } else {
        [self.delegate filedWithErrorCode:IAP_FILEDCOED_APPLECODE andError:@"支付凭证验证失败!"];
    }
    
}

// 验证成功，移除本地记录的购买凭证
- (void)removeReceipt
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[SandBoxHelper iapReceiptPath]]) {
        [fileManager removeItemAtPath:[SandBoxHelper iapReceiptPath] error:nil];
    }
}

#pragma mark - 苹果凭证验证
- (void)applePayBackRequest:(NSString *)receipt
{
    WS(weakSelf)
    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeLoading alertTitle:@"获取相关支付凭证"];
    
    // 统计充值来源数据
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    [parameter setObject:receipt forKey:@"receipt"];
    if (self.production_id > 0) {
        [parameter setObject:[WXYZ_UtilsHelper formatStringWithInteger:self.production_id] forKey:@"book_id"];
        switch (self.productionType) {
            case WXYZ_ProductionTypeBook:
            case WXYZ_ProductionTypeAi:
                [parameter setObject:@"1" forKey:@"content_type"];
                break;
            case WXYZ_ProductionTypeComic:
                [parameter setObject:@"2" forKey:@"content_type"];
                break;
            case WXYZ_ProductionTypeAudio:
                [parameter setObject:@"3" forKey:@"content_type"];
                break;
                
            default:
                break;
        }
    }
    
    [WXYZ_NetworkRequestManger POST:Apple_Pay_Back parameters:[parameter copy] model:nil success:^(BOOL isSuccess, id  _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            [weakSelf requestSuccess];
        } else {
            [weakSelf filedWithErrorCode:IAP_FILEDCOED_BUYFILED error:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf filedWithErrorCode:IAP_FILEDCOED_BUYFILED error:nil];
    }];
}

#pragma mark 错误信息反馈

- (void)requestSuccess
{
    [self removeReceipt];
    
    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"支付成功"];
    
    // 发送全局购买成功通知
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Recharge_Success object:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestSuccess)]) {
        [self.delegate requestSuccess];
    }
}

- (void)filedWithErrorCode:(NSInteger)code error:(NSString *)error
{
    switch (code) {
        case IAP_FILEDCOED_APPLECODE:
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:error];
            break;
            
        case IAP_FILEDCOED_NORIGHT:
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"请您开启内购支付"];
            break;
            
        case IAP_FILEDCOED_EMPTYGOODS:
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"商品获取出错"];
            break;
            
        case IAP_FILEDCOED_CANNOTGETINFORMATION:
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"商品获取出错"];
            break;
            
            
        case IAP_FILEDCOED_USERCANCEL:
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"您已取消交易"];
            break;
            
        case IAP_FILEDCOED_BUYING:
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"交易正在进行"];
            break;
        case IAP_FILEDCOED_NOTLOGGEDIN:
            break;
            
        default:
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"支付失败，请稍后重试"];
            break;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(filedWithErrorCode:andError:)]) {
        [self.delegate filedWithErrorCode:code andError:error];
    }
}

@end

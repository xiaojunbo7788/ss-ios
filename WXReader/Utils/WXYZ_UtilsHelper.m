//
//  WXYZ_UtilsHelper.m
//  WXDating
//
//  Created by Andrew on 2017/8/13.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "WXYZ_UtilsHelper.h"
#import "UUID.h"
#import <sys/utsname.h>
#import "CommonCrypto/CommonDigest.h"

#import "WXYZ_ProductionCollectionManager.h"

@implementation WXYZ_UtilsHelper

#pragma mark - 设备信息
+ (NSString *)getUDID
{
    return [UUID getUUID];
}

+ (NSString *)getSystemVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)getCurrentDeviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
}

+ (long long)getFileSize:(NSString *)filePath
{
    long long ret = 0;
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    ret = [fileSizeNumber longLongValue];
    
    return ret;
}

#pragma mark -  工具类

/// 根据属性名创建对应的set方法。
/// @param name 属性名
+ (SEL)createSetterWithPropertyName:(NSString *)name {
    if (!name || name.length == 0) return nil;
    
    NSString *firstStirng = [name substringToIndex:1];
    NSString *lastString = [name substringFromIndex:1];
    name = [firstStirng.capitalizedString stringByAppendingString:lastString];
    name = [NSString stringWithFormat:@"set%@:", name];
    
    return NSSelectorFromString(name);
}

+ (void)synchronizationRack
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 同步小说
        [self synchronizationRackProductionWithProduction_id:0 productionType:WXYZ_ProductionTypeBook complete:nil];
        
        // 同步漫画
        [self synchronizationRackProductionWithProduction_id:0 productionType:WXYZ_ProductionTypeComic complete:nil];
        
        // 同步有声
        [self synchronizationRackProductionWithProduction_id:0 productionType:WXYZ_ProductionTypeAudio complete:nil];
    });
}

+ (void)synchronizationRackProductionWithProduction_id:(NSInteger)production_id productionType:(WXYZ_ProductionType)productionType complete:(void(^ _Nullable)(BOOL status))complete
{
    if (!WXYZ_UserInfoManager.isLogin) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *url = @"";
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
        switch (productionType) {
            case WXYZ_ProductionTypeAi:
            case WXYZ_ProductionTypeBook:
                url = Book_Add_Collect;
                [parameters setObject:@"book_id" forKey:@"key"];
                break;
            case WXYZ_ProductionTypeComic:
                url = Comic_Collect_Add;
                [parameters setObject:@"comic_id" forKey:@"key"];
                break;
            case WXYZ_ProductionTypeAudio:
                url = Audio_Collection_Add;
                [parameters setObject:@"audio_id" forKey:@"key"];
                break;
                
            default:
                break;
        }
        
        // 添加作品
        if (production_id > 0) {
            [parameters setObject:[WXYZ_UtilsHelper formatStringWithInteger:production_id] forKey:[parameters objectForKey:@"key"]];
            
         // 同步作品
        } else {
            
            NSArray <WXYZ_ProductionModel *> *t_arr = [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:(productionType == WXYZ_ProductionTypeAi?WXYZ_ProductionTypeBook:productionType)] getAllCollection];
            
            NSMutableArray *productionArray = [NSMutableArray array];
            for (WXYZ_ProductionModel *t_productionModel in t_arr) {
                [productionArray addObject:[WXYZ_UtilsHelper formatStringWithInteger:t_productionModel.production_id]];
            }
            
            [parameters setObject:[productionArray componentsJoinedByString:@","] forKey:[parameters objectForKey:@"key"]];
            [parameters setObject:@"1" forKey:@"auto_add"];
        }
        
        [WXYZ_NetworkRequestManger POST:url parameters:parameters model:nil success:^(BOOL isSuccess, id  _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
            !complete ?: complete(isSuccess);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            !complete ?: complete(NO);
        }];
    });
}

+ (BOOL)isInSafetyPeriod
{
#if WX_Enable_Magic
    if ([WXYZ_SystemInfoManager.magicStatus isEqualToString:@"0"]) {
        return NO;
    } else if ([WXYZ_SystemInfoManager.magicStatus isEqualToString:@"1"]) {
        return YES;
    }
    
    NSDateFormatter *date = [[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // 后延天数
    int delayDays = 7;
    
    // 提交审核日期
    NSDate *sd = [date dateFromString:Submission_Date];
    
    // 预计审核成功日期
    NSDate *ead = [[NSDate date] initWithTimeInterval:24 * 3600 * delayDays sinceDate:sd];
    
    // 预计日期 - 当前日期
    NSTimeInterval si = [ead timeIntervalSince1970] * 1;
    NSTimeInterval ei = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
    NSTimeInterval value = si - ei;
    
    // 天
    int day = (int)value / (24 * 3600);
    
    if (day > 0) { // 在审核期
        return YES;
    } else {// 非审核期
        return NO;
    }
#else
    return NO;
#endif
}

static NSArray *siteStateArray;
+ (NSArray *)getSiteState
{
    if (siteStateArray) {
        return siteStateArray;
    }
    
    siteStateArray = @[
#if WX_Enable_Book
        [NSNumber numberWithInt:WXYZ_SiteStateBook],
#endif
        
#if WX_Enable_Comic
        [NSNumber numberWithInt:WXYZ_SiteStateComic],
#endif
        
#if WX_Enable_Audio
        [NSNumber numberWithInt:WXYZ_SiteStateAudio]
#endif
    ];
    
    if (isMagicState) {
        siteStateArray = @[[NSNumber numberWithInt:WXYZ_SiteStateBook], [NSNumber numberWithInt:WXYZ_SiteStateComic]];
        return siteStateArray;
    }
    
    id state = [[NSUserDefaults standardUserDefaults] objectForKey:WX_SITE_STATE];
    if (!state) {// 设置默认站点类型
        siteStateArray = @[@(WXYZ_SiteStateComic), @(WXYZ_SiteStateBook), @(WXYZ_SiteStateAudio)];
        return siteStateArray;
    }
    
    // 兼容老版站点选择
    if ([state isKindOfClass:[NSString class]]) {
        
        if ([state integerValue] != 0) {
            switch ([state integerValue]) {
                case 1:
                    siteStateArray = @[[NSNumber numberWithInt:WXYZ_SiteStateBook]];
                    break;
                case 2:
                    siteStateArray = @[[NSNumber numberWithInt:WXYZ_SiteStateComic]];
                    break;
                case 3:
                    siteStateArray = @[[NSNumber numberWithInt:WXYZ_SiteStateBook], [NSNumber numberWithInt:WXYZ_SiteStateComic]];
                    break;
                case 4:
                    siteStateArray = @[[NSNumber numberWithInt:WXYZ_SiteStateComic], [NSNumber numberWithInt:WXYZ_SiteStateBook]];
                    break;
                    
                default:
                    break;
            }
        }
        
    }
    
    // 新版站点选择
    if ([state isKindOfClass:[NSArray class]]) {
        NSMutableArray *t_siteArray = [NSMutableArray array];
        NSArray *t_arr = (NSArray *)state;
        for (NSString *siteString in t_arr) {
            if ([[WXYZ_UtilsHelper formatStringWithObject:siteString] isEqualToString:@"1"]) {
                [t_siteArray addObject:[NSNumber numberWithInt:WXYZ_SiteStateBook]];
            }
            
            if ([[WXYZ_UtilsHelper formatStringWithObject:siteString] isEqualToString:@"2"]) {
                [t_siteArray addObject:[NSNumber numberWithInt:WXYZ_SiteStateComic]];
            }
            
            if ([[WXYZ_UtilsHelper formatStringWithObject:siteString] isEqualToString:@"3"]) {
                [t_siteArray addObject:[NSNumber numberWithInt:WXYZ_SiteStateAudio]];
            }
        }
        
        if (t_siteArray.count > 0) {
            siteStateArray = t_siteArray;
        }
    }
    
    return siteStateArray;
}

+ (BOOL)getAiReadSwitchState
{
#if WX_Enable_Ai
    if ([[NSUserDefaults standardUserDefaults] objectForKey:WX_Ai_Switch]) {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:WX_Ai_Switch] boolValue];
    }
    return YES;
    
#else
    return NO;
#endif
}

+ (NSUInteger)getArcRandomNumWithMinNum:(NSUInteger)minNum maxNum:(NSUInteger)maxNum
{
    return arc4random() % ((maxNum + 1) - minNum) + minNum;
}

// 与当前的时间间隔
+ (NSInteger)getCurrentMinutesIntervalWithTimeStamp:(NSString *)timeStamp
{
    // 1.确定时间
    NSString *startTime = timeStamp;
    NSString *endTime = [self currentDateString];
    
    if (timeStamp) {
        NSDateFormatter *date = [[NSDateFormatter alloc] init];
        [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *startdate = [date dateFromString:startTime];
        NSDate *enddate = [date dateFromString:endTime];
        
        //时间转时间戳的方法:
        NSTimeInterval aTime = [enddate timeIntervalSinceDate:startdate];
        
        return aTime / 60;
    } else {
        return -1;
    }
}

// 秒数转换成小时
+ (NSString *)getHourTimeTransformationWithTotalTimeLenght:(NSInteger)totalTimeLength
{
    NSInteger seconds = totalTimeLength;
    
    return [NSString stringWithFormat:@"%@:%@:%@",[NSString stringWithFormat:@"%02zd",(NSInteger)(seconds / 3600)], [NSString stringWithFormat:@"%02zd",(NSInteger)((seconds % 3600) / 60)], [NSString stringWithFormat:@"%02zd",(NSInteger)(seconds % 60)]];
}

// 秒数转换成分钟
+ (NSString *)getMinuteTimeTransformationWithTotalTimeLenght:(NSInteger)totalTimeLength
{
    NSInteger seconds = totalTimeLength;
    return [NSString stringWithFormat:@"%@:%@", [NSString stringWithFormat:@"%02zd", (NSInteger)((seconds % 3600) / 60)], [NSString stringWithFormat:@"%02zd", (NSInteger)(seconds % 60)]];
}

+ (NSString *)getTimeStamp
{
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    return timeString;
}

+ (NSString *)formatStringWithObject:(id)object
{
    if ([object isKindOfClass:[NSString class]]) {
        return object;
    } else if (object) {
        return [NSString stringWithFormat:@"%@", object];
    } else {
        return @"";
    }
}

+ (NSString *)formatStringWithInteger:(NSUInteger)interger
{
    return [NSString stringWithFormat:@"%"MZNSI, interger];
}

+ (NSString *)formatStringWithFloat:(float)floatValue
{
    return [NSString stringWithFormat:@"%f", floatValue];
}

+ (NSUInteger)formatIntegerValueWithString:(NSString *)kstring
{
    return [[NSString stringWithFormat:@"%@",kstring] integerValue];
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

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if (err) {
        return nil;
    }
    return dic;
}

+ (NSString *)jsonStringWithDictionary:(NSDictionary *)dictionary
{
    if (!dictionary) {
        return @"";
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
    }else{
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

+ (NSString *)convertFileSize:(int64_t)size
{
    if (size < 1024) { // B
        return [NSString stringWithFormat:@"%lldB", size];
    } else if (size >= 1024 && size < 1024 * 1024) { // KB
        return [NSString stringWithFormat:@"%.2fKB", (double)size / 1024];
    } else if(size >= 1024 * 1024 && size < 1024 * 1024 * 1024) { // MB
        return [NSString stringWithFormat:@"%.2fMB", (double)size / (1024 * 1024)];
    } else { // GB
        return [NSString stringWithFormat:@"%.2fGB", (double)size / (1024 * 1024 * 1024)];
    }
}

+ (NSString *)getRemainingMemorySpace
{
    // 剩余大小
    float freesize = 0.0;
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] error:nil];
    if (dictionary) {
        NSNumber *_free = [dictionary objectForKey:NSFileSystemFreeSize];
        freesize = [_free unsignedLongLongValue] * 1.0;
    }
    return [self convertFileSize:freesize];
}

+ (NSString *)jsonStringWithObject:(id)object
{
    NSString *value = nil;
    if (!object) {
        return value;
    }
    if ([object isKindOfClass:[NSString class]]) {
        value = [WXYZ_UtilsHelper jsonStringWithString:object];
    }else if([object isKindOfClass:[NSDictionary class]]) {
        value = [WXYZ_UtilsHelper jsonStringWithDictionary:object];
    }else if([object isKindOfClass:[NSArray class]]) {
        value = [WXYZ_UtilsHelper jsonStringWithArray:object];
    }
    return value;
}

+ (NSString *)jsonStringWithArray:(NSArray *)array
{
    NSMutableString *reString = [NSMutableString string];
    [reString appendString:@"["];
    NSMutableArray *values = [NSMutableArray array];
    for (id valueObj in array) {
        NSString *value = [WXYZ_UtilsHelper jsonStringWithObject:valueObj];
        if (value) {
            [values addObject:[NSString stringWithFormat:@"%@",value]];
        }
    }
    [reString appendFormat:@"%@",[values componentsJoinedByString:@","]];
    [reString appendString:@"]"];
    return reString;
}

+ (NSString *)jsonStringWithString:(NSString *)string
{
    return [NSString stringWithFormat:@"\"%@\"",[[string stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""]];
}

+ (NSString *)currentDateString
{
    return [self currentDateStringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

+ (NSString *)currentDateStringWithFormat:(NSString *)formatterStr
{
    // 获取系统当前时间
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = formatterStr;
    NSString *currentDateStr = [formatter stringFromDate:currentDate];
    
    return currentDateStr;
}

+ (NSString *)dateStringWithTimestamp:(NSString *)timestamp {
    NSInteger currentTimestamp = [[self getTimeStamp] integerValue];
    
    if ([self isSameDay:[timestamp integerValue] Time2:currentTimestamp]) {
        // 小于60秒
        if (currentTimestamp - [timestamp integerValue] < 60) {
            return @"刚刚";
        }
        
        // 小于60分钟
        if (currentTimestamp - [timestamp integerValue] < 3600) {
            NSInteger temp = (currentTimestamp - [timestamp integerValue]) / 60;
            return [NSString stringWithFormat:@"%zd分钟前", temp];
        }
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"hh:mm"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp integerValue]];
        NSString *string = [dateFormat stringFromDate:date];
        return [NSString stringWithFormat:@"%@ %@", @"今天", string];
        
    } else {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd hh:mm"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp integerValue]];
        NSString *string = [dateFormat stringFromDate:date];
        return string;
    }
}

// 判断2个时间戳是不是同一天
+ (BOOL)isSameDay:(NSInteger)iTime1 Time2:(NSInteger)iTime2 {
    //传入时间毫秒数
    NSDate *pDate1 = [NSDate dateWithTimeIntervalSince1970:iTime1];
    NSDate *pDate2 = [NSDate dateWithTimeIntervalSince1970:iTime2];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:pDate1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:pDate2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

+ (NSDictionary *)dicFromObject:(NSObject *)object {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int count;
    objc_property_t *propertyList = class_copyPropertyList([object class], &count);
 
    for (int i = 0; i < count; i++) {
        objc_property_t property = propertyList[i];
        const char *cName = property_getName(property);
        NSString *name = [NSString stringWithUTF8String:cName];
        NSObject *value = [object valueForKey:name];//valueForKey返回的数字和字符串都是对象
 
        if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
            //string , bool, int ,NSinteger
            [dic setObject:value forKey:name];
 
        } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
            //字典或字典
            [dic setObject:[self arrayOrDicWithObject:(NSArray*)value] forKey:name];
 
        } else if (value == nil) {
            //null
            //[dic setObject:[NSNull null] forKey:name];//这行可以注释掉?????
         } else {
            //model
            [dic setObject:[self dicFromObject:value] forKey:name];
        }
    }
 
    return [dic copy];
}

/// 将可能存在model数组转化为普通数组
+ (id)arrayOrDicWithObject:(id)origin {
    if ([origin isKindOfClass:[NSArray class]]) {
        //数组
        NSMutableArray *array = [NSMutableArray array];
        for (NSObject *object in origin) {
            if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
                //string , bool, int ,NSinteger
                [array addObject:object];
 
            } else if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {
                //数组或字典
                [array addObject:[self arrayOrDicWithObject:(NSArray *)object]];
 
            } else {
                //model
                [array addObject:[self dicFromObject:object]];
            }
        }
 
        return [array copy];
 
    } else if ([origin isKindOfClass:[NSDictionary class]]) {
        //字典
        NSDictionary *originDic = (NSDictionary *)origin;
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (NSString *key in originDic.allKeys) {
            id object = [originDic objectForKey:key];
 
            if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
                //string , bool, int ,NSinteger
                [dic setObject:object forKey:key];
 
            } else if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {
                //数组或字典
                [dic setObject:[self arrayOrDicWithObject:object] forKey:key];
 
            } else {
                //model
                [dic setObject:[self dicFromObject:object] forKey:key];
            }
        }
 
        return [dic copy];
    }
 
    return [NSNull null];
}

@end

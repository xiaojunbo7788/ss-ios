//
//  WXYZ_UtilsHelper.h
//  WXDating
//
//  Created by Andrew on 2017/8/13.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXYZ_BasicViewController.h"

typedef NS_ENUM(NSUInteger, WXYZ_SiteState) {
    WXYZ_SiteStateBook       = 1, // 小说
    WXYZ_SiteStateComic      = 2, // 漫画
    WXYZ_SiteStateAudio      = 3  // 有声
};

NS_ASSUME_NONNULL_BEGIN
@interface WXYZ_UtilsHelper : NSObject

/**
 设备信息
 */
+ (NSString *)getUDID;

+ (NSString *)getSystemVersion;

+ (NSString *)getCurrentDeviceModel;

// 获取文件大小
+ (long long)getFileSize:(NSString *)filePath;

/*
 *  工具方法
 */

// 获取在minNum ~ maxNum 之间的随机数
+ (NSUInteger)getArcRandomNumWithMinNum:(NSUInteger)minNum maxNum:(NSUInteger)maxNum;

+ (SEL _Nullable)createSetterWithPropertyName:(NSString *)name;

+ (void)synchronizationRack;

+ (void)synchronizationRackProductionWithProduction_id:(NSInteger)production_id productionType:(WXYZ_ProductionType)productionType complete:(void(^ _Nullable)(BOOL status))complete;

// 审核日期
+ (BOOL)isInSafetyPeriod;

// 获取站点
+ (NSArray *)getSiteState;

// 是否使用Ai读书功能
+ (BOOL)getAiReadSwitchState;

+ (NSString *)convertFileSize:(long long)size;

+ (NSString *)getRemainingMemorySpace;

// 与当前的时间间隔
+ (NSInteger)getCurrentMinutesIntervalWithTimeStamp:(NSString *)timeStamp;

// 秒数转换成分钟
+ (NSString *)getMinuteTimeTransformationWithTotalTimeLenght:(NSInteger)totalTimeLength;

// 秒数转换成小时
+ (NSString *)getHourTimeTransformationWithTotalTimeLenght:(NSInteger)totalTimeLength;

//获取时间戳
+ (NSString *)getTimeStamp;

+ (NSString *)currentDateString;

+ (NSString *)currentDateStringWithFormat:(NSString *)formatterStr;

/// 将指定时间戳转成“刚刚、昨天类似字样”
+ (NSString *)dateStringWithTimestamp:(NSString *)timestamp;

// 字符串格式化
+ (NSString *)formatStringWithObject:(id)object;

+ (NSString *)formatStringWithInteger:(NSUInteger)interger;

+ (NSString *)formatStringWithFloat:(float)floatValue;

+ (NSUInteger)formatIntegerValueWithString:(NSString *)kstring;

+ (NSString *)stringToMD5:(NSString *)inputStr;


// json格式化
+ (NSString *)jsonStringWithDictionary:(NSDictionary *)dictionary;

+ (NSString *)jsonStringWithObject:(id)object;

+ (NSString *)jsonStringWithArray:(NSArray *)array;

+ (NSString *)jsonStringWithString:(NSString *)string;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

/// 将Model转换为字典
+ (NSDictionary *)dicFromObject:(NSObject *)object;

@end

NS_ASSUME_NONNULL_END

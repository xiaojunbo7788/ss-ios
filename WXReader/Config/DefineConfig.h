//
//  DefineConfig.h
//  WXReader
//
//  Created by Chair on 2019/12/11.
//  Copyright © 2019 Andrew. All rights reserved.
//

#ifndef DefineConfig_h
#define DefineConfig_h

//  将属性转换为字符串(PS:不要在属性的get方法里调用自身)
#define KEY_PATH(objc, property) ((void)objc.property, @(#property))

// 随机整数
#define kRandom_Integer(from, to) ((NSInteger)(from + (arc4random() % (to - from + 1))))

// 随机小数
#define kRandom_Float(from, to) ({\
    float result = 0.0;\
    NSInteger precision = 100;\
    CGFloat subtraction = to - from;\
    subtraction = ABS(subtraction);\
    subtraction *= precision;\
    CGFloat randomNumber = arc4random() % ((int)subtraction + 1);\
    randomNumber /= precision;\
    result = MIN(from, to) + randomNumber;\
})

// 判断对象是否为空
#define kObjectIsEmpty(object) !( \
([object respondsToSelector:@selector(length)] && [(NSData *)object length] > 0) || \
([object respondsToSelector:@selector(count)] && [(NSArray *)object count] > 0) || \
([object respondsToSelector:@selector(floatValue)] && [(id)object floatValue] != 0.0))

#endif /* DefineConfig_h */

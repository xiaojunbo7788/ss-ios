//
//  NSMutableArray+KVO.h
//  iOSHelper
//
//  Created by Chair on 2020/3/5.
//  Copyright © 2020 Chair. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 当数组的元素发生改变时回调
@interface NSMutableArray (KVO)

@property (nonatomic, copy) void(^changeBlock)(NSMutableArray *newVal);

- (void)KVO_addObject:(id)object;
- (void)KVO_insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)KVO_removeLastObject;
- (void)KVO_removeObjectAtIndex:(NSUInteger)index;
- (void)KVO_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

- (void)KVO_addObjectsFromArray:(NSArray<id> *)otherArray;
- (void)KVO_exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (void)KVO_removeAllObjects;
- (void)KVO_removeObject:(id)anObject inRange:(NSRange)range;
- (void)KVO_removeObject:(id)anObject;
- (void)KVO_removeObjectIdenticalTo:(id)anObject inRange:(NSRange)range;
- (void)KVO_removeObjectIdenticalTo:(id)anObject;
- (void)KVO_removeObjectsFromIndices:(NSUInteger *)indices numIndices:(NSUInteger)cnt API_DEPRECATED("Not supported", macos(10.0,10.6), ios(2.0,4.0), watchos(2.0,2.0), tvos(9.0,9.0));
- (void)KVO_removeObjectsInArray:(NSArray<id> *)otherArray;
- (void)KVO_removeObjectsInRange:(NSRange)range;
- (void)KVO_replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<id> *)otherArray range:(NSRange)otherRange;
- (void)KVO_replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<id> *)otherArray;
- (void)KVO_setArray:(NSArray<id> *)otherArray;

- (void)KVO_insertObjects:(NSArray<id> *)objects atIndexes:(NSIndexSet *)indexes;
- (void)KVO_removeObjectsAtIndexes:(NSIndexSet *)indexes;
- (void)KVO_replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray<id> *)objects;

- (void)KVO_setObject:(id)obj atIndexedSubscript:(NSUInteger)idx API_AVAILABLE(macos(10.8), ios(6.0), watchos(2.0), tvos(9.0));

@end

NS_ASSUME_NONNULL_END

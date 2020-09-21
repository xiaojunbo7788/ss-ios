//
//  NSMutableArray+KVO.m
//  iOSHelper
//
//  Created by Chair on 2020/3/5.
//  Copyright © 2020 Chair. All rights reserved.
//

#import "NSMutableArray+KVO.h"

#import <objc/runtime.h>

static const char * identifier = "identifier";

@implementation NSMutableArray (KVO)

- (void)setChangeBlock:(void (^)(NSMutableArray * _Nonnull))changeBlock {
    if (!changeBlock) return ;
    
    objc_setAssociatedObject(self, identifier, changeBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(NSMutableArray * _Nonnull))changeBlock {
    return objc_getAssociatedObject(self, identifier);
}

- (void)KVO_addObject:(id)object {
    if (object == nil || [object isKindOfClass:NSNull.class]) return ;
    [self addObject:object];
    self.changeBlock(self);
}

- (void)KVO_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (anObject == nil || [anObject isKindOfClass:NSNull.class]) return ;
    [self insertObject:anObject atIndex:index];
    self.changeBlock(self);
}

- (void)KVO_removeLastObject {
    [self removeLastObject];
    self.changeBlock(self);
}

- (void)KVO_removeObjectAtIndex:(NSUInteger)index {
    [self removeObjectAtIndex:index];
    self.changeBlock(self);
}

- (void)KVO_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (anObject == nil || [anObject isKindOfClass:NSNull.class]) return ;
    [self replaceObjectAtIndex:index withObject:anObject];
    self.changeBlock(self);
}

- (void)KVO_addObjectsFromArray:(NSArray<id> *)otherArray {
    if (![otherArray isKindOfClass:NSArray.class]) return ;
    [self addObjectsFromArray:otherArray];
    self.changeBlock(self);
}

- (void)KVO_exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
    [self exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
    self.changeBlock(self);
}

- (void)KVO_removeAllObjects {
    [self removeAllObjects];
    self.changeBlock(self);
}

- (void)KVO_removeObject:(id)anObject inRange:(NSRange)range {
    if (anObject == nil || [anObject isKindOfClass:NSNull.class]) return ;
    [self removeObject:anObject inRange:range];
    self.changeBlock(self);
}

- (void)KVO_removeObject:(id)anObject {
    if (anObject == nil || [anObject isKindOfClass:NSNull.class]) return ;
    [self removeObject:anObject];
    self.changeBlock(self);
}

- (void)KVO_removeObjectIdenticalTo:(id)anObject inRange:(NSRange)range {
    if (anObject == nil || [anObject isKindOfClass:NSNull.class]) return ;
    [self removeObjectIdenticalTo:anObject inRange:range];
    self.changeBlock(self);
}

- (void)KVO_removeObjectIdenticalTo:(id)anObject {
    if (anObject == nil || [anObject isKindOfClass:NSNull.class]) return ;
    [self removeObjectIdenticalTo:anObject];
    self.changeBlock(self);
}

- (void)KVO_removeObjectsFromIndices:(NSUInteger *)indices numIndices:(NSUInteger)cnt {
    [self removeObjectsFromIndices:indices numIndices:cnt];
    self.changeBlock(self);
}

- (void)KVO_removeObjectsInArray:(NSArray<id> *)otherArray {
    if (![otherArray isKindOfClass:NSArray.class]) return ;
    [self removeObjectsInArray:otherArray];
    self.changeBlock(self);
}

- (void)KVO_removeObjectsInRange:(NSRange)range {
    [self removeObjectsInRange:range];
    self.changeBlock(self);
}

- (void)KVO_replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<id> *)otherArray range:(NSRange)otherRange {
    if (![otherArray isKindOfClass:NSArray.class]) return ;
    [self replaceObjectsInRange:range withObjectsFromArray:otherArray range:otherRange];
    self.changeBlock(self);
}

- (void)KVO_replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<id> *)otherArray {
    if (![otherArray isKindOfClass:NSArray.class]) return ;
    [self replaceObjectsInRange:range withObjectsFromArray:otherArray];
    self.changeBlock(self);
}

- (void)KVO_setArray:(NSArray<id> *)otherArray {
    if (![otherArray isKindOfClass:NSArray.class]) return ;
    [self setArray:otherArray];
    self.changeBlock(self);
}

- (void)KVO_insertObjects:(NSArray<id> *)objects atIndexes:(NSIndexSet *)indexes {
    if (![objects isKindOfClass:NSArray.class]) return ;
    [self insertObjects:objects atIndexes:indexes];
    self.changeBlock(self);
}

- (void)KVO_removeObjectsAtIndexes:(NSIndexSet *)indexes {
    [self removeObjectsAtIndexes:indexes];
    self.changeBlock(self);
}

- (void)KVO_replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray<id> *)objects {
    if (![objects isKindOfClass:NSArray.class]) return ;
    [self replaceObjectsAtIndexes:indexes withObjects:objects];
    self.changeBlock(self);
}

- (void)KVO_setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    if (obj == nil || [obj isKindOfClass:NSNull.class]) return ;
    [self setObject:obj atIndexedSubscript:idx];
    self.changeBlock(self);
}

@end

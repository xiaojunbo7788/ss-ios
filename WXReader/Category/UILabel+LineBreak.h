//
//  YYLabel+LineBreak.h
//  WXReader
//
//  Created by Andrew on 2020/4/2.
//  Copyright © 2020 Andrew. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (LineBreak)

- (void)setLineBreakByTruncatingLastLineMiddle;

- (NSArray *)getSeparatedLinesArray;

@end

NS_ASSUME_NONNULL_END

//
//  YYLabel+LineBreak.m
//  WXReader
//
//  Created by Andrew on 2020/4/2.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "UILabel+LineBreak.h"

@implementation UILabel (LineBreak)

- (void)setLineBreakByTruncatingLastLineMiddle {

    if ( self.numberOfLines <= 0 ) {
        return;
    }
    
    NSMutableString *limitedText = [NSMutableString string];
    NSArray *separatedLines = [self getSeparatedLinesArray];

    if (separatedLines > 0) {
        
        for (int i = 0; i < separatedLines.count; i ++) {
            if (i == separatedLines.count - 1) {
                UILabel *lastLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width / 2, MAXFLOAT)];
                lastLineLabel.font = self.font;
                lastLineLabel.text = [separatedLines lastObject];

                NSArray *subSeparatedLines = [lastLineLabel getSeparatedLinesArray];
                NSString *lastLineText = [subSeparatedLines firstObject];
                NSInteger lastLineTextCount = lastLineText.length;
                [limitedText appendString:[NSString stringWithFormat:@"%@...",[lastLineText substringToIndex:lastLineTextCount]]];
            } else {
                [limitedText appendString:[separatedLines objectOrNilAtIndex:i]];
            }
        }
    }

    [self setText:limitedText lineSpacing:5];

}

-(void)setText:(NSString*)text lineSpacing:(CGFloat)lineSpacing {
    if (!text || lineSpacing < 0.01) {
        self.text = text;
        return;
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpacing];        //设置行间距
    [paragraphStyle setLineBreakMode:self.lineBreakMode];
    [paragraphStyle setAlignment:self.textAlignment];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    self.attributedText = attributedString;
}

- (NSArray *)getSeparatedLinesArray {
    NSString *text = [self text];
    if (!text || text.length <= 0) {
        return @[@""];
    }
    
    UIFont   *font = [self font];
    CGRect    rect = [self frame];

    CTFontRef myFont = CTFontCreateWithName((__bridge CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)myFont range:NSMakeRange(0, attStr.length)];

    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));

    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);

    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc] init];

    for (id line in lines) {
        CTLineRef lineRef = (__bridge CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);

        NSString *lineString = [text substringWithRange:range];
        [linesArray addObject:lineString];
    }
    return (NSArray *)linesArray;
}

@end

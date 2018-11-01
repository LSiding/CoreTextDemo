//
//  CTDisplayView.m
//  CoreTextDemo
//
//  Created by Young on 2016/12/5.
//  Copyright © 2016年 Young. All rights reserved.
//

#import "CTDisplayView.h"
#import <CoreText/CoreText.h>


@interface CTDisplayView ()

@property (nonatomic, assign) CGRect textRect;
@property (nonatomic, assign) CGFloat numberOfLines;

@end


@implementation CTDisplayView

- (void)drawRect:(CGRect)rect
{
    // 0.创建需要绘制的文本
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试"];
    
    // 设置段落排版样式
    self.numberOfLines = 4;
    CGFloat lineSpace = 2;
    CTLineBreakMode lineBreakMode = kCTLineBreakByCharWrapping;
    const CFIndex kNumberOfSettings = 2;
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        {kCTParagraphStyleSpecifierLineSpacingAdjustment,sizeof(CGFloat),&lineSpace},
        {kCTParagraphStyleSpecifierLineBreakMode,sizeof(CTLineBreakMode),&lineBreakMode}
    };
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    
    // 将设置的行距应用于整段文字
    [attributedString addAttribute:NSParagraphStyleAttributeName value:(__bridge id)(theParagraphRef) range:NSMakeRange(0, attributedString.length)];
    
    // 指定行数内的所有字符显示需要的frame
    self.textRect = [self textRectWithNumberOfLines:_numberOfLines withAttributeString:attributedString];
    // 重新得到需要显示的字符，包含省略号
    attributedString = [self lineCutAttributeStringWithTextRect:_textRect andAttributeString:attributedString];
    
    
    // 1.得到当前绘制画布的上下文，用于后续将内容绘制在画布上。
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // 2.将坐标系上下翻转。对于底层的绘制引擎来说，屏幕的左下角是（0, 0）坐标。而对于上层的 UIKit 来说，左上角是 (0, 0) 坐标。所以为了之后的坐标系描述按UIKit左上角开始绘制，所以做一个坐标系的上下翻转操作。
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, self.bounds.size.height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    
    // 3.创建绘制的区域，CoreText本身支持各种文字排版的区域，这里简单地将 UIView 的整个界面作为排版的区域。
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    // 4.根据AttributedString生成CTFramesetterRef
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attributedString length]), path, NULL);
    
    // 5.以Frame为绘制区域绘制
    CTFrameDraw(frame, contextRef);
    
    // 6.内存释放管理
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}

//指定行数所对应的文字显示区域大小，未指定行数时则是所有文字的显示区域大小
- (CGRect)textRectWithNumberOfLines:(NSInteger)numberOfLines withAttributeString:(NSMutableAttributedString *)attributeString
{
    //步骤3
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    //步骤4
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeString);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, [attributeString length]), path, NULL);
    
    //得到指定行数内的所有字符需要的高度
    CGFloat textHeight = 0;
    //CTLineRef的数组，所有字符显示的行对象
    CFArrayRef lines = CTFrameGetLines(textFrame);
    //数组的个数即行数，所有字符显示需要的行数
    CFIndex count = CFArrayGetCount(lines);
    
    //根据numberOfLines显示的行数判断，如果等于0，就默认suggestSize
    if (numberOfLines > 0) {
        //行数为0返回整个区域大小
        if (count == 0) {
            //步骤6
            CFRelease(framesetterRef);
            CFRelease(textFrame);
            CFRelease(path);
            return self.bounds;
        }
        //判断numberOfLines和默认计算出来的行数的最小值，作为可以显示的行数
        NSInteger lineNum = MIN(numberOfLines, count);
        //得到可以显示的行数的最后一行
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineNum-1);
        //可以显示的行数的最后一行的range
        CFRange lastLineRange = CTLineGetStringRange(line);
        //获得截断的位置，即最后一个字符后面的位置
        NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length;
        //把可以显示的行数里的所有字符全都截取下来
        NSMutableAttributedString *maxAttributedString = [[attributeString attributedSubstringFromRange:NSMakeRange(0, truncationAttributePosition)] mutableCopy];
        
        CFRelease(framesetterRef);
        //步骤4
        framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)maxAttributedString);
        //得到所有截取下来的字符的合适宽高
        CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, maxAttributedString.length), NULL, CGSizeMake(CGRectGetWidth(self.bounds), MAXFLOAT), NULL);
        //headLineTailOffSet是为了显示更协调所加的调整
        CGFloat headLineTailOffSet = 0;
        //得到截取下来的字符的合适高度
        textHeight = MIN(suggestSize.height + headLineTailOffSet, CGRectGetHeight(self.bounds));
    } else {
        //CTFramesetterSuggestFrameSizeWithConstraints是一个获得合适的大小的函数，作用相当于我们平时用的sizeThatFit
        //不限制行数则获取所有字符的合适宽高
        CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, attributeString.length), NULL, CGSizeMake(CGRectGetWidth(self.bounds), MAXFLOAT), NULL);
        //获取所有字符的合适高度
        textHeight = MIN(suggestSize.height, CGRectGetHeight(self.bounds));
    }
    
    //步骤6
    CFRelease(framesetterRef);
    CFRelease(textFrame);
    CFRelease(path);
    
//    CGFloat orginY = (CGRectGetHeight(self.bounds)-textHeight)/2; //居中对齐
//    CGFloat orginY = 0; //底部对齐
    CGFloat orginY = CGRectGetHeight(self.bounds)-textHeight; //顶部对齐
    CGRect textRect = CGRectMake(0, orginY, CGRectGetWidth(self.bounds), textHeight);
    return textRect;
}

//根据指定区域得到有省略号的字符串
- (NSMutableAttributedString *)lineCutAttributeStringWithTextRect:(CGRect)textRect andAttributeString:(NSMutableAttributedString *)attributeString
{
    //步骤4
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeString);
    //获取所有字符的合适宽高
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, attributeString.length), NULL, CGSizeMake(CGRectGetWidth(textRect), MAXFLOAT), NULL);
    
    if (suggestSize.height > CGRectGetHeight(textRect)) {
        //步骤3
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, textRect);
        
        CFRelease(framesetterRef);
        //步骤4
        framesetterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributeString);
        CTFrameRef textFrame = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, [attributeString length]), path, NULL);
        
        //得到指定行数内的所有字符需要的高度
        //CTLineRef的数组，区域内显示字符的行对象
        CFArrayRef lines = CTFrameGetLines(textFrame);
        //数组的个数即行数，区域内字符显示需要的行数
        CFIndex count = CFArrayGetCount(lines);
        //没有行数则返回
        if (count == 0) {
            //步骤6
            CFRelease(path);
            CFRelease(textFrame);
            CFRelease(framesetterRef);
            return nil;
        }
        
        //得到显示区域内的最后一行
        CTLineRef line = CFArrayGetValueAtIndex(lines, count-1);
        //显示区域内的最后一行的range
        CFRange lastLineRange = CTLineGetStringRange(line);
        //显示区域内的最后一行的最后一个字符后面的位置
        NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length;
        //显示区域内的开始到最后一行末尾的字符全都截取下来
        NSMutableAttributedString *cutAttributedString = [[attributeString attributedSubstringFromRange:NSMakeRange(0, truncationAttributePosition)] mutableCopy];
        //显示区域内的最后一行的字符全都截取下来
        NSMutableAttributedString *lastLineAttributeString = [[cutAttributedString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
        
        //省略号
        NSString *ellipsisCharacter = @"\u2026";
        //最后一行加上省略号
        [lastLineAttributeString appendAttributedString:[[NSAttributedString alloc] initWithString:ellipsisCharacter]];
        //对最后一行做处理，删除掉末尾的一些字符以显示省略号
        lastLineAttributeString = [self cutLastLineAttributeString:lastLineAttributeString andWidth:CGRectGetWidth(_textRect)];
        
        //替换最后一行
        cutAttributedString = [[cutAttributedString attributedSubstringFromRange:NSMakeRange(0, lastLineRange.location)] mutableCopy];
        [cutAttributedString appendAttributedString:lastLineAttributeString];
        
        //得到有省略号的字符串
        attributeString = cutAttributedString;
        //添加了省略号以后重新获取textRect
        //        self.textRect = [self textRectWithNumberOfLines:_numberOfLines withAttributeString:[attributeString mutableCopy]];
        
        //步骤6
        CFRelease(path);
        CFRelease(textFrame);
        CFRelease(framesetterRef);
    } else {
        CFRelease(framesetterRef);
    }
    return attributeString;
}

//对最后一行(包含了省略号)做处理，删除掉末尾的一些字符以显示省略号
- (NSMutableAttributedString *)cutLastLineAttributeString:(NSMutableAttributedString *)attributeString andWidth:(CGFloat)width
{
    //得到最后的文字宽度
    CTLineRef truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)attributeString);
    CGFloat lastLineWidth = (CGFloat)CTLineGetTypographicBounds(truncationToken, nil, nil,nil);
    CFRelease(truncationToken);
    
    //字符的宽度超出了范围则删掉末尾字符
    if (lastLineWidth > width) {
        //Emoji表情占两个字符，因此需要判断
        NSString *lastString = [[attributeString attributedSubstringFromRange:NSMakeRange(attributeString.length - 3, 2)] string];
        //是否包含emoji表情
        BOOL isEmoji = [self stringContainsEmoji:lastString];
        //减去省略号前一个符号
        [attributeString deleteCharactersInRange:NSMakeRange(attributeString.length - (isEmoji?3:2), isEmoji?2:1)];
        //递归处理，直到够宽为止
        return [self cutLastLineAttributeString:attributeString andWidth:width];
    }else{
        //宽度足够则直接返回
        return attributeString;
    }
}

//是否包含emoji表情
- (BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}

@end

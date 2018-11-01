//
//  CTSimpleView.m
//  CoreTextDemo
//
//  Created by Young on 2016/12/5.
//  Copyright © 2016年 Young. All rights reserved.
//

#import "CTSimpleView.h"
#import <CoreText/CoreText.h>


@implementation CTSimpleView

- (void)drawRect:(CGRect)rect
{
    // 0.创建需要绘制的文本
    NSAttributedString *attributedString = [self styleAtrributedString];
    
    // 1.得到当前绘制画布的上下文，用于后续将内容绘制在画布上。
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // 2.将坐标系上下翻转。对于底层的绘制引擎来说，屏幕的左下角是（0, 0）坐标。而对于上层的 UIKit 来说，左上角是 (0, 0) 坐标。所以为了之后的坐标系描述按UIKit左上角开始绘制，所以做一个坐标系的上下翻转操作。
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, self.bounds.size.height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    
    // 3.创建绘制的区域，CoreText本身支持各种文字排版的区域，这里简单地将 UIView 的整个界面作为排版的区域。
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    // 4.并根据AttributedString生成CTFramesetterRef
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attributedString length]), path, NULL);
    
    // 5.以Frame为绘制区域绘制
    CTFrameDraw(frame, contextRef);
    
    // 6.内存释放管理
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}

- (NSAttributedString *)simpleAtrributedString
{
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:@"CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试"];
    return attributedString;
}

- (NSAttributedString *)styleAtrributedString
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    
    //设置前景色与字体大小
    NSDictionary *attr = @{NSFontAttributeName: [UIFont systemFontOfSize:14],
                           NSForegroundColorAttributeName:[UIColor redColor]
                           };
    NSAttributedString *tmpStr = [[NSAttributedString alloc] initWithString:@"CoreText测试"
                                                                 attributes:attr];
    [string appendAttributedString:tmpStr];
    
    //斜体
    CGAffineTransform matrix = CGAffineTransformMake(1, 0, tanf(15 * (CGFloat)M_PI / 180), 1, 0, 0);
    UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName:[UIFont systemFontOfSize:14]. fontName matrix:matrix];
    UIFont *italicFont= [UIFont fontWithDescriptor:desc size:14];
    
    attr = @{NSFontAttributeName: italicFont,
             NSForegroundColorAttributeName:[UIColor redColor]
             };
    tmpStr = [[NSAttributedString alloc] initWithString:@"斜体" attributes:attr];
    [string appendAttributedString:tmpStr];
    
    //加粗
    attr = @{
             NSFontAttributeName: [UIFont boldSystemFontOfSize:14],
             NSForegroundColorAttributeName:[UIColor redColor]
             };
    tmpStr = [[NSAttributedString alloc] initWithString:@"加粗" attributes:attr];
    [string appendAttributedString:tmpStr];
    
    NSString *rangeStr = @"这是一条带背景色的下划线";
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString:rangeStr];
    //设置字体与背景色
    [attributeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, [attributeString length])];
    [attributeString addAttribute:NSBackgroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, [attributeString length])];
    //加上下划线
    [attributeString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange(9,3)];
    [string appendAttributedString:attributeString];
    
    return [string copy];
}

@end

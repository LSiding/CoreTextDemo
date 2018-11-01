//
//  ViewController.m
//  CoreTextDemo
//
//  Created by Young on 2016/12/5.
//  Copyright © 2016年 Young. All rights reserved.
//

#import "ViewController.h"
#import "YYText.h"
#import <objc/runtime.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet YYLabel *yyLabel;
@property (weak, nonatomic) IBOutlet YYTextView *yyTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self yyLabelSample1];
//    [self yyLabelSample2];
    
    [self yyTextViewSample1];
}

- (void)yyLabelSample1
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试CoreText测试"];
    attributedString.yy_lineBreakMode = NSLineBreakByCharWrapping;
    attributedString.yy_lineSpacing = 2;
    
    YYTextContainer *container = [YYTextContainer containerWithSize:_yyLabel.frame.size];
    container.maximumNumberOfRows = 4;
    container.truncationType = YYTextTruncationTypeEnd;
    
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:[attributedString copy]];
    _yyLabel.textLayout = layout;
}

- (void)yyLabelSample2
{
    _yyLabel.backgroundColor = [UIColor whiteColor];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"CoreText测试CoreText测试"];
    NSRange range = NSMakeRange(10, 10);
    
//    [attributedString yy_setTextHighlightRange:range color:[UIColor grayColor] backgroundColor:[UIColor lightGrayColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
//        NSLog(@"点击高亮文本");
//    }];
    
    YYTextBorder *border = [YYTextBorder borderWithFillColor:[UIColor lightGrayColor] cornerRadius:3];
    
    YYTextHighlight *highlight = [YYTextHighlight new];
    [highlight setBackgroundBorder:border];
    highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
        NSLog(@"点击高亮文本");
    };
    
    [attributedString yy_setColor:[UIColor grayColor] range:range];
    [attributedString yy_setTextHighlight:highlight range:range];
    
    _yyLabel.attributedText = [attributedString copy];
}

- (void)yyTextViewSample1
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"CoreText测试CoreText测试"];
    attributedString.yy_lineBreakMode = NSLineBreakByCharWrapping;
    
    UIImage *testImage = [UIImage imageNamed:@"testImage"];
    NSMutableAttributedString *attachment1 = [NSMutableAttributedString yy_attachmentStringWithContent:testImage contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(80, 80) alignToFont:[UIFont systemFontOfSize:12] alignment:YYTextVerticalAlignmentCenter];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    imageView.image = testImage;
    NSMutableAttributedString *attachment2 = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeTopLeft width:80 ascent:80 descent:0];
    
    [attributedString appendAttributedString:attachment1];
    [attributedString appendAttributedString:attachment2];

    _yyTextView.textAlignment = NSTextAlignmentLeft;
    _yyTextView.attributedText = [attributedString copy];
}

/* YYTextView文本遍历示例代码
- (void)memoTraverse
{
    [_yyTextView.attributedText enumerateAttribute:YYTextAttachmentAttributeName inRange:NSMakeRange(0, [_yyTextView.attributedText length]) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value isMemberOfClass:[YYTextAttachment class]]) {
            YYTextAttachment *attachment = (YYTextAttachment *)value;
            if ([attachment.content isMemberOfClass:[UIImage class]]) {
                //图片附件
                UIImage *image = (UIImage *)attachment.content;
                NSData *data = objc_getAssociatedObject(image, @"keyValue");
            } else {
                //其他类型的附件
            }
        } else {
            //这部分是文字内容
        }
    }];
}
 */

@end

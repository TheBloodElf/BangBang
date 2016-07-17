//
//  NSString+StringSize.m
//  fadein
//
//  Created by WangYaochang on 16/3/17.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import "NSString+StringSize.h"

@implementation NSString (StringSize)

/**
 * 返回字符串的 自定义 大小
 */
- (CGSize)textSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{
    CGSize textSize;
    if (CGSizeEqualToSize(size, CGSizeZero))
    {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        
        textSize = [self sizeWithAttributes:attributes];
    }
    else
    {
        NSStringDrawingOptions option = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        CGRect rect = [self boundingRectWithSize:size
                                         options:option
                                      attributes:attributes
                                         context:nil];
        
        textSize = rect.size;
    }
    return textSize;
}
@end

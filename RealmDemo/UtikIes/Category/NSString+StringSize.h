//
//  NSString+StringSize.h
//  fadein
//
//  Created by WangYaochang on 16/3/17.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (StringSize)

/**
 * 返回字符串的 自定义 大小
 */
- (CGSize)textSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
@end

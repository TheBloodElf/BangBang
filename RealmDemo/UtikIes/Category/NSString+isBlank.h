//
//  NSString+isBlank.h
//  BangBang
//
//  Created by lottak_mac2 on 16/5/20.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <Foundation/Foundation.h>
//字符串是否为空
@interface NSString (isBlank)

+ (BOOL)isBlank:(NSString*)str;
+ (BOOL)isTelephones:(NSString *)string;
+ (BOOL)isPhoneNumber:(NSString *)string;
/**
 * 返回字符串的 自定义 大小
 */
- (CGSize)textSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

@end

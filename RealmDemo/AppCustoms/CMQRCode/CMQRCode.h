//
//  CMQRCode.h
//  fadein
//
//  Created by Maverick on 15/12/10.
//  Copyright © 2015年 Maverick. All rights reserved.
//
//生产二维码
@interface CMQRCode : NSObject

+ (UIImage *)QRCodeImage:(NSString *)QRCodeStr;
+ (UIImage *)colorQRCodeImage:(UIImage*)image red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

+ (NSString *)QRCodeString:(UIImage *)QRCodeImg;

@end

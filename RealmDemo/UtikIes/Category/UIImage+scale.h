//
//  UIImage+scale.h
//  BangBang
//
//  Created by lottak_mac2 on 16/5/20.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>
//最大图片大小
#define MaXPicSize (200 * 1024)
@interface UIImage (scale)

+ (id)colorImg:(UIColor*)color;
+ (id)colorImg:(UIColor*)color size:(CGSize)size;
//尺寸压缩，质量不变
- (UIImage *)scaleToSize:(CGSize)size;
//质量压缩，尺寸不变，可能压缩不到你要的大小，因为没办法到那么小 这时候你就需要调用尺寸压缩了
- (NSData *)dataInNoSacleLimitBytes:(NSInteger)bytes;
//裁剪图片 取中上部分
- (UIImage *)cutToSize:(CGSize)size;

@end

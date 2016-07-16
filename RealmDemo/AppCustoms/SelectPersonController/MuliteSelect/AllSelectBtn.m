//
//  AllSelectBtn.m
//  BangBang
//
//  Created by lottak_mac2 on 16/7/4.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "AllSelectBtn.h"

@implementation AllSelectBtn

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(15, 7, 100, contentRect.size.height - 14);
}
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake(contentRect.size.width - 22 - 15, 4, 22, 22);
}

@end

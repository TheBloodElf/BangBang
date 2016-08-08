//
//  Attachment.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/8.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
//上传附件的模型（现在只能上传图片，后期来设计这个模型）
@interface Attachment : NSObject

@property (nonatomic, strong) NSData *fileData;//文件数据
@property (nonatomic, strong) NSString *fileType;//文件类型
@property (nonatomic, strong) NSURL *fileLocUrl;//文件本地路径
@property (nonatomic, strong) NSString *fileName;//文件名称

@end

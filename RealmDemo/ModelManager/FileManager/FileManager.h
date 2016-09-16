//
//  FileManager.h
//  RealmDemo
//
//  Created by Mac on 16/8/5.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpService.h"
//文件管理器 文件名用时间戳 防止重名 文件按照不同用户放在不同的文件夹下面
@interface FileManager : NSObject

+ (instancetype)shareManager;
//下载文件
- (NSURLSessionDownloadTask*)downFile:(NSString*)fileUrl handler:(completionHandler)handler;
//删除后缀名为xxx的文件 用于下载文件
- (void)deleteExtionName:(NSString*)extionName;
//文件是否存在
- (BOOL)fileIsExit:(NSString*)fileName;
//文件名对应的本地路径
- (NSString*)fileStr:(NSString*)fileName;
//本地文件数组
- (NSArray*)fileUrlArr;
//文件属于哪种类型 0文档 1视频 2相册 3音乐 4其他
- (int)fileType:(NSString*)fileName;
//把文件写入本地
- (void)writeData:(NSData*)date name:(NSString*)name;
//删除本地所有文件
- (void)remoeAllFile;

@end

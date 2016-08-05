//
//  FileManager.h
//  RealmDemo
//
//  Created by Mac on 16/8/5.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpService.h"

@interface FileManager : NSObject

+ (instancetype)shareManager;
//下载文件
- (NSURLSessionDownloadTask*)downFile:(NSString*)fileUrl handler:(completionHandler)handler;

//文件是否存在
- (BOOL)fileIsExit:(NSString*)fileName;
//文件名对应的本地路径
- (NSURL*)fileUrl:(NSString*)fileName;

@end

//
//  FileManager.m
//  RealmDemo
//
//  Created by Mac on 16/8/5.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "FileManager.h"
#import "UserManager.h"

@interface FileManager () {
    NSString *_defaultFilePath;//默认的本地存放文件的文件夹
}

@end

@implementation FileManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSArray *pathArr = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
        NSString *pathUrl = pathArr[0];
        pathUrl = [pathUrl stringByAppendingPathComponent:[UserManager manager].user.user_guid];
        _defaultFilePath = [pathUrl stringByAppendingPathComponent:@"LocFilePath"];
    }
    return self;
}

+(instancetype)shareManager{
    static dispatch_once_t onceToken;
    static FileManager *instance;
    dispatch_once(&onceToken,^{
        instance = [[FileManager alloc]init];
    });
    return instance;
}

- (NSURLSessionDownloadTask*)downFile:(NSString*)fileUrl handler:(completionHandler)handler {
    return [[HttpService service] downRequesURLPath:fileUrl locFilePath:_defaultFilePath completionHandler:handler];
}

//文件是否存在
- (BOOL)fileIsExit:(NSString*)fileName {
    //获取文件夹下的所有文件
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:_defaultFilePath];
    for (NSString *fileNameTemp in files) {
        if([fileName.lastPathComponent isEqualToString:fileNameTemp.lastPathComponent]) {
            return YES;
        }
    }
    return NO;
}
//文件名对应的本地路径
- (NSURL*)fileUrl:(NSString*)fileName {
    return [NSURL fileURLWithPath:[_defaultFilePath stringByAppendingPathComponent:fileName]];
}
@end

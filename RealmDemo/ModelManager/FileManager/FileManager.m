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
        //创建文件夹
        BOOL bo = [[NSFileManager defaultManager] createDirectoryAtPath:_defaultFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        NSAssert(bo,@"创建目录失败");
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
//本地文件数组
- (NSArray*)fileUrlArr {
   return [[NSFileManager defaultManager] subpathsAtPath:_defaultFilePath];
}
//文件名对应的本地路径
- (NSURL*)fileUrl:(NSString*)fileName {
    return [NSURL fileURLWithPath:[_defaultFilePath stringByAppendingPathComponent:fileName.lastPathComponent]];
}
//文件名对应的本地路径
- (NSString*)fileStr:(NSString*)fileName {
    return [_defaultFilePath stringByAppendingPathComponent:fileName.lastPathComponent];
}

//文件属于哪种类型 0文档 1视频 2相册 3音乐 4其他
- (int)fileType:(NSString*)fileName {
    NSString *fileExe = fileName.pathExtension;
    if([@"doc.docx.xls.xlsx.pdf" rangeOfString:fileExe options:NSCaseInsensitiveSearch].location != NSNotFound)
        return 0;
 if([@"avi,mpg,mpeg,rm,rmvb,dat,wmv,mov,asf,m1v,m2v,mpe,qt,vob,ra,rmj,rms,ram,rmm,ogm,mkv,avi_NEO_,ifo,mp4,3gp,rpm,smi,smil,tp,ts,ifo,mpv2,mp2v,tpr,pss,pva,vg2,drc,ivf,vp6,vp7,divx" rangeOfString:fileExe options:NSCaseInsensitiveSearch].location != NSNotFound)
        return 1;
    if([@"BMP、JPG、JPEG、PNG、GIF" rangeOfString:fileExe options:NSCaseInsensitiveSearch].location != NSNotFound)
        return 2;
    if([@"mp3/wav/mid/" rangeOfString:fileExe options:NSCaseInsensitiveSearch].location != NSNotFound)
        return 3;
    return 4;
}

@end

//
//  AttachmentModel.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/3.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
//附件模型
@interface AttachmentModel : NSObject

@property (nonatomic, assign) int id;//附件编号（主键
@property (nonatomic, strong) NSString *user_guid;//用户唯一标识
@property (nonatomic, strong) NSString *user_real_name;//用户真实姓名
@property (nonatomic, strong) NSString *avatar;//用户头像
@property (nonatomic, strong) NSString *app_guid;//应用编号
@property (nonatomic, strong) NSString *title;//标题
@property (nonatomic, strong) NSString *description;//描述
@property (nonatomic, strong) NSString *module_name;//模块名称
@property (nonatomic, strong) NSString *func_name;//方法名称
@property (nonatomic, strong) NSString *article_id;//存在于一应用主表的主键
@property (nonatomic, strong) NSString *file_name;//原始文件名
@property (nonatomic, strong) NSString *file_domain;//附件存放的域名
@property (nonatomic, strong) NSString *file_path;//存放路径
@property (nonatomic, strong) NSString *file_url;//附件访问的URL
@property (nonatomic, strong) NSString *file_ext;//扩展名
@property (nonatomic, assign) int64_t file_size;//大小（字节）
@property (nonatomic, assign) int status;//附件状态：0-不可用，1-可用
@property (nonatomic, assign) int64_t createdate_utc;//上传日期

@end

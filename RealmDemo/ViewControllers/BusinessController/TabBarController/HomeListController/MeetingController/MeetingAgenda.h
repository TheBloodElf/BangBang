//
//  MeetingAgenda.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/28.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
//会议议程模型，因为要对应列表，所以单独建立
@interface MeetingAgenda : NSObject

@property (nonatomic, assign) int index;
@property (nonatomic, copy) NSString *title;

@end

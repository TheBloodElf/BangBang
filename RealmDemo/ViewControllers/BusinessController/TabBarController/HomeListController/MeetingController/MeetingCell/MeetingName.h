//
//  MeetingName.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/28.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//会议主题

@protocol MeetingNameDelegate <NSObject>

- (void)meetingNameLenghtOver;

@end

@interface MeetingName : UITableViewCell

@property (nonatomic, weak) id<MeetingNameDelegate> delegate;

@end

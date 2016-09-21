//
//  MeetingAgendaCell.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/28.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingAgenda.h"
//会议议程
@protocol MeetingAgendaDelegate <NSObject>

- (void)MeetingAgendaDelete:(MeetingAgenda*)meetingAgenda;
- (void)MeetingAgendaFinishEdit;
- (void)MeetingAgendaLenghtOver;

@end

@interface MeetingAgendaCell : UITableViewCell

@property (nonatomic, weak) id<MeetingAgendaDelegate> delegate;

@end

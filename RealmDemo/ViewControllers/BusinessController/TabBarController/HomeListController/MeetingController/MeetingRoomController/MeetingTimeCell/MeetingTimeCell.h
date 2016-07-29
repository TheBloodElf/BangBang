//
//  MeetingTimeCell.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//会议时间CELL

@protocol MeetingTimeCellDelegate <NSObject>
//会议设备被点击
- (void)MeetingTimeDevice;

@end

@interface MeetingTimeCell : UITableViewCell

@property (nonatomic, weak) id<MeetingTimeCellDelegate> delegate;

@end

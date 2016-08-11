//
//  PushMessageCell.m
//  RealmDemo
//
//  Created by Mac on 16/7/17.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "PushMessageCell.h"
#import "PushMessage.h"

@interface PushMessageCell ()
@property (weak, nonatomic) IBOutlet UILabel *yearMonth;//年月
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;//时分
@property (weak, nonatomic) IBOutlet UILabel *titleName;//标题
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;//内容
@property (weak, nonatomic) IBOutlet UIImageView *pushImage;


@end

@implementation PushMessageCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)dataDidChange {
    PushMessage *pushMessage = self.data;
    self.yearMonth.text = [NSString stringWithFormat:@"%02ld/%02ld",pushMessage.addTime.month,pushMessage.addTime.day];
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",pushMessage.addTime.hour,pushMessage.addTime.minute];
    self.titleName.text = [pushMessage typeString];
    if([NSString isBlank:pushMessage.content])
        self.contentLabel.text = @"会议有新的消息";
    else
        self.contentLabel.text = pushMessage.content;
    if(pushMessage.unread == YES)
        self.pushImage.image = [UIImage imageNamed:[pushMessage unreadImageName]];
    else
        self.pushImage.image = [UIImage imageNamed:[pushMessage readImageName]];
}

@end

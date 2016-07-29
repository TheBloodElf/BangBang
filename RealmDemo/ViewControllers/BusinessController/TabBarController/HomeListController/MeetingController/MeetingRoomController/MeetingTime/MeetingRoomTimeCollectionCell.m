//
//  MeetingRoomTimeCollectionCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MeetingRoomTimeCollectionCell.h"

@interface MeetingRoomTimeCollectionCell ()
@property (weak, nonatomic) IBOutlet UIButton *buttonImage;
@end

@implementation MeetingRoomTimeCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.buttonImage.layer.cornerRadius = 2;
    self.buttonImage.clipsToBounds = YES;
    // Initialization code
}
- (void)dataDidChange {
    MeetingRoomCellModel *model = self.data;
    self.buttonImage.backgroundColor = [UIColor whiteColor];
    model.canClicked = YES;
    //如果是过去的时间，就是灰色
    if([model.end timeIntervalSince1970] < [[NSDate date] timeIntervalSince1970]) {
        self.buttonImage.backgroundColor = [UIColor darkGrayColor];
        model.canClicked = NO;
    }
    //用户选择的时间为绿色
    if((self.userSelectDate.begin.timeIntervalSince1970 <= model.begin.timeIntervalSince1970) && (self.userSelectDate.end.timeIntervalSince1970 >= model.end.timeIntervalSince1970)) {
        self.buttonImage.backgroundColor = [UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1];
    }
    //如果有被占用的就是黄色
}
- (IBAction)timeClicked:(UIButton *)sender {
    MeetingRoomCellModel *model = self.data;
    NSDate *currDate = [NSDate date];
    if(model.canClicked == YES)
        if(model.begin.year == currDate.year)
            if(model.begin.month == currDate.month)
                if(model.begin.day == currDate.day) {
                    if(self.delegate && [self.delegate respondsToSelector:@selector(MeetingRoomTime:)]) {
                        [self.delegate MeetingRoomTime:self.data];
                    }
                }
}

@end

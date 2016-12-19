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
    self.buttonImage.layer.cornerRadius = 1;
    self.buttonImage.clipsToBounds = YES;
    // Initialization code
}
- (void)dataDidChange {
    MeetingRoomCellModel *model = self.data;
    self.buttonImage.backgroundColor = [UIColor colorWithRed:195/255.f green:195/255.f blue:195/255.f alpha:0.2];
    //如果是过去的时间，就是灰色
    if(model.isDidDate == YES){
        self.buttonImage.backgroundColor = [UIColor colorWithRed:195/255.f green:195/255.f blue:195/255.f alpha:1];
    }
    //用户选择的时间为绿色
    if(model.isUserSelectDate == YES) {
        self.buttonImage.backgroundColor = [UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1];
    }
}
- (IBAction)timeClicked:(UIButton *)sender {
    MeetingRoomCellModel *model = self.data;
    if(model.isDidDate == NO)
        if(self.delegate && [self.delegate respondsToSelector:@selector(MeetingRoomTime:)]) {
            [self.delegate MeetingRoomTime:self.data];
        }
}

@end

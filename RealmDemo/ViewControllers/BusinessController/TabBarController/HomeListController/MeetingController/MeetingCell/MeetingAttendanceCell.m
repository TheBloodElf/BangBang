//
//  MeetingAttendanceCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/28.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MeetingAttendanceCell.h"
#import "Employee.h"

@interface MeetingAttendanceCell ()

@property (weak, nonatomic) IBOutlet UIView *memberView;
@property (weak, nonatomic) IBOutlet UILabel *detialLabel;
@end

@implementation MeetingAttendanceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)dataDidChange {
    NSMutableArray<Employee*> *membersArr = self.data;
    if(membersArr.count == 0) {
        self.memberView.hidden = YES;
        self.detialLabel.hidden = NO;
        return;
    }
    self.memberView.hidden = NO;
    for (UIView *view in self.memberView.subviews) {
        [view removeFromSuperview];
    }
    self.detialLabel.hidden = YES;
    //上下行/左右项的间距
    CGFloat space = 5;
    //项的高度
    CGFloat itemHeight = 30;
    //项的坐标
    CGFloat currPointX = 0;
    CGFloat currPointY = 0;
    //最大宽度width - 108
    CGFloat memberWidth = MAIN_SCREEN_WIDTH - 108;
    for (Employee *employee in membersArr) {
        CGFloat currWidth = [employee.real_name textSizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(100, itemHeight)].width + 10;
        if(currWidth + currPointX > memberWidth) {//如果超过了展示视图的宽度
            currPointX = 0;
            currPointY += itemHeight + space;
        }
        UILabel *currLabel = [[UILabel alloc] initWithFrame:CGRectMake(currPointX, currPointY, currWidth, itemHeight)];
        currLabel.textColor = [UIColor whiteColor];
        currLabel.font = [UIFont systemFontOfSize:14];
        currLabel.backgroundColor = [UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1];
        currLabel.layer.cornerRadius = 15;
        currLabel.clipsToBounds = YES;
        currLabel.textAlignment = NSTextAlignmentCenter;
        currLabel.text = employee.real_name;
        [self.memberView addSubview:currLabel];
        
        currPointX += currWidth + space;
    }
}
@end

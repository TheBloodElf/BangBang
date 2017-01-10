//
//  TaskMemberCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskMemberCellCell.h"
#import "TaskModel.h"

@interface TaskMemberCellCell () {
    CGFloat _currScrollWidth;
    CGFloat _maxScrollWidth;
}
@property (weak, nonatomic) IBOutlet UIScrollView *memberImage;
@property (weak, nonatomic) IBOutlet UILabel *memberNumber;

@end

@implementation TaskMemberCellCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)dataDidChange {
    TaskModel *model = self.data;
    //先清除掉子视图
    for (UIView *view in self.memberImage.subviews) {
        [view removeFromSuperview];
    }
    if([NSString isBlank:model.members_avatar]) {
        self.memberNumber.text = [NSString stringWithFormat:@"%d人",0];
        return;
    }
    //人员头像数组
    NSArray *imageArr = [model.members_avatar componentsSeparatedByString:@","];
    //人员姓名数组
    NSArray *nameArr = [model.member_realnames componentsSeparatedByString:@","];
    self.memberNumber.text = [NSString stringWithFormat:@"%lu人",(unsigned long)imageArr.count];
    CGFloat currX = 0;
    for (int index = 0;index < imageArr.count;index ++) {
        //人员头像29宽度
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(currX + 3, 0, 29, 29)];
        [imageView zy_cornerRadiusRoundingRect];
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageArr[index]] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
        [self.memberImage addSubview:imageView];
        //人员名字 35宽度
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(currX, 29 + 3, 35, 16)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont systemFontOfSize:12];
        label.adjustsFontSizeToFitWidth = YES;
        label.text = nameArr[index];
        [self.memberImage addSubview:label];
        currX += 35;
    }
    self.memberImage.contentSize = CGSizeMake(currX, 29);
}
@end

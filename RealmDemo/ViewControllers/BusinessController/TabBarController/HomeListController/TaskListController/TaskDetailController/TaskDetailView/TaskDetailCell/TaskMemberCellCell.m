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
    if([NSString isBlank:model.members_avatar]) {
        self.memberNumber.text = [NSString stringWithFormat:@"%d人",0];
        return;
    }
    NSArray *array = [model.members_avatar componentsSeparatedByString:@","];
    self.memberNumber.text = [NSString stringWithFormat:@"%lu人",(unsigned long)array.count];
    CGFloat currX = 0;
    for (NSString *str in array) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(currX, 0, 29, 29)];
        [imageView zy_cornerRadiusRoundingRect];
        [imageView sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
        [self.memberImage addSubview:imageView];
        
        currX += 31;
    }
    self.memberImage.contentSize = CGSizeMake(currX, 29);
}
@end

//
//  TaskDetailCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskDetailCellCell.h"
#import "TaskModel.h"

@interface TaskDetailCellCell ()
@property (weak, nonatomic) IBOutlet UILabel *teakDetail;

@end

@implementation TaskDetailCellCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)dataDidChange {
    TaskModel *model = self.data;
    self.teakDetail.text = model.descriptionStr;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

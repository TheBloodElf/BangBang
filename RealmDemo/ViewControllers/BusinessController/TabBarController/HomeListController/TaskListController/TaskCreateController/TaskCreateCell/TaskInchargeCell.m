//
//  TaskInchargeCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskInchargeCell.h"
#import "Employee.h"

@interface TaskInchargeCell ()
@property (weak, nonatomic) IBOutlet UIImageView *inchargeImage;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@end

@implementation TaskInchargeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.inchargeImage zy_cornerRadiusRoundingRect];
    // Initialization code
}

- (void)dataDidChange {
    Employee *employee = self.data;
    if(employee.id == 0) {
        self.detailLabel.hidden = NO;
        self.inchargeImage.hidden = YES;
    } else {
        self.detailLabel.hidden = YES;
        self.inchargeImage.hidden = NO;
        [self.inchargeImage sd_setImageWithURL:[NSURL URLWithString:employee.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    }
}

@end

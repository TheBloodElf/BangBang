//
//  RCTransferEmployeeCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/5.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RCTransferEmployeeCell.h"
#import "Employee.h"

@interface RCTransferEmployeeCell ()

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation RCTransferEmployeeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.image zy_cornerRadiusRoundingRect];
}

- (void)dataDidChange {
    Employee *employee = self.data;
    [self.image sd_setImageWithURL:[NSURL URLWithString:employee.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    self.nameLabel.text = employee.real_name;
}

@end

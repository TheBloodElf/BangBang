//
//  RCTransferCompanyCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/5.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RCTransferCompanyCell.h"
#import "Company.h"

@interface RCTransferCompanyCell ()

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation RCTransferCompanyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.image.layer.cornerRadius = 25;
    self.image.clipsToBounds = YES;
    // Initialization code
}
- (void)dataDidChange {
    Company *company = self.data;
    [self.image sd_setImageWithURL:[NSURL URLWithString:company.logo] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    self.nameLabel.text = company.company_name;
}

@end

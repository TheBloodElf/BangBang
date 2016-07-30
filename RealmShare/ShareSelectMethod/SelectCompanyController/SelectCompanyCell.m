//
//  SelectCompanyCell.m
//  BangBang
//
//  Created by haigui on 16/5/23.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "SelectCompanyCell.h"
#import "UtikIesTool.h"
@interface SelectCompanyCell  ()
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@end

@implementation SelectCompanyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setModel:(CompanyModel*)model
{
    [self.image sd_setImageWithURL:[NSURL URLWithString:model.logo] placeholderImage:[UIImage imageNamed:@""]];
    self.name.text = model.company_name;
    self.selectBtn.selected = model.isSelected;
}
@end

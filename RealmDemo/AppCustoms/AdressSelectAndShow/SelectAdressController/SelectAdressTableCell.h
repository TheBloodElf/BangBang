//
//  SelectAdressTableCell.h
//  BangBang
//
//  Created by lottak_mac2 on 16/6/23.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectAdressTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *adressTitle;
@property (weak, nonatomic) IBOutlet UILabel *adressDetail;
@property (weak, nonatomic) IBOutlet UIButton *isSelectedBtn;


@end

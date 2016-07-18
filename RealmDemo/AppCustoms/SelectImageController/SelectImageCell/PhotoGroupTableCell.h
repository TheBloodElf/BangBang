//
//  PhotoGroupTableCell.h
//  fadein
//
//  Created by Apple on 16/1/19.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoGroupTableCell : UITableViewCell

//第一张图片
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

//组名
@property (weak, nonatomic) IBOutlet UILabel *title;
//数量
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;


@end

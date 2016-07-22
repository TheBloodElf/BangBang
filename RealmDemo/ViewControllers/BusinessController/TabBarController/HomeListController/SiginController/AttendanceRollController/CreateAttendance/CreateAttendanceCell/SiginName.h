//
//  SiginName.h
//  BangBang
//
//  Created by lottak_mac2 on 16/6/24.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SiginNameDelegate <NSObject>

- (void)siginNameTextField:(UITextField*)textField;

@end

@interface SiginName : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *inputFixed;
@property (weak, nonatomic) id<SiginNameDelegate> delegate;

@end

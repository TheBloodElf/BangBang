//
//  ComCalendarAdress.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ComCalendarAdressDelegate <NSObject>

- (void)comCalendarAdressOverLength;

@end

@interface ComCalendarAdress : UITableViewCell

@property (nonatomic, weak) id<ComCalendarAdressDelegate> delegate;

@end

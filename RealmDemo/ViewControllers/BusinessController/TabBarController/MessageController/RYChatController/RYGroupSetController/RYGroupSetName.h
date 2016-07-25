//
//  RYGroupSetName.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/25.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//讨论组修改名称
@protocol RYGroupSetNameDelegate <NSObject>

- (void)RYGroupSetName:(NSString*)name;

@end

@interface RYGroupSetName : UIViewController

@property (nonatomic, weak) id<RYGroupSetNameDelegate> delegate;

@end

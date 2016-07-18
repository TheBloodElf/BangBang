//
//  SelectAdressController.h
//  fadein
//
//  Created by Apple on 16/1/14.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import <UIKit/UIKit.h>
//地图上选择位置的控制器

@protocol SelectAdressDelegate <NSObject>

- (void)selectAdress:(AMapPOI*)adress;

@end

@interface SelectAdressController : UIViewController

@property (nonatomic, weak) id<SelectAdressDelegate> delegate;

@end

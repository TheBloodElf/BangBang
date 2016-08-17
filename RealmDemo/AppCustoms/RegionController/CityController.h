//
//  CityController.h
//  fadein
//
//  Created by Apple on 15/12/14.
//  Copyright © 2015年 Maverick. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AreaController;
@interface CityController : UIViewController
/**
 *  装满城市的字典
 */
@property (nonatomic,retain) NSDictionary *cityDic;

//省名字
@property (nonatomic, copy) NSString *regionName;

@property (nonatomic, retain) AreaController *areaView;

@end

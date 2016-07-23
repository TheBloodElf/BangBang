//
//  MANaviAnnotationView.h
//  OfficialDemo3D
//
//  Created by 翁乐 on 15/4/10.
//  Copyright (c) 2015年 songjian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>
#import <CoreLocation/CLLocation.h>

@interface NaviButton : UIButton

@property (nonatomic, strong) UIImageView *carImageView;
@property (nonatomic, strong) UILabel *naviLabel;

@end

@interface MANaviAnnotationView : MAPinAnnotationView

- (id)initWithAnnotation:(id <MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

@end

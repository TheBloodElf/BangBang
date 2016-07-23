//
//  MANaviPolyline.m
//  officialDemo2D
//
//  Created by xiaoming han on 15/5/25.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "MANaviPolyline.h"

@implementation MANaviPolyline

- (id)initWithPolyline:(MAPolyline *)polyline
{
    self = [super init];
    if (self)
    {
        self.polyline = polyline;
        self.type = MANaviAnnotationTypeDrive;
    }
    return self;
}

- (CLLocationCoordinate2D) coordinate
{
    return [_polyline coordinate];
}

- (MAMapRect) boundingMapRect
{
    return [_polyline boundingMapRect];
}

@end

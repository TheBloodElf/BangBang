//
//  ReGeocodeAnnotation.m
//  SearchV3Demo
//
//  Created by songjian on 13-8-26.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "ReGeocodeAnnotation.h"

@interface ReGeocodeAnnotation ()

@property (nonatomic, readwrite, strong) AMapReGeocode *reGeocode;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

@end

@implementation ReGeocodeAnnotation
@synthesize reGeocode  = _reGeocode;
@synthesize coordinate = _coordinate;

- (void)setAMapReGeocode:(AMapReGeocode *)reGerocode
{
    self.reGeocode = reGerocode;
    
    [self updateContent];
}

- (void)updateContent
{
    /* 包含 省, 市, 区以及乡镇.  */
    self.title = [NSString stringWithFormat:@"%@%@%@%@",
                  self.reGeocode.addressComponent.province?: @"",
                  self.reGeocode.addressComponent.city ?: @"",
                  self.reGeocode.addressComponent.district?: @"",
                  self.reGeocode.addressComponent.township?: @""];

    /* 包含 社区，建筑. */
    self.subtitle = [NSString stringWithFormat:@"%@%@",
                     self.reGeocode.addressComponent.neighborhood?: @"",
                     self.reGeocode.addressComponent.building?: @""];
}

#pragma mark - Life Cycle

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate reGeocode:(AMapReGeocode *)reGeocode
{
    if (self = [super init])
    {
        self.coordinate = coordinate;
        self.reGeocode  = reGeocode;
        self.title = [reGeocode formattedAddress];
//        [self updateContent];
    }
    
    return self;
}

@end

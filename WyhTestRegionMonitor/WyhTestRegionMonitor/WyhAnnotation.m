//
//  WyhAnnotation.m
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/6.
//  Copyright © 2017年 wyh. All rights reserved.
//

#import "WyhAnnotation.h"

@implementation WyhAnnotation


- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                            radius:(CLLocationDistance)radius
                        identifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        self.radius = radius;
//        self.identifier = identifier;
    }
    return self;
}

@end

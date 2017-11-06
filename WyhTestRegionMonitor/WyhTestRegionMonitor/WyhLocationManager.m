//
//  WyhLocationManager.m
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/6.
//  Copyright © 2017年 wyh. All rights reserved.
//

#import "WyhLocationManager.h"

@interface WyhLocationManager()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;


@end

@implementation WyhLocationManager

+ (WyhLocationManager *)shareInstance {
    static WyhLocationManager *_manager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

+ (void)startMonitor {
    [[WyhLocationManager shareInstance].locationManager startUpdatingLocation];
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        [_locationManager requestAlwaysAuthorization];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.distanceFilter = 10;
    }
    return _locationManager;
}


@end

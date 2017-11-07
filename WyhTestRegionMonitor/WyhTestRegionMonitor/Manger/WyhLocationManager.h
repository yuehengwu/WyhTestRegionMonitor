//
//  WyhLocationManager.h
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/6.
//  Copyright © 2017年 wyh. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WyhAnnotation.h"

#define USER_DEFAULT [NSUserDefaults standardUserDefaults]

static const CLLocationDistance kGeoFencingRadiusDefault = 100.f;

@interface WyhLocationManager : NSObject

@property (nonatomic, strong) NSMutableArray *annotationArr;

@property (nonatomic, strong) CLLocation *userLocation;

+ (WyhLocationManager *)shareInstance;

+ (void)startMonitor;

+ (void)stopMonitor;

+ (void)startMonitorRegionWithAnnotation:(WyhAnnotation *)annotation;

+ (void)stopMonitorRegionWithAnnotation:(WyhAnnotation *)annotation;

/**
 打印所有添加过的防区信息
 */
+ (void)logAnnotationsInUD;

+ (NSArray *)getUserInfosFromUD;

+ (void)reverseGeocodeLocationWithCoordinate:(CLLocationCoordinate2D)coordinate completeHandler:(void(^)(CLPlacemark *))completeHandle;


@end

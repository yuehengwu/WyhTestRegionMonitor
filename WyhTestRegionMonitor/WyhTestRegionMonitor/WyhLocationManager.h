//
//  WyhLocationManager.h
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/6.
//  Copyright © 2017年 wyh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WyhAnnotation.h"

@interface WyhLocationManager : NSObject

+ (void)startMonitor;

+ (void)startMonitorRegionWithAnnotation:(WyhAnnotation *)annotation;

+ (void)stopMonitor;

+ (void)getAnnotationByReverseCoordinate:(CLLocationCoordinate2D)coordinate completeHandler:(void(^)(WyhAnnotation *))completeHandle;


@end

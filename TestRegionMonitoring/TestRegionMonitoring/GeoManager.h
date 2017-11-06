//
//  GeoManager.h
//  TestRegionMonitoring
//
//  Created by Mr.Chou on 2017/8/3.
//  Copyright © 2017年 iTalkBB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeoFencing.h"

@interface GeoManager : NSObject

@property (nonatomic, strong) GeoFencing *geoFencing;
@property (nonatomic, strong) CLLocation *userLocation;


+ (GeoManager *)shareInstance;


#pragma mark - Method
- (void)startMonitoringForGeoFencing:(GeoFencing *)fencing;

- (void)stopMonitoring;


/**
 反地理编码coordinate获得默认半径的GeoFencing
 
 @param coordinate 经纬度
 @param completionHandler 完成block
 */
- (void)getGeoFencingByReverseCoordinate:(CLLocationCoordinate2D)coordinate
                       completionHandler:(void(^)(GeoFencing *geofencing))completionHandler;

- (void)getPlacemarkByReverseCoordinate:(CLLocationCoordinate2D)coordinate
                      completionHandler:(void (^)(CLPlacemark *placemark))completionHandler;





@end

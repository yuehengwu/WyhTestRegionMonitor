//
//  GeoFencing.h
//  TestRegionMonitoring
//
//  Created by Mr.Chou on 2017/8/7.
//  Copyright © 2017年 iTalkBB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define UD_GeoFencing   @"GeoFencing"

// 39.968838, 116.437016 国内测试坐标
// 37.332331, -122.0287 国外测试坐标

static const CLLocationDistance kGeoFencingRadiusDefault = 100.f; // 建议100~200(100M以内判断已无法准确)

@interface GeoFencing : NSObject <NSCoding, MKAnnotation>

@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) BOOL isReverseComplete;

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) CLLocationDistance radius;


/**
 生成默认半径的GeoFencing(待反地理编码)

 @param coordinate 经纬度
 @return GeoFencing
 */
+ (GeoFencing *)geoFencingWithCoordinate:(CLLocationCoordinate2D)coordinate;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                            radius:(CLLocationDistance)radius
                        identifier:(NSString *)identifier;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                            radius:(CLLocationDistance)radius
                        identifier:(NSString *)identifier
                              name:(NSString *)name
                           address:(NSString *)address;

#pragma mark - Goods
- (CLCircularRegion *)regionFromFencing;

- (void)reverseWithCompletionHandler:(void (^)(void))completionHandler;


#pragma mark - UserDefault
+ (GeoFencing *)getGeoFencingFromUD;

+ (void)saveGeoFencingIntoUD:(GeoFencing *)fencing;


@end

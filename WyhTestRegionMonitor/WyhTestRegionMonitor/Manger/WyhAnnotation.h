//
//  WyhAnnotation.h
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/6.
//  Copyright © 2017年 wyh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface WyhAnnotation : NSObject <MKAnnotation,NSCoding>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, assign) CGFloat radius;

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, assign) BOOL isDefenseRegion;


+ (instancetype)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate CompleteHandler:(void(^)(WyhAnnotation *anno))completeHandler;

+ (instancetype)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate
                                   Title:(NSString *)title
                                Subtitle:(NSString *)subtitle
                                  Radius:(CGFloat)radius
                              Identifier:(NSString *)identifier;

+ (instancetype)geoReverseAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate
                                            Radius:(CGFloat)radius
                                        Identifier:(NSString *)identifier
                                   completeHandler:(void(^)(WyhAnnotation *anno))completeHandler;


/**
 通过反编码更新当前位置信息

 @param completeHandler 完成回调
 */
- (void)reverseGeocodeLocationWithCompleteHandler:(void(^)(WyhAnnotation *anno))completeHandler;



@end

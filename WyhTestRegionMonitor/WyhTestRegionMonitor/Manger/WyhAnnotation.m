//
//  WyhAnnotation.m
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/6.
//  Copyright © 2017年 wyh. All rights reserved.
//

#import "WyhAnnotation.h"
#import "WyhLocationManager.h"
@implementation WyhAnnotation

+ (instancetype)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate CompleteHandler:(void (^)(WyhAnnotation *))completeHandler{
    WyhAnnotation *annotation = [[WyhAnnotation alloc]initWithCoordinate:coordinate Title:nil Subtitle:nil Radius:0 Identifier:nil];
    [annotation reverseGeocodeLocationWithCompleteHandler:completeHandler];
    return annotation;
}

+ (instancetype)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate
                                   Title:(NSString *)title
                                Subtitle:(NSString *)subtitle
                                  Radius:(CGFloat)radius
                              Identifier:(NSString *)identifier {
    WyhAnnotation *annotation = [[WyhAnnotation alloc]initWithCoordinate:coordinate Title:title Subtitle:subtitle Radius:radius Identifier:identifier];
    return annotation;
}

+ (instancetype)geoReverseAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate
                                            Radius:(CGFloat)radius
                                        Identifier:(NSString *)identifier
                                   completeHandler:(void(^)(WyhAnnotation *anno))completeHandler {
    
    __block WyhAnnotation *annotation = [[self alloc]init];
    annotation.coordinate = coordinate;
    annotation.radius = radius;
    annotation.identifier = identifier;
    [annotation reverseGeocodeLocationWithCompleteHandler:completeHandler];
    return annotation;
}

- (void)reverseGeocodeLocationWithCompleteHandler:(void(^)(WyhAnnotation *anno))completeHandler {
    if (!CLLocationCoordinate2DIsValid(self.coordinate)) {
        NSAssert(NO, @"无效的coordinate");
    }
    //更新地理信息
    [WyhLocationManager reverseGeocodeLocationWithCoordinate:self.coordinate completeHandler:^(CLPlacemark *placemark) {
        NSString *locationPlace = [NSString stringWithFormat:@"%@%@", placemark.subLocality, placemark.thoroughfare];
        self.title = placemark.name;
        self.subtitle = locationPlace;
        if(completeHandler) completeHandler(self);
    }];
}



- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                                   Title:(NSString *)title
                                Subtitle:(NSString *)subtitle
                                  Radius:(CGFloat)radius
                              Identifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        self.title = title;
        self.subtitle = subtitle;
        self.radius = radius;
        self.identifier = identifier;
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super init]) {
        CGFloat latitude = [aDecoder decodeDoubleForKey:@"latitude"];
        CGFloat longtitude = [aDecoder decodeDoubleForKey:@"longitude"];
        self.coordinate = CLLocationCoordinate2DMake(latitude,longtitude);
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.subtitle = [aDecoder decodeObjectForKey:@"subtitle"];
        self.radius = [aDecoder decodeDoubleForKey:@"radius"];
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.isDefenseRegion = [aDecoder decodeBoolForKey:@"isDefenseRegion"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:self.coordinate.latitude forKey:@"latitude"];
    [aCoder encodeDouble:self.coordinate.longitude forKey:@"longitude"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.subtitle forKey:@"subtitle"];
    [aCoder encodeDouble:self.radius forKey:@"radius"];
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeBool:self.isDefenseRegion forKey:@"isDefenseRegion"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"latitude = %g, longtitude=%g, title = %@, subtitle = %@, radius = %g, identifier:%@",self.coordinate.latitude,self.coordinate.longitude,self.title,self.subtitle,self.radius,self.identifier];
}

@end

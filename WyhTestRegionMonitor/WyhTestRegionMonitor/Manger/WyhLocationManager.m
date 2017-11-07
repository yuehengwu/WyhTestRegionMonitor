//
//  WyhLocationManager.m
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/6.
//  Copyright © 2017年 wyh. All rights reserved.
//

#import "WyhLocationManager.h"

#define USER_DEFAULT [NSUserDefaults standardUserDefaults]

static CGFloat const minFilter = 50;
static NSString * const saveAnnotationKey = @"saveAnnotationKey";


@interface WyhLocationManager()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;


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

#pragma mark - private function

+ (void)pushNotificationWithMsg:(NSString *)msg {
    
    UILocalNotification *localNoti = [[UILocalNotification alloc] init];
    localNoti.alertBody = msg;
    localNoti.soundName = UILocalNotificationDefaultSoundName;
    localNoti.applicationIconBadgeNumber += 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
    
}

#pragma mark - UD

- (void)logAnnotationsInUD {
    [WyhLocationManager getAnnotationsFromUD];
    for (WyhAnnotation *anno in _annotationArr) {
        NSLog(@"USERDEFAULT存:%@",anno.description);
    }
}

+ (NSArray *)getAnnotationsFromUD {
    NSArray *annoArr = [USER_DEFAULT objectForKey:saveAnnotationKey];
    NSMutableArray *tempArr = [NSMutableArray new];
    for (NSData *data in annoArr) {
        WyhAnnotation *annotation = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [tempArr addObject:annotation];
    }
    return tempArr;
}

+ (void)saveAnnotation:(WyhAnnotation *)annotation {
    NSArray *annoArr = [USER_DEFAULT objectForKey:saveAnnotationKey];
    if (!annoArr) {
        annoArr = [NSArray new];
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:annotation];
    annoArr = [annoArr arrayByAddingObject:data];
    [USER_DEFAULT setValue:annoArr  forKey:saveAnnotationKey];
}

+ (void)removeAnnotation:(WyhAnnotation *)annotation {
    NSArray *annoArr = [USER_DEFAULT objectForKey:saveAnnotationKey];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:annotation];
    NSMutableArray *tempCopyArr = [NSMutableArray arrayWithArray:annoArr];
    if ([tempCopyArr containsObject:data]) {
        [tempCopyArr removeObject:data];
        [USER_DEFAULT setValue:tempCopyArr  forKey:saveAnnotationKey];
    }
}

- (WyhAnnotation *)findAnnotationFromIdentifier:(NSString *)identifier {
    
    for (WyhAnnotation *anno in self.annotationArr) {
        if ([anno.identifier isEqualToString:identifier]) {
            return anno;
        }
    }
    return nil;
}

#pragma mark - publick function

+ (void)startMonitor {
    [[self shareInstance].locationManager startUpdatingLocation];
}

+ (void)stopMonitor {
    [[self shareInstance].locationManager stopUpdatingLocation];
}

+ (void)startMonitorRegionWithAnnotation:(WyhAnnotation *)annotation {
    CLCircularRegion *region = [[CLCircularRegion alloc]initWithCenter:annotation.coordinate radius:annotation.radius identifier:annotation.identifier];
    [self saveAnnotation:annotation]; //save the region into UD
    [[self shareInstance].locationManager startMonitoringForRegion:region];//开始检测区域
}

+ (void)stopMonitorRegionWithAnnotation:(WyhAnnotation *)annotation {
    NSSet *allRegions = [self shareInstance].locationManager.monitoredRegions;
    for (CLRegion *region in allRegions) {
        if ([region.identifier isEqualToString:annotation.identifier]) {
            [[self shareInstance].locationManager stopMonitoringForRegion:region];
            [self removeAnnotation:annotation]; //remove the region from UD
        }
    }
}

+ (void)reverseGeocodeLocationWithCoordinate:(CLLocationCoordinate2D)coordinate completeHandler:(void (^)(CLPlacemark *))completeHandle {
    CLLocation *location = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    [[self shareInstance].geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error || placemarks.count == 0) {
            if(completeHandle) completeHandle(nil);
            return;
        }
        CLPlacemark *placemark = [placemarks firstObject];
        
        if(completeHandle) completeHandle(placemark);
    }];
}

#pragma mark - delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    self.userLocation = locations.lastObject;
    [WyhLocationManager pushNotificationWithMsg:@"update location"];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    
    WyhAnnotation *annodation = [self findAnnotationFromIdentifier:region.identifier];
    [WyhLocationManager pushNotificationWithMsg:[NSString stringWithFormat:@"已进入%@",annodation.title]];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    WyhAnnotation *annodation = [self findAnnotationFromIdentifier:region.identifier];
    [WyhLocationManager pushNotificationWithMsg:[NSString stringWithFormat:@"已离开%@",annodation.title]];
}

#pragma mark - Overwrite

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        [_locationManager requestAlwaysAuthorization];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = minFilter;
    }
    return _locationManager;
}

- (CLGeocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc]init];
    }
    return _geocoder;
}

- (NSMutableArray *)annotationArr {
    if (!_annotationArr) {
        _annotationArr = [NSMutableArray new];
    }
    [_annotationArr removeAllObjects];
    _annotationArr = [NSMutableArray arrayWithArray:[WyhLocationManager getAnnotationsFromUD]];
    return _annotationArr;;
}


@end
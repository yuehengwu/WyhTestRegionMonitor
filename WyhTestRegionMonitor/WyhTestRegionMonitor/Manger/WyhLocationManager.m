//
//  WyhLocationManager.m
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/6.
//  Copyright © 2017年 wyh. All rights reserved.
//

#import "WyhLocationManager.h"
#import <UserNotifications/UserNotifications.h>

static CGFloat const minFilter = 10;

static NSString * const saveAnnotationKey = @"saveAnnotationKey";
static NSString * const saveUserLocationInfoKey = @"saveUserLocationInfoKey";

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
//        [self.locationManager startUpdatingLocation];
    }
    return self;
}

#pragma mark - private function

+ (void)pushNotificationWithMsg:(NSString *)msg {
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        if (msg) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"防区消息!" message:msg preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [alert show];
        }
    }else {
        if (msg) {
//            UNNotificationRequest
            UILocalNotification *localNoti = [[UILocalNotification alloc] init];
            localNoti.alertBody = msg;
            localNoti.soundName = UILocalNotificationDefaultSoundName;
            localNoti.applicationIconBadgeNumber += 1;
            [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
        }
    }
}

#pragma mark - UD

+ (BOOL)saveUserCurrentLocationInfoWithTitle:(NSString *)title Location:(CLLocation *)location {
    NSArray *userInfos = [USER_DEFAULT objectForKey:saveUserLocationInfoKey];
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:userInfos];
    NSDictionary *dictionary = @{@"title":title,@"longitude":@(location.coordinate.longitude),@"latitude":@(location.coordinate.latitude),@"time":[NSDate currentTime]};
    [tempArr addObject:dictionary];
    [USER_DEFAULT setValue:tempArr forKey:saveUserLocationInfoKey];
    return [USER_DEFAULT synchronize];
}

+ (BOOL)removeUserLocationInfoFromTime:(NSString *)time {
    NSArray *userInfos = [USER_DEFAULT objectForKey:saveUserLocationInfoKey];
    NSMutableArray *tempCopyArr = [NSMutableArray arrayWithArray:userInfos];
    NSInteger idx = 0;
    for (NSDictionary *info in userInfos) {
        if ([info[@"time"] isEqualToString:time]) {
            [tempCopyArr removeObjectAtIndex:idx];
            break;
        }
        idx++;
    }
    [USER_DEFAULT setValue:tempCopyArr forKey:saveUserLocationInfoKey];
    return [USER_DEFAULT synchronize];
}

+ (BOOL)clearAllUserLocationInfos {
    [USER_DEFAULT removeObjectForKey:saveUserLocationInfoKey];
    return [USER_DEFAULT synchronize];
}

+ (NSArray *)getUserInfosFromUD {
    NSArray *userInfos = [USER_DEFAULT objectForKey:saveUserLocationInfoKey];
    return userInfos;
}

+ (void)logAnnotationsInUD {
    [WyhLocationManager getAnnotationsFromUD];
    for (WyhAnnotation *anno in [self shareInstance].annotationArr) {
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

+ (BOOL)saveAnnotation:(WyhAnnotation *)annotation {
    NSArray *annoArr = [USER_DEFAULT objectForKey:saveAnnotationKey];
    if (!annoArr) {
        annoArr = [NSArray new];
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:annotation];
    if ([annoArr containsObject:data]) {
        return NO;
    }
    annoArr = [annoArr arrayByAddingObject:data];
    [USER_DEFAULT setValue:annoArr  forKey:saveAnnotationKey];
    return [USER_DEFAULT synchronize];
}

+ (BOOL)removeAnnotation:(WyhAnnotation *)annotation {
    NSArray *annoArr = [USER_DEFAULT objectForKey:saveAnnotationKey];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:annotation];
    NSMutableArray *tempCopyArr = [NSMutableArray arrayWithArray:annoArr];
    if ([tempCopyArr containsObject:data]) {
        [tempCopyArr removeObject:data];
        [USER_DEFAULT setValue:tempCopyArr  forKey:saveAnnotationKey];
        return [USER_DEFAULT synchronize];
    }else {
        return NO;
    }
}

- (WyhAnnotation *)findAnnotationFromRegion:(CLCircularRegion *)region {
    
    for (WyhAnnotation *anno in self.annotationArr) {
        if ([region.identifier isEqualToString:anno.identifier]) {
            return anno;
        }
//        if ([region containsCoordinate:anno.coordinate]) {
//            return anno; //找到地区 返回
//        }
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
//    NSLog(@"开始监测'%@'防区",annotation);
    CLLocationCoordinate2D WGScoordinate = [TQLocationConverter transformFromGCJToWGS:annotation.coordinate]; //转换坐标系
    CLCircularRegion *region = [[CLCircularRegion alloc]initWithCenter:WGScoordinate radius:annotation.radius identifier:annotation.identifier];
    [self saveAnnotation:annotation]; //save the region into UD
    [[self shareInstance].locationManager startMonitoringForRegion:region];//开始监测区域
    
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
    CLLocation *recentLocation = locations.lastObject;
    if ((recentLocation.coordinate.latitude == self.userLocation.coordinate.latitude && recentLocation.coordinate.longitude == self.userLocation.coordinate.longitude) || !self.userLocation) {
        self.userLocation = recentLocation;
        return;
    }
    self.userLocation = recentLocation;
    [WyhLocationManager reverseGeocodeLocationWithCoordinate:self.userLocation.coordinate completeHandler:^(CLPlacemark *placemark) {
        NSString *locationPlace = [NSString stringWithFormat:@"%@%@", placemark.subLocality,placemark.thoroughfare];
        NSString *tip = [NSString stringWithFormat:@"您经过了:%@",locationPlace];
            [WyhLocationManager saveUserCurrentLocationInfoWithTitle:tip Location:self.userLocation];
    }];
//    [WyhLocationManager pushNotificationWithMsg:@"update location ing...(for test)"];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    
    [WyhLocationManager pushNotificationWithMsg:[NSString stringWithFormat:@"监测到您已经进入:%@防区",region.identifier]];
    
    WyhAnnotation *annodation = [self findAnnotationFromRegion:(CLCircularRegion *)region];
    if (!annodation) {
        return;
    }
    NSString *tip = [NSString stringWithFormat:@"您已进入%@(防区)",annodation.title];
//    [WyhLocationManager pushNotificationWithMsg:tip];
    static int timeIndex = 0;
    if (@available(iOS 10.0, *)) {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            timeIndex++;
            [WyhLocationManager pushNotificationWithMsg:[NSString stringWithFormat:@"测试进入防区唤醒时长，当前时长为:%zd",timeIndex]];
            NSLog(@"测试进入防区唤醒时长，当前时长为:%d",timeIndex);
        }];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    } else {
        // Fallback on earlier versions
    }
    
    [WyhLocationManager saveUserCurrentLocationInfoWithTitle:tip Location:[[CLLocation alloc] initWithLatitude:annodation.coordinate.latitude longitude:annodation.coordinate.longitude]];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [WyhLocationManager pushNotificationWithMsg:[NSString stringWithFormat:@"监测到您已经离开:%@防区",region.identifier]];
    
    WyhAnnotation *annodation = [self findAnnotationFromRegion:(CLCircularRegion *)region];
    if (!annodation) {
        return;
    }
    NSString *tip = [NSString stringWithFormat:@"您已离开%@(防区)",annodation.title];
//    [WyhLocationManager pushNotificationWithMsg:tip];
    [WyhLocationManager saveUserCurrentLocationInfoWithTitle:tip Location:[[CLLocation alloc] initWithLatitude:annodation.coordinate.latitude longitude:annodation.coordinate.longitude]];
    static int timeIndex = 0;
    
    if (@available(iOS 10.0, *)) {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            timeIndex++;
            [WyhLocationManager pushNotificationWithMsg:[NSString stringWithFormat:@"测试离开唤醒时长，当前时长为:%zd",timeIndex]];
            NSLog(@"测试离开唤醒时长，当前时长为:%d",timeIndex);
        }];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    } else {
        // Fallback on earlier versions
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {}

// 监控region失败
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    [WyhLocationManager pushNotificationWithMsg:[NSString stringWithFormat:@"%@监测失败",region.identifier]];
}

#pragma mark - Overwrite

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        [_locationManager requestAlwaysAuthorization];//8.0系统
//        [_locationManager setAllowsBackgroundLocationUpdates:YES];//9.0系统
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

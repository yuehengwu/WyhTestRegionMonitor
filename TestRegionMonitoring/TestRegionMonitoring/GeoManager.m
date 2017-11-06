//
//  GeoManager.m
//  TestRegionMonitoring
//
//  Created by Mr.Chou on 2017/8/3.
//  Copyright © 2017年 iTalkBB. All rights reserved.
//

#import "GeoManager.h"
#import <CoreLocation/CoreLocation.h>
#import "TQLocationConverter.h"

@interface GeoManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;



@end

@implementation GeoManager

+ (GeoManager *)shareInstance {
    static GeoManager *manager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (id)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
//        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
        #warning Test
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.distanceFilter = 10;
        [self.locationManager startUpdatingLocation];
        
        self.geoFencing = [GeoFencing getGeoFencingFromUD];
        for (CLRegion *region in self.locationManager.monitoredRegions) {
            NSLog(@"LocationManager.monitoredRegion:%@", region);
        }
    }
    
    return self;
}


#pragma mark - Overwrite
- (CLGeocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    
    return _geocoder;
}



#pragma mark - Method
/**
 反地理编码coordinate获得默认半径的GeoFencing
 
 @param coordinate 经纬度
 @param completionHandler 完成block
 */
- (void)getGeoFencingByReverseCoordinate:(CLLocationCoordinate2D)coordinate
                       completionHandler:(void(^)(GeoFencing *geofencing))completionHandler {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error || placemarks.count == 0) {
            completionHandler(nil);
            return;
        }
        
        CLPlacemark *placemark = [placemarks firstObject];
        GeoFencing *fencing = [[GeoFencing alloc] initWithCoordinate:location.coordinate
                                                              radius:kGeoFencingRadiusDefault
                                                          identifier:[NSString UUIDString]
                                                                name:placemark.name
                                                             address:[NSString stringWithFormat:@"%@%@", placemark.subLocality, placemark.thoroughfare]];
        completionHandler(fencing);
    }];
}


- (void)getPlacemarkByReverseCoordinate:(CLLocationCoordinate2D)coordinate
                      completionHandler:(void (^)(CLPlacemark *placemark))completionHandler {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
        [GeoManager printDetailForPlacemark:[placemarks firstObject]];
        completionHandler([placemarks firstObject]);
    }];
}



/**
 添加防区、本地序列化、并开始监控

 @param fencing <#fencing description#>
 */
- (void)startMonitoringForGeoFencing:(GeoFencing *)fencing {
    self.geoFencing = fencing;
    self.geoFencing.isActive = YES;
    [GeoFencing saveGeoFencingIntoUD:fencing];
    
    if (![CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        NSLog(@"Error! Geofencing is not supported on this device!");
        return;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        NSLog(@"Warning! Your GeoFencing is saved but will only be activated once you grant us permission to access the device location.");
    }
    
    CLLocationCoordinate2D coordinateWGS = [TQLocationConverter transformFromGCJToWGS:fencing.coordinate];
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coordinateWGS radius:fencing.radius identifier:fencing.identifier];
    [self.locationManager startMonitoringForRegion:region];
}

- (void)stopMonitoring {
    [self.locationManager stopMonitoringForRegion:[self.geoFencing regionFromFencing]];
    
    self.geoFencing = nil;
    [GeoFencing saveGeoFencingIntoUD:nil];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"消息" message:@"已停止防区监控" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert show];
}



#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"[定位授权 kCLAuthorizationStatusNotDetermined]");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"[定位授权 kCLAuthorizationStatusRestricted]");
            break;
        case kCLAuthorizationStatusDenied:
            NSLog(@"[定位授权 kCLAuthorizationStatusDenied]");
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"[定位授权 kCLAuthorizationStatusAuthorizedAlways]");
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"[定位授权 kCLAuthorizationStatusAuthorizedWhenInUse]");
            break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    self.userLocation = location;
    NSDate *eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    //根据取到的location的时间戳，输出经纬度
    if (fabs(howRecent) < 15.0) {
//        NSLog(@"latitude %+.6f, longitude %+.6f\n", location.coordinate.latitude, location.coordinate.longitude);
        NSLog(@"Manager.UserLocation.Update(%f, %f)", location.coordinate.latitude, location.coordinate.longitude);
    }
}

#pragma mark MonitoringForRegion
// 开始监控region
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"消息" message:@"已添加防区监控" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert show];
}

// 监控region失败
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"消息" message:@"防区监控失败" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert show];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"进入防区");
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        [self handleRegionEventWithIsEnter:YES];
    }
    
//    for (int i = 0; i < NSIntegerMax; i++) {
//        NSLog(@"[still active]");
//    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"离开防区");
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        [self handleRegionEventWithIsEnter:NO];
    }
    
//    for (int i = 0; i < NSIntegerMax; i++) {
//        NSLog(@"[still active]");
//    }
}


#pragma mark - Goods
- (void)handleRegionEventWithIsEnter:(BOOL)isEnter {
    NSString *message = [self noteRegionWithIsEnter:isEnter];
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) { // 前台
        if (message) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"防区消息" message:message preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [alert show];
        }
        
    } else {
        UILocalNotification *localNotic = [[UILocalNotification alloc] init];
        localNotic.alertBody = message;
        localNotic.soundName = UILocalNotificationDefaultSoundName;
        localNotic.applicationIconBadgeNumber = 1;
//        localNotic.fireDate = [[NSDate date] dateByAddingTimeInterval:3];
        //    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotic];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotic];
    }
}

- (NSString *)noteRegionWithIsEnter:(BOOL)isEnter {
    GeoFencing *savedGeoFencing = [GeoFencing getGeoFencingFromUD];
    if(savedGeoFencing) {
        if (isEnter) {
            return [NSString stringWithFormat:@"已进入[%@]", savedGeoFencing.name];
        } else {
            return [NSString stringWithFormat:@"已离开[%@]", savedGeoFencing.name];
        }
        
    }
    
    return nil;
}


+ (void)printDetailForPlacemark:(CLPlacemark *)placemark {
    
    NSLog(@"{%@", placemark);
    NSLog(@"-------------------------------------");
    
    NSString *country = [placemark.addressDictionary valueForKey:@"Country"];
    NSString *countryCode = [placemark.addressDictionary valueForKey:@"CountryCode"];
    NSString *state = [placemark.addressDictionary valueForKey:@"State"];
    NSString *city = [placemark.addressDictionary valueForKey:@"City"];
    NSString *subLocality = [placemark.addressDictionary valueForKey:@"SubLocality"]; // 区
    NSString *thoroughfare = [placemark.addressDictionary valueForKey:@"Thoroughfare"]; // 主道路
    NSString *subThoroughfare = [placemark.addressDictionary valueForKey:@"SubThoroughfare"];
    NSString *street = [placemark.addressDictionary valueForKey:@"Street"]; // 街道
    NSString *name = [placemark.addressDictionary valueForKey:@"Name"];
    NSArray *formattedAddressLines = [placemark.addressDictionary valueForKey:@"FormattedAddressLines"];
    NSLog(@"[");
    NSLog(@"Country:%@", country);
    NSLog(@"CountryCode:%@", countryCode);
    NSLog(@"State:%@", state);
    NSLog(@"city:%@", city);
    NSLog(@"SubLocality:%@", subLocality);
    NSLog(@"Thoroughfare:%@", thoroughfare);
    NSLog(@"SubThoroughfare:%@", subThoroughfare);
    NSLog(@"Street:%@", street);
    NSLog(@"Name:%@", name);
    for (NSString *formattedAddressLine in formattedAddressLines) {
        NSLog(@"FormattedAddressLine:%@", formattedAddressLine);
    }
    NSLog(@"]");
    
    NSLog(@"-------------------------------------");
    NSLog(@"[");
    NSLog(@".Country:%@", placemark.country);
    NSLog(@".CountryCode:%@", placemark.ISOcountryCode);
    NSLog(@".postalCode:%@", placemark.postalCode);
    NSLog(@".administrativeArea:%@", placemark.administrativeArea); // 省
    NSLog(@".subAdministrativeArea:%@", placemark.subAdministrativeArea);
    NSLog(@".locality:%@", placemark.locality); // 市
    NSLog(@".subLocality:%@", placemark.subLocality); // 区
    NSLog(@".thoroughfare:%@", placemark.thoroughfare); // 路
    NSLog(@".subThoroughfare:%@", placemark.subThoroughfare); // 号
    NSLog(@".name:%@", placemark.name);
    NSLog(@".interest:%@", [placemark.areasOfInterest componentsJoinedByString:@", "]);
    NSLog(@"]");
    
    NSLog(@"}");
     
}

@end

//
//  GeoFencing.m
//  TestRegionMonitoring
//
//  Created by Mr.Chou on 2017/8/7.
//  Copyright © 2017年 iTalkBB. All rights reserved.
//

#import "GeoFencing.h"
#import "GeoManager.h"

static NSString *kGeoFencingIsActiveKey = @"isActive";
static NSString *kGeoFencingIsReverseComplete = @"isReverseComplete";
static NSString *kGeoFencingLatitudeKey = @"latitude";
static NSString *kGeoFencingLongitudeKey = @"longitude";
static NSString *kGeoFencingRadiusKey = @"radius";
static NSString *kGeoFencingIdentifierKey = @"identifier";
static NSString *kGeoFencingNameKey = @"name";
static NSString *kGeoFencingAddressTypeKey = @"address";

@implementation GeoFencing

+ (GeoFencing *)getGeoFencingFromUD {
    NSData *fencingData = [[NSUserDefaults standardUserDefaults] dataForKey:UD_GeoFencing];
    GeoFencing *fencing = [NSKeyedUnarchiver unarchiveObjectWithData:fencingData];
    return fencing;
}

+ (void)saveGeoFencingIntoUD:(GeoFencing *)fencing {
    NSData *fencingData = [NSKeyedArchiver archivedDataWithRootObject:fencing];
    [[NSUserDefaults standardUserDefaults] setValue:fencingData forKey:UD_GeoFencing];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


/**
 生成默认半径的GeoFencing(待反地理编码)
 
 @param coordinate 经纬度
 @return GeoFencing
 */
+ (GeoFencing *)geoFencingWithCoordinate:(CLLocationCoordinate2D)coordinate {
    GeoFencing *fencing = [[GeoFencing alloc] initWithCoordinate:coordinate
                                                          radius:kGeoFencingRadiusDefault
                                                      identifier:[NSString UUIDString]];
    return fencing;
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                            radius:(CLLocationDistance)radius
                        identifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        self.radius = radius;
        self.identifier = identifier;
    }
    
    return self;
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                            radius:(CLLocationDistance)radius
                        identifier:(NSString *)identifier
                              name:(NSString *)name
                           address:(NSString *)address {
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.name = name;
        self.address = address;
        self.coordinate = coordinate;
        self.radius = radius;
    }
    
    return self;
}


#pragma mark - Overwrite
- (void)setName:(NSString *)name {
    [self willChangeValueForKey:@"title"];
    _name = name;
    [self didChangeValueForKey:@"title"];
}

- (void)setAddress:(NSString *)address {
    [self willChangeValueForKey:@"subtitle"];
    _address = address;
    [self didChangeValueForKey:@"subtitle"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"GeoFencing:{identifier:%@, name:%@, address:%@, coordinate:[%f,%f], radius:%f}", self.identifier, self.name, self.address, self.coordinate.latitude, self.coordinate.longitude, self.radius];
}


#pragma mark - Goods
- (CLCircularRegion *)regionFromFencing {
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:self.coordinate radius:self.radius identifier:self.identifier];
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    
    return region;
}

- (void)reverseWithCompletionHandler:(void (^)(void))completionHandler {
    [[GeoManager shareInstance] getPlacemarkByReverseCoordinate:self.coordinate completionHandler:^(CLPlacemark *placemark) {
        NSString *street = [placemark.addressDictionary valueForKey:@"Street"]; // 街道
        if ([placemark.ISOcountryCode isEqualToString:@"CN"]) {
            self.address = [NSString stringWithFormat:@"%@%@", placemark.subLocality, street];
        } else {
            self.address = [NSString stringWithFormat:@"%@, %@", street, placemark.locality];
        }
        
        self.name = placemark.name;
        self.isReverseComplete = YES;
        completionHandler();
    }];
}


#pragma mark - MKAnnotation
- (NSString *)title {
    return self.name;
}

- (NSString *)subtitle {
    return self.address;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    if (_coordinate.latitude != newCoordinate.latitude || _coordinate.longitude != newCoordinate.longitude) {
        _coordinate = newCoordinate;
        self.isReverseComplete = NO;
        self.name = @"Loading...";
        self.address = @"Loading...";
        /*
        [[GeoManager shareInstance] reverseCoordinate:_coordinate completionHandler:^(CLPlacemark *placemark) {
            NSString *street = [placemark.addressDictionary valueForKey:@"Street"]; // 街道
            self.name = placemark.name;
            self.address = [NSString stringWithFormat:@"%@%@", placemark.subLocality, street];
        }];
         */
    }
}


#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.isActive = [decoder decodeBoolForKey:kGeoFencingIsActiveKey];
        self.isReverseComplete = [decoder decodeBoolForKey:kGeoFencingIsReverseComplete];
        
        CGFloat latitude = [decoder decodeDoubleForKey:kGeoFencingLatitudeKey];
        CGFloat longitude = [decoder decodeDoubleForKey:kGeoFencingLongitudeKey];
        _coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        self.radius = [decoder decodeDoubleForKey:kGeoFencingRadiusKey];
        self.identifier = [decoder decodeObjectForKey:kGeoFencingIdentifierKey];
        self.name = [decoder decodeObjectForKey:kGeoFencingNameKey];
        self.address = [decoder decodeObjectForKey:kGeoFencingAddressTypeKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.isActive forKey:kGeoFencingIsActiveKey];
    [coder encodeBool:self.isReverseComplete forKey:kGeoFencingIsReverseComplete];
    [coder encodeDouble:self.coordinate.latitude forKey:kGeoFencingLatitudeKey];
    [coder encodeDouble:self.coordinate.longitude forKey:kGeoFencingLongitudeKey];
    [coder encodeDouble:self.radius forKey:kGeoFencingRadiusKey];
    [coder encodeObject:self.identifier forKey:kGeoFencingIdentifierKey];
    [coder encodeObject:self.name forKey:kGeoFencingNameKey];
    [coder encodeObject:self.address forKey:kGeoFencingAddressTypeKey];
}



@end

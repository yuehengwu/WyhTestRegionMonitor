//
//  WyhAnnotation.h
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/6.
//  Copyright © 2017年 wyh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface WyhAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy, nullable) NSString *title;

@property (nonatomic, copy, nullable) NSString *subtitle;

@property (nonatomic, assign) CGFloat radius;

//@property (nonatomic, strong) <#类名#> *<#变量名#>;


@end

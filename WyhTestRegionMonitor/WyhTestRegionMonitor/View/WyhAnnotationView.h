//
//  WyhAnnotationView.h
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/6.
//  Copyright © 2017年 wyh. All rights reserved.
//

#import <MapKit/MapKit.h>

@class WyhAnnotation;

@interface WyhAnnotationView : MKPinAnnotationView

+ (MKPinAnnotationView *)createAnnotationViewWithAnnotation:(WyhAnnotation *)annotation ReuseIdentifier:(NSString *)reuseIdentifier;

//+ (MKAnnotationView *)createCustomAnnotationViewWithAnnotation:(WyhAnnotation *)annotation ReuseIdentifier:(NSString *)reuseIdentifier;

- (void)updateAccessoryView;

@end

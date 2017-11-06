//
//  WyhAnnotationView.m
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/6.
//  Copyright © 2017年 wyh. All rights reserved.
//

#import "WyhAnnotationView.h"
#import "WyhAnnotation.h"

@implementation WyhAnnotationView

+ (MKPinAnnotationView *)createAnnotationViewWithAnnotation:(WyhAnnotation *)annotation ReuseIdentifier:(NSString *)reuseIdentifier {
    
    MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    pinView.animatesDrop = YES;
    pinView.canShowCallout = YES;
    pinView.pinTintColor = [UIColor magentaColor];
    pinView.draggable = YES;
    
    return pinView;
}

@end

//
//  WyhAnnotationView.m
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/6.
//  Copyright © 2017年 wyh. All rights reserved.
//

#import "WyhAnnotationView.h"
#import "WyhAnnotation.h"

@interface WyhAnnotationView()

@property (nonatomic, strong) UIButton *detailButton;

@end

@implementation WyhAnnotationView

+ (MKPinAnnotationView *)createAnnotationViewWithAnnotation:(WyhAnnotation *)annotation ReuseIdentifier:(NSString *)reuseIdentifier {
    
    WyhAnnotationView *pinView = [[WyhAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    [pinView setRightCalloutAccessoryView:pinView.detailButton];
    
    return pinView;
}

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        self.animatesDrop = YES;
        self.canShowCallout = YES;
//        self.pinTintColor = [UIColor magentaColor];
        self.draggable = YES;
    }
    return self;
}

- (void)updateAccessoryView {
    if ([self.annotation isKindOfClass:[WyhAnnotation class]]) {
        WyhAnnotation *annotation = (WyhAnnotation *)self.annotation;
        if (annotation.isDefenseRegion) {
            [_detailButton setBackgroundImage:[UIImage imageNamed:@"delete"] forState:(UIControlStateNormal)];
        }else {
            [_detailButton setBackgroundImage:[UIImage imageNamed:@"yes"] forState:(UIControlStateNormal)];
        }
    }
}

- (UIButton *)detailButton {
    if (!_detailButton) {
        _detailButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        _detailButton.frame = CGRectMake(.0f, .0f, 30.0f, 30.0f);
        _detailButton.layer.cornerRadius = 15.f;
//        [_detailButton setBackgroundImage:[UIImage imageNamed:@"yes"] forState:(UIControlStateNormal)];
    }
    return _detailButton;
}

@end

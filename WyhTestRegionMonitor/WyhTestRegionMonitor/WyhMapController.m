//
//  WyhMapController.m
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/6.
//  Copyright © 2017年 wyh. All rights reserved.
//

#import "WyhMapController.h"
#import "WyhAnnotation.h"
#import "WyhAnnotationView.h"

@interface WyhMapController () <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, strong) UIButton *userLocationButton;

@end

@implementation WyhMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.mapView];
 
    [self.view addSubview:self.userLocationButton];
    
    
    UILongPressGestureRecognizer *longpressed = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(LongPressedGestureAction:)];
    [self.mapView addGestureRecognizer:longpressed];
}

- (void)zoomToUserLocationAnimationed {
    CLLocation *location = self.mapView.userLocation.location;
    CLLocationCoordinate2D coordinate = location.coordinate;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000);
    [self.mapView setRegion:region animated:YES];
}


- (void)LongPressedGestureAction:(UILongPressGestureRecognizer *)longGesture{
    if (longGesture.state == UIGestureRecognizerStateBegan) {
        CGPoint touchPoint = [longGesture locationInView:self.mapView];
        CLLocationCoordinate2D pointCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        WyhAnnotation *annotation = [[WyhAnnotation alloc]init];
        annotation.title = @"test";
        annotation.subtitle = @"asdasd";
        annotation.coordinate = pointCoordinate;
        annotation.radius = 500;
        [self.mapView addAnnotation:annotation];
        [self.mapView addOverlay:[MKCircle circleWithCenterCoordinate:annotation.coordinate radius:annotation.radius]];
    }
    
}

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"WyhAnnotationReuseIdentifier";
    WyhAnnotationView *annotationView = (WyhAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!annotationView) {
        annotationView = (WyhAnnotationView *)[WyhAnnotationView createAnnotationViewWithAnnotation:annotation ReuseIdentifier:identifier];
    }
    annotationView.annotation = annotation;
    return annotationView;
}

#pragma mark Overlay !!
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        circleRenderer.lineWidth = 1.0f;
        circleRenderer.strokeColor = [UIColor yellowColor];
        circleRenderer.fillColor = [[UIColor redColor] colorWithAlphaComponent:.4f];
        
        return circleRenderer;
    }
    
    return nil;
}


- (MKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MKMapView alloc]initWithFrame:self.view.bounds];
        _mapView.delegate = self;
        _mapView.mapType = MKMapTypeStandard;
        _mapView.showsUserLocation = YES;
    }
    return _mapView;
}

- (UIButton *)userLocationButton {
    if (!_userLocationButton) {
        _userLocationButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_userLocationButton  addTarget:self action:@selector(zoomToUserLocationAnimationed) forControlEvents:(UIControlEventTouchUpInside)];
        _userLocationButton.frame = CGRectMake(20, self.view.bounds.size.height - 100, 40, 40);
        _userLocationButton.layer.cornerRadius = 20;
        _userLocationButton.backgroundColor = [UIColor redColor];
    }
    return _userLocationButton;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

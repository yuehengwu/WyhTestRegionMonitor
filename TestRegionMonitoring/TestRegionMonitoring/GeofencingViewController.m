//
//  GeofencingViewController.m
//  TestRegionMonitoring
//
//  Created by Mr.Chou on 2017/8/3.
//  Copyright © 2017年 iTalkBB. All rights reserved.
//

#import "GeofencingViewController.h"
#import <VBFPopFlatButton/VBFPopFlatButton.h>
#import "GeoManager.h"
#import "TQLocationConverter.h"

static const CLLocationDistance kDefaultZoomUserRegionDistance = 2000.f;
static const CLLocationDistance kDefaultZoomRegionDistance = 1500.f;


@interface GeofencingViewController () <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIButton *userLocationBtn;

@property (nonatomic, assign) BOOL haveSetUpZoom;
@property (nonatomic, strong) CLLocation *userLocation;
@property (nonatomic, strong) GeoFencing *tempGeoFencing;
@property (nonatomic, strong) GeoFencing *mUserLocationGeoFencing;


@end

@implementation GeofencingViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [GeoManager shareInstance];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView = [[MKMapView alloc] init];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
//    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    
    [self.view addSubview:self.mapView];
    [self.mapView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
    
    self.userLocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.userLocationBtn.backgroundColor = [UIColor grayColor];
    self.userLocationBtn.layer.cornerRadius = 20.f;
    [self.userLocationBtn addTarget:self action:@selector(zoomMapViewToUserLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.userLocationBtn];
    [self.userLocationBtn makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-40.f);
        make.leading.equalTo(self.view).offset(30.f);
        make.width.equalTo(40.f);
        make.height.equalTo(40.f);
    }];
    
    [self addGestureRecognizer];
    
    if ([GeoManager shareInstance].geoFencing) {
        [self mapViewAddGeoFencing:[GeoManager shareInstance].geoFencing];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setUpNaviTitle:NSLocalizedString(@"地理围栏", nil)];
    [self setUpNaviBackBtn];
    
    VBFPopFlatButton *mUserLocationBtn = [[VBFPopFlatButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)
                                                                      buttonType:buttonSquareType
                                                                     buttonStyle:buttonPlainStyle
                                                           animateToInitialState:NO];
    mUserLocationBtn.lineThickness = 2;
    mUserLocationBtn.lineRadius = 2;
    mUserLocationBtn.tintColor = [UIColor whiteColor];
    [mUserLocationBtn addTarget:self action:@selector(showManagerUserLocation) forControlEvents:UIControlEventTouchUpInside];
    [self setUpNaviRightBarButtons:@[mUserLocationBtn]];
}

- (void)showManagerUserLocation {
    if (self.mUserLocationGeoFencing) {
        [self.mapView removeAnnotation:self.mUserLocationGeoFencing];
        self.mUserLocationGeoFencing = nil;
        
    } else {
        CLLocation *mUserLocation = [GeoManager shareInstance].userLocation;
        NSLog(@"Manager.UserLocation.Coordinate(%f, %f)", mUserLocation.coordinate.latitude, mUserLocation.coordinate.longitude);
        if (mUserLocation) {
            self.mUserLocationGeoFencing = [GeoFencing geoFencingWithCoordinate:mUserLocation.coordinate];
            self.mUserLocationGeoFencing.radius = 0;
            [self.mapView addAnnotation:self.mUserLocationGeoFencing];
            [self.mUserLocationGeoFencing reverseWithCompletionHandler:^{
                
            }];
        }
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - GestureRecognizer
- (void)addGestureRecognizer {
    /*
    UITapGestureRecognizer *mapTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapeMapAction:)];
    mapTap.numberOfTapsRequired = 1;
    [self.mapView addGestureRecognizer:mapTap];
    
    UITapGestureRecognizer *mapTapDouble = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
    mapTapDouble.numberOfTapsRequired = 2;
    [self.mapView addGestureRecognizer:mapTapDouble];
    
    [mapTap requireGestureRecognizerToFail:mapTapDouble];
     */
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(selectedSomeWhereAction:)];
    [self.mapView addGestureRecognizer:longPress];
}

- (void)selectedSomeWhereAction:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        if ([GeoManager shareInstance].geoFencing) {
            NSLog(@"GeoFencing already exist, you can't add another one!");
            return;
        }
        
        if (self.tempGeoFencing) {
            [self mapViewRemoveGeoFencing:self.tempGeoFencing];
        }
        
        CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
        CLLocationCoordinate2D pointCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        NSLog(@"Coordinate(%f, %f)", pointCoordinate.latitude, pointCoordinate.longitude);
        
        GeoFencing *geoFencing = [GeoFencing geoFencingWithCoordinate:pointCoordinate];
        [self mapViewAddGeoFencing:geoFencing];
        [geoFencing reverseWithCompletionHandler:^{
            
        }];
    }
}


#pragma mark - Method
- (void)zoomMapViewToUserLocation {
    CLLocation *location = self.mapView.userLocation.location;
    #warning Test
    CLLocationCoordinate2D coordinateGCJ = location.coordinate;
    CLLocationCoordinate2D coordinateWGS = [TQLocationConverter transformFromGCJToWGS:coordinateGCJ];
    NSLog(@"MapView.UserLocation.CoordinateGCJ(%f, %f)", coordinateGCJ.latitude, coordinateGCJ.longitude);
    NSLog(@"MapView.UserLocation.CoordinateWGS(%f, %f)", coordinateWGS.latitude, coordinateWGS.longitude);
    
    [self zoomMapViewToLocation:location
           withLatitudeDistance:kDefaultZoomUserRegionDistance
              longitudeDistance:kDefaultZoomUserRegionDistance];
    self.userLocation = location;
}

- (void)zoomMapViewToLocation:(CLLocation *)location
         withLatitudeDistance:(CLLocationDistance)latitudeDistance
            longitudeDistance:(CLLocationDistance)longitudeDistance {
    if (location) {
        CLLocationCoordinate2D coordinate = location.coordinate;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, latitudeDistance, longitudeDistance);
        [self.mapView setRegion:region animated:YES];
        self.haveSetUpZoom = YES;
    }
}

- (void)mapViewAddGeoFencing:(GeoFencing *)geoFencing {
    [self.mapView addAnnotation:geoFencing];
    [self.mapView addOverlay:[MKCircle circleWithCenterCoordinate:geoFencing.coordinate radius:geoFencing.radius]];
    
    if (!geoFencing.isActive) {
        self.tempGeoFencing = geoFencing;
    }
}

- (void)mapViewRemoveGeoFencing:(GeoFencing *)geoFencing {
    [self.mapView removeAnnotation:geoFencing];
    [self.mapView removeOverlays:self.mapView.overlays];
    
    if (geoFencing.isActive) {
        [self stopGeoFencing];
    } else {
        self.tempGeoFencing = nil;
    }
}

- (void)startGeoFencing:(GeoFencing *)geoFencing {
    if ([GeoManager shareInstance].geoFencing) {
        NSLog(@"GeoFencing already exist, you can't add another one!");
        return;
    }
    
    self.tempGeoFencing = nil;
    [[GeoManager shareInstance] startMonitoringForGeoFencing:geoFencing];
}

- (void)stopGeoFencing {
    if ([GeoManager shareInstance].geoFencing) {
        [[GeoManager shareInstance] stopMonitoring];
    }
}


#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
}

#pragma mark UserLocation
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!self.userLocation && ![GeoManager shareInstance].geoFencing) {
        [self zoomMapViewToUserLocation];
    }
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"Error! MKMapView locate user failed!");
}


#pragma mark AnnotationView
// 配置AnnotationView
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *identifier = @"GeoFencingAnnotation";
    if ([annotation isKindOfClass:[GeoFencing class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (![annotation isKindOfClass:[MKPinAnnotationView class]] || annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.canShowCallout = YES;
            annotationView.animatesDrop = YES;
            
            if (((GeoFencing *)annotation).radius) {
                UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                removeBtn.frame = CGRectMake(.0f, .0f, 22.0f, 22.0f);
                [removeBtn setImage:[UIImage imageNamed:@"DeleteGeoFencing"] forState:UIControlStateNormal];
                removeBtn.tag = 1;
                [annotationView setLeftCalloutAccessoryView:removeBtn];
                
                if (!((GeoFencing *)annotation).isActive) { // 非生效GeoFencing才可有设置按钮
                    UIButton *addGeoFencingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    addGeoFencingBtn.frame = CGRectMake(.0f, .0f, 22.0f, 22.0f);
                    addGeoFencingBtn.layer.cornerRadius = 11.f;
                    [addGeoFencingBtn setBackgroundColor:Color_Green];
                    addGeoFencingBtn.tag = 2;
//                [addGeoFencingBtn setImage:[UIImage imageNamed:@"DeleteGeoFencing"] forState:UIControlStateNormal];
                    [annotationView setRightCalloutAccessoryView:addGeoFencingBtn];
                    
                    annotationView.draggable = YES;
                }
            }
            
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}

// AnnotationView已添加
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views {
    for (MKAnnotationView *view in views) {
        if ([view.annotation isKindOfClass:[GeoFencing class]]) {
            [self.mapView selectAnnotation:view.annotation animated:YES]; // 显示新AnnotationView自动选中
        }
    }
}

// AnnotationView被选中
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"MKMapView did select annotationView, show detail.");
    
    if ([view.annotation isKindOfClass:[GeoFencing class]]) {
        GeoFencing *geoFencing = (GeoFencing *)view.annotation;
        if (geoFencing.radius) {
            CLLocationCoordinate2D coordinate = view.annotation.coordinate;
            if (self.haveSetUpZoom) {
                [self.mapView setCenterCoordinate:coordinate animated:YES];
            } else {
                [self zoomMapViewToLocation:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude]
                       withLatitudeDistance:kDefaultZoomRegionDistance
                          longitudeDistance:kDefaultZoomRegionDistance];
            }
        }
    }
}

// AnnotationView取消选中
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"MKMapView did deselect annotationView, hide detail.");
}

// Annotation的callout点击事件
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    GeoFencing *geoFencing = (GeoFencing *)view.annotation;
    if (control.tag == 1) { // 删除
        [self mapViewRemoveGeoFencing:geoFencing];
        
    } else if (control.tag == 2) { // 设定
        [self startGeoFencing:geoFencing];
    }
}

// 拖拽AnnotationView事件
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState {
    switch (newState) {
        case MKAnnotationViewDragStateStarting: {
            NSLog(@"拿起");
            return;
        }
        case MKAnnotationViewDragStateDragging: {
            NSLog(@"开始拖拽");
            return;
        }
        case MKAnnotationViewDragStateEnding: {
            NSLog(@"放下大头针Start");
            GeoFencing *fencing = (GeoFencing *)view.annotation;
            [fencing reverseWithCompletionHandler:^{
                
            }];
            [self.mapView removeOverlays:self.mapView.overlays];
            [self.mapView addOverlay:[MKCircle circleWithCenterCoordinate:fencing.coordinate radius:fencing.radius]];
            NSLog(@"放下大头针End");
            return;
        }
            
        default:
            return;
    }
}


#pragma mark Overlay
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        circleRenderer.lineWidth = 1.0f;
        circleRenderer.strokeColor = Color_Green;
        circleRenderer.fillColor = [Color_Green colorWithAlphaComponent:.4f];
        
        return circleRenderer;
    }
    
    return nil;
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

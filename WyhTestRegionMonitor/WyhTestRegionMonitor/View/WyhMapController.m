//
//  WyhMapController.m
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/6.
//  Copyright © 2017年 wyh. All rights reserved.
//
#import "WyhMapController.h"
#import "WyhAnnotationView.h"
#import "WyhLocationManager.h"


static CGFloat const kDefaultLocationDistance = 2000.0f;

@interface WyhMapController () <MKMapViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, strong) UIButton *userLocationButton;
@property (nonatomic, strong) UIButton *switchDefenseButton;

@property (nonatomic, assign) NSInteger currentDefenseAreaIndex;

@property (nonatomic, strong) WyhAnnotation *currentTempAnnotation;


@end

@implementation WyhMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"电子围栏";
    
    
    [self configUI];
    
    [self configGestureRecognizer];
    
    // 初始化 各个防区
    if ([WyhLocationManager shareInstance].annotationArr.count != 0) {
        for (WyhAnnotation *annotation in [WyhLocationManager shareInstance].annotationArr) {
            [self addAnnotation:annotation];
            [self addOverLayFromAnnotation:annotation];
        }
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self zoomToUserLocationWithAnimated];
}

- (void)configUI {
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.switchDefenseButton];
    [self.view addSubview:self.userLocationButton];
    
    [self.userLocationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.view).offset(-80);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
    
    [self.switchDefenseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.bottom.equalTo(self.view).offset(-80);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
}

- (void)prepareNavigation {
    UIButton *rightItem = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [rightItem addTarget:self action:@selector(addCurrentLocationRegionOverLay) forControlEvents:(UIControlEventTouchUpInside)];
//    [rightItem setBackgroundImage:[UIImage imageNamed:@"add"] forState:(UIControlStateNormal)];
    rightItem.frame = CGRectMake(0, 0, 44, 44);
    [rightItem setTitle:@"add" forState:(UIControlStateNormal)];
    [rightItem setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
    rightItem.contentHorizontalAlignment =UIControlContentHorizontalAlignmentRight;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightItem];
}

- (void)configGestureRecognizer {
    
    UILongPressGestureRecognizer *longpressed = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(LongPressedGestureAction:)];
    
//    UIPanGestureRecognizer *dragGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragMapViewWhenDone:)];
//    dragGesture.delegate = self;
//    [self.mapView addGestureRecognizer:dragGesture];
    [self.mapView addGestureRecognizer:longpressed];
}

#pragma mark - private function

- (void)zoomToUserLocationWithAnimated {
    CLLocation *location = self.mapView.userLocation.location;
    
    [self zoomMapViewToLocation:location withLatitudeDistance:kDefaultLocationDistance longitudeDistance:kDefaultLocationDistance];
}

- (void)switchDefenseLocationWithAnimated {
    _currentDefenseAreaIndex = (_currentDefenseAreaIndex+1)<[WyhLocationManager shareInstance].annotationArr.count?(_currentDefenseAreaIndex+1):0; //找到下一个引用计数
    if ([WyhLocationManager shareInstance].annotationArr.count <= 0) {
        return;
    }
    WyhAnnotation *nextAnnotation = [WyhLocationManager shareInstance].annotationArr[_currentDefenseAreaIndex];
    if (nextAnnotation) {
        for (WyhAnnotation *annotation in self.mapView.annotations) {
            if ([annotation isKindOfClass:[WyhAnnotation class]]) {
                if ([annotation.identifier isEqualToString:nextAnnotation.identifier]) {
                    [self selectAnnotation:annotation];
                    break;
                }
            }
        }
    }
}

- (void)addCurrentLocationRegionOverLay {
    
    WyhAnnotation *annotation = [WyhAnnotation annotationWithCoordinate:self.mapView.userLocation.coordinate CompleteHandler:nil];
    [self addAnnotation:annotation];
}

#pragma mark - mapView selector
/**
 选择一个标签
 */
- (void)selectAnnotation:(WyhAnnotation *)annotation {
    [self.mapView selectAnnotation:annotation animated:YES]; // 显示新AnnotationView自动选中
}

/**
 跳转到指定位置
 */
- (void)zoomMapViewToLocation:(CLLocation *)location
         withLatitudeDistance:(CLLocationDistance)latitudeDistance
            longitudeDistance:(CLLocationDistance)longitudeDistance {
    if (location) {
        CLLocationCoordinate2D coordinate = location.coordinate;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, latitudeDistance, longitudeDistance);
        [self.mapView setRegion:region animated:YES];
    }
}

/**
 添加一个标签
 */
- (void)addAnnotation:(WyhAnnotation *)annotation {
    if (self.currentTempAnnotation && !self.currentTempAnnotation.isDefenseRegion) {
        [self.mapView removeAnnotation:self.currentTempAnnotation];
    }
    
    [self.mapView addAnnotation:annotation];
    self.currentTempAnnotation = annotation;
//    [self.mapView addOverlay:[MKCircle circleWithCenterCoordinate:annotation.coordinate radius:annotation.radius]];
}

/**
 移除一个标签
 */
- (void)removeAnnotation:(WyhAnnotation *)annotation {
    if ([self.mapView.annotations containsObject:annotation]) {
        [self.mapView removeAnnotation:annotation];
    }
    for (MKCircle *circleLay in self.mapView.overlays) {
        if ((circleLay.coordinate.latitude == annotation.coordinate.latitude) && (circleLay.coordinate.longitude == annotation.coordinate.longitude)) {
            [self.mapView removeOverlay:circleLay];
        }
    }
}

/**
 添加一个区域
 */
- (void)addOverLayFromAnnotation:(WyhAnnotation *)annotation {

    MKCircle *circleOverlay = [MKCircle circleWithCenterCoordinate:annotation.coordinate radius:annotation.radius];
    [self.mapView addOverlay:circleOverlay];
}


#pragma mark - gestureRecognizer delegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)LongPressedGestureAction:(UILongPressGestureRecognizer *)longGesture{
    if (longGesture.state == UIGestureRecognizerStateBegan) {
        CGPoint touchPoint = [longGesture locationInView:self.mapView];
        CLLocationCoordinate2D pointCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        [WyhAnnotation annotationWithCoordinate:pointCoordinate CompleteHandler:^(WyhAnnotation *anno) {
            NSLog(@"最后得到的%@",anno.description);
            [self addAnnotation:anno];
        }];
//        [annotation reverseGeocodeLocationWithCompleteHandler:^(WyhAnnotation *anno) {
//            NSLog(@"最后得到的%@",anno.description);
//        }];
        
    }
}

- (void)dragMapViewWhenDone:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        
        CGPoint touchPoint = [panGesture locationInView:self.mapView];
        CLLocationCoordinate2D pointCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        [WyhAnnotation annotationWithCoordinate:pointCoordinate CompleteHandler:^(WyhAnnotation *anno) {
            NSLog(@"最后得到的%@",anno.description);
            [self addAnnotation:anno];
        }];
    }
    
}

#pragma mark - mapView delegate

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"WyhAnnotationReuseIdentifier";
    if ([annotation isKindOfClass:[WyhAnnotation class]]) {
        WyhAnnotationView *annotationView = (WyhAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (!annotationView) {
            annotationView = (WyhAnnotationView *)[WyhAnnotationView createAnnotationViewWithAnnotation:(WyhAnnotation *)annotation ReuseIdentifier:identifier];
        }else{
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    return nil;
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        circleRenderer.lineWidth = 0.5f;
        circleRenderer.strokeColor = [UIColor redColor];
        circleRenderer.fillColor = [[UIColor greenColor] colorWithAlphaComponent:.4f];
        
        return circleRenderer;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (userLocation && [WyhLocationManager shareInstance].annotationArr.count == 0) {
        [self zoomToUserLocationWithAnimated];
    }
}

#pragma mark - AccessoryView TapAction

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    __block WyhAnnotation *annotation = (WyhAnnotation *)view.annotation;
    WyhAnnotationView *annotationView = (WyhAnnotationView *)view;
    
    if (!annotation.isDefenseRegion) {
        // add defense region
        
        [self showAlertTitle:@"请输入防区信息" Subtitle:nil OKtitle:@"确认" CancelTitle:@"取消" OKAction:^(UIAlertAction *action, UIAlertController *alertController) {
            annotation.title = [alertController.textFields[0] text];
            annotation.identifier = [alertController.textFields[0] text];
            annotation.radius = alertController.textFields[1].text.doubleValue;
            annotation.isDefenseRegion = YES;
            [annotationView updateAccessoryView];
            [self addOverLayFromAnnotation:annotation];
            [WyhLocationManager startMonitorRegionWithAnnotation:annotation];
            
        } CancelAction:^(UIAlertAction *action, UIAlertController *alertController) {
            
        } TextFieldStyles:^NSArray<wyhTextFieldStyleBlock> *{
            wyhTextFieldStyleBlock blockStyle1 = ^(UITextField *textField) {
                textField.placeholder = @"请输入地点标记";
                textField.returnKeyType = UIReturnKeyNext;
            };
            wyhTextFieldStyleBlock blockStyle2 = ^(UITextField *textField) {
                textField.placeholder = @"请输入布放的半径";
                textField.returnKeyType = UIReturnKeyNext;
                textField.keyboardType = UIKeyboardTypeNumberPad;
            };
            return @[blockStyle1,blockStyle2];
        }];
        
    }else {
        // delete defense region
        [self showAlertTitle:@"确定删除当前防区吗？" Subtitle:nil OKtitle:@"确定" CancelTitle:@"取消" OKAction:^(UIAlertAction *action, UIAlertController *alertController) {
            
            [self removeAnnotation:annotation];
            [WyhLocationManager stopMonitorRegionWithAnnotation:annotation];
            
        } CancelAction:^(UIAlertAction *action, UIAlertController *alertController) {
            
        } TextFieldStyles:nil];
        
    }
}

/**
 annotationView添加后自动选中
 */
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views {
    for (MKAnnotationView *view in views) {
        if ([view.annotation isKindOfClass:[WyhAnnotation class]]) {
            [self performSelector:@selector(selectAnnotation:) withObject:view.annotation afterDelay:0.1];
        }
    }
}


/**
 annotationView被选中的处理
 */
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if ([view.annotation isKindOfClass:[WyhAnnotation class]]) {
        [(WyhAnnotationView *)view updateAccessoryView]; //更新按钮状态
        WyhAnnotation *annotation = (WyhAnnotation *)view.annotation;
        if (annotation.radius != 0) {
//            [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
            [self zoomMapViewToLocation:[[CLLocation alloc]initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude] withLatitudeDistance:kDefaultLocationDistance longitudeDistance:kDefaultLocationDistance];
        }
    }
}

// AnnotationView取消选中
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"MKMapView did deselect annotationView, hide detail.");
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
            WyhAnnotation *annotation = (WyhAnnotation *)view.annotation;
            [annotation reverseGeocodeLocationWithCompleteHandler:^(WyhAnnotation *anno) {
                
            }];
            NSLog(@"放下大头针End");
            return;
        }
            
        default:
            return;
    }
}

#pragma mark - Lazy

- (MKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MKMapView alloc]initWithFrame:self.view.bounds];
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES;
    }
    return _mapView;
}

- (UIButton *)userLocationButton {
    if (!_userLocationButton) {
        _userLocationButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_userLocationButton  addTarget:self action:@selector(zoomToUserLocationWithAnimated) forControlEvents:(UIControlEventTouchUpInside)];
        [_userLocationButton setBackgroundImage:[UIImage imageNamed:@"userlocation"] forState:(UIControlStateNormal)];
//        _userLocationButton.layer.cornerRadius = 20;
    }
    return _userLocationButton;
}

- (UIButton *)switchDefenseButton {
    if (!_switchDefenseButton) {
        _switchDefenseButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_switchDefenseButton  addTarget:self action:@selector(switchDefenseLocationWithAnimated) forControlEvents:(UIControlEventTouchUpInside)];
        [_switchDefenseButton setBackgroundImage:[UIImage imageNamed:@"switch"] forState:(UIControlStateNormal)];
//        _switchDefenseButton.layer.cornerRadius = 20;
    }
    return _switchDefenseButton;
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

//
//  ViewController.m
//  TestRegionMonitoring
//
//  Created by Mr.Chou on 2017/8/2.
//  Copyright © 2017年 iTalkBB. All rights reserved.
//

#import "ViewController.h"
#import "GeofencingViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *geoFencingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [geoFencingBtn setTitle:@"设置GeoFencing" forState:UIControlStateNormal];
    [geoFencingBtn setBackgroundColor:[UIColor lightGrayColor]];
    [geoFencingBtn addTarget:self action:@selector(geoFencingBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:geoFencingBtn];
    [geoFencingBtn makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(150);
        make.height.equalTo(50);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)geoFencingBtnAction {
    [self.navigationController pushViewController:[GeofencingViewController new] animated:YES];
}


@end

//
//  WyhTabBarBaseController.m
//  WyhLocationRegionMonitorDemo
//
//  Created by wyh on 2017/11/6.
//  Copyright © 2017年 Wyh. All rights reserved.
//

#import "WyhTabBarBaseController.h"
#import "WyhNavBaseController.h"

#import "WyhMapController.h"
#import "WyhDataViewController.h"

@interface WyhTabBarBaseController ()

@end

@implementation WyhTabBarBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addChildViewControllerWithvcName:[WyhMapController new] title:@"Map" imageName:@"map" selectedImage:@"map"];
    [self addChildViewControllerWithvcName:[WyhDataViewController new] title:@"Data" imageName:@"data" selectedImage:@"data"];
    
}

- (void)addChildViewControllerWithvcName:(UIViewController *)vcName title:(NSString *)title imageName:(NSString *)imageName selectedImage:(NSString *)selectedImage {
    
    WyhNavBaseController *NC = [[WyhNavBaseController alloc]initWithRootViewController:vcName];
    NC.topViewController.title = title;
    NC.tabBarItem.image = [UIImage imageNamed:imageName];
    NC.tabBarItem.selectedImage = [UIImage imageNamed:selectedImage];
    [self addChildViewController:NC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

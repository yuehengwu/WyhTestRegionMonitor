//
//  SuperViewController.h
//  PDQBook
//
//  ViewController基类
//  Created by Mr.Chou on 16/7/14.
//  Since v1.0.0
//  Copyright (c) 2016年 周 骏豪. All rights reserved.
//

#import "SuperViewController.h"
#import <VBFPopFlatButton/VBFPopFlatButton.h>
//#import "CWStatusBarNotification.h"

@interface SuperViewController () <UIWebViewDelegate>

//@property (nonatomic, strong) CWStatusBarNotification *statusBarMsg;

@end

@implementation SuperViewController

#pragma mark - LifeCircle
- (id)init {
    self = [super init];
    if (self) {
//        self.statusBarMsg = [CWStatusBarNotification new];
//        
//        // set default blue color (since iOS 7.1, default window tintColor is black)
//        self.statusBarMsg.notificationLabelBackgroundColor = Color_TextYellow;
//        self.statusBarMsg.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
//        self.statusBarMsg.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RCIMReceiveMessageAction) name:Notifi_RCIMReceiveMessage object:nil];
    }
    
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];  // 清理NSURLCache的CachedResponse
}

- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:Notifi_RCIMReceiveMessage object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate]; // 注：在navigation栈中会失效
    self.view.backgroundColor = [UIColor whiteColor];
    self.tabBarController.navigationController.navigationBar.hidden = YES;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack; // 设置statusBar
}



#pragma mark - StatusBar
/// 回调设置StatusBarStyle
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}




#pragma mark - NavigationBar
/**
 *  设置标题
 */
- (void)setUpNaviTitle:(NSString *)title {
    self.navigationItem.title = title;
}

/**
 *  设置返回按钮
 */
- (void)setUpNaviBackBtn {
    [self setUpNaviBackBtnWithAction:@selector(naviBackBtnAction)];
}

/**
 *  设置返回按钮
 *
 *  @param action 调用方法
 */
- (void)setUpNaviBackBtnWithAction:(SEL)action {
    // 返回按钮
//    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnBack.frame = CGRectMake(0, 0, 13.5, 23.5);
//    [btnBack addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
//    [btnBack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [btnBack setBackgroundImage:[UIImage imageNamed:@"Navi_Back"] forState:UIControlStateNormal];
//    UIBarButtonItem *btnBackItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    
    VBFPopFlatButton *backBtn = [[VBFPopFlatButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)
                                                                 buttonType:buttonBackType
                                                                buttonStyle:buttonPlainStyle
                                                      animateToInitialState:NO];
    backBtn.lineThickness = 2;
    backBtn.lineRadius = 2;
    backBtn.tintColor = [UIColor whiteColor];
    [backBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBtnItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    self.navigationItem.leftBarButtonItem = backBtnItem;
}

- (void)naviBackBtnAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setUpNaviRightBarButtons:(NSArray<UIButton *> *)btns {
    NSMutableArray *rightBarButtonItems = [NSMutableArray array];
    for (int i = 0; i < btns.count; i++) {
        UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:[btns objectAtIndex:i]];
        [rightBarButtonItems addObject:btnItem];
    }
    
    if (rightBarButtonItems.count) {
        self.navigationItem.rightBarButtonItems = rightBarButtonItems;
    }
}


#pragma mark - Goods
/**
 页面退出编辑
 */
- (void)endEditing {
    [self.view endEditing:YES];
}


#pragma mark - MsgAction
/**
 *  新消息通知处理
 */
- (void)RCIMReceiveMessageAction {
//    [self.statusBarMsg displayNotificationWithMessage:@"讨论组收到新消息了哦，点击可查看~" forDuration:3.0f];
//    __weak typeof(self) weakSelf = self;
//    self.statusBarMsg.notificationTappedBlock = ^(void) {
////        [weakSelf.statusBarMsg dismissNotification]; // 通常需要先隐藏状态栏通知.
////        UserGroupListViewController * listView = [UserGroupListViewController new];
////        [weakSelf.navigationController pushViewController:listView animated:YES];
//    };
}






@end

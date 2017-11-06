//
//  SuperViewController.h
//  PDQBook
//
//  ViewController基类
//  Created by Mr.Chou on 16/7/14.
//  Since v1.0.0
//  Copyright (c) 2016年 周 骏豪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuperViewController : UIViewController

// Add property here


#pragma mark - NavigationBar
/**
 *  设置标题
 */
- (void)setUpNaviTitle:(NSString *)title;

/**
 *  设置返回按钮
 */
- (void)setUpNaviBackBtn;

/**
 *  设置返回按钮
 *
 *  @param action 调用方法
 */
- (void)setUpNaviBackBtnWithAction:(SEL)action;

/**
 *  设置右侧按钮
 *
 *  @param btns 按钮们
 */
- (void)setUpNaviRightBarButtons:(NSArray<UIButton *> *)btns;


#pragma mark - Goods
/**
 页面退出编辑
 */
- (void)endEditing;


#pragma mark - MsgAction
/**
 *  新消息通知处理
 */
- (void)RCIMReceiveMessageAction;




@end

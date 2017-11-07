//
//  UIViewController+WyhAlert.m
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/7.
//  Copyright © 2017年 wyh. All rights reserved.
//

#import "UIViewController+WyhAlert.h"

@implementation UIViewController (WyhAlert)

- (void)showAlertTitle:(NSString *)title
              Subtitle:(NSString *)subtitle
               OKtitle:(NSString *)oktitle
           CancelTitle:(NSString *)canceltitle
              OKAction:(void(^)(UIAlertAction * action, UIAlertController *alertController))okhandler
          CancelAction:(void(^)(UIAlertAction * action, UIAlertController *alertController))cancelhandler
       TextFieldStyles:(NSArray<wyhTextFieldStyleBlock> *(^)(void))styles {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:subtitle preferredStyle:(UIAlertControllerStyleAlert)];
    
    if (styles) {
        for (wyhTextFieldStyleBlock block in styles()) {
            [alertController addTextFieldWithConfigurationHandler:block];
        }
    }
    
    if (canceltitle) {
        [alertController addAction:[UIAlertAction actionWithTitle:canceltitle style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            cancelhandler(action, alertController);
        }]];
    }
    if (oktitle) {
        [alertController addAction:[UIAlertAction actionWithTitle:oktitle style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            okhandler(action, alertController);
        }]];
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

@end

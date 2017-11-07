//
//  UIViewController+WyhAlert.h
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/7.
//  Copyright © 2017年 wyh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^wyhTextFieldStyleBlock)(UITextField * textField);

@interface UIViewController (WyhAlert)

- (void)showAlertTitle:(NSString *)title
              Subtitle:(NSString *)subtitle
               OKtitle:(NSString *)oktitle
           CancelTitle:(NSString *)canceltitle
              OKAction:(void(^)(UIAlertAction * action, UIAlertController *alertController))okhandler
          CancelAction:(void(^)(UIAlertAction * action, UIAlertController *alertController))cancelhandler
       TextFieldStyles:(NSArray<wyhTextFieldStyleBlock> *(^)(void))styles;

@end

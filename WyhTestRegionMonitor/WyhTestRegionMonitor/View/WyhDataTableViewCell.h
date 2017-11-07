//
//  WyhDataTableViewCell.h
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/7.
//  Copyright © 2017年 wyh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WyhDataTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *latitude;
@property (weak, nonatomic) IBOutlet UILabel *longtitude;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

- (void)setDataDic:(NSDictionary *)dict;

@end

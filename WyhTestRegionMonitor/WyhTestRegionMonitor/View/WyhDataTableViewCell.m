//
//  WyhDataTableViewCell.m
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/7.
//  Copyright © 2017年 wyh. All rights reserved.
//

#import "WyhDataTableViewCell.h"

@implementation WyhDataTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setDataDic:(NSDictionary *)dict {
    
    self.title.text = dict[@"title"];
    
    self.latitude.text = [NSString stringWithFormat:@"纬度:%.2g",[dict[@"latitude"] floatValue]];
    self.longtitude.text = [NSString stringWithFormat:@"经度:%.2g",[dict[@"longtitude"] floatValue]];
    self.timeLabel.text = dict[@"time"];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

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
    NSString *latitude = [NSString stringWithFormat:@"%@",dict[@"latitude"]];
    NSString *longitude = [NSString stringWithFormat:@"%@",dict[@"longitude"]];
    if (latitude.length >= 7) {
        latitude  = [latitude substringWithRange:NSMakeRange(0, 7)];
        longitude = [longitude substringWithRange:NSMakeRange(0, 7)];
    }
    
    self.latitude.text = [NSString stringWithFormat:@"纬度:%@",latitude];
    self.longitude.text = [NSString stringWithFormat:@"经度:%@",longitude];

    self.timeLabel.text = dict[@"time"];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

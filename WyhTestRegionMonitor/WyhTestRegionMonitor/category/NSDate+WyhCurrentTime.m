
//
//  NSDate+WyhCurrentTime.m
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/7.
//  Copyright © 2017年 wyh. All rights reserved.
//

#import "NSDate+WyhCurrentTime.h"

@implementation NSDate (WyhCurrentTime)

+ (NSString *)currentTime {
    NSDate*currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:currentDate];
    return dateStr;
}

@end

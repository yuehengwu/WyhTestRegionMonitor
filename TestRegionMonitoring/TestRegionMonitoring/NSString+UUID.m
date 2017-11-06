//
//  NSString+UUID.m
//  TestRegionMonitoring
//
//  Created by Mr.Chou on 2017/8/7.
//  Copyright © 2017年 iTalkBB. All rights reserved.
//

#import "NSString+UUID.h"

@implementation NSString (UUID)

#pragma mark - UUID
/**
 获取UUID
 
 @return uuid
 */
+ (NSString *)UUIDString {
    CFUUIDRef puuid = CFUUIDCreate(nil);
    CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
    NSString *result = (NSString *)CFBridgingRelease(CFStringCreateCopy(NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    
    result = [result stringByReplacingOccurrencesOfString:@"-" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@" " withString:@""];
    result = result.lowercaseString;
    
    return result;
}


@end

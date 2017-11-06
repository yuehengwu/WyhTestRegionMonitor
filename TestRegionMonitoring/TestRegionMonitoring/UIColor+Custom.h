//
//  UIColor+Custom.h
//  AirPPT
//
//  Created by Mr.Chou on 15/3/27.
//  Copyright (c) 2015年 周 骏豪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Custom)

/**
 *  根据6位16进制hex值获得颜色
 *
 *  @param hex 6位16进制hex值
 *
 *  @return color
 */
+ (UIColor *)colorWithHexString:(NSString *)hex;


/**
 *  根据6位16进制hex值、透明度获得颜色
 *
 *  @param hex 6位16进制hex值
 *  @param alpha 透明度
 *
 *  @return color
 */
+ (UIColor *)colorWithHexString:(NSString *)hex alpha:(float)alpha;


/**
 *  根据RGBA获得UIColor
 *
 *  @param rgbaString rgba(66,61,61,1)
 *
 *  @return color
 */
+ (UIColor *)colorWithRGBA:(NSString *)rgbaString;


#pragma mark - RandomColor
/**
 *  随机颜色
 *
 *  @return randomColor
 */
+ (UIColor *)randomColor;


@end

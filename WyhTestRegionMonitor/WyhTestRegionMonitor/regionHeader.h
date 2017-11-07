//
//  regionHeader.h
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/7.
//  Copyright © 2017年 wyh. All rights reserved.
//


#define wyh_async_safe_dispatch(block) \
if ([NSThread isMainThread]) { \
block(); \
} else { \
dispatch_async(dispatch_get_main_queue(), block); \
}




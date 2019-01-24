//
//  MMPhotoPickerConst.h
//  MMPhotoPicker
//
//  Created by LEA on 2017/11/10.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "UIView+Geometry.h"
#import "MMPhotoUtil.h"

//#### 宏定义

// iPhone4
#define kIPhone4                        CGSizeEqualToSize(CGSizeMake(640,960), [[[UIScreen mainScreen] currentMode] size])
// iPhone5
#define kIPhone5                        CGSizeEqualToSize(CGSizeMake(640,1136), [[[UIScreen mainScreen] currentMode] size])
// iPhone6
#define kIPhone6                        CGSizeEqualToSize(CGSizeMake(750,1334), [[[UIScreen mainScreen] currentMode] size])
// iPhone6p
#define kIPhone6p                       CGSizeEqualToSize(CGSizeMake(1242,2208), [[[UIScreen mainScreen] currentMode] size])
// iPhoneX | iPhoneXS
#define kIPhoneX                        CGSizeEqualToSize(CGSizeMake(1125,2436), [[[UIScreen mainScreen] currentMode] size])
// iPhoneXR
#define kIPhoneXR                       CGSizeEqualToSize(CGSizeMake(828,1792), [[[UIScreen mainScreen] currentMode] size])
// iPhoneXS Max
#define kIPhoneXM                       CGSizeEqualToSize(CGSizeMake(1242,2688), [[[UIScreen mainScreen] currentMode] size])

// iPhone X系列
#define k_iPhoneX                       (kDeviceHeight >= 812.0f)
// 图片边距
#define kMargin                         4.0f
// 底部菜单高度
#define kTabHeight                      (k_iPhoneX ? 84.0f : 50.0f)

// 顶部整体高度
#define kTopHeight                      (kStatusHeight + kNavHeight)
// 状态栏高度
#define kStatusHeight                   [[UIApplication sharedApplication] statusBarFrame].size.height
// 导航栏高度
#define kNavHeight                      self.navigationController.navigationBar.height

// 屏幕高度
#define kDeviceHeight                   [UIScreen mainScreen].bounds.size.height
// 屏幕宽度
#define kDeviceWidth                    [UIScreen mainScreen].bounds.size.width

// RGB颜色
#define RGBColor(r,g,b,a)               [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
// 主颜色
#define kMainColor                      RGBColor(211.0, 58.0, 49.0, 1.0)
// 图片路径
#define MMPhotoPickerSrcName(file)      [@"MMPhotoPicker.bundle" stringByAppendingPathComponent:file]

// 资源类型 PHAssetMediaType
#define MMPhotoMediaType                @"mediaType"
// 位置方向
#define MMPhotoLocation                 @"location"
// 原始图片
#define MMPhotoOriginalImage            @"originalImage"
// 视频路径
#define MMPhotoVideoURL                 @"videoURL"

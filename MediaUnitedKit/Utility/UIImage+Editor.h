//
//  UIImage+Editor.h
//  MediaUnitedKit
//
//  Created by LEA on 2017/9/21.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Editor)

// 颜色转图片
+ (UIImage *)imageFromColor:(UIColor *)color;

// 图像黑白处理
- (UIImage *)sketchImage;

// 等比压缩
- (UIImage *)imageScaleAspectToMaxSize:(CGFloat)newSize;

// 添加边框
- (UIImage *)imageAddBorderByIndex:(NSInteger)index;

// 图片旋转
- (UIImage *)rotateImage;

@end


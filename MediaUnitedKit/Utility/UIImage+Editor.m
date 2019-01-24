//
//  UIImage+Editor.m
//  MediaUnitedKit
//
//  Created by LEA on 2017/9/21.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "UIImage+Editor.h"
#import <GPUImage/GPUImagePicture.h>
#import <GPUImage/GPUImageSketchFilter.h>

// 由角度转换弧度
#define kDegreesToRadian(x)         (M_PI * (x) / 180.0)
// 由弧度转换角度
#define kRadianToDegrees(radian)    (radian * 180.0) / (M_PI)

@implementation UIImage (Editor)

// 颜色转图片
+ (UIImage *)imageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage * outImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outImage;
}

// 图片黑白处理
- (UIImage *)sketchImage
{
    UIImage * image = [Utility fixOrientation:self];
    GPUImageSketchFilter * filter = [[GPUImageSketchFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture * picture = [[GPUImagePicture alloc] initWithImage:image];
    [picture addTarget:filter];
    [picture processImage];
    [filter useNextFrameForImageCapture];
    UIImage * outImage = [filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    return outImage;
}

// 等比压缩
- (UIImage *)imageScaleAspectToMaxSize:(CGFloat)newSize
{
    CGSize size = [self size];
    CGFloat ratio;
    if (size.width > size.height) {
        ratio = newSize / size.width;
    } else {
        ratio = newSize / size.height;
    }
    CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);
    [self drawInRect:rect];
    UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

// 添加边框
- (UIImage *)imageAddBorderByIndex:(NSInteger)index
{
    // 边框图片
    UIImage * borderImage = [UIImage imageNamed:[NSString stringWithFormat:@"border_%ld",(long)index]];
    // 对中间点像素拉伸
    borderImage = [borderImage stretchableImageWithLeftCapWidth:floorf(borderImage.size.width/2) topCapHeight:floorf(borderImage.size.height/2)];
    // 合成
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    [borderImage drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    // 刨去边框的宽度
    CGFloat margin  = 40;
    [self drawInRect:CGRectMake(margin, margin, self.size.width-2*margin, self.size.height-2*margin)];
    // 输出
    UIImage * outImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outImage;
}

// 将图片旋转
- (UIImage *)rotateImage
{
    // 90度向右旋转，-90度向左旋转
    return [self imageRotatedByRadians:kDegreesToRadian(-90)];
}

// 将图片旋转弧度radians
- (UIImage *)imageRotatedByRadians:(CGFloat)radians
{
    UIView * containView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform transform = CGAffineTransformMakeRotation(radians);
    containView.transform = transform;
    CGSize rotatedSize = containView.frame.size;
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    CGContextRotateCTM(bitmap, radians);
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    UIImage * outImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outImage;
}

@end

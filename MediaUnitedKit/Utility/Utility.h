//
//  Utility.h
//  MediaUnitedKit
//
//  Created by LEA on 2017/9/21.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface Utility : NSObject

#pragma mark - 时间

// 获取当前时间的时间戳(秒)
+ (long long)getNowTimestampSec;
// 获取当前时间的时间戳字符串
+ (NSString *)getNowTimestampString;
// 获取时分秒
+ (NSString *)getHMSFormatBySeconds:(int)seconds;

#pragma mark - 文件路径
+ (NSString *)getDocDir;
+ (NSString *)getVideoDir;
+ (NSString *)getAudioDir;
+ (NSString *)getAudioFilePath;
+ (NSString *)getTempPicDir;

#pragma mark - 获取视频缩略图
+ (UIImage *)getVideoImage:(NSURL *)videoPath;

#pragma mark - 权限
+ (BOOL)isAudioRecordPermit;
+ (BOOL)isPhotoLibraryPermit;
+ (BOOL)isCameraPermit;

#pragma mark - 保存图片/视频
+ (void)writeImageToMUKAssetsGroup:(UIImage *)image completion:(void(^)(BOOL isSuccess))completion;
+ (void)writeVideoToMUKAssetsGroup:(NSURL *)videoURL completion:(void(^)(BOOL isSuccess))completion;

#pragma mark - 图片处理
+ (UIImage *)fixOrientation:(UIImage *)aImage;
+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize;

@end

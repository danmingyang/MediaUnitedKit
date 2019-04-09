//
//  Utility.m
//  MediaUnitedKit
//
//  Created by LEA on 2017/9/21.
//  Copyright © 2017年 LEA. All rights reserved.
//

static NSString * kAssetsGroup = @"MUK";

@implementation Utility

#pragma mark - 时间
// 获取当前时间的时间戳(秒)
+ (long long)getNowTimestampSec
{
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970];
    NSInteger Timestamp = a;
    return (int)Timestamp;
}

// 获取当前时间的时间戳字符串(秒)
+ (NSString *)getNowTimestampString
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    
    NSTimeInterval time = [self getNowTimestampSec];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:time];
    NSString * timeString = [dateFormatter stringFromDate:date];
    return timeString;
}

// 获取时分秒
+ (NSString *)getHMSFormatBySeconds:(int)seconds
{
    NSString *hour = [NSString stringWithFormat:@"%02d",seconds/3600];
    NSString *minute = [NSString stringWithFormat:@"%02d",(seconds%3600)/60];
    NSString *second = [NSString stringWithFormat:@"%02d",seconds%60];
    NSString *hmsFormat = [NSString stringWithFormat:@"%@:%@:%@",hour,minute,second];
    return hmsFormat;
}

#pragma mark - 文件、路劲
// doc路径
+ ( NSString *)getDocDir
{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    return documentPath;
}

// 获取视频文件夹路径
+ (NSString *)getVideoDir
{
    NSString *docDir = [self getDocDir];
    NSString *videoDir = [docDir stringByAppendingPathComponent:@"Video"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:videoDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:videoDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return videoDir;
}

// 获取音频文件夹路径
+ (NSString *)getAudioDir
{
    NSString *docDir = [self getDocDir];
    NSString *audioDir = [docDir stringByAppendingPathComponent:@"Audio"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:audioDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:audioDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return audioDir;
}

// 获取音频文件路径
+ (NSString *)getAudioFilePath
{
    NSString *audioDir = [self getAudioDir];
    NSString *filepath = [audioDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",[self getNowTimestampString]]];
    return filepath;
}

// 图片临时路径（用于图像处理）
+ (NSString *)getTempPicDir
{
    NSString *docDir = [self getDocDir];
    NSString *picDir = [docDir stringByAppendingPathComponent:@"TempPic"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:picDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:picDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return picDir;
}

#pragma mark - 产生视频缩略图
+ (UIImage *)getVideoImage:(NSURL *)videoURL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:opts];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(kScreenHeight, kScreenHeight);
    NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(10, 10) actualTime:NULL error:&error];
    UIImage *image = [UIImage imageWithCGImage: img];
    return image;
}

#pragma mark - 权限
// 麦克风权限
+ (BOOL)isAudioRecordPermit
{
    __block BOOL isOK = YES;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                isOK = YES;
            } else {
                isOK = NO;
            }
        }];
    }
    return isOK;
}

// 相册权限
+ (BOOL)isPhotoLibraryPermit
{
    __block BOOL isOK = YES;
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
        isOK = NO;
    }
    return isOK;
}

// 相机权限
+ (BOOL)isCameraPermit
{
    __block BOOL isOK = YES;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
        isOK = NO;
    }
    return isOK;
}

#pragma mark - 创建自定义相册
// 保存图片到自定义相册
+ (void)writeImageToMUKAssetsGroup:(UIImage *)image completion:(void(^)(BOOL isSuccess))completion
{
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status)
            {
                case PHAuthorizationStatusAuthorized://权限打开
                {
                    //获取所有自定义相册
                    PHFetchResult *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
                    //筛选
                    __block PHAssetCollection *simoCollection = nil;
                    __block NSString *collectionID = nil;
                    for (PHAssetCollection *collection in collections)  {
                        if ([collection.localizedTitle isEqualToString:kAssetsGroup]) {
                            simoCollection = collection;
                            break;
                        }
                    }
                    if (!simoCollection) {
                        //创建相册
                        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                            collectionID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:kAssetsGroup].placeholderForCreatedAssetCollection.localIdentifier;
                        } error:nil];
                        //取出
                        simoCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionID] options:nil].firstObject;
                    }
                    //保存图片
                    __block NSString *assetId = nil;
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        assetId = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
                        if (error) {
                            DLog(@"保存橡胶相册失败");
                            if (completion) completion(NO);
                            return ;
                        }
                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:simoCollection];
                            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
                            // 添加图片到相册中
                            [request addAssets:@[asset]];
                            
                        } completionHandler:^(BOOL success, NSError * _Nullable error) {
                            if (error) {
                                DLog(@"保存自定义相册失败");
                            }
                            if (completion) completion(success);
                        }];
                    }];
                    
                    break;
                }
                case PHAuthorizationStatusDenied:
                case PHAuthorizationStatusRestricted:
                {
                    if (oldStatus == PHAuthorizationStatusNotDetermined) {
                        return;
                    }
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                    message:@"请在设置>隐私>相册中开启权限"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"知道了"
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                    break;
                }
                default:
                    break;
            }
        });
    }];
}

// 保存视频到自定义相册
+ (void)writeVideoToMUKAssetsGroup:(NSURL *)videoURL completion:(void(^)(BOOL isSuccess))completion
{
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status)
            {
                case PHAuthorizationStatusAuthorized://权限打开
                {
                    //获取所有自定义相册
                    PHFetchResult *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
                    //筛选
                    __block PHAssetCollection *simoCollection = nil;
                    __block NSString *collectionID = nil;
                    for (PHAssetCollection *collection in collections)  {
                        if ([collection.localizedTitle isEqualToString:kAssetsGroup]) {
                            simoCollection = collection;
                            break;
                        }
                    }
                    if (!simoCollection) {
                        //创建相册
                        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                            collectionID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:kAssetsGroup].placeholderForCreatedAssetCollection.localIdentifier;
                        } error:nil];
                        //取出
                        simoCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionID] options:nil].firstObject;
                    }
                    //保存图片
                    __block NSString *assetId = nil;
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        assetId = [PHAssetCreationRequest creationRequestForAssetFromVideoAtFileURL:videoURL].placeholderForCreatedAsset.localIdentifier;
                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
                        if (error) {
                            DLog(@"视频保存橡胶相册失败");
                            if (completion) completion(NO);
                            return ;
                        }
                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:simoCollection];
                            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
                            // 添加图片到相册中
                            [request addAssets:@[asset]];
                            
                        } completionHandler:^(BOOL success, NSError * _Nullable error) {
                            if (error) {
                                DLog(@"视频保存自定义相册失败");
                            }
                            if (completion) completion(success);
                        }];
                    }];
                    
                    break;
                }
                case PHAuthorizationStatusDenied:
                case PHAuthorizationStatusRestricted:
                {
                    if (oldStatus == PHAuthorizationStatusNotDetermined) {
                        return;
                    }
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                    message:@"请在设置>隐私>相册中开启权限"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"知道了"
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                    break;
                }
                default:
                    break;
            }
        });
    }];
}

#pragma mark - 图片
// 调整图片方向
+ (UIImage *)fixOrientation:(UIImage *)aImage
{
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    //我们需要计算出适当的变换使图像直立。
    //我们在2个步骤：如果左/右/下就旋转，如果镜像就翻转。
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end

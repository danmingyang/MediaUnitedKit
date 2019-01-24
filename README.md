# MediaUnitedKit

**MediaUnitedKit 集成：**

1、图像、视频采集<支持对焦、双击缩放镜头、前后置摄像头切换、闪光灯设置以及屏幕旋转>；

2、自定义相册的创建及视频、图片保存到自定义相册；

3、图片编辑<支持不规则裁剪、旋转、加框、黑白、撤销>；

4、图片选择器；

5、音频的录制、播放<支持本地和网络音频播放>。

![Screenshot](https://github.com/ChellyLau/MediaUnitedKit/blob/master/Screenshot/screenshot.gif)
![Screenshot](https://github.com/ChellyLau/MediaUnitedKit/blob/master/Screenshot/editor.png)
![Screenshot](https://github.com/ChellyLau/MediaUnitedKit/blob/master/Screenshot/gallery.png)

## 代码结构

![Screenshot](https://github.com/ChellyLau/MediaUnitedKit/blob/master/Screenshot/framework.png)

### 音频

`MMAudioUtil`集成了音频的录制和播放，使用`AVFoundation`框架。音频录制使用的是`AVAudioRecorder`。音频播放其实可以使用`AVAudioPlayer` ，但是网络音频的播放需要先将音频下载到本地，然后通过本地路径播放。所以这里使用的是`AVPlayer`，支持本地和网络路径。

使用方式也比较简单：

```objc
NSURL *mp3URL = [NSURL fileURLWithPath:@"本地路径"];
NSURL *mp3URL = [NSURL URLWithString:@"网络路径"];
// 播放器
AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:mp3URL];
AVPlayer *audioPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
[audioPlayer play];
```

### 视频

`MediaCaptureController`同样使用`AVFoundation`框架。拍照和录制视频自由切换，支持对焦、双击缩放镜头、前后置摄像头切换、闪光灯设置以及支持屏幕旋转。采集的视频和图片通过代理回传，通过key值`UIImagePickerControllerMediaURL`获取视频路径，key值`UIImagePickerControllerOriginalImage`获取图片。

```objc
//代理
- (void)mediaCaptureController:(UIViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
```

### 图片编辑

**1、裁剪**

`MMImageClipper`实现图片的不规则裁剪，参考：[链接](https://github.com/jberlana/JBCroppableView)。

**2、旋转**

旋转就是每次旋转90度，这里需要注意一点是，需要把角度转化成弧度：

```
// 由角度转换弧度
#define kDegreesToRadian(x)         (M_PI * (x) / 180.0)
```

具体代码实现：

```
- (UIImage *)imageRotatedByRadians:(CGFloat)radians
{
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(radians);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    CGContextRotateCTM(bitmap, radians);
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
```

**3、加框**

这个就是图片合成了，需要注意的是图片的形状是各种各样的，所以要针对所编辑图片的size对边框图片做拉伸处理，为防止边框变形，要选非边框位置的某一像素点拉伸，具体试下入下：


```
- (UIImage *)imageAddBorderByIndex:(NSInteger)index
{
    // 边框图片
    UIImage *borderImage = [UIImage imageNamed:[NSString stringWithFormat:@"border_%ld",(long)index]];
    // 对中间点像素拉伸
    borderImage = [borderImage stretchableImageWithLeftCapWidth:floorf(borderImage.size.width/2) topCapHeight:floorf(borderImage.size.height/2)];
    // 合成
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    [borderImage drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    // 刨去边框的宽度
    CGFloat margin  = 40;
    [self drawInRect:CGRectMake(margin, margin, self.size.width-2*margin, self.size.height-2*margin)];
    // 输出
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}
```

**4、黑白**

使用开源框架：[GPUImage](https://github.com/BradLarson/GPUImage)。使用方式详见`UIImage+Category`类下的`sketchImage`方法。

```
- (UIImage *)sketchImage
{
    UIImage *image = [Utility fixOrientation:self];
    GPUImageSketchFilter *filter = [[GPUImageSketchFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    [pic processImage];
    [filter useNextFrameForImageCapture];
    UIImage *outImage = [filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    return outImage;
}
```

**5、撤销**

使用数据库存储，数据ID可代表顺序。

### 图库

自定义的图片选择器[MMPhotoPicker](https://github.com/ChellyLau/MMPhotoPicker)，使用`Photos`框架，同时集成了图片的预览和固定形状的裁剪。

## 后记

不定时更新，如有问题欢迎给我[留言](https://github.com/ChellyLau/MediaUnitedKit/issues)，我会及时回复。如果这个工具对你有一些帮助，请给我一个star，谢谢。


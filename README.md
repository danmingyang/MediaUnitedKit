# MediaUnitedKit

MediaUnitedKit集成了自定义【视频+图像】采集、【视频+图片】保存到自定义相册、图片编辑【不规则裁剪、旋转、加框、黑白、撤销】、自定义图片选择器、音频的录制+播放【支持本地和网络音频播放】。

![Screenshot](https://github.com/CheeryLau/MediaUnitedKit/blob/master/Screenshot/capture.png)
![Screenshot](https://github.com/CheeryLau/MediaUnitedKit/blob/master/Screenshot/editor.png)
![Screenshot](https://github.com/CheeryLau/MediaUnitedKit/blob/master/Screenshot/audio.png)
![Screenshot](https://github.com/CheeryLau/MediaUnitedKit/blob/master/Screenshot/gallery.png)

## 代码结构
![Screenshot](https://github.com/CheeryLau/MediaUnitedKit/blob/master/Screenshot/framework.png)

其实通过类名就可以一目了然，在这里简述一下，具体可以去看代码。

### 音频
`MMAudioUtil`集成了音频的录制和播放，使用`AVFoundation`框架。音频录制使用的是`AVAudioRecorder`。音频播放可以使用`AVAudioPlayer` ，但是网络音频的播放需要先将音频下载到本地，然后通过本地路径播放。所以这里使用的是`AVPlayer`，支持本地和网络路径。

使用方式就比较简单了：

```objc
NSURL *mp3URL = [NSURL fileURLWithPath:@"本地路径"];
NSURL *mp3URL = [NSURL URLWithString:@"网络路径"];
//播放器
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

视频的播放，GitHub上有很多，我在本项目中添加了[WMPlayer](https://github.com/zhengwenming/WMPlayer)，大家可以看一下。

### 图片编辑

1、裁剪

`MMImageClipper`实现图片的不规则裁剪，我参考的是在code4app下载的，GitHub上的貌似更好一些：[链接](https://github.com/jberlana/JBCroppableView)。

2、旋转

旋转就是每次旋转90度，这里需要注意一点是，需要把角度转化成弧度：

```
//由角度转换弧度
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

3、加框

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

4、黑白

使用强大的框架：[GPUImage](https://github.com/BradLarson/GPUImage)。使用方式详见`UIImage+Category`类下的`sketchImage`方法。

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

5、撤销

使用数据库存储，数据ID可代表顺序。

### 图库

自定义的图片选择器[MMPhotoPicker](https://github.com/CheeryLau/MMPhotoPicker)，使用`Photos`框架，同时集成了图片的预览和固定形状的裁剪。

## 后记

如有问题，欢迎给我[留言](https://github.com/CheeryLau/MediaUnitedKit/issues)，如果这个工具对你有些帮助，请给我一个star。O(∩_∩)O谢谢

💡 💡 💡 
欢迎访问我的[主页](https://github.com/CheeryLau)，希望以下工具也会对你有帮助。

1、类似滴滴出行侧滑抽屉效果：[MMSideslipDrawer](https://github.com/CheeryLau/MMSideslipDrawer)

2、基础组合动画：[CAAnimationUtil](https://github.com/CheeryLau/CAAnimationUtil)

3、图片选择器基于AssetsLibrary框架：[MMImagePicker](https://github.com/CheeryLau/MMImagePicker)

4、图片选择器基于Photos框架：[MMPhotoPicker](https://github.com/CheeryLau/MMPhotoPicker)

5、webView支持顶部进度条和侧滑返回:[MMWebView](https://github.com/CheeryLau/MMWebView)

6、多功能滑动菜单控件：[MenuComponent](https://github.com/CheeryLau/MenuComponent)

7、仿微信朋友圈：[MomentKit](https://github.com/CheeryLau/MomentKit)

8、图片验证码：[MMCaptchaView](https://github.com/CheeryLau/MMCaptchaView)

9、源生二维码扫描与制作：[MMScanner](https://github.com/CheeryLau/MMScanner)

10、简化UIButton文字和图片对齐：[UUButton](https://github.com/CheeryLau/UUButton)


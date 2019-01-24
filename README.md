# MediaUnitedKit

**MediaUnitedKit 集成：**

1、图像、视频采集<支持对焦、双击缩放镜头、前后置摄像头切换、闪光灯设置以及屏幕旋转>；

2、自定义相册的创建及视频、图片保存到自定义相册；

3、图片编辑<支持不规则裁剪、旋转、加框、黑白、撤销>；

4、图片选择器；

5、音频的录制、播放<支持本地和网络音频播放>。

![Screenshot](https://github.com/ChellyLau/MediaUnitedKit/blob/master/Screenshot/screenshot_0.png)
![Screenshot](https://github.com/ChellyLau/MediaUnitedKit/blob/master/Screenshot/screenshot_1.png)
![Screenshot](https://github.com/ChellyLau/MediaUnitedKit/blob/master/Screenshot/screenshot_2.png)

## 代码结构

![Screenshot](https://github.com/ChellyLau/MediaUnitedKit/blob/master/Screenshot/screenshot_3.png)

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

`MediaCaptureController`采用`AVFoundation`框架，拍照和录制视频自由切换。支持对焦、双击缩放镜头、前后置摄像头切换、闪光灯设置以及支持屏幕旋转。采集的视频和图片通过代理回传，通过key值`UIImagePickerControllerMediaURL`获取视频路径，key值`UIImagePickerControllerOriginalImage`获取图片。

```objc
//代理
- (void)mediaCaptureController:(UIViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
```

### 图片编辑


**裁剪：** `MMImageClipper`实现图片的不规则裁剪，参考[链接](https://github.com/jberlana/JBCroppableView)。

**旋转：** 旋转就是每次旋转90度，每旋转一次存储一张图片和一个标记Model。

**加框：** 即图片合成，需要注意的是图片的形状是各种各样的，所以要针对所编辑图片的size对边框图片做拉伸处理，为防止边框变形，要选非边框位置的某一像素点拉伸。

**黑白：** 使用开源框架：[GPUImage](https://github.com/BradLarson/GPUImage)。

**撤销：** 使用数据库存储，数据ID代表顺序，没撤销一次删除一个标记和一张图片。


### 图库

自定义的图片选择器[MMPhotoPicker](https://github.com/ChellyLau/MMPhotoPicker)，使用`Photos`框架，同时集成了图片的预览和固定形状的裁剪。

## 后记

不定时更新，如有问题欢迎给我[留言](https://github.com/ChellyLau/MediaUnitedKit/issues)，我会及时回复。如果这个工具对你有一些帮助，请给我一个star，谢谢。


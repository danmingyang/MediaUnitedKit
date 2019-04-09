//
//  EditorViewController.m
//  MediaUnitedKit
//
//  Created by LEA on 2017/9/21.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "EditorViewController.h"
#import "MMEditView.h"
#import "MMTabBar.h"
#import "MMBorderView.h"
#import "MMImageClipper.h"
#import "PhotoModel.h"

@interface EditorViewController ()<MMTabBarDelegate,MMEditViewDelegate,MMBorderViewDelegate>

@property (nonatomic, strong) UIImageView * imageView; // 当前编辑图片
@property (nonatomic, strong) MMTabBar * tabBar; // 底部菜单
@property (nonatomic, strong) MMEditView * editView; // 编辑菜单
@property (nonatomic, strong) MMBorderView * borderView; // 边框选择视图
@property (nonatomic, strong) MMImageClipper * clipView; // 图片裁剪
@property (nonatomic, strong) PhotoModel * photoModel; // 编辑的model
@property (nonatomic, strong) UIImage * originImage; // 未编辑之前图片
@property (nonatomic, strong) UIImage * editImage; // 最后一次编辑后的图片
@property (nonatomic, assign) NSInteger editIndex; // 记录编辑的索引
@property (nonatomic, assign) BOOL isSketch; // 黑白化

@end

@implementation EditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"图片编辑";
    self.view.backgroundColor = RGBColor(70, 70, 70, 1.0);

    self.originImage = [UIImage imageNamed:@"MUK"];
    self.editImage = [UIImage imageNamed:@"MUK"];
    self.imageView.image = self.editImage;
    
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.tabBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 禁止侧滑
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

#pragma mark - 清空图片
- (void)clearTempPic
{
    // 清空编辑的图片和Model
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [PhotoModel clearTable];
        NSFileManager * manager = [NSFileManager defaultManager];
        NSString * filePath = [Utility getTempPicDir];
        if ([manager fileExistsAtPath:filePath]) {
            [manager removeItemAtPath:filePath error:nil];
        }
    });
}

- (void)saveTempPic
{
    // 保存文件
    NSString * fileName = [NSString stringWithFormat:@"%@.jpg",[Utility getNowTimestampString]];
    NSString * filePath = [[Utility getTempPicDir] stringByAppendingPathComponent:fileName];
    NSData * fileData = UIImageJPEGRepresentation(self.editImage, 0.5);
    BOOL isOK = [fileData writeToFile:filePath atomically:NO];
    if (isOK) {
        // 创建Model
        _photoModel = [[PhotoModel alloc] init];
        _photoModel.isSketch = self.isSketch;
        _photoModel.fileName = fileName;
        [_photoModel save];
        // 显示
        self.imageView.image = self.editImage;
    }
}

#pragma mark - 横向视图
- (void)tabBar:(MMTabBar *)tabBar didSelectAtIndex:(NSInteger)index
{
    _editIndex = index;
    switch (index)
    {
        case 0: // 裁剪
        {
            self.title = @"裁剪";
            self.editView.midImage = [UIImage imageNamed:@"pic_cut"];
            [self showCutEditView];
            break;
        }
        case 1: // 旋转
        {
            self.editImage =  [self.imageView.image rotateImage];
            self.isSketch = _photoModel.isSketch;
            [self saveTempPic];
            break;
        }
        case 2:// 加框
        {
            self.title = @"加框";
            self.editView.midImage = [UIImage imageNamed:@"pic_border"];
            [self showBorderEditView];
            break;
        }
        case 3: // 黑白化
        {
            if (_photoModel.isSketch) {
                return;
            }
            self.editImage =  [self.imageView.image sketchImage];
            self.isSketch = YES;
            [self saveTempPic];
            break;
        }
        case 4: // 撤销
        {
            NSString * sql = [NSString stringWithFormat:@"WHERE PK < %d ORDER BY PK DESC LIMIT 1",_photoModel.pk];
            PhotoModel * model = [PhotoModel findFirstByCriteria:sql];
            if (model) {
                // 移除文件
                NSFileManager * manager = [NSFileManager defaultManager];
                NSString * filePath = [[Utility getTempPicDir] stringByAppendingPathComponent:_photoModel.fileName];
                if ([manager fileExistsAtPath:filePath]) {
                    [manager removeItemAtPath:filePath error:nil];
                }
                // 移除实体
                [_photoModel deleteObject];
                // 重新复制
                _photoModel = model;
                filePath = [[Utility getTempPicDir] stringByAppendingPathComponent:_photoModel.fileName];
                self.editImage = [UIImage imageWithContentsOfFile:filePath];
                self.imageView.image = self.editImage;
            } else {
                [self clearTempPic];
                _photoModel = nil;
                self.editImage = self.originImage;
                self.imageView.image = self.originImage;
            }
            break;
        }
        default:
            break;
    }
}


#pragma mark - 图片编辑
// 裁剪
- (void)showCutEditView
{
    // 加载视图
    self.editView.top = kScreenHeight;
    [self.view addSubview:self.editView];
    // 动画
    [UIView animateWithDuration:0.3 animations:^{
        self.tabBar.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kTabHeight);
        self.editView.frame = CGRectMake(0, kScreenHeight-kTopHeight-kTabHeight, kScreenWidth, kTabHeight);
        CGSize toSize = CGSizeMake(kScreenWidth-50, kScreenHeight-kTopHeight-kTabHeight-50);
        CGSize scaledSize = [MMImageClipper scaleAspectFromSize:self.imageView.image.size toSize:toSize];
        self.imageView.frame = CGRectMake((kScreenWidth-scaledSize.width)/2, (kScreenHeight-kTopHeight-kTabHeight-scaledSize.height)/2, scaledSize.width, scaledSize.height);
    } completion:^(BOOL finished) {
        CGFloat margin = 20;
        self.clipView = [[MMImageClipper alloc] initWithFrame:CGRectMake(self.imageView.left-margin, self.imageView.top-margin, self.imageView.width+2*margin, self.imageView.height+2*margin)];
        self.clipView.margin = margin;
        self.clipView.pointNumber = 4;
        [self.view addSubview:self.clipView];
    }];
}

// 加框
- (void)showBorderEditView
{
    // 加载视图
    self.borderView.top = kScreenHeight;
    self.editView.top = kScreenHeight+100;
    [self.view addSubview:self.editView];
    [self.view addSubview:self.borderView];
    // 动画
    [UIView animateWithDuration:0.3 animations:^{
        self.tabBar.top = kScreenHeight;
        self.editView.top = kScreenHeight-kTopHeight-kTabHeight;
        self.borderView.top = self.editView.top-100;
        CGSize toSize = CGSizeMake(kScreenWidth, kScreenHeight-kTopHeight-kTabHeight-150);
        CGSize scaledSize = [MMImageClipper scaleAspectFromSize:self.imageView.image.size toSize:toSize];
        self.imageView.frame = CGRectMake((kScreenWidth-scaledSize.width)/2, (kScreenHeight-kTopHeight-kTabHeight-100-scaledSize.height)/2, scaledSize.width, scaledSize.height);
    }];
}

#pragma mark - MMEditViewDelegate
- (void)editView:(MMEditView *)tabBar operateType:(OperateType)type
{
    if (_editIndex == 0) { // 裁剪
        if (type == kOperateTypeFinish) {
            self.editImage = [self.clipView getClippedImage:self.imageView];
            self.isSketch = _photoModel.isSketch;
            [self saveTempPic];
        }
        [self.clipView removeFromSuperview];
        [UIView animateWithDuration:0.3 animations:^{
            self.tabBar.frame = CGRectMake(0, kScreenHeight-kTopHeight-kTabHeight, kScreenWidth, kTabHeight);
            self.imageView.frame = CGRectMake(20, 25, kScreenWidth-40, kScreenHeight-kTopHeight-kTabHeight-50);
            self.editView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kTabHeight);
        } completion:^(BOOL finished) {
            [self.editView removeFromSuperview];
            self.title = @"图片编辑";
        }];
    } else { // 加框
        if (type == kOperateTypeFinish) {
            self.editImage = self.imageView.image;
            self.isSketch = NO;
            [self saveTempPic];
        } else {
            self.imageView.image = self.editImage;
        }
        [UIView animateWithDuration:0.3 animations:^{
            self.imageView.frame = CGRectMake(20, 25, kScreenWidth-40, kScreenHeight-kTopHeight-kTabHeight-50);
            self.tabBar.top = kScreenHeight-kTopHeight-kTabHeight;
            self.borderView.top = kScreenHeight;
            self.editView.top = kScreenHeight+100;
        } completion:^(BOOL finished) {
            [self.borderView removeFromSuperview];
            [self.editView removeFromSuperview];
            self.title = @"图片编辑";
        }];
    }
}

#pragma mark - MMBorderViewDelegate
- (void)didSelectBorderAtIndex:(NSInteger)index
{
    self.imageView.image = [self.editImage imageAddBorderByIndex:index];
}

#pragma mark - 视图区
- (MMTabBar *)tabBar
{
    if (!_tabBar) {
        NSArray *images = @[[UIImage imageNamed:@"pic_cut"],[UIImage imageNamed:@"pic_rotate"],[UIImage imageNamed:@"pic_border"],[UIImage imageNamed:@"pic_sketch"],[UIImage imageNamed:@"pic_revoke"]];
        NSArray *selectedImages = @[[UIImage imageNamed:@"pic_cut_h"],[UIImage imageNamed:@"pic_rotate_h"],[UIImage imageNamed:@"pic_border_h"],[UIImage imageNamed:@"pic_sketch_h"],[UIImage imageNamed:@"pic_revoke_h"]];
        _tabBar = [[MMTabBar alloc] initWithFrame:CGRectMake(0, kScreenHeight-kTopHeight-kTabHeight, kScreenWidth, kTabHeight)
                                           titles:@[@"裁剪",@"旋转",@"边框",@"黑白",@"撤销"]
                                           images:images
                                     selectdColor:kUnitMainColor
                                   selectedImages:selectedImages];
        _tabBar.delegate = self;
    }
    return _tabBar;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 25, kScreenWidth-40, kScreenHeight-kTopHeight-kTabHeight-50)];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.contentScaleFactor = [[UIScreen mainScreen] scale];
    }
    return _imageView;
}

- (MMEditView *)editView
{
    if (!_editView) {
        _editView = [[MMEditView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kTabHeight)];
        _editView.midImage = [UIImage imageNamed:@"pic_cut"];
        _editView.delegate = self;
    }
    return _editView;
}

- (MMBorderView *)borderView
{
    if (!_borderView) {
        _borderView = [[MMBorderView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 100)];
        _borderView.delegate = self;
    }
    return _borderView;
}

#pragma mark - 
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self clearTempPic];
}

@end

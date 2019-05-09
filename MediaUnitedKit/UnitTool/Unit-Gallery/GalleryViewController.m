//
//  GalleryViewController.m
//  MediaUnitedKit
//
//  Created by LEA on 2017/9/22.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "GalleryViewController.h"
#import <MMPhotoPickerController.h>
#import <UIView+Geometry.h>

static NSString *const CellIdentifier = @"GalleryCell";
@interface GalleryViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,MMPhotoPickerDelegate>

@property (nonatomic,strong) UICollectionView * collectionView;
@property (nonatomic,strong) NSMutableArray * infoArray;

@end

@implementation GalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"图片选择器";
    self.view.backgroundColor = [UIColor whiteColor];
    // 选择图片
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake((self.view.width-100)/2, 50, 100, 44)];
    button.backgroundColor = [UIColor lightGrayColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"选择图片" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    // 图片显示
    self.infoArray = [[NSMutableArray alloc] init];
    [self.view addSubview:self.collectionView];
}

#pragma mark - lazy load
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        NSInteger numInLine = (kIPhone6p || kIPhoneXM) ? 5 : 4;
        CGFloat itemWidth = (self.view.width - (numInLine + 1) * kMargin) / numInLine;
        
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
        flowLayout.sectionInset = UIEdgeInsetsMake(kMargin, kMargin, kMargin, kMargin);
        flowLayout.minimumLineSpacing = kMargin;
        flowLayout.minimumInteritemSpacing = 0.f;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 150, self.view.width, self.view.height - kTopHeight - 150) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = YES;
        [_collectionView registerClass:[GalleryCell class] forCellWithReuseIdentifier:CellIdentifier];
    }
    return _collectionView;
}

#pragma mark - 选择图片
- (void)btClicked
{
    // 优先级 cropOption > singleOption > maxNumber
    // cropOption = YES 时，不显示视频
    MMPhotoPickerController * controller = [[MMPhotoPickerController alloc] init];
    controller.delegate = self;
    controller.showEmptyAlbum = YES;
    controller.showVideo = YES;
    controller.cropOption = NO;
    controller.singleOption = NO;
    controller.maxNumber = 6;
    controller.mainColor = kUnitMainColor;
    controller.markedImgName = @"gallery_marked";
    controller.maskImgName = @"gallery_overlay";

    BaseNavigationController * navigation = [[BaseNavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:navigation animated:YES completion:nil];
}

#pragma mark - MMPhotoPickerDelegate
- (void)mmPhotoPickerController:(MMPhotoPickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self.infoArray removeAllObjects];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 图片压缩一下，不然大图显示太慢
        for (int i = 0; i < [info count]; i ++)
        {
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:[info objectAtIndex:i]];
            UIImage * image = [dict objectForKey:MMPhotoOriginalImage];
            if (!picker.isOrigin) { // 原图
                NSData * imageData = UIImageJPEGRepresentation(image,1.0);
                int size = (int)[imageData length]/1024;
                if (size < 100) {
                    imageData = UIImageJPEGRepresentation(image, 0.5);
                } else {
                    imageData = UIImageJPEGRepresentation(image, 0.1);
                }
                image = [UIImage imageWithData:imageData];
            }
            [dict setObject:image forKey:MMPhotoOriginalImage];
            [self.infoArray addObject:dict];
        }
        
        GCD_MAIN(^{ // 主线程
            [self.collectionView reloadData];
            [picker dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

- (void)mmPhotoPickerControllerDidCancel:(MMPhotoPickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.infoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 赋值
    GalleryCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.info = [self.infoArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

#pragma mark - #################### GalleryCell
@interface GalleryCell ()

@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UIImageView * videoOverLay;

@end

@implementation GalleryCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.layer.masksToBounds = YES;
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.contentScaleFactor = [[UIScreen mainScreen] scale];
        [self addSubview:_imageView];
        
        _videoOverLay = [[UIImageView alloc] init];
        _videoOverLay.size = CGSizeMake(_imageView.width * 0.4, _imageView.height * 0.4);
        _videoOverLay.center = _imageView.center;
        _videoOverLay.image = [UIImage imageNamed:@"mmphoto_video"];
        [self addSubview:_videoOverLay];
        _videoOverLay.hidden = YES;
    }
    return self;
}

#pragma mark - setter
- (void)setInfo:(NSDictionary *)info
{
    PHAssetMediaType mediaType = [[info objectForKey:MMPhotoMediaType] integerValue];
    if (mediaType == PHAssetMediaTypeVideo) {
        self.videoOverLay.hidden = NO;
    } else {
        self.videoOverLay.hidden = YES;
    }
    self.imageView.image = [info objectForKey:MMPhotoOriginalImage];
}

@end

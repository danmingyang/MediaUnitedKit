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
@property (nonatomic,strong) NSMutableArray * imageArray;

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
    self.imageArray = [[NSMutableArray alloc] init];
    [self.view addSubview:self.collectionView];
}

#pragma mark - lazy load
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 150, self.view.width, self.view.height-kTopHeight-150) collectionViewLayout:flowLayout];
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
    MMPhotoPickerController * controller = [[MMPhotoPickerController alloc] init];
    controller.delegate = self;
    controller.mainColor = kUnitMainColor;
    controller.showEmptyAlbum = YES;
    controller.showOriginImageOption = YES;
    controller.maximumNumberOfImage = 9;
//    controller.cropImageOption = YES;
//    controller.singleImageOption = YES;
    BaseNavigationController * navigation = [[BaseNavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:navigation animated:YES completion:nil];
}

#pragma mark - 代理
- (void)mmPhotoPickerController:(MMPhotoPickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self.imageArray removeAllObjects];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < [info count]; i ++)
        {
            NSDictionary *dict = [info objectAtIndex:i];
            UIImage * image = [dict objectForKey:MMPhotoOriginalImage];
            NSData * imageData = UIImageJPEGRepresentation(image,1.0);
            int size = (int)[imageData length]/1024;
            if (size < 100) {
                imageData = UIImageJPEGRepresentation(image, 0.5);
            } else {
                imageData = UIImageJPEGRepresentation(image, 0.1);
            }
            [self.imageArray addObject:[UIImage imageWithData:imageData]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            [picker dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

- (void)mmPhotoPickerControllerDidCancel:(MMPhotoPickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSInteger eachLine = 4;
    if (kIPhone6p || kIPhoneXM) {
        eachLine = 5;
    }
    CGFloat cellWidth = (self.view.width-(eachLine+1)*kMargin)/eachLine;
    return CGSizeMake(cellWidth, cellWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kMargin, kMargin, kMargin, kMargin);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kMargin;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 赋值
    GalleryCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.image = [self.imageArray objectAtIndex:indexPath.row];
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

@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation GalleryCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
    }
    return self;
}

#pragma mark - lazy load
- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.layer.masksToBounds = YES;
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.contentScaleFactor = [[UIScreen mainScreen] scale];
    }
    return _imageView;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
}

@end

//
//  GalleryViewController.h
//  MediaUnitedKit
//
//  Created by LEA on 2017/9/22.
//  Copyright © 2017年 LEA. All rights reserved.
//
//  图库>图片选择
//

#import <UIKit/UIKit.h>

@interface GalleryViewController : UIViewController

@end


@interface GalleryCell : UICollectionViewCell

@property (nonatomic, strong) NSDictionary * info;

@end

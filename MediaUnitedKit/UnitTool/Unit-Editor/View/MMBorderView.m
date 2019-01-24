//
//  MMBorderView.m
//  MediaUnitedKit
//
//  Created by LEA on 2017/9/21.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "MMBorderView.h"

#define kBorderHeight       90
#define kBorderWidth        75
#define kBorderMargin       5

@implementation MMBorderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        
        CGFloat height = 90;
        CGFloat width = 75;
        CGFloat magin = 5;
        
        // 滚动视图
        UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.userInteractionEnabled = YES;
        scrollView.contentSize = CGSizeMake((width + magin) * 7, 0);
        [self addSubview:scrollView];
        // 边框小图
        for (int i = 0; i < 7; i ++) {
            CGRect rect = CGRectMake(magin + (width + magin) * i, magin, width, height);
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:rect];
            imageView.tag = 100 + i;
            imageView.userInteractionEnabled = YES;
            imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"border_h_%d",i]];
            [scrollView addSubview:imageView];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapp:)];
            [imageView addGestureRecognizer:tap];
        }
    }
    return self;
}

#pragma mark - 点击
- (void)tapp:(UITapGestureRecognizer *)tap
{
    UIImageView *imageView = (UIImageView *)[tap view];
    NSInteger index = imageView.tag - 100;
    if ([self.delegate respondsToSelector:@selector(didSelectBorderAtIndex:)]) {
        [self.delegate didSelectBorderAtIndex:index];
    }
}

@end

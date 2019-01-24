//
//  MMBorderView.h
//  MediaUnitedKit
//
//  Created by LEA on 2017/9/21.
//  Copyright © 2017年 LEA. All rights reserved.
//
//  图片加框
//

#import <UIKit/UIKit.h>

@protocol MMBorderViewDelegate;
@interface MMBorderView : UIView

@property (nonatomic,assign) id<MMBorderViewDelegate> delegate;

@end

@protocol MMBorderViewDelegate <NSObject>

@optional
- (void)didSelectBorderAtIndex:(NSInteger)index;

@end

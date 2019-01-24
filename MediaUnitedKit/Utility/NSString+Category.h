//
//  NSString+Category.h
//  MediaUnitedKit
//
//  Created by LEA on 2017/9/21.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Category)

// 计算文本占用的宽高
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;

@end

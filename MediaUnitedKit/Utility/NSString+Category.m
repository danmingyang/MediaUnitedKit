//
//  NSString+Category.m
//  MediaUnitedKit
//
//  Created by LEA on 2017/9/21.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "NSString+Category.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSString (Category)

// 计算文本占用的宽高
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary * attributes = @{NSFontAttributeName:font};
    CGSize size = [self boundingRectWithSize:maxSize
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attributes
                                     context:nil].size;
    return size;
}

@end

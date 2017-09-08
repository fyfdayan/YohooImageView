//
//  ImageBlurUtils.h
//  Pods
//
//  Created by 傅雁锋 on 2017/8/3.
//
//

#import <Foundation/Foundation.h>

@interface ImageBlurUtils : NSObject
+ (UIImage *)applyBlurRadius:(CGFloat)radius toImage:(UIImage *)image;
@end

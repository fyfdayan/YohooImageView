//
//  ImageBlurUtils.m
//  Pods
//
//  Created by 傅雁锋 on 2017/8/3.
//
//

#import "ImageBlurUtils.h"

@implementation ImageBlurUtils

//给Image增加
+ (UIImage *)applyBlurRadius:(CGFloat)radius toImage:(UIImage *)image {
    if (radius < 0) {
        radius = 0;
    }
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    
    // Setting up gaussian blur
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    
    [filter setValue:inputImage forKey:kCIInputImageKey];
    
    [filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return returnImage;
}

@end

//
//  EGOSDWebImageView.m
//  CompanyPlus
//
//  Created by 傅雁锋 on 15/9/28.
//  Copyright (c) 2015年 厦门象形远教网络科技有限公司. All rights reserved.
//

#import "EGOSDWebImageView.h"
#import <Masonry/Masonry.h>
#import "UIImageView+WebCache.h"

#import "UIImageView+PlayGIF.h"
#import "UIImage+GIF.h"
#import "ImageBlurUtils.h"

@interface EGOSDWebImageView() {
    
@private
    UIButton *clickBtn;
    UIImageView *placeholderImageView;
    
    CGRect oldFrame;
    CGSize imageSize;
    
    UILabel *gifLabel;
    
    UIImage *_placeholderImage;
    UIImage *originImage;
}

@end

@implementation EGOSDWebImageView
@synthesize imageView;

- (id)initWithFrame:(CGRect)frame {
//    self = [ViewUtils loadViewWithViewClass:[EGOSDWebImageView class]];
    self = [super initWithFrame:frame];
    if (self) {
        [self initComponents];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initComponents];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self checkComponentFrame];
}

- (void)checkComponentFrame {
    self.clipsToBounds = true;
    if (oldFrame.size.width != self.frame.size.width || oldFrame.size.height != self.frame.size.height) {
        //        placeholderImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        //        imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        CGFloat x = (self.frame.size.width-placeholderImageView.frame.size.width)/2;
        CGFloat y = (self.frame.size.height-placeholderImageView.frame.size.height)/2;
        placeholderImageView.frame = CGRectMake(x, y, placeholderImageView.frame.size.width, placeholderImageView.frame.size.height);
        
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;
        clickBtn.frame = CGRectMake(clickBtn.frame.origin.x, clickBtn.frame.origin.y, width, height);
        
        [self changeFrame];
    }
    
    [self changePlaceholderImageViewFrame];
}

//给Image增加
- (UIImage *)applyBlurRadius:(CGFloat)radius toImage:(UIImage *)image {
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

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    clickBtn.frame = CGRectMake(clickBtn.frame.origin.x, clickBtn.frame.origin.y, frame.size.width, frame.size.height);
}

- (void)changeBlurRadius:(int)blurRadius image:(UIImage *)image {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        UIImage *image = [[UIImage alloc]initWithData:data];
        UIImage *_image = [ImageBlurUtils applyBlurRadius:blurRadius toImage:image];
        if (_image != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = _image;
            });
        }  
    });
}

- (void)changeBlurRadius:(int)blurRadius {
    UIImage *image = [self applyBlurRadius:blurRadius toImage:originImage];
    imageView.image = image;
}

- (void)setImage:(UIImage *)image {
    
    placeholderImageView.hidden = true;
    originImage = image;
    
    if (self.needBlur) {
        [self changeBlurRadius:_blurRadius image:image];
    }
    
    imageView.image = image;
    imageSize = image.size;
    [self changeFrame];
}

- (void)initComponents {
    self.clipsToBounds = true;
    oldFrame = self.frame;
    _blurRadius = 3;
    placeholderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
//    [self addSubview:placeholderImageView];
    [self insertSubview:placeholderImageView atIndex:0];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    clickBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    clickBtn.hidden = true;
//    [self addSubview:imageView];
    [self insertSubview:imageView atIndex:1];
    [self insertSubview:clickBtn atIndex:2];
    
    self.alignType = Align_Center;
}

- (void)loadImage:(NSString *)url loadingImageSize:(CGSize)size loadingImage:(UIImage *)loadingImage {
    placeholderImageView.hidden = false;
    placeholderImageView.image = loadingImage;

    placeholderImageView.frame = CGRectMake((self.frame.size.width-size.width)/2, (self.frame.size.height-size.height)/2, size.width, size.height);
    
    [self realLoadImage:url withPlaceholderImage:loadingImage withSize:size];
}

- (void)loadImage:(NSString *)url withPlaceholderImage:(UIImage *)placeholderImage {
    [self loadImage:url withPlaceholderImage:placeholderImage withSize:self.frame.size];
}

- (void)loadImage:(NSString *)url withPlaceholderImage:(UIImage *)placeholderImage withSize:(CGSize)size {
    [self loadImage:url withPlaceholderImage:placeholderImage withSize:size withType:self.alignType];
}

- (void)setGifPath:(NSString *)gifPath {
    _gifPath = gifPath;
    placeholderImageView.hidden = true;
    imageView.gifPath = gifPath;
}

- (void)startGIF {
    imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [imageView startGIF];
}

- (void)stopGIF {
    [imageView stopGIF];
}

- (void)changePlaceholderImageViewFrame {
    if (_placeholderImage == nil) {
        return;
    }
    
    CGRect frame = placeholderImageView.frame;
    frame.size = _placeholderImage.size;
    if (self.loadingImageFrameEqualParent) {
        frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    } else if (!self.loadingImageNeedFullScreen) {
        frame.origin.x = (self.frame.size.width-frame.size.width)/2;
        frame.origin.y = (self.frame.size.height-frame.size.height)/2;
    } else {
        if (frame.size.width < self.frame.size.width) {
            frame.size.width = self.frame.size.width;
            frame.size.height = (frame.size.width*self.frame.size.height)/self.frame.size.width;
            frame.origin.x = 0;
            frame.origin.y = -(frame.size.height-self.frame.size.height)/2;
        } else {
            frame.size.height = self.frame.size.height;
            frame.size.width = (frame.size.height*self.frame.size.width)/self.frame.size.height;
            
            frame.origin.x = -(frame.size.width-self.frame.size.width)/2;
            frame.origin.y = 0;
        }
    }
    
    placeholderImageView.frame = frame;
}

- (void)loadImage:(NSString *)url withPlaceholderImage:(UIImage *)placeholderImage withSize:(CGSize)size withType:(ImageViewAlignType)type {
    
    placeholderImageView.hidden = false;
    placeholderImageView.image = placeholderImage;
    _placeholderImage = placeholderImage;
    [self checkComponentFrame];
    
    [self realLoadImage:url withPlaceholderImage:placeholderImage withSize:size];
}

- (void)realLoadImage:(NSString *)url withPlaceholderImage:(UIImage *)placeholderImage withSize:(CGSize)size {
    //gif logo添加
    NSURL *realUrl = [NSURL URLWithString:url];
    if ([realUrl.absoluteString hasSuffix:@".gif"] || [realUrl.absoluteString hasSuffix:@".GIF"]) {
        if (gifLabel == nil) {
            gifLabel = [[UILabel alloc] init];
            
//            gifLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-37, self.frame.size.height-19, 36, 18)];
            //        (245, 137, 20)
            
//            [gifLabel setBackgroundColor:CPMainYellowColor];
            if (_gifLabelBackgroundColor != nil) {
                [gifLabel setBackgroundColor:_gifLabelBackgroundColor];
            } else {
                gifLabel.backgroundColor = [UIColor blueColor];
            }
            
            gifLabel.layer.cornerRadius = 5;
            gifLabel.layer.masksToBounds = YES;
            
            [gifLabel setText:@"GIF"];
            [gifLabel setFont:[UIFont systemFontOfSize:14.0]];
            [gifLabel setTextColor:[UIColor whiteColor]];
            
            gifLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:gifLabel];
            [gifLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.mas_right).with.offset(-37);
                make.bottom.mas_equalTo(self.mas_bottom).with.offset(-19);
                make.width.mas_equalTo(36);
                make.height.mas_equalTo(18);
            }];
        }
        
        gifLabel.hidden = false;
    } else {
        gifLabel.hidden = true;
    }
    
    if (self.fullScreenWithScale) {
        CGRect frame = placeholderImageView.frame;
        frame.size = placeholderImage.size;
        
        if (frame.size.width > frame.size.height) {
            float width = (float)((self.frame.size.height*frame.size.width)/frame.size.height);
            
            frame.origin.x = (self.frame.size.width-width)/2;
            frame.origin.y = 0;
            
            frame.size = CGSizeMake(width, self.frame.size.height);
        } else {
            float height = (float)((self.frame.size.width*frame.size.height)/frame.size.width);
            
            frame.origin.x = 0;
            frame.origin.y = (self.frame.size.height-height)/2;
            
            frame.size = CGSizeMake(self.frame.size.width, height);
        }
        
        placeholderImageView.frame = frame;
    }
    
    imageSize = size;
    
    [self changeFrame];
    if ([self isNotEmpty:url]) {
        imageView.hidden = false;

        [imageView sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error == nil) {
                originImage = image;
                
                
                if (self.needBlur) {
//                    image = [self applyBlurRadius:_blurRadius toImage:image];//[image blurredImageWithRadius:20 iterations:3 tintColor:[UIColor whiteColor]];
//                    imageView.image = image;
                    [self changeBlurRadius:_blurRadius image:image];
                } else {
                    imageView.image = image;
                }
                
                if (image != nil) {
                    placeholderImageView.hidden = true;
                }
                
                imageSize = image.size;
                [self changeFrame];
            }
        }];
        //        imageView.imageURL = [NSURL URLWithString:url];
    } else {
        imageView.hidden = true;
    }
}

- (BOOL)isNotEmpty:(NSString *)str {
    return !(str == nil && [str isEqualToString:@""]);
}

- (void)startLocalGif:(NSString *)gifPath {
    NSData  *imageData = [NSData dataWithContentsOfFile:gifPath];
    imageView.image =  [UIImage sd_animatedGIFWithData:imageData];
}

- (CGFloat)changeX:(CGRect)frame {
    frame.origin.y = 0;
    if (self.alignType == Align_Top_Left) {
        frame.origin.x = 0;
    } else if (self.alignType == Align_Bottom_Right) {
        frame.origin.x = frame.size.width-self.frame.size.width;
    } else {
        frame.origin.x = -(frame.size.width-self.frame.size.width)/2;
    }
    
    return frame.origin.x;
}

- (CGFloat)changeY:(CGRect)frame {
    frame.origin.x = 0;
    if (self.alignType == Align_Top_Left) {
        frame.origin.y = 0;
    } else if (self.alignType == Align_Bottom_Right) {
        frame.origin.y = frame.size.height-self.frame.size.height;
    } else {
        frame.origin.y = -(frame.size.height-self.frame.size.height)/2;
    }
    
    return frame.origin.y;
}

- (void)changeFrame {
    
    if (imageSize.width > 0 && imageSize.height > 0) {
        if (self.alignType == Fit_Center) {
            CGRect frame = imageView.frame;
            if (imageSize.width > imageSize.height) {
                frame.size.width = self.frame.size.width;
                frame.size.height = frame.size.width*imageSize.height/imageSize.width;
                if (frame.size.height > self.frame.size.height) {
                    frame.size.height = self.frame.size.height;
                    frame.size.width = frame.size.height*imageSize.width/imageSize.height;
                    frame.origin.y = 0;
                    frame.origin.x = (self.frame.size.width-frame.size.width)/2;
                } else {
                    frame.origin.x = 0;
                    frame.origin.y = (self.frame.size.height-frame.size.height)/2;
                }
                
            } else {
                frame.size.height = self.frame.size.height;
                frame.size.width = frame.size.height*imageSize.width/imageSize.height;
                if (frame.size.width > self.frame.size.width) {
                    frame.size.width = self.frame.size.width;
                    frame.size.height = frame.size.width*imageSize.height/imageSize.width;
                    frame.origin.x = 0;
                    frame.origin.y = (self.frame.size.height-frame.size.height)/2;
                } else {
                    frame.origin.y = 0;
                    frame.origin.x = (self.frame.size.width-frame.size.width)/2;
                }
            }
            
            imageView.frame = frame;
        } else if (self.alignType == Fit_XY) {
            CGRect frame = imageView.frame;
            if (imageSize.width > imageSize.height) {
                frame.size.height = self.frame.size.height;
                frame.size.width = frame.size.height*imageSize.width/imageSize.height;
                frame.origin.x = (self.frame.size.width-frame.size.width)/2;
                frame.origin.y = 0;
            } else {
                frame.size.width = self.frame.size.width;
                frame.size.height = frame.size.width*imageSize.height/imageSize.width;
                frame.origin.x = 0;
                frame.origin.y = (self.frame.size.height-frame.size.height)/2;
            }
            imageView.frame = frame;
        } else if (self.alignType == Fit_Full) {
            imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, self.frame.size.width, self.frame.size.height);
        } else {
            CGRect frame = imageView.frame;
            
            if (self.alignType == Fit_Top) {
                if (imageSize.width > imageSize.height) {
                    frame.size.width = self.frame.size.width;
                    frame.size.height = frame.size.width*imageSize.height/imageSize.width;
                    frame.origin.x = 0;
                    frame.origin.y = 0;
                } else {
                    frame.size.height = self.frame.size.height;
                    frame.size.width = frame.size.height*imageSize.width/imageSize.height;
                    frame.origin.x = 0;
                    frame.origin.y = 0;
                }
            } else {
                if (imageSize.width > imageSize.height) {
                    frame.size.height = self.frame.size.height;
                    frame.size.width = frame.size.height*imageSize.width/imageSize.height;
                    
                    if (frame.size.width < self.frame.size.width) {
                        frame.size.width = self.frame.size.width;
                        frame.size.height = frame.size.width*imageSize.height/imageSize.width;
                        frame.origin.x = 0;
                        frame.origin.y = [self changeY:frame];
                    } else {
                        frame.origin.y = 0;
                        frame.origin.x = [self changeX:frame];
                    }
                } else {
                    frame.size.width = self.frame.size.width;
                    frame.size.height = frame.size.width*imageSize.height/imageSize.width;
                    
                    if (frame.size.height < self.frame.size.height) {
                        frame.size.height = self.frame.size.height;
                        frame.size.width = frame.size.height*imageSize.width/imageSize.height;
                        frame.origin.y = 0;
                        frame.origin.x = [self changeX:frame];
                    } else {
                        frame.origin.x = 0;
                        frame.origin.y = [self changeY:frame];
                    }
                }
            }

            imageView.frame = frame;
        }
    } else {
        CGRect frame = imageView.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        frame.size.width = self.frame.size.width;
        frame.size.height = self.frame.size.height;
        imageView.frame = frame;
    }
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    clickBtn.tag = self.tag;
    clickBtn.userInteractionEnabled = true;
    self.userInteractionEnabled = true;
    clickBtn.hidden = false;
    [clickBtn addTarget:target action:action forControlEvents:controlEvents];
}

@end

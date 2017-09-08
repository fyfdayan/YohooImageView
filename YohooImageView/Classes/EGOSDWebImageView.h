//
//  EGOSDWebImageView.h
//  CompanyPlus
//
//  Created by 傅雁锋 on 15/9/28.
//  Copyright (c) 2015年 厦门象形远教网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum ImageViewAlignType {
    //显示中间部分
    Align_Center = 1,
    //显示顶部或左侧部分
    Align_Top_Left = 2,
    //显示底部或右侧部分
    Align_Bottom_Right = 3,
    // 居中显示
    Fit_Center = 4,
    // 缩放显示顶部
    Fit_Top = 5,
    // 全屏显示，如果宽度大于高度，则高度=控件高度，如果高度大于宽度，则宽度=控件宽度,并等比缩放
    Fit_XY = 6,
    Fit_Full = 7,
    Align_Bottom = 8
} ImageViewAlignType;

@interface EGOSDWebImageView : UIImageView

@property (strong, nonatomic) UIImageView *imageView;

- (void)loadImage:(NSString *)url withPlaceholderImage:(UIImage *)placeholderImage;

- (void)loadImage:(NSString *)url withPlaceholderImage:(UIImage *)placeholderImage withSize:(CGSize)size;

- (void)loadImage:(NSString *)url withPlaceholderImage:(UIImage *)placeholderImage withSize:(CGSize)size withType:(ImageViewAlignType)type;

- (void)loadImage:(NSString *)url loadingImageSize:(CGSize)size loadingImage:(UIImage *)loadingImage;

@property (nonatomic) ImageViewAlignType alignType;
@property (nonatomic) BOOL loadingImageNeedFullScreen;
@property (nonatomic) BOOL loadingImageFrameEqualParent;
@property (nonatomic) BOOL fullScreenWithScale;

@property (nonatomic) BOOL needBlur;
@property (nonatomic) int blurRadius;
@property (copy, nonatomic) NSString *gifPath;

@property (strong, nonatomic) UIColor *gifLabelBackgroundColor;

- (void)changeBlurRadius:(int)blurRadius;

- (void)startLocalGif:(NSString *)gifPath;

- (void)startGIF;

- (void)stopGIF;

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end

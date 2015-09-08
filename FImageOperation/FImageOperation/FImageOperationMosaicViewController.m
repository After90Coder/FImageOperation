//
//  FImageOperationMosaicViewController.m
//  FImageOperation
//
//  Created by 江红胡 on 15/9/8.
//  Copyright (c) 2015年 Frank. All rights reserved.
//

#import "FImageOperationMosaicViewController.h"

#define kBitsPerComponent (8)
#define kBitsPerPixel (32)
#define kPixelChannelCount (4)

#define buttonWidth self.view.frame.size.width/5
#define operationWidth self.view.frame.size.width/2

@interface FImageOperationMosaicViewController ()
{
    BOOL ISENBALE;
    CGFloat scale;
    CGFloat brushWidth;
    BOOL IsCanChange;
    UIImage *backupImage;
    BOOL isHaveCancel;
}

@property (strong, nonatomic) UIImageView *backImgView;
@property (strong, nonatomic) UIImageView *imageView;

@property (nonatomic, strong) UIView *buttonView;

@property (nonatomic, strong) UIView *leftButton;
@property (nonatomic, strong) UIButton *brushSmallButton;
@property (nonatomic, strong) UIButton *brushMiddleButton;
@property (nonatomic, strong) UIButton *brushBigButton;

@property (nonatomic, strong) UIView *rightButton;
@property (nonatomic, strong) UIButton *brushCancelButton;
@property (nonatomic, strong) UIButton *brushNextButton;

@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *cancleButton;
@property (nonatomic, strong) UIButton *okButton;

@property (nonatomic, strong) UIImageView *moveImageView;

@end

@implementation FImageOperationMosaicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"马赛克";
    
    [self initAllMosaicSubViews];
    
    //第一次默认选中小画笔
    IsCanChange = YES;
    [self brushSmallButtonClick:nil];
}

- (void)initAllMosaicSubViews
{
    if (self.showImageView) {
        [self.showImageView removeFromSuperview];
        self.showImageView = nil;
    }
    
    if (self.sourceImage) {
        if (self.sourceImage.size.width > self.sourceImage.size.height) {
            scale = self.view.frame.size.width / self.sourceImage.size.width;
            CGFloat editHeight = self.sourceImage.size.height * scale;
            CGFloat topMargin = ((viewHeight - 170) - editHeight)/2;
            
            self.backImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, topMargin, self.view.frame.size.width, editHeight)];
            self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, topMargin, self.view.frame.size.width, editHeight)];
        }
        else {
            scale = (self.view.frame.size.height - 240)/self.sourceImage.size.height;
            CGFloat editWidth = self.sourceImage.size.width * scale;
            CGFloat leftMargin = (self.view.frame.size.width - editWidth)/2;
            
            self.backImgView = [[UIImageView alloc] initWithFrame:CGRectMake(leftMargin, 0, editWidth, self.view.frame.size.height - 240)];
            self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(leftMargin, 0, editWidth, self.view.frame.size.height - 240)];
        }
        
        [self.backImgView setImage:[self transToMosaicImage:self.sourceImage blockLevel:10/scale]];
        
        [self.imageView setImage:self.sourceImage];
        [self.imageView setUserInteractionEnabled:YES];
        
        [self.view addSubview:self.backImgView];
        [self.view addSubview:self.imageView];
    }
    
    //buttonView
    self.buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight - 170, self.view.frame.size.width, 120)];
    [self.buttonView setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.buttonView];
    
    //leftButton
    self.leftButton = [[UIView alloc] initWithFrame:CGRectMake(0, 0, operationWidth, 120)];
    
    [self.buttonView addSubview:self.leftButton];
    
    //brushSmallButton
    UIImage *brushSmallImage = [UIImage imageNamed:@"image_mosaic_small"];
    CGFloat leftMargin = 40;
    CGFloat topMargin = (120 - brushSmallImage.size.height)/2 - 10;
    
    self.brushSmallButton = [[UIButton alloc] initWithFrame:CGRectMake(leftMargin, topMargin, brushSmallImage.size.width, brushSmallImage.size.height)];
    [self.brushSmallButton setBackgroundImage:brushSmallImage forState:UIControlStateNormal];
    [self.brushSmallButton setBackgroundImage:[UIImage imageNamed:@"image_mosaic_small_click"] forState:UIControlStateSelected];
    [self.brushSmallButton addTarget:self action:@selector(brushSmallButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.leftButton addSubview:self.brushSmallButton];
    
    //brushMiddleButton
    UIImage *brushMiddleImage = [UIImage imageNamed:@"image_mosaic_middle"];
    leftMargin += brushSmallImage.size.width;
    leftMargin += 30;
    topMargin = (120 - brushMiddleImage.size.height)/2 - 10;
    
    self.brushMiddleButton = [[UIButton alloc] initWithFrame:CGRectMake(leftMargin, topMargin, brushMiddleImage.size.width, brushMiddleImage.size.height)];
    [self.brushMiddleButton setBackgroundImage:brushMiddleImage forState:UIControlStateNormal];
    [self.brushMiddleButton setBackgroundImage:[UIImage imageNamed:@"image_mosaic_middle_click"] forState:UIControlStateSelected];
    [self.brushMiddleButton addTarget:self action:@selector(brushMiddleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.leftButton addSubview:self.brushMiddleButton];
    
    //brushBigButton
    UIImage *brushBigImage = [UIImage imageNamed:@"image_mosaic_big"];
    leftMargin += brushMiddleImage.size.width;
    leftMargin += 30;
    topMargin = (120 - brushBigImage.size.height)/2 - 10;
    
    self.brushBigButton = [[UIButton alloc] initWithFrame:CGRectMake(leftMargin, topMargin, brushBigImage.size.width, brushBigImage.size.height)];
    [self.brushBigButton setBackgroundImage:brushBigImage forState:UIControlStateNormal];
    [self.brushBigButton setBackgroundImage:[UIImage imageNamed:@"image_mosaic_big_click"] forState:UIControlStateSelected];
    [self.brushBigButton addTarget:self action:@selector(brushBigButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.leftButton addSubview:self.brushBigButton];
    
    //brushLabel
    topMargin += brushBigImage.size.height;
    topMargin += 20;
    UILabel *brushLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, topMargin, self.leftButton.frame.size.width, 11)];
    [brushLabel setText:@"画笔设置"];
    [brushLabel setTextColor:[UIColor colorWithRed:128.f/255.f green:128.f/255.f blue:128.f/255.f alpha:1.f]];
    [brushLabel setFont:[UIFont systemFontOfSize:11]];
    [brushLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.leftButton addSubview:brushLabel];
    
    //rightButton
    self.rightButton = [[UIView alloc] initWithFrame:CGRectMake(operationWidth, 0, operationWidth, 120)];
    
    [self.buttonView addSubview:self.rightButton];
    
    //brushNextButton
    UIImage *brushNextImage = [UIImage imageNamed:@"image_mosaic_next"];
    leftMargin = operationWidth - 40 - brushNextImage.size.width;
    topMargin = (120 - brushNextImage.size.height)/2 - 10;
    self.brushNextButton = [[UIButton alloc] initWithFrame:CGRectMake(leftMargin, topMargin, brushNextImage.size.width, brushNextImage.size.height)];
    [self.brushNextButton setBackgroundImage:brushNextImage forState:UIControlStateNormal];
    [self.brushNextButton addTarget:self action:@selector(brushNextButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.rightButton addSubview:self.brushNextButton];
    
    //brushCancelLabel
    topMargin += brushNextImage.size.height;
    topMargin += 20;
    UILabel *brushNextLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, topMargin, brushNextImage.size.width, 11)];
    [brushNextLabel setText:@"还原"];
    [brushNextLabel setTextColor:[UIColor colorWithRed:128.f/255.f green:128.f/255.f blue:128.f/255.f alpha:1.f]];
    [brushNextLabel setFont:[UIFont systemFontOfSize:11]];
    [brushNextLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.rightButton addSubview:brushNextLabel];
    
    //brushCancelButton
    UIImage *brushCancelImage = [UIImage imageNamed:@"image_mosaic_cancel"];
    leftMargin -= 30;
    leftMargin -= brushCancelImage.size.width;
    topMargin = (120 - brushCancelImage.size.height)/2 - 10;
    self.brushCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(leftMargin, topMargin, brushCancelImage.size.width, brushCancelImage.size.height)];
    [self.brushCancelButton setBackgroundImage:brushCancelImage forState:UIControlStateNormal];
    [self.brushCancelButton addTarget:self action:@selector(brushCancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.rightButton addSubview:self.brushCancelButton];
    
    //brushCancelLabel
    topMargin += brushCancelImage.size.height;
    topMargin += 20;
    UILabel *brushCancelLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, topMargin, brushCancelImage.size.width, 11)];
    [brushCancelLabel setText:@"撤销"];
    [brushCancelLabel setTextColor:[UIColor colorWithRed:128.f/255.f green:128.f/255.f blue:128.f/255.f alpha:1.f]];
    [brushCancelLabel setFont:[UIFont systemFontOfSize:11]];
    [brushCancelLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.rightButton addSubview:brushCancelLabel];
    
    //footerView
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight - 50, self.view.frame.size.width, 50)];
    
    //cancelButton
    self.cancleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth*2, 50)];
    [self.cancleButton setBackgroundColor:[UIColor colorWithRed:47.f/255.f green:56.f/255.f blue:67.f/255.f alpha:1]];
    [self.cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancleButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [self.cancleButton addTarget:self action:@selector(cancleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.footerView addSubview:self.cancleButton];
    
    //okButton
    self.okButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth*2, 0, buttonWidth*3, 50)];
    [self.okButton setBackgroundColor:[UIColor colorWithRed:255.f/255.f green:106.f/255.f blue:34.f/255.f alpha:1]];
    [self.okButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.okButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [self.okButton addTarget:self action:@selector(okButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.footerView addSubview:self.okButton];
    
    [self.view addSubview:self.footerView];
    
    //moveImageView
    UIImage *moveImage = [UIImage imageNamed:@"image_brush_small"];
    self.moveImageView = [[UIImageView alloc] init];
    [self.moveImageView setImage:moveImage];
    [self.moveImageView setCenter:CGPointMake(-100, -100)];
    [self.moveImageView setBounds:CGRectMake(0, 0, moveImage.size.width, moveImage.size.height)];
    
    [self.view addSubview:self.moveImageView];
}

#pragma mark - 画笔设置

- (void)brushSmallButtonClick:(id)sender
{
    if (IsCanChange) {
        if (self.brushSmallButton.isSelected)
            return ;
        else {
            [self allBrushButtonCancel];
            
            [self.brushSmallButton setSelected:YES];
            
            [self showBrushView:0];
            
            brushWidth = 11/scale;
            
            IsCanChange = NO;
        }
    }
}

- (void)brushMiddleButtonClick:(id)sender
{
    if (IsCanChange) {
        if (self.brushMiddleButton.isSelected)
            return ;
        else {
            [self allBrushButtonCancel];
            
            [self.brushMiddleButton setSelected:YES];
            
            [self showBrushView:1];
            
            brushWidth = 16/scale;
            
            IsCanChange = NO;
        }
    }
}

- (void)brushBigButtonClick:(id)sender
{
    if (IsCanChange) {
        if (self.brushBigButton.isSelected)
            return ;
        else {
            [self allBrushButtonCancel];
            
            [self.brushBigButton setSelected:YES];
            
            [self showBrushView:2];
            
            brushWidth = 24/scale;
            
            IsCanChange = NO;
        }
    }
}

- (void)allBrushButtonCancel
{
    [self.brushSmallButton setSelected:NO];
    [self.brushMiddleButton setSelected:NO];
    [self.brushBigButton setSelected:NO];
}

- (void)showBrushView:(NSInteger)tag
{
    UIImage *image;
    UIImageView *brushImageView = [[UIImageView alloc] init];
    [brushImageView setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    
    switch (tag) {
        case 0:
            image = [UIImage imageNamed:@"image_brush_small"];
            break;
        case 1:
            image = [UIImage imageNamed:@"image_brush_middle"];
            break;
        case 2:
            image = [UIImage imageNamed:@"image_brush_big"];
            break;
    }
    
    [brushImageView setImage:image];
    [brushImageView setBounds:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    [self.moveImageView setImage:image];
    [self.moveImageView setBounds:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    [self.view addSubview:brushImageView];
    
    [self performSelector:@selector(hideBrushView:) withObject:brushImageView afterDelay:0.2f];
}

- (void)hideBrushView:(id)sender
{
    UIImageView *imgView = (UIImageView *)sender;
    [imgView removeFromSuperview];
    
    IsCanChange = YES;
}

#pragma mark - 撤销&还原
- (void)brushCancelButtonClick:(id)sender
{
    if (!isHaveCancel) {
        backupImage = self.imageView.image;
        
        isHaveCancel = YES;
    }
    
    [self.imageView setImage:self.sourceImage];
}

- (void)brushNextButtonClick:(id)sender
{
    if (backupImage) {
        [self.imageView setImage:backupImage];
    }
}

#pragma mark - 确定&取消
- (void)cancleButtonClick:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)okButtonClick:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(imageOperationdidFinish:)]) {
        [self.delegate imageOperationdidFinish:[self addImage:self.backImgView.image toImage:self.imageView.image]];
    }
}

- (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2
{
    UIGraphicsBeginImageContext(image1.size);
    
    // Draw image1
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    // Draw image2
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

#pragma mark - Touch Events
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if([touch view] == self.imageView) {
        ISENBALE = YES;
        
        CGPoint currentPoint = [touch locationInView:self.imageView];
        CGPoint showPoint = [touch locationInView:self.view];
        
        [self drawMosaicView:currentPoint andShowPoint:showPoint];
        
        isHaveCancel = false;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if(ISENBALE) {
        CGPoint currentPoint = [touch locationInView:self.imageView];
        CGPoint showPoint = [touch locationInView:self.view];
        
        [self drawMosaicView:currentPoint andShowPoint:showPoint];
    }
}

- (void)drawMosaicView:(CGPoint)currentPoint andShowPoint:(CGPoint)showPoint
{
    [self.moveImageView setCenter:showPoint];
    
    UIGraphicsBeginImageContextWithOptions(self.imageView.image.size, NO, self.imageView.image.scale);
    //    UIGraphicsBeginImageContext(self.imageView.image.size);
    [self.imageView.image drawInRect:CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height)];
    CGContextClearRect (UIGraphicsGetCurrentContext(), CGRectMake(currentPoint.x/scale - brushWidth, currentPoint.y/scale - brushWidth, brushWidth*2, brushWidth*2));
    self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    ISENBALE = NO;
    
    [self.moveImageView setCenter:CGPointMake(-100, -100)];
}

/*
 *转换成马赛克,level代表一个点转为多少level*level的正方形
 */
- (UIImage *)transToMosaicImage:(UIImage*)orginImage blockLevel:(NSUInteger)level
{
    //获取BitmapData
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = orginImage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  kBitsPerComponent,        //每个颜色值8bit
                                                  width*kPixelChannelCount, //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit
                                                  colorSpace,
                                                  kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    unsigned char *bitmapData = CGBitmapContextGetData (context);
    
    //这里把BitmapData进行马赛克转换,就是用一个点的颜色填充一个level*level的正方形
    unsigned char pixel[kPixelChannelCount] = {0};
    NSUInteger index,preIndex;
    for (NSUInteger i = 0; i < height - 1 ; i++) {
        for (NSUInteger j = 0; j < width - 1; j++) {
            index = i * width + j;
            if (i % level == 0) {
                if (j % level == 0) {
                    memcpy(pixel, bitmapData + kPixelChannelCount*index, kPixelChannelCount);
                }else{
                    memcpy(bitmapData + kPixelChannelCount*index, pixel, kPixelChannelCount);
                }
            } else {
                preIndex = (i-1)*width +j;
                memcpy(bitmapData + kPixelChannelCount*index, bitmapData + kPixelChannelCount*preIndex, kPixelChannelCount);
            }
        }
    }
    
    NSInteger dataLength = width*height* kPixelChannelCount;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData, dataLength, NULL);
    //创建要输出的图像
    CGImageRef mosaicImageRef = CGImageCreate(width, height,
                                              kBitsPerComponent,
                                              kBitsPerPixel,
                                              width*kPixelChannelCount ,
                                              colorSpace,
                                              kCGImageAlphaPremultipliedLast,
                                              provider,
                                              NULL, NO,
                                              kCGRenderingIntentDefault);
    CGContextRef outputContext = CGBitmapContextCreate(nil,
                                                       width,
                                                       height,
                                                       kBitsPerComponent,
                                                       width*kPixelChannelCount,
                                                       colorSpace,
                                                       kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(outputContext, CGRectMake(0.0f, 0.0f, width, height), mosaicImageRef);
    CGImageRef resultImageRef = CGBitmapContextCreateImage(outputContext);
    UIImage *resultImage = nil;
    if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
        //        float scale_screen = [[UIScreen mainScreen] scale];
        resultImage = [UIImage imageWithCGImage:resultImageRef scale:orginImage.scale orientation:UIImageOrientationUp];
    } else {
        resultImage = [UIImage imageWithCGImage:resultImageRef];
    }
    
    //释放
    if(resultImageRef){
        CFRelease(resultImageRef);
    }
    if(mosaicImageRef){
        CFRelease(mosaicImageRef);
    }
    if(colorSpace){
        CGColorSpaceRelease(colorSpace);
    }
    if(provider){
        CGDataProviderRelease(provider);
    }
    if(context){
        CGContextRelease(context);
    }
    if(outputContext){
        CGContextRelease(outputContext);
    }
    
    return resultImage;
}


@end

//
//  FImageOperationClipViewController.m
//  FImageOperation
//
//  Created by 江红胡 on 15/9/8.
//  Copyright (c) 2015年 Frank. All rights reserved.
//

#import "FImageOperationClipViewController.h"

#define SCALE_FRAME_Y 100.0f
#define BOUNDCE_DURATION 0.3f

#define buttonWidth self.view.frame.size.width/5

@interface FImageOperationClipViewController ()

@property (nonatomic, strong) UIImageView *showImgView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *ratioView;

@property (nonatomic, assign) CGRect oldFrame;
@property (nonatomic, assign) CGRect largeFrame;
@property (nonatomic, assign) CGFloat limitRatio;
@property (nonatomic, assign) CGRect cropFrame;

@property (nonatomic, assign) CGRect latestFrame;

@property (nonatomic, strong) UIView *clipSizeView;
@property (nonatomic, strong) UIButton *horButton;
@property (nonatomic, strong) UIButton *verButton;

@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *confirmBtn;

@end

@implementation FImageOperationClipViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES];
    
    [self setTitle:@"裁剪"];
    
    //手势缩小范围
    self.limitRatio = 3.f;
    
    [self initView];
    [self initAllButtons];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (void)initView
{
    if (self.showImageView) {
        [self.showImageView removeFromSuperview];
        self.showImageView = nil;
    }
    
    self.cropFrame = CGRectMake(0, (viewHeight - 170 - self.view.frame.size.width/4*3)/2, self.view.frame.size.width, self.view.frame.size.width/4*3);
    
    self.showImgView = [[UIImageView alloc] init];
    [self.showImgView setMultipleTouchEnabled:YES];
    [self.showImgView setUserInteractionEnabled:YES];
    [self.showImgView setImage:self.sourceImage];
    
    // scale to fit the screen
    CGFloat oriWidth = self.cropFrame.size.width;
    CGFloat oriHeight = self.sourceImage.size.height * (oriWidth / self.sourceImage.size.width);
    CGFloat oriX = self.cropFrame.origin.x + (self.cropFrame.size.width - oriWidth) / 2;
    CGFloat oriY = self.cropFrame.origin.y + (self.cropFrame.size.height - oriHeight) / 2;
    
    self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
    self.latestFrame = self.oldFrame;
    self.showImgView.frame = self.oldFrame;
    
    self.largeFrame = CGRectMake(0, 0, self.limitRatio * self.oldFrame.size.width, self.limitRatio * self.oldFrame.size.height);
    
    [self addGestureRecognizers];
    [self.view addSubview:self.showImgView];
    
    self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.overlayView.alpha = .4f;
    self.overlayView.backgroundColor = [UIColor whiteColor];
    [self.overlayView setUserInteractionEnabled:YES];
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.overlayView];
    
    self.ratioView = [[UIView alloc] initWithFrame:self.cropFrame];
    self.ratioView.autoresizingMask = UIViewAutoresizingNone;
    [self.ratioView setUserInteractionEnabled:YES];
    self.ratioView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.ratioView.layer.borderWidth = 1;
    
    [self addLineInratioView];
    
    [self.view addSubview:self.ratioView];
    
    [self overlayClipping];
}

- (void)addLineInratioView
{
    for (UIView *subView in self.ratioView.subviews) {
        [subView removeFromSuperview];
    }
    
    CGFloat topMargin = self.ratioView.frame.size.height/3;
    CGFloat leftMargin = self.ratioView.frame.size.width/3;
    CGFloat width = self.ratioView.frame.size.width;
    CGFloat height = self.ratioView.frame.size.height;
    
    UIView *horLine1 = [[UIView alloc] initWithFrame:CGRectMake(0, topMargin, width, 0.5)];
    [horLine1 setBackgroundColor:[UIColor whiteColor]];
    
    [self.ratioView addSubview:horLine1];
    
    UIView *horLine2 = [[UIView alloc] initWithFrame:CGRectMake(0, topMargin*2, width, 0.5)];
    [horLine2 setBackgroundColor:[UIColor whiteColor]];
    
    [self.ratioView addSubview:horLine2];
    
    UIView *verLine1 = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, 0, 0.5, height)];
    [verLine1 setBackgroundColor:[UIColor whiteColor]];
    
    [self.ratioView addSubview:verLine1];
    
    UIView *verLine2 = [[UIView alloc] initWithFrame:CGRectMake(leftMargin*2, 0, 0.5, height)];
    [verLine2 setBackgroundColor:[UIColor whiteColor]];
    
    [self.ratioView addSubview:verLine2];
    
    UIImageView *leftUpImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_clip_leftup"]];
    [leftUpImageView setFrame:CGRectMake(1, 1, leftUpImageView.frame.size.width, leftUpImageView.frame.size.height)];
    
    [self.ratioView addSubview:leftUpImageView];
    
    UIImageView *leftDownImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_clip_leftdown"]];
    [leftDownImageView setFrame:CGRectMake(1, self.ratioView.frame.size.height - leftDownImageView.frame.size.height - 1, leftDownImageView.frame.size.width, leftDownImageView.frame.size.height)];
    
    [self.ratioView addSubview:leftDownImageView];
    
    UIImageView *rightUpImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_clip_rightup"]];
    [rightUpImageView setFrame:CGRectMake(self.ratioView.frame.size.width - rightUpImageView.frame.size.width - 1, 1, rightUpImageView.frame.size.width, rightUpImageView.frame.size.height)];
    
    [self.ratioView addSubview:rightUpImageView];
    
    UIImageView *rightDownImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_clip_rightdown"]];
    [rightDownImageView setFrame:CGRectMake(self.ratioView.frame.size.width -  rightDownImageView.frame.size.width - 1, self.ratioView.frame.size.height -  rightDownImageView.frame.size.height - 1, rightDownImageView.frame.size.width, rightDownImageView.frame.size.height)];
    
    [self.ratioView addSubview:rightDownImageView];
}

- (void)initAllButtons
{
    //clipSizeView
    self.clipSizeView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight - 170, self.view.frame.size.width, 120)];
    [self.clipSizeView setBackgroundColor:[UIColor whiteColor]];
    
    //horButton
    self.horButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, 120)];
    [self.horButton addTarget:self action:@selector(horButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *horImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_hor"]];
    [horImageView setFrame:CGRectMake((self.horButton.frame.size.width - horImageView.frame.size.width)/2, 53/2, horImageView.frame.size.width, horImageView.frame.size.height)];
    
    [self.horButton addSubview:horImageView];
    
    UILabel *horLabel = [[UILabel alloc] initWithFrame:CGRectMake(horImageView.frame.origin.x, horImageView.frame.origin.y + horImageView.frame.size.height + 15, horImageView.frame.size.width, 11)];
    [horLabel setText:@"横屏"];
    [horLabel setTextColor:[UIColor colorWithRed:128.f/255.f green:128.f/255.f blue:128.f/255.f alpha:1.f]];
    [horLabel setFont:[UIFont systemFontOfSize:11]];
    [horLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.horButton addSubview:horLabel];
    
    [self.clipSizeView addSubview:self.horButton];
    
    //verButton
    self.verButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, 100)];
    [self.verButton addTarget:self action:@selector(verButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *verImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_ver"]];
    [verImageView setFrame:CGRectMake((self.horButton.frame.size.width - verImageView.frame.size.width)/2, 53/2, verImageView.frame.size.width, verImageView.frame.size.height)];
    
    [self.verButton addSubview:verImageView];
    
    UILabel *verLabel = [[UILabel alloc] initWithFrame:CGRectMake(verImageView.frame.origin.x, verImageView.frame.origin.y + verImageView.frame.size.height + 15, verImageView.frame.size.width, 11)];
    [verLabel setText:@"竖屏"];
    [verLabel setTextColor:[UIColor colorWithRed:128.f/255.f green:128.f/255.f blue:128.f/255.f alpha:1.f]];
    [verLabel setFont:[UIFont systemFontOfSize:11]];
    [verLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.verButton addSubview:verLabel];
    
    [self.clipSizeView addSubview:self.verButton];
    
    [self.view addSubview:self.clipSizeView];
    
    //footerView
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight - 50, self.view.frame.size.width, 50)];
    
    [self.view addSubview:self.footerView];
    
    //cancelBtn
    self.cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth*2, 50)];
    self.cancelBtn.backgroundColor = [UIColor colorWithRed:47.f/255.f green:56.f/255.f blue:67.f/255.f alpha:1];//[UIColor blackColor];
    self.cancelBtn.titleLabel.textColor = [UIColor whiteColor];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [self.cancelBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.cancelBtn.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.cancelBtn.titleLabel setNumberOfLines:0];
    [self.cancelBtn setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
    [self.cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.footerView addSubview:self.cancelBtn];
    
    //confirmBtn
    self.confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth*2, 0, buttonWidth*3, 50)];
    self.confirmBtn.backgroundColor = [UIColor colorWithRed:255.f/255.f green:106.f/255.f blue:34.f/255.f alpha:1];//[UIColor orangeColor];
    self.confirmBtn.titleLabel.textColor = [UIColor whiteColor];
    [self.confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.confirmBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [self.confirmBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    self.confirmBtn.titleLabel.textColor = [UIColor whiteColor];
    [self.confirmBtn.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.confirmBtn.titleLabel setNumberOfLines:0];
    [self.confirmBtn setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
    [self.confirmBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.footerView addSubview:self.confirmBtn];
}

#pragma mark - Button Events

- (void)horButtonClick:(id)sender
{
    CGFloat width = self.view.frame.size.width;
    CGFloat height = width/4*3;
    
    self.cropFrame = CGRectMake(0, (self.view.frame.size.height - 170 - self.view.frame.size.width/4*3)/2, width, height);
    
    [self.ratioView setFrame:self.cropFrame];
    [self addLineInratioView];
    [self overlayClipping];
}

- (void)verButtonClick:(id)sender
{
    CGFloat height = self.view.frame.size.height - 170;
    CGFloat width = height/4*3;
    CGFloat leftMargin = (self.view.frame.size.width - width)/2;
    
    self.cropFrame = CGRectMake(leftMargin, 0, width, height);
    
    [self.ratioView setFrame:self.cropFrame];
    [self addLineInratioView];
    [self overlayClipping];
}

- (void)cancel:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)confirm:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageOperationdidFinish:)]) {
        [self.delegate imageOperationdidFinish:[self getSubImage]];
    }
}

- (void)overlayClipping
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    // Left side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        self.ratioView.frame.origin.x,
                                        self.overlayView.frame.size.height));
    // Right side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(
                                        self.ratioView.frame.origin.x + self.ratioView.frame.size.width,
                                        0,
                                        self.overlayView.frame.size.width - self.ratioView.frame.origin.x - self.ratioView.frame.size.width,
                                        self.overlayView.frame.size.height));
    // Top side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        self.overlayView.frame.size.width,
                                        self.ratioView.frame.origin.y));
    // Bottom side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0,
                                        self.ratioView.frame.origin.y + self.ratioView.frame.size.height,
                                        self.overlayView.frame.size.width,
                                        self.overlayView.frame.size.height - self.ratioView.frame.origin.y + self.ratioView.frame.size.height));
    maskLayer.path = path;
    
    self.overlayView.layer.mask = maskLayer;
    
    CGPathRelease(path);
}

// register all gestures
- (void)addGestureRecognizers
{
    // add pinch gesture
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
    // add pan gesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    
    [self.view addGestureRecognizer:panGestureRecognizer];
}

// pinch gesture handler
- (void)pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = self.showImgView;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

// pan gesture handler
- (void)panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = self.showImgView;
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // calculate accelerator
        CGFloat absCenterX = self.cropFrame.origin.x + self.cropFrame.size.width / 2;
        CGFloat absCenterY = self.cropFrame.origin.y + self.cropFrame.size.height / 2;
        CGFloat scaleRatio = self.showImgView.frame.size.width / self.cropFrame.size.width;
        
        CGFloat acceleratorX = 1 - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX);
        CGFloat acceleratorY = 1 - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY);
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
        
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // bounce to original frame
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

- (CGRect)handleScaleOverflow:(CGRect)newFrame
{
    // bounce to original frame
    CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width/2, newFrame.origin.y + newFrame.size.height/2);
    
    if (newFrame.size.width < self.oldFrame.size.width) {
        newFrame = self.oldFrame;
    }
    
    if (newFrame.size.width > self.largeFrame.size.width) {
        newFrame = self.largeFrame;
    }
    
    newFrame.origin.x = oriCenter.x - newFrame.size.width/2;
    newFrame.origin.y = oriCenter.y - newFrame.size.height/2;
    
    return newFrame;
}

- (CGRect)handleBorderOverflow:(CGRect)newFrame
{
    // horizontally
    if (newFrame.origin.x > self.cropFrame.origin.x)
        newFrame.origin.x = self.cropFrame.origin.x;
    
    if (CGRectGetMaxX(newFrame) < (self.cropFrame.size.width + self.cropFrame.origin.x))
        newFrame.origin.x = self.cropFrame.origin.x + self.cropFrame.size.width - newFrame.size.width;
    
    // vertically
    if (newFrame.origin.y > self.cropFrame.origin.y)
        newFrame.origin.y = self.cropFrame.origin.y;
    
    if (CGRectGetMaxY(newFrame) < self.cropFrame.origin.y + self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + self.cropFrame.size.height - newFrame.size.height;
    }
    
    // adapt horizontally rectangle
    if (self.showImgView.frame.size.width > self.showImgView.frame.size.height && newFrame.size.height <= self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + (self.cropFrame.size.height - newFrame.size.height) / 2;
    }
    
    return newFrame;
}

#pragma mark - 裁剪
- (UIImage *)getSubImage
{
    CGRect squareFrame = self.ratioView.frame;
    CGFloat scaleRatio = self.latestFrame.size.width / self.sourceImage.size.width;
    
    CGFloat x = (squareFrame.origin.x - self.latestFrame.origin.x) / scaleRatio;
    CGFloat y = (squareFrame.origin.y - self.latestFrame.origin.y) / scaleRatio;
    CGFloat w = squareFrame.size.width / scaleRatio;
    CGFloat h = squareFrame.size.width / scaleRatio;
    
    if (self.latestFrame.size.width < squareFrame.size.width) {
        CGFloat newW = self.sourceImage.size.width;
        CGFloat newH = newW * (squareFrame.size.height / squareFrame.size.width);
        x = 0; y = y + (h - newH) / 2;
        w = newH;
        h = newH;
    }
    
    if (self.latestFrame.size.height < squareFrame.size.height) {
        CGFloat newH = self.sourceImage.size.height;
        CGFloat newW = newH * (squareFrame.size.width / squareFrame.size.height);
        x = x + (w - newW) / 2; y = 0;
        w = newH;
        h = newH;
    }
    
    CGRect myImageRect = CGRectMake(x, y, self.cropFrame.size.width/scaleRatio, self.cropFrame.size.height/scaleRatio);
    CGImageRef imageRef = self.sourceImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    CGSize size;
    size.width = myImageRect.size.width;
    size.height = myImageRect.size.height;
    UIGraphicsBeginImageContextWithOptions(size, YES, self.sourceImage.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    
    UIGraphicsEndImageContext();
    
    return smallImage;
}

@end

//
//  FImageOperationRotaingViewController.m
//  FImageOperation
//
//  Created by 江红胡 on 15/9/8.
//  Copyright (c) 2015年 Frank. All rights reserved.
//

#import "FImageOperationRotaingViewController.h"

#define buttonWidth self.view.frame.size.width/5
#define operationWidth self.view.frame.size.width/3

@interface FImageOperationRotaingViewController ()
{
    BOOL isTurn;
}

@property (nonatomic, strong) UIView *buttonView;
@property (nonatomic, strong) UIButton *rotationButton;

@end

@implementation FImageOperationRotaingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"旋转";
    [self setupSubViews];
}

- (void)setupSubViews
{
    //buttonView
    self.buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight - 170, self.view.frame.size.width, 120)];
    [self.buttonView setBackgroundColor:[UIColor whiteColor]];
    
    //rotationButton
    CGFloat leftMargin = (self.view.frame.size.width - operationWidth)/2;
    self.rotationButton = [[UIButton alloc] initWithFrame:CGRectMake(leftMargin, 0, operationWidth, 120)];
    [self.rotationButton addTarget:self action:@selector(rotationButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *rotateImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_rotate"]];
    [rotateImageView setFrame:CGRectMake((self.rotationButton.frame.size.width - rotateImageView.frame.size.width)/2, 57/2, rotateImageView.frame.size.width, rotateImageView.frame.size.height)];
    
    [self.rotationButton addSubview:rotateImageView];
    
    UILabel *rotateLabel = [[UILabel alloc] initWithFrame:CGRectMake(rotateImageView.frame.origin.x, rotateImageView.frame.origin.y + rotateImageView.frame.size.height + 15, rotateImageView.frame.size.width, 11)];
    [rotateLabel setText:@"旋转"];
    [rotateLabel setTextColor:[UIColor colorWithRed:128.f/255.f green:128.f/255.f blue:128.f/255.f alpha:1.f]];
    [rotateLabel setFont:[UIFont systemFontOfSize:11]];
    [rotateLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.rotationButton addSubview:rotateLabel];
    
    [self.buttonView addSubview:self.rotationButton];
    
    [self.view addSubview:self.buttonView];
}

- (void)rotationButtonClick:(id)sender
{
    if (isTurn)
        return;
    
    isTurn = YES;
    
    UIImage *image = [self image:self.showImageView.image rotation:UIImageOrientationRight];
    if (image) {
        if (image.size.width > image.size.height) {
            CGFloat scale = self.view.frame.size.width / image.size.width;
            CGFloat editHeight = image.size.height * scale;
            CGFloat topMargin = ((viewHeight - 170) - editHeight)/2;
            
            [self.showImageView setFrame:CGRectMake(0, topMargin, self.view.frame.size.width, editHeight)];
        }
        else {
            CGFloat scale = (self.view.frame.size.height - 170)/image.size.height;
            CGFloat editWidth = image.size.width * scale;
            CGFloat leftMargin = (self.view.frame.size.width - editWidth)/2;
            
            [self.showImageView setFrame:CGRectMake(leftMargin, 0, editWidth, self.view.frame.size.height - 170)];
        }
        
        [self.showImageView setImage:image];
    }
    
    isTurn = NO;
}

- (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    
    CGRect rect;
    
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
        {
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, self.showImageView.frame.size.height, self.showImageView.frame.size.width);
            translateX = 0;
            translateY = - rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
        }
            break;
        case UIImageOrientationRight:
        {
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
        }
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.f, -1.f);
    CGContextRotateCTM(context, rotate);
    
    CGContextTranslateCTM(context, translateX, translateY);
    CGContextScaleCTM(context, scaleX, scaleY);
    
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    return newPic;
}

@end

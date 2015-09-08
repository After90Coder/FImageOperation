//
//  FImageOperationBaseViewController.m
//  FImageOperation
//
//  Created by 江红胡 on 15/9/8.
//  Copyright (c) 2015年 Frank. All rights reserved.
//

#import "FImageOperationBaseViewController.h"

#define buttonWidth self.view.frame.size.width/5
#define operationWidth self.view.frame.size.width/3

@interface FImageOperationBaseViewController ()

@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *cancleButton;
@property (nonatomic, strong) UIButton *okButton;

@end

@implementation FImageOperationBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationItem setHidesBackButton:YES];
    
    [self initAllViews];
}

- (void)initAllViews
{
    //showImageView
    if (self.sourceImage) {
        if (self.sourceImage.size.width > self.sourceImage.size.height) {
            CGFloat scale = self.view.frame.size.width / self.sourceImage.size.width;
            CGFloat editHeight = self.sourceImage.size.height * scale;
            CGFloat topMargin = ((viewHeight - 170) - editHeight)/2;
            
            self.showImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, topMargin, self.view.frame.size.width, editHeight)];
        }
        else {
            CGFloat scale = (self.view.frame.size.height - 240)/self.sourceImage.size.height;
            CGFloat editWidth = self.sourceImage.size.width * scale;
            CGFloat leftMargin = (self.view.frame.size.width - editWidth)/2;
            
            self.showImageView = [[UIImageView alloc] initWithFrame:CGRectMake(leftMargin, 0, editWidth, self.view.frame.size.height - 240)];
        }
        
        [self.showImageView setImage:self.sourceImage];
        
        [self.view addSubview:self.showImageView];
    }
    
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
}

#pragma mark - Button Events

- (void)cancleButtonClick:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)okButtonClick:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(imageOperationdidFinish:)]) {
        [self.delegate imageOperationdidFinish:self.showImageView.image];
    }
}

@end

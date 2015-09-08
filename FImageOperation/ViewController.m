//
//  ViewController.m
//  FImageOperation
//
//  Created by 江红胡 on 15/9/8.
//  Copyright (c) 2015年 Frank. All rights reserved.
//

#import "ViewController.h"
#import "FImageOperationManager.h"

@interface ViewController () <FImageOperationBaseViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)navToRotaing:(id)sender
{
    [[FImageOperationManager sharedInstance] operationType:FImageOperationTypeRotaing sourceImage:self.imageView.image delegate:self];
}

- (IBAction)navToClip:(id)sender
{
    [[FImageOperationManager sharedInstance] operationType:FImageOperationTypeClip sourceImage:self.imageView.image delegate:self];
}

- (IBAction)navToMosaic:(id)sender
{
    [[FImageOperationManager sharedInstance] operationType:FImageOperationTypeMosaic sourceImage:self.imageView.image delegate:self];
}

#pragma mark - FImageOperationBaseViewControllerDelegate

- (void)imageOperationdidFinish:(UIImage *)finishImage
{
    [self.imageView setImage:finishImage];
}

@end

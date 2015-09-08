//
//  FImageOperationManager.m
//  FImageOperation
//
//  Created by 江红胡 on 15/9/8.
//  Copyright (c) 2015年 Frank. All rights reserved.
//

#import "FImageOperationManager.h"
#import "FImageOperationRotaingViewController.h"
#import "FImageOperationClipViewController.h"
#import "FImageOperationMosaicViewController.h"

@implementation FImageOperationManager

+ (instancetype)sharedInstance
{
    static FImageOperationManager *manager = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager = [[FImageOperationManager alloc] init];
    });
    
    return manager;
}

- (void)operationType:(FImageOperationType)operationType sourceImage:(UIImage *)sourceImage delegate:(UIViewController<FImageOperationBaseViewControllerDelegate> *)delegate
{
    FImageOperationBaseViewController *baseVC = nil;
    switch (operationType) {
        case FImageOperationTypeRotaing:
            baseVC = [[FImageOperationRotaingViewController alloc] init];
            break;
        case FImageOperationTypeClip:
            baseVC = [[FImageOperationClipViewController alloc] init];
            break;
        case FImageOperationTypeMosaic:
            baseVC = [[FImageOperationMosaicViewController alloc] init];
            break;
    }
    
    if (baseVC) {
        baseVC.sourceImage = sourceImage;
        baseVC.delegate = delegate;
    }
    
    [delegate presentViewController:[[UINavigationController alloc] initWithRootViewController:baseVC] animated:YES completion:nil];
}

@end

//
//  FImageOperationManager.h
//  FImageOperation
//
//  Created by 江红胡 on 15/9/8.
//  Copyright (c) 2015年 Frank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FImageOperationBaseViewController.h"

typedef NS_ENUM(NSInteger, FImageOperationType)
{
    FImageOperationTypeRotaing = 0, // 旋转
    FImageOperationTypeMosaic,      // 马赛克
    FImageOperationTypeClip         // 裁剪
};

@interface FImageOperationManager : NSObject

+ (instancetype)sharedInstance;

- (void)operationType:(FImageOperationType)operationType sourceImage:(UIImage *)sourceImage delegate:(UIViewController<FImageOperationBaseViewControllerDelegate> *)delegate;

@end

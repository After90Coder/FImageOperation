//
//  FImageOperationBaseViewController.h
//  FImageOperation
//
//  Created by 江红胡 on 15/9/8.
//  Copyright (c) 2015年 Frank. All rights reserved.
//

#import <UIKit/UIKit.h>

#define viewHeight self.view.frame.size.height - 64

@protocol FImageOperationBaseViewControllerDelegate <NSObject>

- (void)imageOperationdidFinish:(UIImage *)finishImage;

@end


@interface FImageOperationBaseViewController : UIViewController

@property (nonatomic, strong) UIImage *sourceImage;
@property (nonatomic, strong) UIImageView *showImageView;
@property (nonatomic, weak) id<FImageOperationBaseViewControllerDelegate> delegate;

@end

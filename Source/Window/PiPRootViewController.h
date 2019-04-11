//
//  PiPRootViewController.h
//  PiPhone
//
//  Created by KY1VSTAR on 01.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PiPPictureInPictureController;
typedef NS_ENUM(NSInteger, PiPManagerContentInsetAdjustmentBehavior);

NS_ASSUME_NONNULL_BEGIN

@interface PiPRootViewController : UIViewController

@property (class, nonatomic, readonly) PiPRootViewController *shared;

@property (nonatomic) UIEdgeInsets additionalContentInsets;
@property (nonatomic) PiPManagerContentInsetAdjustmentBehavior contentInsetAdjustmentBehavior;
@property (nonatomic, readonly) UILayoutGuide *contentLayoutGuide;

@end

NS_ASSUME_NONNULL_END

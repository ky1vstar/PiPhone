//
//  PiPManager.m
//  PiPhone
//
//  Created by KY1VSTAR on 03.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import "PiPManager.h"
#import "PiPRootViewController.h"

static BOOL _pictureInPicturePossible;

@interface PiPManager ()

@end

@implementation PiPManager

+ (void)load {
    _pictureInPicturePossible = YES;
}

#pragma mark - pictureInPicturePossible

+ (BOOL)pictureInPicturePossible {
    return _pictureInPicturePossible;
}

+ (void)setPictureInPicturePossible:(BOOL)pictureInPicturePossible {
    _pictureInPicturePossible = pictureInPicturePossible;
}

#pragma mark - additionalContentInsets

+ (UIEdgeInsets)additionalContentInsets {
    return PiPRootViewController.shared.additionalContentInsets;
}

+ (void)setAdditionalContentInsets:(UIEdgeInsets)additionalContentInsets {
    PiPRootViewController.shared.additionalContentInsets = additionalContentInsets;
}

+ (void)setAdditionalContentInsets:(UIEdgeInsets)additionalContentInsets animated:(BOOL)flag {
    [PiPRootViewController.shared setAdditionalContentInsets:additionalContentInsets animated:flag];
}

#pragma mark - contentInsetAdjustmentBehavior

+ (PiPManagerContentInsetAdjustmentBehavior)contentInsetAdjustmentBehavior {
    return PiPRootViewController.shared.contentInsetAdjustmentBehavior;
}

+ (void)setContentInsetAdjustmentBehavior:(PiPManagerContentInsetAdjustmentBehavior)contentInsetAdjustmentBehavior {
    PiPRootViewController.shared.contentInsetAdjustmentBehavior = contentInsetAdjustmentBehavior;
}

+ (void)setContentInsetAdjustmentBehavior:(PiPManagerContentInsetAdjustmentBehavior)contentInsetAdjustmentBehavior animated:(BOOL)flag {
    [PiPRootViewController.shared setContentInsetAdjustmentBehavior:contentInsetAdjustmentBehavior animated:flag];
}

@end

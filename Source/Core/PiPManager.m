//
//  PiPManager.m
//  PiPhone
//
//  Created by KY1VSTAR on 03.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import "PiPManager+Private.h"
#import "PiPRootViewController.h"

NSNotificationName const PiPManagerDidChangePictureInPicturePossibleNotification = @"PiPManagerDidChangePictureInPicturePossibleNotification";
static BOOL _settedUp;
static BOOL _pictureInPicturePossible;

@interface PiPManager ()

@end

@implementation PiPManager

+ (void)load {
    _pictureInPicturePossible = YES;
}

#pragma mark - settedUp

+ (BOOL)settedUp {
    return _settedUp;
}

+ (void)setSettedUp:(BOOL)settedUp {
    _settedUp = settedUp;
}

#pragma mark - pictureInPicturePossible

+ (BOOL)pictureInPicturePossible {
    return _pictureInPicturePossible;
}

+ (void)setPictureInPicturePossible:(BOOL)pictureInPicturePossible {
    _pictureInPicturePossible = pictureInPicturePossible;
    
    [NSNotificationCenter.defaultCenter postNotificationName:PiPManagerDidChangePictureInPicturePossibleNotification object:nil];
}

#pragma mark - additionalContentInsets

+ (UIEdgeInsets)additionalContentInsets {
    return PiPRootViewController.shared.additionalContentInsets;
}

+ (void)setAdditionalContentInsets:(UIEdgeInsets)additionalContentInsets {
    PiPRootViewController.shared.additionalContentInsets = additionalContentInsets;
}

#pragma mark - contentInsetAdjustmentBehavior

+ (PiPManagerContentInsetAdjustmentBehavior)contentInsetAdjustmentBehavior {
    return PiPRootViewController.shared.contentInsetAdjustmentBehavior;
}

+ (void)setContentInsetAdjustmentBehavior:(PiPManagerContentInsetAdjustmentBehavior)contentInsetAdjustmentBehavior {
    PiPRootViewController.shared.contentInsetAdjustmentBehavior = contentInsetAdjustmentBehavior;
}

@end

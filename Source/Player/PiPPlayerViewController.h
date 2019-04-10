//
//  PiPPlayerViewController.h
//  PiPhone
//
//  Created by KY1VSTAR on 01.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import <AVKit/AVKit.h>

@class PiPPlayerView;
@class PiPPictureInPictureController;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PiPPlayerViewControllerPosition) {
    PiPPlayerViewControllerPositionTopLeft = 0,
    PiPPlayerViewControllerPositionTopRight,
    PiPPlayerViewControllerPositionBottomLeft,
    PiPPlayerViewControllerPositionBottomRight,
    
    PiPPlayerViewControllerPositionTopLeftHidden,
    PiPPlayerViewControllerPositionTopRightHidden,
    PiPPlayerViewControllerPositionBottomLeftHidden,
    PiPPlayerViewControllerPositionBottomRightHidden
};

@interface PiPPlayerViewController : UIViewController

- (instancetype)initWithPictureInPictureController:(PiPPictureInPictureController *)pictureInPictureController;

- (void)start;

- (void)stop;

@end

@protocol PiPPlayerViewControllerDelegate <NSObject>

- (void)playerViewControllerWillStartPictureInPicture:(PiPPlayerViewController *)playerViewController;

- (void)playerViewControllerDidStartPictureInPicture:(PiPPlayerViewController *)playerViewController;

- (void)playerViewController:(PiPPlayerViewController *)playerViewController failedToStartPictureInPictureWithError:(NSError *)error;

- (void)playerViewControllerWillStopPictureInPicture:(PiPPlayerViewController *)playerViewController;

- (void)playerViewControllerDidStopPictureInPicture:(PiPPlayerViewController *)playerViewController;

- (void)playerViewController:(PiPPlayerViewController *)playerViewController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler;

@end

NS_ASSUME_NONNULL_END

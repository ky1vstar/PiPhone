//
//  PiPPictureInPictureController.h
//  PiPhone
//
//  Created by KY1VSTAR on 11.03.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import <AVKit/AVKit.h>

@class PiPPlayerLayerObserver;
@protocol PiPPlayerViewControllerDelegate;
@protocol PiPPlayerLayerObserverDelegate;

NS_ASSUME_NONNULL_BEGIN

// To get rid of 'Cannot find protocol definition' warnings
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
@interface PiPPictureInPictureController : NSObject <PiPPlayerViewControllerDelegate, PiPPlayerLayerObserverDelegate>
#pragma clang diagnostic pop

@property (nonatomic, readonly) PiPPlayerLayerObserver *playerLayerObserver;

// Public 'AVPictureInPictureController' properties
@property (nonatomic, readonly) AVPlayerLayer *playerLayer;
@property (nonatomic, weak, nullable) id <AVPictureInPictureControllerDelegate> delegate;
@property (nonatomic, readonly, getter = isPictureInPicturePossible) BOOL pictureInPicturePossible;
@property (nonatomic, readonly, getter = isPictureInPictureActive) BOOL pictureInPictureActive;
@property (nonatomic, readonly, getter = isPictureInPictureSuspended) BOOL pictureInPictureSuspended;

// Private 'AVPictureInPictureController' properties
@property (nonatomic, readonly, nullable) id playerLayerView;
@property (nonatomic) id playerController;
@property (nonatomic) BOOL allowsPictureInPicturePlayback;

- (instancetype)initWithPlayerLayer:(AVPlayerLayer *)playerLayer;

- (instancetype _Nullable)initWithPlayerLayerView:(id)playerLayerView;

- (void)startPictureInPicture;

- (void)stopPictureInPicture;

@end

NS_ASSUME_NONNULL_END

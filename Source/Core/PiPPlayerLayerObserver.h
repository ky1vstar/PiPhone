//
//  PiPPlayerLayerObserver.h
//  PiPhone
//
//  Created by KY1VSTAR on 01.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PiPPlayerLayerObserverDelegate;

@interface PiPPlayerLayerObserver : NSObject

@property (nonatomic, readonly) BOOL readyForDisplay;
@property (nonatomic, readonly) AVPlayerItemStatus playerItemStatus;
@property (nonatomic, readonly) CGSize presentationSize;
@property (nonatomic, readonly) BOOL playing;

// from 0.0 to 1.0
@property (nonatomic, readonly) CGFloat playbackProgress;

// if PiP is presented but AVPlayer's currentItem become nil or AVPlayerItem's status become failed we should dismiss PiP
@property (nonatomic, readonly) BOOL shouldDismiss;

@property (nonatomic, readonly) BOOL valid;
@property (nonatomic, readonly) BOOL initializing;

- (instancetype)initWithPlayerLayer:(AVPlayerLayer *)playerLayer;

- (void)addDelegate:(id<PiPPlayerLayerObserverDelegate>)delegate;

- (void)removeDelegate:(id<PiPPlayerLayerObserverDelegate>)delegate;

@end

@protocol PiPPlayerLayerObserverDelegate <NSObject>

@optional
- (void)playerLayerObserverDidChangeValidity:(PiPPlayerLayerObserver *)playerLayerObserver;
- (void)playerLayerObserverDidChangeShouldDismiss:(PiPPlayerLayerObserver *)playerLayerObserver;
- (void)playerLayerObserverDidChangeInitializingState:(PiPPlayerLayerObserver *)playerLayerObserver;
- (void)playerLayerObserverDidChangePlayingState:(PiPPlayerLayerObserver *)playerLayerObserver;
- (void)playerLayerObserverDidChangePlaybackProgress:(PiPPlayerLayerObserver *)playerLayerObserver;
- (void)playerLayerObserverDidChangePresentationSize:(PiPPlayerLayerObserver *)playerLayerObserver;

@end

NS_ASSUME_NONNULL_END

//
//  PiPPictureInPictureController.m
//  PiPhone
//
//  Created by KY1VSTAR on 11.03.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import "PiPPictureInPictureController.h"
#import "PiPPlayerLayerObserver.h"
#import "PiPRootViewController.h"
#import "PiPPlayerViewController.h"
#import "PiPManager+Private.h"

static __weak PiPPictureInPictureController *_currentPictureInPictureController;

@interface PiPPictureInPictureController () {
    
    struct {
        unsigned int willStart:1;
        unsigned int didStart:1;
        unsigned int failedToStart:1;
        unsigned int willStop:1;
        unsigned int didStop:1;
        unsigned int restoreUserInterface:1;
    } delegateRespondsTo;
    
}

@property (nonatomic, weak, nullable) PiPPlayerViewController *currentPlayerViewController;
@property (readwrite) BOOL pictureInPicturePossible;
@property (readwrite) BOOL pictureInPictureActive;

@end

@implementation PiPPictureInPictureController

#pragma mark - Class methods

+ (void)pictureInPictureControllerWillStart:(PiPPictureInPictureController *)pictureInPictureController {
    if (_currentPictureInPictureController != pictureInPictureController) {
        [_currentPictureInPictureController stopPictureInPicture];
    }
    
    _currentPictureInPictureController = pictureInPictureController;
}

+ (void)pictureInPictureControllerWillStop:(PiPPictureInPictureController *)pictureInPictureController {
    if (_currentPictureInPictureController == pictureInPictureController) {
        _currentPictureInPictureController = nil;
    }
}

#pragma mark - Initializers

- (instancetype)initWithPlayerLayer:(AVPlayerLayer *)playerLayer {
    if (self = [super init]) {
        _playerLayer = playerLayer;
        _pictureInPicturePossible = YES;
        _allowsPictureInPicturePlayback = YES;
        _playerLayerObserver = [[PiPPlayerLayerObserver alloc] initWithPlayerLayer:playerLayer];
        [_playerLayerObserver addDelegate:self];
        
        [self updatePossibility];
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updatePossibility) name:PiPManagerDidChangePictureInPicturePossibleNotification object:nil];
    }
    
    return self;
}

- (instancetype)initWithPlayerLayerView:(id)playerLayerView {
    AVPlayerLayer *playerLayer;

    if ([playerLayerView respondsToSelector:@selector(playerLayer)] &&
        (playerLayer = [playerLayerView valueForKey:@"playerLayer"]) &&
        (self = [self initWithPlayerLayer:playerLayer])) {
        _playerLayerView = playerLayerView;
    } else {
        return nil;
    }
    
    return self;
}

- (void)dealloc {
    [self stopPictureInPicture];
}

#pragma mark - AVPictureInPictureController methods

- (void)setDelegate:(id<AVPictureInPictureControllerDelegate>)delegate {
    _delegate = delegate;
    
    delegateRespondsTo.willStart = [delegate respondsToSelector:@selector(pictureInPictureControllerWillStartPictureInPicture:)];
    delegateRespondsTo.didStart = [delegate respondsToSelector:@selector(pictureInPictureControllerDidStartPictureInPicture:)];
    delegateRespondsTo.failedToStart = [delegate respondsToSelector:@selector(pictureInPictureController:failedToStartPictureInPictureWithError:)];
    delegateRespondsTo.willStop = [delegate respondsToSelector:@selector(pictureInPictureControllerWillStopPictureInPicture:)];
    delegateRespondsTo.didStop = [delegate respondsToSelector:@selector(pictureInPictureControllerDidStopPictureInPicture:)];
    delegateRespondsTo.restoreUserInterface = [delegate respondsToSelector:@selector(pictureInPictureController:restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:)];
}

- (void)startPictureInPicture {
    if (!_pictureInPicturePossible || _currentPlayerViewController) {
        return;
    }
    
    PiPPlayerViewController *playerViewController = [[PiPPlayerViewController alloc] initWithPictureInPictureController:self];
    _currentPlayerViewController = playerViewController;
    
    [playerViewController start];
}

- (void)stopPictureInPicture {
    [_currentPlayerViewController stop];
}

- (void)stopPictureInPictureEvenWhenInBackground {
    [self stopPictureInPicture];
}

- (void)setAllowsPictureInPicturePlayback:(BOOL)allowsPictureInPicturePlayback {
    _allowsPictureInPicturePlayback = allowsPictureInPicturePlayback;
    
    [self updatePossibility];
}

#pragma mark - Possibility

- (void)updatePossibility {
    BOOL newValue = _playerLayerObserver.valid && _allowsPictureInPicturePlayback && PiPManager.pictureInPicturePossible;
    
    if (newValue != _pictureInPicturePossible) {
        self.pictureInPicturePossible = newValue;
    }
}

#pragma mark - Runtime support for non-implemented methods

- (BOOL)isKindOfClass:(Class)aClass {
    if (aClass == AVPictureInPictureController.class) {
        return YES;
    }
    
    return [super isKindOfClass:aClass];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([AVPictureInPictureController instancesRespondToSelector:aSelector]) {
        return YES;
    }
    
    return [super respondsToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [AVPictureInPictureController instanceMethodSignatureForSelector:aSelector] ?: [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if (![AVPictureInPictureController instancesRespondToSelector:anInvocation.selector]) {
        [super forwardInvocation:anInvocation];
        return;
    }
    
    anInvocation.target = nil;
    [anInvocation invoke];
}

#pragma mark - PiPPlayerViewControllerDelegate

- (void)playerViewControllerWillStartPictureInPicture:(PiPPlayerViewController *)playerViewController {
    if (delegateRespondsTo.willStart) {
        id object = self;
        [_delegate pictureInPictureControllerWillStartPictureInPicture:object];
    }
    
    [PiPPictureInPictureController pictureInPictureControllerWillStart:self];
}

- (void)playerViewControllerDidStartPictureInPicture:(PiPPlayerViewController *)playerViewController {
    if (delegateRespondsTo.didStart) {
        id object = self;
        [_delegate pictureInPictureControllerDidStartPictureInPicture:object];
    }
    
    self.pictureInPictureActive = YES;
}

- (void)playerViewController:(PiPPlayerViewController *)playerViewController failedToStartPictureInPictureWithError:(NSError *)error {
    if (delegateRespondsTo.failedToStart) {
        id object = self;
        [_delegate pictureInPictureController:object failedToStartPictureInPictureWithError:error];
    }
}

- (void)playerViewControllerWillStopPictureInPicture:(PiPPlayerViewController *)playerViewController {
    self.pictureInPictureActive = NO;
    
    if (delegateRespondsTo.willStop) {
        id object = self;
        [_delegate pictureInPictureControllerWillStopPictureInPicture:object];
    }
    
    [PiPPictureInPictureController pictureInPictureControllerWillStop:self];
}

- (void)playerViewControllerDidStopPictureInPicture:(PiPPlayerViewController *)playerViewController {
    if (delegateRespondsTo.didStop) {
        id object = self;
        [_delegate pictureInPictureControllerDidStopPictureInPicture:object];
    }
}

- (void)playerViewController:(PiPPlayerViewController *)playerViewController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler {
    if (delegateRespondsTo.willStart) {
        id object = self;
        [_delegate pictureInPictureController:object restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:completionHandler];
    } else {
        completionHandler(YES);
    }
}

#pragma mark - PiPPlayerLayerObserverDelegate

- (void)playerLayerObserverDidChangeValidity:(PiPPlayerLayerObserver *)playerLayerObserver {
    [self updatePossibility];
}

@end

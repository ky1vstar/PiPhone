//
//  PiPPlayerLayerObserver.m
//  PiPhone
//
//  Created by KY1VSTAR on 01.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import "PiPPlayerLayerObserver.h"
#import "NSObject+PiPhone.h"

static BOOL kAlwaysReadyForDisplay = NO;
static NSString *kPlayerKeyPath = @"player";
static NSString *kCurrentItemKeyPath = @"player.currentItem";
static NSString *kReadyForDisplayKeyPath = @"readyForDisplay";
static NSString *kStatusKeyPath = @"player.currentItem.status";
static NSString *kPresentationSizeKeyPath = @"player.currentItem.presentationSize";
static NSString *kRateKeyPath = @"player.rate";

@interface PiPPlayerLayerObserver ()

@property (nonatomic) NSHashTable *delegates;
@property (nonatomic) AVPlayer *player;
@property (nonatomic, nullable) AVPlayerItem *currentPlayerItem;
@property (nonatomic, nullable) id playerTimeObserver;
@property (nonatomic) AVPlayerLayer *playerLayer;
@property (nonatomic, readwrite) CGSize presentationSize;
@property (nonatomic, readwrite) BOOL playing;
@property (nonatomic, readwrite) BOOL shouldDismiss;
@property (nonatomic, readwrite) BOOL valid;
@property (nonatomic, readwrite) BOOL initializing;

@end

@implementation PiPPlayerLayerObserver

+ (void)initialize {
    // AVQueuePlayer is broken on iOS 9. After currentItem being changed AVPlayerLayer's readyForDisplay will always remain NO;
    if (@available(iOS 10.0, *)) {
        kAlwaysReadyForDisplay = NO;
    } else {
        kAlwaysReadyForDisplay = YES;
    }
}

- (instancetype)initWithPlayerLayer:(AVPlayerLayer *)playerLayer {
    if (self = [super init]) {
        _delegates = [NSHashTable weakObjectsHashTable];
        _playerLayer = playerLayer;
        
        [self setupObservations];
    }
    
    return self;
}

- (void)dealloc {
    [self removeObserversForPlayer:_player];
    
    
    [_playerLayer removeObserver:self forKeyPath:kPlayerKeyPath];
    [_playerLayer removeObserver:self forKeyPath:kCurrentItemKeyPath];
    [_playerLayer removeObserver:self forKeyPath:kReadyForDisplayKeyPath];
    [_playerLayer removeObserver:self forKeyPath:kStatusKeyPath];
    [_playerLayer removeObserver:self forKeyPath:kPresentationSizeKeyPath];
    [_playerLayer removeObserver:self forKeyPath:kRateKeyPath];
}

- (void)setupObservations {
    AVPlayerItem *playerItem = _playerLayer.player.currentItem;
    
    _player = _playerLayer.player;
    [self addObserversForPlayer:_player];
    
    _currentPlayerItem = _player.currentItem;
    _readyForDisplay = _playerLayer.readyForDisplay || kAlwaysReadyForDisplay;
    _playerItemStatus = playerItem.status;
    _presentationSize = playerItem.presentationSize;
    _playing = _player.rate > 0;
    
    [self updateShouldDismiss];
    [self updateValidity];
    
    [_playerLayer addObserver:self forKeyPath:kPlayerKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [_playerLayer addObserver:self forKeyPath:kCurrentItemKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [_playerLayer addObserver:self forKeyPath:kReadyForDisplayKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [_playerLayer addObserver:self forKeyPath:kStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [_playerLayer addObserver:self forKeyPath:kPresentationSizeKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [_playerLayer addObserver:self forKeyPath:kRateKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)updateValidity {
    self.valid = _readyForDisplay && _playerItemStatus == AVPlayerItemStatusReadyToPlay && !CGSizeEqualToSize(_presentationSize, CGSizeZero);
}

- (void)updateShouldDismiss {
    self.shouldDismiss = _currentPlayerItem == nil || _playerItemStatus == AVPlayerItemStatusFailed;
}

- (void)updateInitializing {
    self.initializing = _currentPlayerItem != nil && (!_readyForDisplay || _playerItemStatus == AVPlayerItemStatusUnknown);
}

- (void)updatePlaybackProgressWithTime:(CMTime)currentTime {
    NSValue *seekableTimeRangeValue = [_player.currentItem.seekableTimeRanges firstObject];
    CMTimeRange seekableTimeRange = seekableTimeRangeValue.CMTimeRangeValue;
    
    if (CMTIME_IS_INDEFINITE(currentTime) || !seekableTimeRangeValue || CMTIMERANGE_IS_INDEFINITE(seekableTimeRange)) {
        self.playbackProgress = 0;
        return;
    }
    
    Float64 start = CMTimeGetSeconds(seekableTimeRange.start);
    Float64 duration = CMTimeGetSeconds(seekableTimeRange.duration);
    Float64 currentSeconds = CMTimeGetSeconds(currentTime);
    
    self.playbackProgress = MAX(MIN((currentSeconds - start) / duration, 1), 0);
}

#pragma mark - Delegates

- (void)addDelegate:(id<PiPPlayerLayerObserverDelegate>)delegate {
    [_delegates addObject:delegate];
}

- (void)removeDelegate:(id<PiPPlayerLayerObserverDelegate>)delegate {
    [_delegates removeObject:delegate];
}

- (void)enumerateDelegatesWithBlock:(void (^)(id<PiPPlayerLayerObserverDelegate> delegate))block {
    NSEnumerator *enumerator = [_delegates objectEnumerator];
    id<PiPPlayerLayerObserverDelegate> delegate;
    
    while (delegate = [enumerator nextObject]) {
        block(delegate);
    }
}

#pragma mark - Value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kPlayerKeyPath]) {
        self.player = [change[NSKeyValueChangeNewKey] ifNullThenNil];
        
    } else if ([keyPath isEqualToString:kCurrentItemKeyPath]) {
        _currentPlayerItem = [change[NSKeyValueChangeNewKey] ifNullThenNil];
        
        [self updateShouldDismiss];
        
    } else if ([keyPath isEqualToString:kReadyForDisplayKeyPath]) {
        NSNumber *number = [change[NSKeyValueChangeNewKey] ifNullThenNil];
        _readyForDisplay = number.boolValue || kAlwaysReadyForDisplay;
        
        [self updateValidity];
        [self updateInitializing];
        
    } else if ([keyPath isEqualToString:kStatusKeyPath]) {
        NSNumber *number = [change[NSKeyValueChangeNewKey] ifNullThenNil];
        AVPlayerItemStatus status = number.integerValue;
        _playerItemStatus = status;
        
        [self updateShouldDismiss];
        [self updateValidity];
        [self updateInitializing];
        
    } else if ([keyPath isEqualToString:kPresentationSizeKeyPath]) {
        NSValue *value = [change[NSKeyValueChangeNewKey] ifNullThenNil];
        self.presentationSize = value.CGSizeValue;
        
    } else if ([keyPath isEqualToString:kRateKeyPath]) {
        NSNumber *number = [change[NSKeyValueChangeNewKey] ifNullThenNil];
        self.playing = number.floatValue > 0;
    }
}

- (void)addObserversForPlayer:(AVPlayer *)player {
    __weak PiPPlayerLayerObserver *weakSelf = self;
    _playerTimeObserver = [player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [weakSelf updatePlaybackProgressWithTime:time];
    }];
    
    if (player) {
        [self updatePlaybackProgressWithTime:player.currentTime];
    } else {
        [self updatePlaybackProgressWithTime:kCMTimeZero];
    }
}

- (void)removeObserversForPlayer:(AVPlayer *)player {
    if (_playerTimeObserver) {
        [player removeTimeObserver:_playerTimeObserver];
        _playerTimeObserver = nil;
    }
}

#pragma mark - Setters

- (void)setPlayer:(AVPlayer * _Nullable)player {
    if (player == _player) {
        return;
    }
    
    [self removeObserversForPlayer:_player];
    
    _player = player;
    [self addObserversForPlayer:player];
}

- (void)setPresentationSize:(CGSize)presentationSize {
    if (CGSizeEqualToSize(presentationSize, _presentationSize)) {
        return;
    }
    _presentationSize = presentationSize;
    
    [self updateValidity];
    
    [self enumerateDelegatesWithBlock:^(id<PiPPlayerLayerObserverDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(playerLayerObserverDidChangePresentationSize:)]) {
            [delegate playerLayerObserverDidChangePresentationSize:self];
        }
    }];
}

- (void)setPlaying:(BOOL)playing {
    if (playing == _playing) {
        return;
    }
    _playing = playing;
    
    [self enumerateDelegatesWithBlock:^(id<PiPPlayerLayerObserverDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(playerLayerObserverDidChangePlayingState:)]) {
            [delegate playerLayerObserverDidChangePlayingState:self];
        }
    }];
}

- (void)setPlaybackProgress:(CGFloat)playbackProgress {
    if (playbackProgress == _playbackProgress) {
        return;
    }
    _playbackProgress = playbackProgress;
    
    [self enumerateDelegatesWithBlock:^(id<PiPPlayerLayerObserverDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(playerLayerObserverDidChangePlaybackProgress:)]) {
            [delegate playerLayerObserverDidChangePlaybackProgress:self];
        }
    }];
}

- (void)setShouldDismiss:(BOOL)shouldDismiss {
    if (shouldDismiss == _shouldDismiss) {
        return;
    }
    _shouldDismiss = shouldDismiss;
    
    [self enumerateDelegatesWithBlock:^(id<PiPPlayerLayerObserverDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(playerLayerObserverDidChangeShouldDismiss:)]) {
            [delegate playerLayerObserverDidChangeShouldDismiss:self];
        }
    }];
}

- (void)setValid:(BOOL)valid {
    if (valid == _valid) {
        return;
    }
    _valid = valid;
    
    [self enumerateDelegatesWithBlock:^(id<PiPPlayerLayerObserverDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(playerLayerObserverDidChangeValidity:)]) {
            [delegate playerLayerObserverDidChangeValidity:self];
        }
    }];
}

- (void)setInitializing:(BOOL)initializing {
    if (initializing == _initializing) {
        return;
    }
    _initializing = initializing;
    
    [self enumerateDelegatesWithBlock:^(id<PiPPlayerLayerObserverDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(playerLayerObserverDidChangeInitializingState:)]) {
            [delegate playerLayerObserverDidChangeInitializingState:self];
        }
    }];
}

@end

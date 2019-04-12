//
//  PiPPlaybackControlsViewController.m
//  PiPhone
//
//  Created by KY1VSTAR on 03.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import "PiPPlaybackControlsViewController.h"
#import "PiPPlayerLayerObserver.h"
#import "PiPButton.h"
#import "UIImage+PiPhone.h"

#define kMinPadding 23.f
#define kPaddingMultipiler 1.5f
#define kButtonBottomPadding 11.f
#define kDelayBeforeHidding 5.f
#define kFadeDuration 0.2f
#define kUpdateProgressDuration 0.1f

@interface PiPPlaybackControlsViewController () <PiPPlayerLayerObserverDelegate>

@property PiPButton *restoreButton;
@property PiPButton *playPauseButton;
@property PiPButton *closeButton;
@property (nonatomic) UIView *totalTimeRangeView;
@property (nonatomic) UIView *currentTimeRangeView;
@property (nonatomic) NSLayoutConstraint *currentTimeRangeConstraint;

@property (nonatomic) BOOL visible;
@property (nonatomic) CGFloat playbackProgress;
@property (nonatomic) dispatch_source_t dispatchTimer;

@end

@implementation PiPPlaybackControlsViewController

- (instancetype)initWithPlayerLayerObserver:(PiPPlayerLayerObserver *)playerLayerObserver {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _playerLayerObserver = playerLayerObserver;
        
        _restoreButton = [[PiPButton alloc] init];
        _playPauseButton = [[PiPButton alloc] init];
        _closeButton = [[PiPButton alloc] init];
        
        _totalTimeRangeView = [[UIView alloc] init];
        _currentTimeRangeView = [[UIView alloc] init];
        
        _visible = YES;
    }
    
    return self;
}

- (void)dealloc {
    [_playerLayerObserver removeDelegate:self];
    
    [self cancelTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.hidden = _hidden;

    [self setupConstraints];
    [self setupViews];
    
    [_playerLayerObserver addDelegate:self];
    [self updateVisibility];
}

- (void)setHidden:(BOOL)hidden {
    _hidden = hidden;
    
    self.viewIfLoaded.hidden = hidden;
}

#pragma mark - Constraints

- (void)setupConstraints {
    // leftPaddingLayoutGuide
    UILayoutGuide *leftPaddingLayoutGuide = [UILayoutGuide new];
    [self.view addLayoutGuide:leftPaddingLayoutGuide];
    
    [leftPaddingLayoutGuide.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [leftPaddingLayoutGuide.widthAnchor constraintGreaterThanOrEqualToConstant:kMinPadding].active = YES;
    
    // restoreButton
    [self.view addSubview:_restoreButton];
    
    [_restoreButton.leadingAnchor constraintEqualToAnchor:leftPaddingLayoutGuide.trailingAnchor].active = YES;
    [_restoreButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-kButtonBottomPadding].active = YES;
    
    // firstSpacingLayoutGuide
    UILayoutGuide *firstSpacingLayoutGuide = [UILayoutGuide new];
    [self.view addLayoutGuide:firstSpacingLayoutGuide];
    
    [firstSpacingLayoutGuide.leftAnchor constraintEqualToAnchor:_restoreButton.rightAnchor].active = YES;
    [leftPaddingLayoutGuide.widthAnchor constraintEqualToAnchor:firstSpacingLayoutGuide.widthAnchor multiplier:kPaddingMultipiler].active = YES;
    
    // playPauseButton
    [self.view addSubview:_playPauseButton];
    
    [_playPauseButton.leadingAnchor constraintEqualToAnchor:firstSpacingLayoutGuide.trailingAnchor].active = YES;
    [_playPauseButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-kButtonBottomPadding].active = YES;
    [_playPauseButton.widthAnchor constraintEqualToAnchor:_restoreButton.widthAnchor].active = YES;
    
    // secondSpacingLayoutGuide
    UILayoutGuide *secondSpacingLayoutGuide = [UILayoutGuide new];
    [self.view addLayoutGuide:secondSpacingLayoutGuide];
    
    [secondSpacingLayoutGuide.leftAnchor constraintEqualToAnchor:_playPauseButton.rightAnchor].active = YES;
    [secondSpacingLayoutGuide.widthAnchor constraintEqualToAnchor:firstSpacingLayoutGuide.widthAnchor].active = YES;
    
    // closeButton
    [self.view addSubview:_closeButton];
    
    [_closeButton.leadingAnchor constraintEqualToAnchor:secondSpacingLayoutGuide.trailingAnchor].active = YES;
    [_closeButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-kButtonBottomPadding].active = YES;
    [_closeButton.widthAnchor constraintEqualToAnchor:_restoreButton.widthAnchor].active = YES;
    
    // rightPaddingLayoutGuide
    UILayoutGuide *rightPaddingLayoutGuide = [UILayoutGuide new];
    [self.view addLayoutGuide:rightPaddingLayoutGuide];
    
    [rightPaddingLayoutGuide.leftAnchor constraintEqualToAnchor:_closeButton.rightAnchor].active = YES;
    [rightPaddingLayoutGuide.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [rightPaddingLayoutGuide.widthAnchor constraintEqualToAnchor:leftPaddingLayoutGuide.widthAnchor].active = YES;
    
    // totalTimeRangeView
    _totalTimeRangeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_totalTimeRangeView];
    
    [_totalTimeRangeView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [_totalTimeRangeView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [_totalTimeRangeView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [_totalTimeRangeView.heightAnchor constraintEqualToConstant:3.5].active = YES;
    
    // currentTimeRangeView
    _currentTimeRangeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_currentTimeRangeView];
    
    [_currentTimeRangeView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [_currentTimeRangeView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [_currentTimeRangeView.heightAnchor constraintEqualToConstant:3].active = YES;
    
    self.playbackProgress = _playerLayerObserver.playbackProgress;
}

#pragma mark - Views

- (void)setupViews {
    _restoreButton.backgroundImage = [UIImage bundleImageNamed:@"StopPiPBackground"];
    _restoreButton.image = [UIImage bundleImageNamed:@"StopPiP"];
    
    _playPauseButton.backgroundImage = [UIImage bundleImageNamed:@"PlayBackground"];
    _playPauseButton.image = [UIImage bundleImageNamed:@"Play"];
    _playPauseButton.selectedBackgroundImage = [UIImage bundleImageNamed:@"PauseBackground"];
    _playPauseButton.selectedImage = [UIImage bundleImageNamed:@"Pause"];
    _playPauseButton.selected = _playerLayerObserver.playing;
    
    _closeButton.backgroundImage = [UIImage bundleImageNamed:@"CloseBackground"];
    _closeButton.image = [UIImage bundleImageNamed:@"Close"];
    
    _totalTimeRangeView.backgroundColor = [UIColor colorWithRed:0.27 green:0.23 blue:0.23 alpha:1.0];
    
    _currentTimeRangeView.backgroundColor = [UIColor colorWithRed:0.54 green:0.47 blue:0.46 alpha:1.0];
}

#pragma mark - PlaybackProgress

- (void)setPlaybackProgress:(CGFloat)playbackProgress {
    _playbackProgress = playbackProgress;
    
    _currentTimeRangeConstraint.active = NO;
    _currentTimeRangeConstraint = [_currentTimeRangeView.widthAnchor constraintEqualToAnchor:_totalTimeRangeView.widthAnchor multiplier:playbackProgress];
    _currentTimeRangeConstraint.active = YES;
}

- (void)setPlaybackProgress:(CGFloat)playbackProgress animated:(BOOL)animated {
    self.playbackProgress = playbackProgress;
    
    if (animated) {
        [UIView animateWithDuration:kUpdateProgressDuration animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - Timer

- (void)addTimerWithBlock:(void (^)(void))block {
    [self cancelTimer];
    
    _dispatchTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    
    uint64_t delay = (uint64_t)(kDelayBeforeHidding * (Float64)NSEC_PER_SEC);
    dispatch_source_set_timer(_dispatchTimer, dispatch_time(DISPATCH_TIME_NOW, delay), DISPATCH_TIME_FOREVER, 0);
    
    __weak PiPPlaybackControlsViewController *weakSelf = self;
    dispatch_source_set_event_handler(_dispatchTimer, ^{
        [weakSelf cancelTimer];
        block();
    });
    
    dispatch_resume(_dispatchTimer);
}

- (void)cancelTimer {
    if (_dispatchTimer) {
        dispatch_source_cancel(_dispatchTimer);
        _dispatchTimer = nil;
    }
}

#pragma mark - Visibility

- (void)toggleVisibility {
    if (_visible) {
        [self hideAnimated];
    } else {
        [self showAnimated];
    }
}

- (void)updateVisibility {
    if (_playerLayerObserver.playing) {
        [self hideAnimatedAfterDelayIfPlaying];
    } else {
        [self showAnimated];
    }
}

- (void)hideAnimatedAfterDelayIfPlaying {
    if (!_playerLayerObserver.playing) {
        return;
    }
    
    __weak PiPPlaybackControlsViewController *weakSelf = self;
    [self addTimerWithBlock:^{
        [weakSelf hideAnimated];
    }];
}

- (void)showAnimated {
    [self cancelTimer];
    [self hideAnimatedAfterDelayIfPlaying];
    
    if (_visible) {
        return;
    }
    _visible = YES;
    
    [UIView animateWithDuration:kFadeDuration animations:^{
        self.view.alpha = 1;
    }];
}

- (void)hideAnimated {
    [self cancelTimer];
    
    if (!_visible) {
        return;
    }
    _visible = NO;
    
    [UIView animateWithDuration:kFadeDuration animations:^{
        self.view.alpha = 0;
    }];
}

#pragma mark - PiPPlayerLayerObserverDelegate

- (void)playerLayerObserverDidChangePlayingState:(PiPPlayerLayerObserver *)playerLayerObserver {
    _playPauseButton.selected = _playerLayerObserver.playing;
    [self updateVisibility];
}

- (void)playerLayerObserverDidChangePlaybackProgress:(PiPPlayerLayerObserver *)playerLayerObserver {
    [self setPlaybackProgress:playerLayerObserver.playbackProgress animated:YES];
}

@end

//
//  PiPPlayerViewController.m
//  PiPhone
//
//  Created by KY1VSTAR on 01.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import <objc/runtime.h>
#import "PiPPlayerViewController.h"
#import "PiPPictureInPictureController.h"
#import "PiPPlayerLayerObserver.h"
#import "PiPPlayerView.h"
#import "PiPRootViewController.h"
#import "PiPWindow.h"
#import "PiPRuntime.h"
#import "PiPPlaybackControlsViewController.h"
#import "PiPLoadingIndicatorView.h"
#import "PiPStashedView.h"

#pragma mark - Constants

#define kEdgeSpacing 4.f
#define kHiddenEdgeSpacing 44.f
#define kShowHideAnimationDuration 0.3f
#define kMoveAnimationDuration 0.3f
#define kMinWidth 180.f
#define kMinHeight 160.f
#define kMaxSideSize 475.f
#define kOnePixelSize 1.0 / UIScreen.mainScreen.scale

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

static CGFloat kDecelerationRate;
static CGFloat previousScaleProgress = 0.f;
static PiPPlayerViewControllerPosition previousPosition = PiPPlayerViewControllerPositionTopRight;

#pragma mark - PiPPlayerViewControllerPosition

static BOOL PiPPlayerViewControllerPositionIsTop(PiPPlayerViewControllerPosition position) {
    return position == PiPPlayerViewControllerPositionTopLeft || position == PiPPlayerViewControllerPositionTopRight || position == PiPPlayerViewControllerPositionTopLeftHidden || position == PiPPlayerViewControllerPositionTopRightHidden;
}

static BOOL PiPPlayerViewControllerPositionIsLeft(PiPPlayerViewControllerPosition position) {
    return position == PiPPlayerViewControllerPositionTopLeft || position == PiPPlayerViewControllerPositionBottomLeft;
}

static BOOL PiPPlayerViewControllerPositionIsLeftHidden(PiPPlayerViewControllerPosition position) {
    return position == PiPPlayerViewControllerPositionTopLeftHidden || position == PiPPlayerViewControllerPositionBottomLeftHidden;
}

static BOOL PiPPlayerViewControllerPositionIsRight(PiPPlayerViewControllerPosition position) {
    return position == PiPPlayerViewControllerPositionTopRight || position == PiPPlayerViewControllerPositionBottomRight;
}

static BOOL PiPPlayerViewControllerPositionIsRightHidden(PiPPlayerViewControllerPosition position) {
    return position == PiPPlayerViewControllerPositionTopRightHidden || position == PiPPlayerViewControllerPositionBottomRightHidden;
}

static PiPPlayerViewControllerPosition PiPPlayerViewControllerPositionVisiblePosition(PiPPlayerViewControllerPosition position) {
    switch (position) {
        case PiPPlayerViewControllerPositionTopLeftHidden:
            return PiPPlayerViewControllerPositionTopLeft;
            
        case PiPPlayerViewControllerPositionTopRightHidden:
            return PiPPlayerViewControllerPositionTopRight;
            
        case PiPPlayerViewControllerPositionBottomLeftHidden:
            return PiPPlayerViewControllerPositionBottomLeft;
            
        case PiPPlayerViewControllerPositionBottomRightHidden:
            return PiPPlayerViewControllerPositionBottomRight;
            
        default:
            return position;
    }
}

#pragma mark - PiPPlayerViewController

@interface PiPPlayerViewController () <PiPPlayerLayerObserverDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) PiPPictureInPictureController *pictureInPictureController;
@property (nonatomic) PiPPlayerLayerObserver *playerLayerObserver;
@property (nonatomic) PiPPlayerViewControllerPosition position;
@property (nonatomic) BOOL didStart;
@property (nonatomic) BOOL didStop;
@property (nonatomic) CGSize minSize;
@property (nonatomic) CGSize maxSize;
@property (nonatomic) CGFloat scaleProgress; // 0.0 - minSize; 1.0 - maxSize

@property (nonatomic) AVPlayerLayer *internalPlayerLayer;
@property (nonatomic) AVPlayerLayer *sourcePlayerLayer;

@property (nonatomic) UIView *shadowContainerView;
@property (nonatomic) UIView *playerContainerView;
@property (nonatomic) PiPPlayerView *playerView;
@property (nonatomic) PiPLoadingIndicatorView *loadingIndicatorView;
@property (nonatomic) PiPPlaybackControlsViewController *playbackControlsViewController;
@property (nonatomic) PiPStashedView *stashedView;
@property (nonatomic) UIView *overlayView;

@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) CGPoint panInitialCenter;
@property (nonatomic) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (nonatomic) CGFloat pinchMinScale;
@property (nonatomic) CGFloat pinchMaxScale;

@property (nonatomic) BOOL autoLayoutEnabled;
@property (nonatomic) NSLayoutConstraint *topConstraint;
@property (nonatomic) NSLayoutConstraint *bottomConstraint;
@property (nonatomic) NSLayoutConstraint *leftConstraint;
@property (nonatomic) NSLayoutConstraint *rightConstraint;
@property (nonatomic) NSLayoutConstraint *leftHiddenConstraint;
@property (nonatomic) NSLayoutConstraint *rightHiddenConstraint;
@property (nonatomic) NSLayoutConstraint *widthConstraint;
@property (nonatomic) NSLayoutConstraint *heightConstraint;

@end

@implementation PiPPlayerViewController

+ (void)initialize {
    kDecelerationRate = [UIScrollView new].decelerationRate / 1.001;
}

- (instancetype)initWithPictureInPictureController:(PiPPictureInPictureController *)pictureInPictureController {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _playerView = [[PiPPlayerView alloc] init];
        _playbackControlsViewController = [[PiPPlaybackControlsViewController alloc] initWithPlayerLayerObserver:pictureInPictureController.playerLayerObserver];
        
        _pictureInPictureController = pictureInPictureController;
        _playerLayerObserver = pictureInPictureController.playerLayerObserver;
        
        _internalPlayerLayer = _playerView.playerLayer;
        _sourcePlayerLayer = pictureInPictureController.playerLayer;
        
        [_playerLayerObserver addDelegate:self];
    }
    
    return self;
}

- (void)dealloc {
    [_playerLayerObserver removeDelegate:self];
}

#pragma mark - ViewController's life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.clipsToBounds = NO;
    
    [self setupShadowContainerView];
    [self setupPlayerView];
    [self setupOverlayView];
    [self setupGestures];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillEnterForegroun) name:UIApplicationWillEnterForegroundNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self updateSizes];
}

#pragma mark - Setup

- (void)setupShadowContainerView {
    // shadowContainerView
    _shadowContainerView = [[UIView alloc] initWithFrame:CGRectInset(self.view.bounds, -kOnePixelSize, -kOnePixelSize)];
    _shadowContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _shadowContainerView.alpha = 0;
    [self.view addSubview:_shadowContainerView];
    
    // shadowView
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectInset(_shadowContainerView.bounds, kOnePixelSize, kOnePixelSize)];
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    shadowView.backgroundColor = UIColor.blackColor;
    shadowView.layer.cornerRadius = 2;
    shadowView.layer.shadowRadius = 10.5;
    shadowView.layer.shadowOpacity = 0.25;
    shadowView.layer.shadowOffset = CGSizeMake(0, 3);
    shadowView.layer.shadowColor = UIColor.blackColor.CGColor;
    [_shadowContainerView addSubview:shadowView];
    
    // backgroundView
    UIView *backgroundView = [[UIView alloc] initWithFrame:_shadowContainerView.bounds];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
    backgroundView.layer.cornerRadius = 2 + kOnePixelSize;
    [_shadowContainerView addSubview:backgroundView];
}

- (void)setupPlayerView {
    // playerContainerView
    _playerContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    _playerContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _playerContainerView.backgroundColor = UIColor.blackColor;
    _playerContainerView.clipsToBounds = YES;
    [self.view addSubview:_playerContainerView];
    
    // playerView
    _playerView.frame = self.view.bounds;
    _playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _playerView.userInteractionEnabled = NO;
    [_playerContainerView addSubview:_playerView];
    
    // loadingIndicatorView
    _loadingIndicatorView = [[PiPLoadingIndicatorView alloc] initWithFrame:self.view.bounds];
    _loadingIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_playerContainerView addSubview:_loadingIndicatorView];
    
    // stashedView
    _stashedView = [[PiPStashedView alloc] initWithFrame:self.view.bounds];
    _stashedView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_playerContainerView addSubview:_stashedView];
}

- (void)setupOverlayView {
    _overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    _overlayView.alpha = 0;
    _overlayView.userInteractionEnabled = NO;
    _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _overlayView.layer.cornerRadius = 2;
    _overlayView.layer.borderWidth = kOnePixelSize;
    _overlayView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.15].CGColor;
    [self.view addSubview:_overlayView];
}

- (void)setupPlaybackControlsViewController {
    [self addChildViewController:_playbackControlsViewController];
    
    _playbackControlsViewController.view.frame = _playerContainerView.bounds;
    [_playerContainerView addSubview:_playbackControlsViewController.view];
    
    [_playbackControlsViewController didMoveToParentViewController:self];
    
    [_playbackControlsViewController.restoreButton addTarget:self action:@selector(stopWithRestoringUserInterface) forControlEvents:UIControlEventTouchUpInside];
    [_playbackControlsViewController.playPauseButton addTarget:self action:@selector(playPauseButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_playbackControlsViewController.closeButton addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Auto Layout

- (void)setupConstraints {
    PiPRootViewController *rootViewController = PiPRootViewController.shared;
    
    if (self.view.superview != rootViewController.view) return;
    
    _topConstraint = [self.view.topAnchor constraintEqualToAnchor:rootViewController.contentLayoutGuide.topAnchor constant:kEdgeSpacing];
    _bottomConstraint = [self.view.bottomAnchor constraintEqualToAnchor:rootViewController.contentLayoutGuide.bottomAnchor constant:-kEdgeSpacing];
    
    _leftConstraint = [self.view.leftAnchor constraintEqualToAnchor:rootViewController.contentLayoutGuide.leftAnchor constant:kEdgeSpacing];
    _rightConstraint = [self.view.rightAnchor constraintEqualToAnchor:rootViewController.contentLayoutGuide.rightAnchor constant:-kEdgeSpacing];
    
    _leftHiddenConstraint = [self.view.rightAnchor constraintEqualToAnchor:rootViewController.contentLayoutGuide.leftAnchor constant:kHiddenEdgeSpacing];
    _rightHiddenConstraint = [self.view.leftAnchor constraintEqualToAnchor:rootViewController.contentLayoutGuide.rightAnchor constant:-kHiddenEdgeSpacing];
    
    _widthConstraint = [self.view.widthAnchor constraintEqualToConstant:0];
    _heightConstraint = [self.view.heightAnchor constraintEqualToConstant:0];
}

- (void)setAutoLayoutEnabled:(BOOL)autoLayoutEnabled {
    _autoLayoutEnabled = autoLayoutEnabled;
    
    if (autoLayoutEnabled) {
        self.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self setPosition:self.position];
        
        [NSLayoutConstraint activateConstraints:@[_widthConstraint, _heightConstraint]];
    } else {
        [NSLayoutConstraint deactivateConstraints:@[_leftConstraint, _leftHiddenConstraint, _rightConstraint, _rightHiddenConstraint, _topConstraint, _bottomConstraint, _widthConstraint, _heightConstraint]];
        
        self.view.translatesAutoresizingMaskIntoConstraints = YES;
    }
}

#pragma mark - Gestures

- (void)setupGestures {
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_tapGestureRecognizer];
    
    _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    _doubleTapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_doubleTapGestureRecognizer];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:_panGestureRecognizer];
    
    _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:_pinchGestureRecognizer];
    
    [_tapGestureRecognizer requireGestureRecognizerToFail:_doubleTapGestureRecognizer];
    [_tapGestureRecognizer requireGestureRecognizerToFail:_panGestureRecognizer];
    [_doubleTapGestureRecognizer requireGestureRecognizerToFail:_panGestureRecognizer];
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    if (!_stashedView.visible) {
        [_playbackControlsViewController toggleVisibility];
        return;
    }
    
    self.position = PiPPlayerViewControllerPositionVisiblePosition(self.position);
    [self.view.superview setNeedsLayout];
    
    [UIView animateWithDuration:kMoveAnimationDuration delay:0 usingSpringWithDamping:1.f initialSpringVelocity:0.1f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view.superview layoutIfNeeded];
        [self updateViewsVisibility];
    } completion:nil];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    self.scaleProgress = 0;
    [self.view.superview setNeedsLayout];
    
    [UIView animateWithDuration:kShowHideAnimationDuration animations:^{
        [self.view.superview layoutIfNeeded];
    }];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view.superview];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _panInitialCenter = self.view.center;
        [_stashedView setChevronState:PiPStashedViewChevronStateNormal animated:YES];
    }
    
    if (gesture.state != UIGestureRecognizerStateCancelled && gesture.state != UIGestureRecognizerStateFailed) {
        self.view.transform = CGAffineTransformMakeTranslation(translation.x, translation.y);
        
        [self updateViewsVisibility];
        
        if (gesture.state == UIGestureRecognizerStateEnded) {
            self.view.transform = CGAffineTransformIdentity;
            
            CGPoint newCenter = CGPointMake(self.panInitialCenter.x + translation.x, self.panInitialCenter.y + translation.y);
            self.view.center = newCenter;
            
            CGPoint velocity = [gesture velocityInView:self.view.superview];
            CGPoint throwDistance = CGPointMake([self throwDistanceForInitialVelocity:velocity.x], [self throwDistanceForInitialVelocity:velocity.y]);
            CGPoint throwPoint = CGPointMake(newCenter.x + throwDistance.x, newCenter.y + throwDistance.y);
            
            self.position = [self nearestPositionForPoint:throwPoint];
            [self.view.superview setNeedsLayout];
            
            [UIView animateWithDuration:kMoveAnimationDuration delay:0 usingSpringWithDamping:1.f initialSpringVelocity:0.1f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.view.superview layoutIfNeeded];
                [self updateViewsVisibility];
            } completion:nil];
            
            [_stashedView setChevronState:PiPStashedViewChevronStateInteractable animated:YES];
        }
    } else {
        self.view.transform = CGAffineTransformIdentity;
        [_stashedView setChevronState:PiPStashedViewChevronStateInteractable animated:YES];
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _playbackControlsViewController.view.hidden = YES;
        
        _pinchMinScale = _minSize.width / self.view.frame.size.width;
        _pinchMaxScale = _maxSize.width / self.view.frame.size.width;
    }
    
    if (gesture.state != UIGestureRecognizerStateCancelled && gesture.state != UIGestureRecognizerStateFailed) {
        // https://github.com/PaulSolt/LimitPinchGestureZoom
        float currentScale = [[gesture.view.layer valueForKeyPath:@"transform.scale.x"] floatValue];
        float zoomSpeed = .5;
        float deltaScale = gesture.scale;
        
        deltaScale = ((deltaScale - 1) * zoomSpeed) + 1;
        
        // Limit to min/max size (i.e maxScale = 2, current scale = 2, 2/2 = 1.0)
        //  A deltaScale is ~0.99 for decreasing or ~1.01 for increasing
        //  A deltaScale of 1.0 will maintain the zoom size
        deltaScale = MIN(deltaScale, _pinchMaxScale / currentScale);
        deltaScale = MAX(deltaScale, _pinchMinScale / currentScale);
        
        CGAffineTransform zoomTransform = CGAffineTransformScale(gesture.view.transform, deltaScale, deltaScale);
        gesture.view.transform = zoomTransform;
        
        // Reset to 1 for scale delta's
        // Note: not 0, or we won't see a size: 0 * width = 0
        gesture.scale = 1;
        
        if (gesture.state == UIGestureRecognizerStateEnded) {
            self.scaleProgress = [self scaleProgressForWidth:self.view.frame.size.width];
            [self.view.superview setNeedsLayout];
            
            [UIView animateWithDuration:kShowHideAnimationDuration animations:^{
                self.view.transform = CGAffineTransformIdentity;
                [self.view.superview layoutIfNeeded];
            } completion:^(BOOL finished) {
                [self updateViewsVisibility];
            }];
        }
    } else {
        self.view.transform = CGAffineTransformIdentity;
        [self updateViewsVisibility];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == _doubleTapGestureRecognizer) {
        if (self.scaleProgress == 0) {
            return NO;
        }
    }
    
    CGPoint location = [gestureRecognizer locationInView:self.view];
    UIView *hitView = [self.view hitTest:location withEvent:nil];
    
    return ![hitView isKindOfClass:UIControl.class];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Action

- (void)playPauseButtonTapped {
    if (_playerLayerObserver.playing) {
        [_internalPlayerLayer.player pause];
    } else {
        [_internalPlayerLayer.player play];
    }
}

- (void)updateViewsVisibility {
    CGRect layoutGuideRect = PiPRootViewController.shared.contentLayoutGuide.layoutFrame;
    CGRect visibleRectInLayoutGuide = CGRectIntersection(layoutGuideRect, self.view.frame);
    
    if (visibleRectInLayoutGuide.size.width < self.view.frame.size.width / 2) {
        _stashedView.visible = YES;
    } else if (visibleRectInLayoutGuide.size.width > self.view.frame.size.width * 2 / 3) {
        _stashedView.visible = NO;
    }
    
    if (_stashedView.visible) {
        if (self.view.frame.origin.x <= layoutGuideRect.origin.x) {
            _stashedView.poition = PiPStashedViewPositionRight;
        } else {
            _stashedView.poition = PiPStashedViewPositionLeft;
        }
    }
    
    if (_playerLayerObserver.initializing) {
        _loadingIndicatorView.hidden = NO;
        _playbackControlsViewController.hidden = YES;
    } else {
        _loadingIndicatorView.hidden = YES;
        _playbackControlsViewController.hidden = _stashedView.visible;
    }
}

- (void)applicationWillEnterForegroun {
    if (!_didStart || _didStop) {
        return;
    }

    SuppressPerformSelectorLeakWarning([_sourcePlayerLayer performSelector:kEnterPIPModeRedirectingVideoToLayer withObject:_internalPlayerLayer]);
}

- (void)applicationDidEnterBackground {
    if (!_didStart || _didStop) {
        return;
    }
    
    // without doing so our AVPlayerLayer will display black screen
    SuppressPerformSelectorLeakWarning([_sourcePlayerLayer performSelector:kEnterPIPModeRedirectingVideoToLayer withObject:[AVPlayerLayer new]]);
}

#pragma mark - Position

- (void)setPosition:(PiPPlayerViewControllerPosition)position {
    _position = position;
    previousPosition = PiPPlayerViewControllerPositionVisiblePosition(position);
    
    NSMutableArray<NSLayoutConstraint *> *constraintsToActivate = [NSMutableArray array];
    NSMutableArray<NSLayoutConstraint *> *constraintsToDeactivate = [NSMutableArray arrayWithObjects:_topConstraint, _bottomConstraint, _leftConstraint, _rightConstraint, _leftHiddenConstraint, _rightHiddenConstraint, nil];
    
    if (PiPPlayerViewControllerPositionIsTop(position)) {
        [constraintsToActivate addObject:_topConstraint];
    } else {
        [constraintsToActivate addObject:_bottomConstraint];
    }
    
    if (PiPPlayerViewControllerPositionIsLeft(position)) {
        [constraintsToActivate addObject:_leftConstraint];
    } else if (PiPPlayerViewControllerPositionIsLeftHidden(position)) {
        [constraintsToActivate addObject:_leftHiddenConstraint];
    } else if (PiPPlayerViewControllerPositionIsRight(position)) {
        [constraintsToActivate addObject:_rightConstraint];
    } else if (PiPPlayerViewControllerPositionIsRightHidden(position)) {
        [constraintsToActivate addObject:_rightHiddenConstraint];
    }
    
    for (NSLayoutConstraint *constraint in constraintsToActivate) {
        [constraintsToDeactivate removeObject:constraint];
    }
    
    [NSLayoutConstraint deactivateConstraints:constraintsToDeactivate];
    [NSLayoutConstraint activateConstraints:constraintsToActivate];
}

# pragma mark - Size

- (void)updateSizes {
    // cancel recognized gestures
    for (UIGestureRecognizer *gesture in @[_panGestureRecognizer, _pinchGestureRecognizer]) {
        if (gesture.enabled) {
            gesture.enabled = NO;
            gesture.enabled = YES;
        }
    }
    
    CGSize presentationSize = _playerLayerObserver.presentationSize;
    CGSize contentSize = PiPRootViewController.shared.contentLayoutGuide.layoutFrame.size;
    
    if (CGSizeEqualToSize(presentationSize, CGSizeZero)) {
        return;
    }
    
    CGSize maxAvailableSize = CGSizeMake(MIN(kMaxSideSize, contentSize.width - kHiddenEdgeSpacing / 2),
                                         MIN(kMaxSideSize, contentSize.height - kHiddenEdgeSpacing / 2));
    
    if (presentationSize.width > presentationSize.height) {
        CGFloat minWidth = (kMinHeight / presentationSize.height) * presentationSize.width;
        _minSize = CGSizeMake(MIN(maxAvailableSize.width, minWidth), kMinHeight);
    } else {
        CGFloat minHeight = (kMinWidth / presentationSize.width) * presentationSize.height;
        _minSize = CGSizeMake(kMinWidth, MIN(maxAvailableSize.height, minHeight));
    }
    
    _maxSize = AVMakeRectWithAspectRatioInsideRect(_minSize, CGRectMake(0, 0, maxAvailableSize.width, maxAvailableSize.height)).size;
    
    // if maxSize nearly equals minSize disable pinch gesture
    _pinchGestureRecognizer.enabled = ABS(_maxSize.width - _minSize.width) > 5;
    
    self.scaleProgress = _scaleProgress;
}

- (void)setScaleProgress:(CGFloat)scaleProgress {
    _scaleProgress = MAX(0, MIN(scaleProgress, 1));
    previousScaleProgress = _scaleProgress;
    
    _widthConstraint.constant = _minSize.width + (_maxSize.width - _minSize.width) * scaleProgress;
    _heightConstraint.constant = _minSize.height + (_maxSize.height - _minSize.height) * scaleProgress;
}

#pragma mark - Start

- (void)start {
    if (_didStart) {
        return;
    }
    _didStart = YES;
    
    [_pictureInPictureController playerViewControllerWillStartPictureInPicture:self];
    
    // disable user interaction
    [PiPWindow.shared startAnimating];
    
    // add itself to PiPRootViewController
    PiPRootViewController *rootViewController = PiPRootViewController.shared;
    
    [rootViewController addChildViewController:self];
    [rootViewController.view addSubview:self.view];
    [self didMoveToParentViewController:rootViewController];
    
    // setup sizes and position
    [self setupConstraints];
    _position = previousPosition;
    _scaleProgress = previousScaleProgress;
    [self updateSizes];
    
    // show PiP placeholder for __AVPlayerLayerView and AVPlayerLayer
    id placeholderContentLayer;
    if ([_pictureInPictureController.playerLayerView respondsToSelector:kStartRoutingVideoToPictureInPicturePlayerLayerView]) {
        SuppressPerformSelectorLeakWarning([_pictureInPictureController.playerLayerView performSelector:kStartRoutingVideoToPictureInPicturePlayerLayerView]);
        
    } else if ([_sourcePlayerLayer respondsToSelector:kSetPlaceholderContentLayerDuringPIPMode] && (placeholderContentLayer = [PiPRuntime newPiPIndicatorLayer])) {
        SuppressPerformSelectorLeakWarning([_sourcePlayerLayer performSelector:kSetPlaceholderContentLayerDuringPIPMode withObject:placeholderContentLayer]);
    }
    
    SuppressPerformSelectorLeakWarning([_sourcePlayerLayer performSelector:kEnterPIPModeRedirectingVideoToLayer withObject:_internalPlayerLayer]);
    
    // start animation transaction
    [CATransaction begin];
    [CATransaction setAnimationDuration:kShowHideAnimationDuration];
    
    // perform either fade or zoom animation and show decorations (cornerRadius and shadow)
    UIWindow *playerLayerWindow = [self windowForLayer:_sourcePlayerLayer];
    if (playerLayerWindow) {
        [self startWithZoomAnimation:playerLayerWindow];
        [self setDecorationEnabled:YES animated:YES];
    } else {
        [self startWithFadeAnimation];
        [self setDecorationEnabled:YES animated:NO];
    }
    
    [CATransaction commit];
}

- (void)startWithFadeAnimation {
    self.autoLayoutEnabled = YES;
    self.view.transform = CGAffineTransformScale(self.view.transform, 0.1, 0.1);
    self.view.alpha = 0;
    
    [UIView animateWithDuration:kShowHideAnimationDuration animations:^{
        self.view.transform = CGAffineTransformIdentity;
        self.view.alpha = 1;
    } completion:^(BOOL finished) {
        [self finishStartTransition];
    }];
}

- (void)startWithZoomAnimation:(UIWindow *)playerLayerWindow {
    CGRect playerLayerRect = [playerLayerWindow.layer convertRect:_sourcePlayerLayer.videoRect fromLayer:_sourcePlayerLayer];
    self.view.frame = [playerLayerWindow convertRect:playerLayerRect toWindow:PiPWindow.shared];

    [UIView animateWithDuration:kShowHideAnimationDuration animations:^{
        self.view.frame = [self rectForPosition:self.position];
    } completion:^(BOOL finished) {
        self.autoLayoutEnabled = YES;

        [self finishStartTransition];
    }];
}

- (void)finishStartTransition {
    if (!_didStop) {
        [self setupPlaybackControlsViewController];
    }
    
    [self.pictureInPictureController playerViewControllerDidStartPictureInPicture:self];
    
    // enable user interaction
    [PiPWindow.shared stopAnimating];
}

#pragma mark - Stop

- (void)stop {
    [self stopImmediately:NO];
}

- (void)stopWithRestoringUserInterface {
    if (_didStop) {
        return;
    }
    _didStop = YES;
    
    // disable user interaction
    [PiPWindow.shared startAnimating];
    
    __block BOOL shouldExecute = YES;
    
    void (^block)(BOOL restored) = ^(BOOL restored) {
        if (!shouldExecute) {
            return;
        }
        shouldExecute = NO;
        
        [self stopImmediately:YES];
    };
    
    // - [AVPictureInPictureControllerDelegate pictureInPictureController:restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:] default behaviour is waiting approximately 0.5 seconds for delegate call completionHandler
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC / 2)), dispatch_get_main_queue(), ^{
        block(YES);
    });
    
    [_pictureInPictureController playerViewController:self restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:^(BOOL restored) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(restored);
        });
    }];
}

- (void)stopImmediately:(BOOL)ignoreDidStop {
    if (_didStop && !ignoreDidStop) {
        return;
    }
    _didStop = YES;
    
    // disable user interaction
    if (!ignoreDidStop) {
        [PiPWindow.shared startAnimating];
    }
    
    [_pictureInPictureController playerViewControllerWillStopPictureInPicture:self];
    
    // hide controls
    [_playbackControlsViewController.viewIfLoaded removeFromSuperview];
    [_loadingIndicatorView removeFromSuperview];
    [_stashedView removeFromSuperview];
    
    // start animation transaction
    [CATransaction begin];
    [CATransaction setAnimationDuration:kShowHideAnimationDuration];
    
    // perform either fade or zoom animation and hide decorations (cornerRadius and shadow)
    UIWindow *playerLayerWindow = [self windowForLayer:_sourcePlayerLayer];
    if (playerLayerWindow) {
        [self stopWithZoomAnimation:playerLayerWindow];
        [self setDecorationEnabled:NO animated:YES];
    } else {
        [self stopWithFadeAnimation];
        [self setDecorationEnabled:NO animated:NO];
    }
    
    [CATransaction commit];
}

- (void)stopWithFadeAnimation {
    [UIView animateWithDuration:kShowHideAnimationDuration animations:^{
        self.view.transform = CGAffineTransformScale(self.view.transform, 0.1, 0.1);
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self finishStopTranistion];
    }];
}

- (void)stopWithZoomAnimation:(UIWindow *)playerLayerWindow {
    CGRect playerLayerRect = [playerLayerWindow.layer convertRect:_sourcePlayerLayer.videoRect fromLayer:_sourcePlayerLayer];
    playerLayerRect = [playerLayerWindow convertRect:playerLayerRect toWindow:PiPWindow.shared];
    
    self.autoLayoutEnabled = NO;
    
    [UIView animateWithDuration:kShowHideAnimationDuration animations:^{
        self.view.frame = playerLayerRect;
    } completion:^(BOOL finished) {
        [self finishStopTranistion];
    }];
}

- (void)finishStopTranistion {
    // hide PiP placeholder for __AVPlayerLayerView and AVPlayerLayer
    if ([_pictureInPictureController.playerLayerView respondsToSelector:kStopRoutingVideoToPictureInPicturePlayerLayerView]) {
        SuppressPerformSelectorLeakWarning([_pictureInPictureController.playerLayerView performSelector:kStopRoutingVideoToPictureInPicturePlayerLayerView]);
    }
    
    SuppressPerformSelectorLeakWarning([_sourcePlayerLayer performSelector:kLeavePIPMode]);
    
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    [_pictureInPictureController playerViewControllerDidStopPictureInPicture:self];
    
    // enable user interaction
    [PiPWindow.shared stopAnimating];
}

#pragma mark - Helper

- (void)setDecorationEnabled:(BOOL)enabled animated:(BOOL)animated {
    if (!animated) {
        _shadowContainerView.alpha = enabled ? 1 : 0;
        _overlayView.alpha = enabled ? 1 : 0;
        _playerContainerView.layer.cornerRadius = 2;
        
        return;
    }
    
    [UIView animateWithDuration:kShowHideAnimationDuration animations:^{
        self.shadowContainerView.alpha = enabled ? 1 : 0;
        self.overlayView.alpha = enabled ? 1 : 0;
    }];
    
    // cornerRadius animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    animation.fromValue = @(enabled ? 0 : 2);
    animation.toValue = @(enabled ? 2 : 0);
    
    [_playerContainerView.layer addAnimation:animation forKey:@"cornerRadiusAnimation"];
    _playerContainerView.layer.cornerRadius = 2;
}

- (CGFloat)throwDistanceForInitialVelocity:(CGFloat)velocity {
    return (velocity / 3000.f) * kDecelerationRate / (1.0 - kDecelerationRate);
}

- (UIWindow * _Nullable)windowForLayer:(CALayer *)layer {
    CALayer *superlayer = layer;
    
    while (superlayer.superlayer) {
        superlayer = superlayer.superlayer;
    }
    
    Ivar ivar = class_getInstanceVariable(superlayer.class, "_window");
    if (ivar) {
        return object_getIvar(superlayer, ivar);
    }

    return nil;
}

- (PiPPlayerViewControllerPosition)nearestPositionForPoint:(CGPoint)point {
    CGFloat minDistance = CGFLOAT_MAX;
    PiPPlayerViewControllerPosition resultPosition = PiPPlayerViewControllerPositionTopLeft;
    
    for (PiPPlayerViewControllerPosition position = PiPPlayerViewControllerPositionTopLeft; position <= PiPPlayerViewControllerPositionBottomRightHidden; position++) {
        CGPoint positionCenter = [self centerForRect:[self rectForPosition:position]];
        CGFloat distance = [self distanceBetweenPoint:positionCenter andPoint:point];
        
        if (distance < minDistance) {
            resultPosition = position;
            minDistance = distance;
        }
    }
    
    return resultPosition;
}

- (CGRect)rectForPosition:(PiPPlayerViewControllerPosition)position {
    CGRect layoutGuideRect = PiPRootViewController.shared.contentLayoutGuide.layoutFrame;
    CGSize size = CGSizeMake(_widthConstraint.constant, _heightConstraint.constant); //self.view.frame.size;
    
    CGFloat leftX = layoutGuideRect.origin.x + kEdgeSpacing;
    CGFloat leftHiddenX = layoutGuideRect.origin.x + kHiddenEdgeSpacing - size.width;
    
    CGFloat rightX = CGRectGetMaxX(layoutGuideRect) - size.width - kEdgeSpacing;
    CGFloat rightHiddenX = CGRectGetMaxX(layoutGuideRect) - kHiddenEdgeSpacing;
    
    CGFloat topY = layoutGuideRect.origin.y + kEdgeSpacing;
    CGFloat bottomY = CGRectGetMaxY(layoutGuideRect) - size.height - kEdgeSpacing;
    
    switch (position) {
        case PiPPlayerViewControllerPositionTopLeft:
            return CGRectMake(leftX, topY, size.width, size.height);
            
        case PiPPlayerViewControllerPositionTopLeftHidden:
            return CGRectMake(leftHiddenX, topY, size.width, size.height);
            
        case PiPPlayerViewControllerPositionTopRight:
            return CGRectMake(rightX, topY, size.width, size.height);
            
        case PiPPlayerViewControllerPositionTopRightHidden:
            return CGRectMake(rightHiddenX, topY, size.width, size.height);
            
        case PiPPlayerViewControllerPositionBottomLeft:
            return CGRectMake(leftX, bottomY, size.width, size.height);
            
        case PiPPlayerViewControllerPositionBottomLeftHidden:
            return CGRectMake(leftHiddenX, bottomY, size.width, size.height);
            
        case PiPPlayerViewControllerPositionBottomRight:
            return CGRectMake(rightX, bottomY, size.width, size.height);
            
        case PiPPlayerViewControllerPositionBottomRightHidden:
            return CGRectMake(rightHiddenX, bottomY, size.width, size.height);
    }
}

- (CGPoint)centerForRect:(CGRect)rect {
    return CGPointMake(rect.origin.x + rect.size.width / 2.f, rect.origin.y + rect.size.height / 2.f);
}

- (CGFloat)distanceBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2 {
    CGFloat diffX = point1.x - point2.x;
    CGFloat diffY = point1.y - point2.y;
    return sqrt(diffX * diffX + diffY * diffY);
}

- (CGFloat)scaleProgressForWidth:(CGFloat)width {
    if (_maxSize.width - _minSize.width == 0) {
        return 0;
    }
    return (width - _minSize.width) / (_maxSize.width - _minSize.width);
}

#pragma mark - PiPPlayerLayerObserverDelegate

- (void)playerLayerObserverDidChangePresentationSize:(PiPPlayerLayerObserver *)playerLayerObserver {
    [self updateSizes];
}

- (void)playerLayerObserverDidChangeShouldDismiss:(PiPPlayerLayerObserver *)playerLayerObserver {
    if (playerLayerObserver.shouldDismiss) {
        // Must be called asynchronously due to `Cannot remove an observer <NSKeyValueObservance 0x...> for the key path "currentItem.hasEnabledAudio" from <AVQueuePlayer 0x...>, most likely because the value for the key "currentItem" has changed without an appropriate KVO notification being sent. Check the KVO-compliance of the AVQueuePlayer class` exception
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stop];
        });
    }
}

- (void)playerLayerObserverDidChangeInitializingState:(PiPPlayerLayerObserver *)playerLayerObserver {
    [self updateViewsVisibility];
}

@end

//
//  PiPRootViewController.m
//  PiPhone
//
//  Created by KY1VSTAR on 01.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import "PiPRootViewController.h"
#import "PiPWindow.h"
#import "PiPRootView.h"
#import "PiPPictureInPictureController.h"
#import "PiPManager.h"

#define kNavigationBarDefaultHeight 44.f
#define kNavigationBarCompactHeight 32.f
#define kTabBarDefaultHeight 49.f
#define kTabBarCompactHeight 32.f
#define kAnimationDuration 0.2f

@interface PiPRootViewController ()

@property (nonatomic) NSLayoutConstraint *topSafeAreaConstraint;
@property (nonatomic) NSLayoutConstraint *bottomSafeAreaConstraint;
@property (nonatomic) NSLayoutConstraint *leftSafeAreaConstraint;
@property (nonatomic) NSLayoutConstraint *rightSafeAreaConstraint;

@property (nonatomic) NSLayoutConstraint *topEdgeConstraint;
@property (nonatomic) NSLayoutConstraint *bottomEdgeConstraint;
@property (nonatomic) NSLayoutConstraint *leftEdgeConstraint;
@property (nonatomic) NSLayoutConstraint *rightEdgeConstraint;

@end

@implementation PiPRootViewController

+ (PiPRootViewController *)shared {
    return (PiPRootViewController *)PiPWindow.shared.rootViewController;
}

- (void)loadView {
    self.view = [[PiPRootView alloc] initWithFrame:UIScreen.mainScreen.bounds];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupContentLayoutGuide];
    [self updateContentInsetsWithTraitCollection:self.traitCollection];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    
    [self updateContentInsetsWithTraitCollection:newCollection];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)setupContentLayoutGuide {
    _contentLayoutGuide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:_contentLayoutGuide];
    
    if (@available(iOS 11.0, *)) {
        _topSafeAreaConstraint = [_contentLayoutGuide.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor];
        _bottomSafeAreaConstraint = [_contentLayoutGuide.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor];
        _leftSafeAreaConstraint = [_contentLayoutGuide.leftAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leftAnchor];
        _rightSafeAreaConstraint = [_contentLayoutGuide.rightAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.rightAnchor];
    } else {
        _topSafeAreaConstraint = [_contentLayoutGuide.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor];
        _bottomSafeAreaConstraint = [_contentLayoutGuide.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor];
        _leftSafeAreaConstraint = [_contentLayoutGuide.leftAnchor constraintEqualToAnchor:self.view.leftAnchor];
        _rightSafeAreaConstraint = [_contentLayoutGuide.rightAnchor constraintEqualToAnchor:self.view.rightAnchor];
    }
    
    _topEdgeConstraint = [_contentLayoutGuide.topAnchor constraintEqualToAnchor:self.view.topAnchor];
    _bottomEdgeConstraint = [_contentLayoutGuide.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];
    _leftEdgeConstraint = [_contentLayoutGuide.leftAnchor constraintEqualToAnchor:self.view.leftAnchor];
    _rightEdgeConstraint = [_contentLayoutGuide.rightAnchor constraintEqualToAnchor:self.view.rightAnchor];
}

- (void)layoutSubviews {
    [self.view layoutIfNeeded];
    
    for (UIView *subview in self.view.subviews) {
        [subview setNeedsLayout];
        [subview layoutIfNeeded];
    }
}

- (void)setAdditionalContentInsets:(UIEdgeInsets)additionalContentInsets {
    _additionalContentInsets = additionalContentInsets;
    
    [self updateContentInsetsWithTraitCollection:self.traitCollection];
    
    [self layoutSubviews];
}

- (void)setContentInsetAdjustmentBehavior:(PiPManagerContentInsetAdjustmentBehavior)contentInsetAdjustmentBehavior {
    _contentInsetAdjustmentBehavior = contentInsetAdjustmentBehavior;
    
    [self updateContentInsetsWithTraitCollection:self.traitCollection];
    
    [self layoutSubviews];
}

- (void)updateContentInsetsWithTraitCollection:(UITraitCollection *)traitCollection {
    CGFloat navigationBarHeight = kNavigationBarDefaultHeight;
    CGFloat tabBarHeight = kTabBarDefaultHeight;
    
    if (traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        navigationBarHeight = kNavigationBarCompactHeight;
        
        if (@available(iOS 11.0, *)) {
            tabBarHeight = kTabBarCompactHeight;
        }
    }
    
    if (_contentInsetAdjustmentBehavior != PiPManagerContentInsetAdjustmentNavigationBar && _contentInsetAdjustmentBehavior != PiPManagerContentInsetAdjustmentNavigationAndTabBars) {
        navigationBarHeight = 0;
    }
    
    if (_contentInsetAdjustmentBehavior != PiPManagerContentInsetAdjustmentTabBar && _contentInsetAdjustmentBehavior != PiPManagerContentInsetAdjustmentNavigationAndTabBars) {
        tabBarHeight = 0;
    }
    
    _leftSafeAreaConstraint.constant = _additionalContentInsets.left;
    _leftEdgeConstraint.constant = _additionalContentInsets.left;
    
    _rightSafeAreaConstraint.constant = -_additionalContentInsets.right;
    _rightEdgeConstraint.constant = -_additionalContentInsets.right;
    
    _topSafeAreaConstraint.constant = navigationBarHeight + _additionalContentInsets.top;
    _topEdgeConstraint.constant = _additionalContentInsets.top;
    
    _bottomSafeAreaConstraint.constant = -tabBarHeight - _additionalContentInsets.bottom;
    _bottomEdgeConstraint.constant = -_additionalContentInsets.bottom;
    
    if (_contentInsetAdjustmentBehavior == PiPManagerContentInsetAdjustmentNone) {
        [NSLayoutConstraint deactivateConstraints:@[_leftSafeAreaConstraint, _rightSafeAreaConstraint, _topSafeAreaConstraint, _bottomSafeAreaConstraint]];
        
        [NSLayoutConstraint activateConstraints:@[_leftEdgeConstraint, _rightEdgeConstraint, _topEdgeConstraint, _bottomEdgeConstraint]];
    } else {
        [NSLayoutConstraint deactivateConstraints:@[_leftEdgeConstraint, _rightEdgeConstraint, _topEdgeConstraint, _bottomEdgeConstraint]];
        
        [NSLayoutConstraint activateConstraints:@[_leftSafeAreaConstraint, _rightSafeAreaConstraint, _topSafeAreaConstraint, _bottomSafeAreaConstraint]];
    }
}

@end

//
//  PiPStashedView.m
//  PiPhone
//
//  Created by KY1VSTAR on 06.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import "PiPStashedView.h"
#import "PiPChevronView.h"

#define kAnimationDuration 0.3f

@interface PiPStashedView ()

@property (nonatomic) PiPChevronView *leftChevronView;
@property (nonatomic) PiPChevronView *rightChevronView;

@end

@implementation PiPStashedView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    self.alpha = 0;
    
    // visualEffectView
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEffectView.frame = self.bounds;
    visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:visualEffectView];
    
    // leftChevronView
    _leftChevronView = [[PiPChevronView alloc] init];
    _leftChevronView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_leftChevronView];
    
    [_leftChevronView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:15].active = YES;
    [_leftChevronView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    
    // rightChevronView
    _rightChevronView = [[PiPChevronView alloc] init];
    _rightChevronView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_rightChevronView];
    
    [_rightChevronView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-15].active = YES;
    [_rightChevronView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    
    self.poition = PiPStashedViewPositionLeft;
}

- (void)setVisible:(BOOL)visible {
    if (_visible == visible) {
        return;
    }
    _visible = visible;
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.alpha = visible ? 1 : 0;
    }];
}

- (void)setPoition:(PiPStashedViewPosition)poition {
    _poition = poition;
    
    switch (poition) {
        case PiPStashedViewPositionLeft:
            _leftChevronView.hidden = NO;
            _rightChevronView.hidden = YES;
            break;
            
        case PiPStashedViewPositionRight:
            _leftChevronView.hidden = YES;
            _rightChevronView.hidden = NO;
            break;
    }
}

- (void)setChevronState:(PiPStashedViewChevronState)chevronState {
    [self setChevronState:chevronState animated:NO];
}

- (void)setChevronState:(PiPStashedViewChevronState)chevronState animated:(BOOL)flag {
    _chevronState = chevronState;
    
    switch (chevronState) {
        case PiPStashedViewChevronStateNormal:
            [_leftChevronView setState:PiPChevronViewStateNormal animated:flag];
            [_rightChevronView setState:PiPChevronViewStateNormal animated:flag];
            break;
            
        case PiPStashedViewChevronStateInteractable:
            [_leftChevronView setState:PiPChevronViewStateLeft animated:flag];
            [_rightChevronView setState:PiPChevronViewStateRight animated:flag];
            break;
    }
}

@end

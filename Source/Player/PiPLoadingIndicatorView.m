//
//  PiPLoadingIndicatorView.m
//  PiPhone
//
//  Created by KY1VSTAR on 05.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import "PiPLoadingIndicatorView.h"

@interface PiPLoadingIndicatorView ()

@property (nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation PiPLoadingIndicatorView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
        self.hidden = YES;
    }
    
    return self;
}

- (void)setup {
    // visualEffectView
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEffectView.frame = self.bounds;
    visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:visualEffectView];
    
    // activityIndicatorView
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicatorView.color = [UIColor colorWithWhite:0 alpha:0.4];
    _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_activityIndicatorView];
    
    [_activityIndicatorView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [_activityIndicatorView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    if (hidden) {
        [_activityIndicatorView stopAnimating];
    } else {
        [_activityIndicatorView startAnimating];
    }
}

@end

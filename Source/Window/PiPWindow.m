//
//  PiPWindow.m
//  PiPhone
//
//  Created by KY1VSTAR on 01.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import "PiPWindow.h"
#import "PiPRootViewController.h"

@interface PiPWindow ()

@property (nonatomic) NSInteger animationCount;

@end

@implementation PiPWindow

+ (PiPWindow *)shared {
    static PiPWindow *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PiPWindow alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super initWithFrame:UIScreen.mainScreen.bounds]) {
        self.windowLevel = UIWindowLevelStatusBar;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.hidden = NO;
        self.rootViewController = [[PiPRootViewController alloc] init];
        
        self.rootViewController.view.frame = self.bounds;
    }
    
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];

    return hitView == self && _animationCount == 0 ? nil : hitView;
}

- (void)startAnimating {
    _animationCount++;
}

- (void)stopAnimating {
    _animationCount = MAX(0, _animationCount - 1);
}

#pragma mark - Private API overrides for status bar appearance

// http://www.openradar.me/15573442
// https://openradar.appspot.com/23677818
- (BOOL)_canAffectStatusBarAppearance {
    return NO;
}

@end

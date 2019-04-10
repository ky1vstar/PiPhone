//
//  PiPSafeAreaObserver.m
//  PiPhone
//
//  Created by KY1VSTAR on 09.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import "PiPSafeAreaObserver.h"

@interface PiPSafeAreaView : UIView

@end

@implementation PiPSafeAreaView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSLog(@"PiPSafeAreaView frame: %@", NSStringFromCGRect(self.frame));
}

@end


@interface PiPSafeAreaObserver ()

@property (nonatomic) UIView *safeAreaView;
@property (nonatomic) UILayoutGuide *safeAreaGuide;
@property (nonatomic, weak) UIViewController *previousViewController;

@end

@implementation PiPSafeAreaObserver

+ (PiPSafeAreaObserver *)shared {
    static PiPSafeAreaObserver *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PiPSafeAreaObserver alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _safeAreaView = [[PiPSafeAreaView alloc] init];
        _safeAreaView.translatesAutoresizingMaskIntoConstraints = NO;
        _safeAreaView.userInteractionEnabled = NO;
        
        _safeAreaGuide = [[UILayoutGuide alloc] init];
    }
    
    return self;
}

- (void)processViewController:(UIViewController *)viewController {
    NSDate *date = [NSDate date];
    
    if (viewController.viewLoaded &&
        viewController.view.window == UIApplication.sharedApplication.keyWindow &&
        !viewController.presentedViewController &&
        (!viewController.parentViewController || [viewController.parentViewController isKindOfClass:UITabBarController.class] || [viewController.parentViewController isKindOfClass:UISplitViewController.class])) {
        [self updateSafeArea];
    }
    
    NSLog(@"processViewController: %f", -date.timeIntervalSinceNow);
}

- (void)updateSafeArea {
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    UIViewController *topPresentedController = keyWindow.rootViewController;
    if (!topPresentedController) {
        return;
    }
    
    UIViewController *vc;
    while ((vc = topPresentedController.presentedViewController)) {
        CGRect rectInWindow = [vc.viewIfLoaded convertRect:vc.viewIfLoaded.bounds toView:keyWindow];
        if (!CGRectEqualToRect(rectInWindow, keyWindow.frame)) {
            break;
        }
        
        topPresentedController = vc;
    }
    
    do {
        vc = topPresentedController;
        topPresentedController = [self topViewControllerForViewController:topPresentedController];
    } while (vc != topPresentedController);
    
    [self setupObserverForViewController:topPresentedController];
}

- (UIViewController *)topViewControllerForViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:UITabBarController.class]) {
        UITabBarController *tabBarController = (UITabBarController *)viewController;
        viewController = tabBarController.selectedViewController ?: tabBarController;
        
    } else if ([viewController isKindOfClass:UISplitViewController.class]) {
        UISplitViewController *splitViewController = (UISplitViewController *)viewController;
        viewController = [splitViewController.viewControllers lastObject] ?: splitViewController;
        
    } else if ([viewController isKindOfClass:UINavigationController.class]) {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        viewController = navigationController.topViewController ?: navigationController;
    }
    
    return viewController;
}

- (void)setupObserverForViewController:(UIViewController *)viewController {
    if (viewController == _previousViewController) {
        return;
    }
    _previousViewController = viewController;
    
    NSLog(@"topPresentedController: %@", viewController);
    
//    [UIApplication.sharedApplication.keyWindow addSubview:_safeAreaView];
//
//    [viewController.view addLayoutGuide:_safeAreaGuide];
    [viewController.view addSubview:_safeAreaView];
    
    if (@available(iOS 11.0, *)) {
        [_safeAreaView.leftAnchor constraintEqualToAnchor:viewController.view.safeAreaLayoutGuide.leftAnchor].active = YES;
        [_safeAreaView.rightAnchor constraintEqualToAnchor:viewController.view.safeAreaLayoutGuide.rightAnchor].active = YES;
        [_safeAreaView.topAnchor constraintEqualToAnchor:viewController.view.safeAreaLayoutGuide.topAnchor].active = YES;
        [_safeAreaView.bottomAnchor constraintEqualToAnchor:viewController.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
    } else {
        // Fallback on earlier versions
    }
    
//    [_safeAreaView.leftAnchor constraintEqualToAnchor:_safeAreaGuide.leftAnchor].active = YES;
//    [_safeAreaView.rightAnchor constraintEqualToAnchor:_safeAreaGuide.rightAnchor].active = YES;
//    [_safeAreaView.topAnchor constraintEqualToAnchor:_safeAreaGuide.topAnchor].active = YES;
//    [_safeAreaView.bottomAnchor constraintEqualToAnchor:_safeAreaGuide.bottomAnchor].active = YES;
}

@end

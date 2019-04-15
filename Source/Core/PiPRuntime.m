//
//  PiPRuntime.m
//  PiPhone
//
//  Created by KY1VSTAR on 11.03.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>
#import <objc/runtime.h>
#import "PiPRuntime.h"
#import "PiPPictureInPictureController.h"
#import "PiPRootViewController.h"
#import "PiPManager+Private.h"

SEL kStartRoutingVideoToPictureInPicturePlayerLayerView = nil;
SEL kStopRoutingVideoToPictureInPicturePlayerLayerView = nil;
SEL kSetPlaceholderContentLayerDuringPIPMode = nil;
SEL kEnterPIPModeRedirectingVideoToLayer = nil;
SEL kLeavePIPMode = nil;

// AVPictureInPictureIndicatorLayer
static Class PiPIndicatorLayer = nil;

@interface DummyLayer : CALayer

- (id)initWithTraitCollection:(id)arg1 opaque:(BOOL)arg2;

@end

// I'm not sure why I have to retaine object explicitly, but without doing so PiPPictureInPictureController gets deallocated to early
static id retainedObject(id object) {
    return (__bridge id)(__bridge_retained void *)object;
}

@implementation PiPRuntime

+ (void)load {
    // - [__AVPlayerLayerView startRoutingVideoToPictureInPicturePlayerLayerView]
    kStartRoutingVideoToPictureInPicturePlayerLayerView = NSSelectorFromString([NSString stringWithFormat:@"startRoutin%@rePlayerLayerView", @"gVideoToPictureInPictu"]);
    
    // - [__AVPlayerLayerView stopRoutingVideoToPictureInPicturePlayerLayerView]
    kStopRoutingVideoToPictureInPicturePlayerLayerView = NSSelectorFromString([NSString stringWithFormat:@"stopRoutin%@rePlayerLayerView", @"gVideoToPictureInPictu"]);
    
    // - [AVPlayerLayer setPlaceholderContentLayerDuringPIPMode:]
    kSetPlaceholderContentLayerDuringPIPMode = NSSelectorFromString([NSString stringWithFormat:@"setPlaceh%@ringPIPMode:", @"olderContentLayerDu"]);
    
    // - [AVPlayerLayer enterPIPModeRedirectingVideoToLayer:]
    kEnterPIPModeRedirectingVideoToLayer = NSSelectorFromString([NSString stringWithFormat:@"enterPIPMo%@oLayer:", @"deRedirectingVideoT"]);
    
    // - [AVPlayerLayer leavePIPMode]
    kLeavePIPMode = NSSelectorFromString([NSString stringWithFormat:@"leav%@de", @"ePIPMo"]);
    
    PiPIndicatorLayer = NSClassFromString([NSString stringWithFormat:@"AVPi%@catorLayer", @"ctureInPictureIndi"]);
    
    if ([AVPictureInPictureController isPictureInPictureSupported] ||
        UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone ||
        ![AVPlayerLayer instancesRespondToSelector:kEnterPIPModeRedirectingVideoToLayer] ||
        ![AVPlayerLayer instancesRespondToSelector:kLeavePIPMode]) {
        return;
    }
    
    [self swizzleIsPictureInPictureSupported];
    [self swizzleInitWithPlayerLayer];
    [self swizzleInitWithPlayerLayerView];
//    [self swizzleAlloc];
    
    PiPManager.settedUp = YES;
}

// probably we should create placeholder layer without using private API
+ (id)newPiPIndicatorLayer {
    if (![PiPIndicatorLayer instancesRespondToSelector:@selector(initWithTraitCollection:opaque:)]) {
        return nil;
    }
    
    return [[PiPIndicatorLayer alloc] initWithTraitCollection:PiPRootViewController.shared.traitCollection opaque:YES];
}

// + [AVPictureInPictureController isPictureInPictureSupported]
static BOOL replacement_isPictureInPictureSupported(id self, SEL _cmd) {
    return YES;
}

+ (void)swizzleIsPictureInPictureSupported {
    Class cls = object_getClass([AVPictureInPictureController class]);

    SEL sel = @selector(isPictureInPictureSupported);
    
    Method originalMethod = class_getInstanceMethod(cls, sel);
    if (!originalMethod)
        return;
    
    method_setImplementation(originalMethod, (IMP)replacement_isPictureInPictureSupported);
}

// - [AVPictureInPictureController initWithPlayerLayer:]
static id replacement_initWithPlayerLayer(id self, SEL _cmd, id playerLayer) {
    return retainedObject([[PiPPictureInPictureController alloc] initWithPlayerLayer:playerLayer]);
}

+ (void)swizzleInitWithPlayerLayer {
    Class cls = [AVPictureInPictureController class];
    
    SEL sel = @selector(initWithPlayerLayer:);
    Method originalMethod = class_getInstanceMethod(cls, sel);
    if (!originalMethod)
        return;
    
    method_setImplementation(originalMethod, (IMP)replacement_initWithPlayerLayer);
}

// - [AVPictureInPictureController initWithPlayerLayerView:]
static id replacement_initWithPlayerLayerView(id self, SEL _cmd, id playerLayerView) {
    return retainedObject([[PiPPictureInPictureController alloc] initWithPlayerLayerView:playerLayerView]);
}

+ (void)swizzleInitWithPlayerLayerView {
    Class cls = [AVPictureInPictureController class];
    if (!cls)
        return;
    
    SEL sel = NSSelectorFromString(@"initWithPlayerLayerView:");
    Method originalMethod = class_getInstanceMethod(cls, sel);
    if (!originalMethod)
        return;
    
    method_setImplementation(originalMethod, (IMP)replacement_initWithPlayerLayerView);
}

// + [AVPictureInPictureController alloc]
static id replacement_alloc(id self, SEL _cmd) {
    return retainedObject([PiPPictureInPictureController alloc]);
}

+ (void)swizzleAlloc {
    Class cls = object_getClass([AVPictureInPictureController class]);
    
    SEL sel = @selector(alloc);
    
    Method originalMethod = class_getInstanceMethod(cls, sel);
    if (!originalMethod)
        return;
    
    if (!class_addMethod(cls, sel, (IMP)replacement_alloc, method_getTypeEncoding(originalMethod)))
        method_setImplementation(originalMethod, (IMP)replacement_alloc);
}

@end

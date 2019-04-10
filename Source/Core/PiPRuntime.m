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
#import "PiPSafeAreaObserver.h"

#import "PiPWindow.h"

SEL kStartRoutingVideoToPictureInPicturePlayerLayerView = nil;
SEL kStopRoutingVideoToPictureInPicturePlayerLayerView = nil;
SEL kEnterPIPModeRedirectingVideoToLayer = nil;
SEL kLeavePIPMode = nil;

// I'm not sure why I have to retaine object explicitly, but without doing so PiPPictureInPictureController gets deallocated to early
static id retainedObject(id object) {
    return (__bridge id)(__bridge_retained void *)object;
}

// + [AVPictureInPictureController isPictureInPictureSupported]
static BOOL replacement_isPictureInPictureSupported(id self, SEL _cmd) {
    return YES;
}

// - [AVPictureInPictureController initWithPlayerLayer:]
static id replacement_initWithPlayerLayer(id self, SEL _cmd, id playerLayer) {
    return retainedObject([[PiPPictureInPictureController alloc] initWithPlayerLayer:playerLayer]);
}

// - [AVPictureInPictureController initWithPlayerLayerView:]
static id replacement_initWithPlayerLayerView(id self, SEL _cmd, id playerLayerView) {
    return retainedObject([[PiPPictureInPictureController alloc] initWithPlayerLayerView:playerLayerView]);
}

// + [AVPictureInPictureController alloc]
static id replacement_alloc(id self, SEL _cmd) {
    return [PiPPictureInPictureController alloc];
}

@interface PiPRuntime : NSObject
@end

@implementation PiPRuntime

+ (void)load {
    // - [__AVPlayerLayerView startRoutingVideoToPictureInPicturePlayerLayerView]
    kStartRoutingVideoToPictureInPicturePlayerLayerView = NSSelectorFromString([NSString stringWithFormat:@"startRoutin%@rePlayerLayerView", @"gVideoToPictureInPictu"]);
    
    // - [__AVPlayerLayerView stopRoutingVideoToPictureInPicturePlayerLayerView]
    kStopRoutingVideoToPictureInPicturePlayerLayerView = NSSelectorFromString([NSString stringWithFormat:@"stopRoutin%@rePlayerLayerView", @"gVideoToPictureInPictu"]);
    
    // - [AVPlayerLayer enterPIPModeRedirectingVideoToLayer:]
    kEnterPIPModeRedirectingVideoToLayer = NSSelectorFromString([NSString stringWithFormat:@"enterPIPMo%@oLayer:", @"deRedirectingVideoT"]);
    
    // - [AVPlayerLayer leavePIPMode]
    kLeavePIPMode = NSSelectorFromString([NSString stringWithFormat:@"leav%@de", @"ePIPMo"]);
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(kek) name:UIApplicationDidFinishLaunchingNotification object:nil];
    
//    if ([AVPictureInPictureController isPictureInPictureSupported] || ![AVPlayerLayer instancesRespondToSelector:kEnterPIPModeRedirectingVideoToLayer] || ![AVPlayerLayer instancesRespondToSelector:kLeavePIPMode])
//        return;
    
    [self swizzleIsPictureInPictureSupported];
    [self swizzleInitWithPlayerLayer];
    [self swizzleInitWithPlayerLayerView];
//    [self swizzleAlloc];
}

+ (void)kek {
    [PiPWindow shared];
}

+ (void)swizzleIsPictureInPictureSupported {
    Class cls = object_getClass([AVPictureInPictureController class]);

    SEL sel = @selector(isPictureInPictureSupported);
    
    Method originalMethod = class_getInstanceMethod(cls, sel);
    if (!originalMethod)
        return;
    
    method_setImplementation(originalMethod, (IMP)replacement_isPictureInPictureSupported);
}

+ (void)swizzleInitWithPlayerLayer {
    Class cls = [AVPictureInPictureController class];
    
    SEL sel = @selector(initWithPlayerLayer:);
    Method originalMethod = class_getInstanceMethod(cls, sel);
    if (!originalMethod)
        return;
    
    method_setImplementation(originalMethod, (IMP)replacement_initWithPlayerLayer);
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

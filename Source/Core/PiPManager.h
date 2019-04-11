//
//  PiPManager.h
//  PiPhone
//
//  Created by KY1VSTAR on 03.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import <AVKit/AVKit.h>

/**
 Constants indicating how automatic content inset are calculated.
 */
typedef NS_ENUM(NSInteger, PiPManagerContentInsetAdjustmentBehavior) {
    
    /**
     Includes safe area insets and additional 44dp (32dp on landscape) inset from top safe area.
     */
    PiPManagerContentInsetAdjustmentNavigationBar,
    
    /**
     Includes safe area insets and additional 49dp (32dp on landscape in iOS 11 and above) inset from bottom safe area.
     */
    PiPManagerContentInsetAdjustmentTabBar,
    
    /**
     Includes both `PiPManagerContentInsetAdjustmentNavigationBar` and `PiPManagerContentInsetAdjustmentTabBar`.
     */
    PiPManagerContentInsetAdjustmentNavigationAndTabBars,
    
    /**
     Includes safe area insets.
     */
    PiPManagerContentInsetAdjustmentSafeArea,
    
    /**
     Overlay video is pinned to screen edges.
     */
    PiPManagerContentInsetAdjustmentNone
};

NS_ASSUME_NONNULL_BEGIN

/**
 The `PiPManager` class manages behavior of `AVPictureInPictureController` on iPhone devices.
 */
@interface PiPManager : NSObject

/**
 Whether or not `PiPhone` managed to enable Picture in Picture support for current device. Can be NO if current device is not iPhone or iPod touch (iPad will use default Picture in Picture implementation) or if `PiPhone` failed to swizzle necessary methods.
 */
@property (class, nonatomic, readonly) BOOL settedUp NS_SWIFT_NAME(isSettedUp);

/**
 Whether or not Picture in Picture is currently possible. Assigning this property will automatically affect all existing `AVPictureInPictureController` instances. Default is YES.
 */
@property (class, nonatomic) BOOL pictureInPicturePossible NS_SWIFT_NAME(isPictureInPicturePossible);

/**
 Extra insets from screen edges to currently active AVPictureInPictureController in addition to automatically calculated one based on `contentInsetAdjustmentBehavior`. Default is `UIEdgeInsetsZero`. Animatable.
 */
@property (class, nonatomic) UIEdgeInsets additionalContentInsets;

/**
 Configure the behavior of automatic calculation of insets from screen edges to currently active `AVPictureInPictureController`. Default is `PiPManagerContentInsetAdjustmentNavigationBar`. Animatable.
 
 @discussion Default `AVPictureInPictureController` behavior is to find the topmost `UINavigationController`'s bar, `UITabBarController`'s bar, `safeAreaInsets`, etc and determine where to place overlay video based on this metrics. Since imitation of this behavior turned out to be complicated and tricky process, it've been decided to control overlay video position based on predefined configurations. For example, choosing `PiPManagerContentInsetAdjustmentNavigationBar` will automatically add 44dp inset from top safe area in portrait orientation regardless of whether there is currently visible `UINavigationBar` or no.
 */
@property (class, nonatomic) PiPManagerContentInsetAdjustmentBehavior contentInsetAdjustmentBehavior;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

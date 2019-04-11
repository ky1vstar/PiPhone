//
//  PiPRuntime.h
//  PiPhone
//
//  Created by KY1VSTAR on 03.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

extern SEL kStartRoutingVideoToPictureInPicturePlayerLayerView;
extern SEL kStopRoutingVideoToPictureInPicturePlayerLayerView;
extern SEL kSetPlaceholderContentLayerDuringPIPMode;
extern SEL kEnterPIPModeRedirectingVideoToLayer;
extern SEL kLeavePIPMode;

@interface PiPRuntime : NSObject

+ (id _Nullable)newPiPIndicatorLayer;

@end

NS_ASSUME_NONNULL_END

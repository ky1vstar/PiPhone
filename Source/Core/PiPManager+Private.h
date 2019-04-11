//
//  PiPManager+Private.h
//  PiPhone
//
//  Created by KY1VSTAR on 11.04.2019.
//

#import "PiPManager.h"

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const PiPManagerDidChangePictureInPicturePossibleNotification;

@interface PiPManager (Private)

@property (class, nonatomic, readwrite) BOOL settedUp;

@end

NS_ASSUME_NONNULL_END

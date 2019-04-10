//
//  PiPChevronView.h
//  PiPhone
//
//  Created by KY1VSTAR on 05.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PiPChevronViewState) {
    PiPChevronViewStateLeft = 0,
    PiPChevronViewStateNormal,
    PiPChevronViewStateRight
};

NS_ASSUME_NONNULL_BEGIN

@interface PiPChevronView : UIView

@property (nonatomic) PiPChevronViewState state;

- (void)setState:(PiPChevronViewState)state animated:(BOOL)flag;

@end

NS_ASSUME_NONNULL_END
